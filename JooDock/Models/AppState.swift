import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var files: [FileItem] = []
    @Published var groups: [FileGroup] = []
    @Published var searchQuery: String = ""

    private let storage = FileStorage.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadData()
        setupAutoSave()
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
        NSWorkspace.shared.open(file.url)
    }

    func revealInFinder(_ file: FileItem) {
        NSWorkspace.shared.activateFileViewerSelecting([file.url])
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
}