import Foundation
import Combine
import AppKit

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var files: [FileItem] = []
    @Published var groups: [FileGroup] = []
    @Published var searchQuery: String = ""
    @Published var recentFiles: [FileItem] = []
    @Published var searchResults: [FileItem] = []
    @Published var isSearching: Bool = false

    private let storage = FileStorage.shared
    private var cancellables = Set<AnyCancellable>()
    private var metadataQuery: NSMetadataQuery?
    private var searchMetadataQuery: NSMetadataQuery?

    private init() {
        loadData()
        setupAutoSave()
        loadRecentFiles()
        setupSearchObserver()
    }

    // MARK: - Computed Properties

    var filteredFiles: [FileItem] {
        if searchQuery.isEmpty {
            return files
        }
        return files.filter { file in
            file.name.localizedCaseInsensitiveContains(searchQuery) ||
            file.path.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var sortedGroups: [FileGroup] {
        groups.sorted { $0.sortOrder < $1.sortOrder }
    }

    func filesInGroup(_ group: FileGroup) -> [FileItem] {
        if group.isUngrouped {
            return filteredFiles.filter { $0.groupId == nil }
        }
        return filteredFiles.filter { $0.groupId == group.id }
    }

    var groupsWithUngrouped: [FileGroup] {
        var result = sortedGroups
        let ungroupedFiles = files.filter { $0.groupId == nil }
        if !ungroupedFiles.isEmpty {
            result.append(.ungrouped)
        }
        return result
    }

    // MARK: - File Operations

    func addFile(from url: URL, toGroup groupId: UUID? = nil) {
        let file = FileItem(
            name: url.lastPathComponent,
            path: url.path,
            groupId: groupId
        )

        // Avoid duplicates
        guard !files.contains(where: { $0.path == file.path }) else { return }

        files.append(file)
    }

    func addFiles(from urls: [URL], toGroup groupId: UUID? = nil) {
        for url in urls {
            addFile(from: url, toGroup: groupId)
        }
    }

    func removeFile(_ file: FileItem) {
        files.removeAll { $0.id == file.id }
    }

    func moveFile(_ file: FileItem, toGroup groupId: UUID?) {
        if let index = files.firstIndex(where: { $0.id == file.id }) {
            files[index].groupId = groupId
        }
    }

    func openFile(_ file: FileItem) {
        // Update last accessed time
        if let index = files.firstIndex(where: { $0.id == file.id }) {
            files[index].lastAccessedAt = Date()
        }
        NSWorkspace.shared.open(file.url)
    }

    func revealInFinder(_ file: FileItem) {
        if file.isDirectory {
            // 폴더인 경우: 폴더를 열어서 내부 파일들 보기
            NSWorkspace.shared.open(file.url)
        } else {
            // 파일인 경우: 부모 폴더에서 파일 선택
            NSWorkspace.shared.activateFileViewerSelecting([file.url])
        }
    }

    // MARK: - Group Operations

    func addGroup(name: String, icon: String = "folder") {
        let group = FileGroup(
            name: name,
            icon: icon,
            sortOrder: groups.count
        )
        groups.append(group)
    }

    func removeGroup(_ group: FileGroup) {
        // Move files to ungrouped
        for i in files.indices {
            if files[i].groupId == group.id {
                files[i].groupId = nil
            }
        }
        groups.removeAll { $0.id == group.id }
    }

    func renameGroup(_ group: FileGroup, to newName: String) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].name = newName
        }
    }

    func toggleGroupExpanded(_ group: FileGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].isExpanded.toggle()
        }
    }

    // MARK: - Persistence

    private func loadData() {
        files = storage.loadFiles()
        groups = storage.loadGroups()

        // Create default groups if empty
        if groups.isEmpty {
            addGroup(name: "Work", icon: "briefcase")
            addGroup(name: "Personal", icon: "person")
        }
    }

    private func setupAutoSave() {
        $files
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] files in
                self?.storage.saveFiles(files)
            }
            .store(in: &cancellables)

        $groups
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] groups in
                self?.storage.saveGroups(groups)
            }
            .store(in: &cancellables)
    }

    // MARK: - Recent Files (Spotlight Query)

    private func loadRecentFiles() {
        metadataQuery = NSMetadataQuery()
        guard let query = metadataQuery else { return }

        // 최근 7일 이내 사용된 파일 검색
        let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        query.predicate = NSPredicate(format: "kMDItemLastUsedDate > %@", sevenDaysAgo as CVarArg)
        query.sortDescriptors = [NSSortDescriptor(key: "kMDItemLastUsedDate", ascending: false)]
        query.searchScopes = [NSMetadataQueryLocalComputerScope]

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidFinish),
            name: .NSMetadataQueryDidFinishGathering,
            object: query
        )

        query.start()
    }

    @objc private func queryDidFinish(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else { return }
        query.stop()

        var items: [FileItem] = []
        let resultCount = min(query.resultCount, 10)  // 최대 10개

        for i in 0..<resultCount {
            if let item = query.result(at: i) as? NSMetadataItem,
               let path = item.value(forAttribute: kMDItemPath as String) as? String {
                let url = URL(fileURLWithPath: path)

                // 숨김 파일이나 시스템 파일 제외
                if !url.lastPathComponent.hasPrefix(".") &&
                   !path.contains("/Library/") &&
                   !path.contains("/.") {
                    items.append(FileItem(
                        name: url.lastPathComponent,
                        path: path
                    ))
                }

                if items.count >= 5 { break }
            }
        }

        DispatchQueue.main.async {
            self.recentFiles = items
        }
    }

    // MARK: - Spotlight Search

    private func setupSearchObserver() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSpotlightSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSpotlightSearch(query: String) {
        // 기존 검색 중지
        searchMetadataQuery?.stop()

        // 빈 쿼리면 검색 결과 초기화
        guard !query.isEmpty else {
            isSearching = false
            searchResults = []
            return
        }

        isSearching = true

        searchMetadataQuery = NSMetadataQuery()
        guard let metaQuery = searchMetadataQuery else { return }

        // 파일명에 검색어가 포함된 파일/폴더 검색
        metaQuery.predicate = NSPredicate(format: "kMDItemFSName CONTAINS[cd] %@", query)
        metaQuery.sortDescriptors = [NSSortDescriptor(key: "kMDItemLastUsedDate", ascending: false)]
        metaQuery.searchScopes = [NSMetadataQueryLocalComputerScope]

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(searchQueryDidFinish),
            name: .NSMetadataQueryDidFinishGathering,
            object: metaQuery
        )

        metaQuery.start()
    }

    @objc private func searchQueryDidFinish(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else { return }
        query.stop()

        var items: [FileItem] = []
        let resultCount = min(query.resultCount, 50)  // 최대 50개

        for i in 0..<resultCount {
            if let item = query.result(at: i) as? NSMetadataItem,
               let path = item.value(forAttribute: kMDItemPath as String) as? String {
                let url = URL(fileURLWithPath: path)

                // 숨김 파일이나 시스템 파일 제외
                if !url.lastPathComponent.hasPrefix(".") &&
                   !path.contains("/Library/") &&
                   !path.contains("/.") &&
                   !path.contains("/System/") {
                    items.append(FileItem(
                        name: url.lastPathComponent,
                        path: path
                    ))
                }

                if items.count >= 20 { break }  // UI에 표시할 최대 20개
            }
        }

        DispatchQueue.main.async {
            self.searchResults = items
            self.isSearching = false
        }
    }
}