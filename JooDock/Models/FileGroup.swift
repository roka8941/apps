import Foundation

struct FileGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String // SF Symbol name
    var sortOrder: Int
    var isExpanded: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "folder",
        sortOrder: Int = 0,
        isExpanded: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.isExpanded = isExpanded
        self.createdAt = createdAt
    }

    // MARK: - Preset Groups

    static let presets: [(name: String, icon: String)] = [
        ("Work", "briefcase"),
        ("Personal", "person"),
        ("Development", "hammer"),
        ("Documents", "doc.text"),
        ("Downloads", "arrow.down.circle"),
        ("Projects", "folder.badge.gearshape"),
    ]

    // MARK: - Ungrouped Special Group

    static var ungrouped: FileGroup {
        FileGroup(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            name: "Ungrouped",
            icon: "tray",
            sortOrder: Int.max,
            isExpanded: true
        )
    }

    var isUngrouped: Bool {
        id == FileGroup.ungrouped.id
    }
}