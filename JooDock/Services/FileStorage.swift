import Foundation

class FileStorage {
    static let shared = FileStorage()

    private let fileManager = FileManager.default

    private var appSupportDirectory: URL {
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = paths[0].appendingPathComponent("JooDock", isDirectory: true)

        // Create directory if needed
        if !fileManager.fileExists(atPath: appSupport.path) {
            try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }

        return appSupport
    }

    private var filesURL: URL {
        appSupportDirectory.appendingPathComponent("files.json")
    }

    private var groupsURL: URL {
        appSupportDirectory.appendingPathComponent("groups.json")
    }

    // MARK: - Files

    func loadFiles() -> [FileItem] {
        guard fileManager.fileExists(atPath: filesURL.path),
              let data = try? Data(contentsOf: filesURL),
              let files = try? JSONDecoder().decode([FileItem].self, from: data) else {
            return []
        }
        return files
    }

    func saveFiles(_ files: [FileItem]) {
        guard let data = try? JSONEncoder().encode(files) else { return }
        try? data.write(to: filesURL)
    }

    // MARK: - Groups

    func loadGroups() -> [FileGroup] {
        guard fileManager.fileExists(atPath: groupsURL.path),
              let data = try? Data(contentsOf: groupsURL),
              let groups = try? JSONDecoder().decode([FileGroup].self, from: data) else {
            return []
        }
        return groups
    }

    func saveGroups(_ groups: [FileGroup]) {
        guard let data = try? JSONEncoder().encode(groups) else { return }
        try? data.write(to: groupsURL)
    }

    // MARK: - Export/Import

    func exportData() -> Data? {
        let exportData = ExportData(
            files: loadFiles(),
            groups: loadGroups(),
            exportDate: Date()
        )
        return try? JSONEncoder().encode(exportData)
    }

    func importData(_ data: Data) -> Bool {
        guard let importData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return false
        }

        saveFiles(importData.files)
        saveGroups(importData.groups)
        return true
    }

    // MARK: - Clear

    func clearAllData() {
        try? fileManager.removeItem(at: filesURL)
        try? fileManager.removeItem(at: groupsURL)
    }
}

struct ExportData: Codable {
    let files: [FileItem]
    let groups: [FileGroup]
    let exportDate: Date
}