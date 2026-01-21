import Foundation
import AppKit

struct FileItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var path: String
    var groupId: UUID?
    var addedAt: Date

    init(id: UUID = UUID(), name: String, path: String, groupId: UUID? = nil, addedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.path = path
        self.groupId = groupId
        self.addedAt = addedAt
    }

    // MARK: - Computed Properties

    var url: URL {
        URL(fileURLWithPath: path)
    }

    var fileExtension: String {
        url.pathExtension.lowercased()
    }

    var icon: NSImage {
        NSWorkspace.shared.icon(forFile: path)
    }

    var exists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    var isDirectory: Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        return isDir.boolValue
    }

    // MARK: - File Type Categories

    var fileType: FileType {
        switch fileExtension {
        case "pdf":
            return .pdf
        case "doc", "docx":
            return .word
        case "xls", "xlsx":
            return .excel
        case "ppt", "pptx":
            return .powerpoint
        case "txt", "md", "rtf":
            return .text
        case "jpg", "jpeg", "png", "gif", "webp", "heic":
            return .image
        case "mp4", "mov", "avi", "mkv":
            return .video
        case "mp3", "wav", "aac", "m4a":
            return .audio
        case "zip", "rar", "7z", "tar", "gz":
            return .archive
        case "swift", "py", "js", "ts", "java", "go", "rs":
            return .code
        case "html", "css", "json", "xml", "yml", "yaml":
            return .code
        default:
            return isDirectory ? .folder : .other
        }
    }

    enum FileType: String, Codable {
        case pdf, word, excel, powerpoint, text
        case image, video, audio, archive
        case code, folder, other

        var systemImage: String {
            switch self {
            case .pdf: return "doc.richtext"
            case .word: return "doc.text"
            case .excel: return "tablecells"
            case .powerpoint: return "rectangle.on.rectangle"
            case .text: return "doc.plaintext"
            case .image: return "photo"
            case .video: return "film"
            case .audio: return "music.note"
            case .archive: return "archivebox"
            case .code: return "chevron.left.forwardslash.chevron.right"
            case .folder: return "folder"
            case .other: return "doc"
            }
        }
    }
}