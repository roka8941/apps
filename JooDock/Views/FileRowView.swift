import SwiftUI

struct FileRowView: View {
    let file: FileItem
    let onOpen: () -> Void
    let onPreview: () -> Void
    let onReveal: () -> Void
    let onRemove: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            // File icon
            FileIconView(file: file)

            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .foregroundColor(file.exists ? .primary : .secondary)

                Text(file.path)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            // Quick actions (visible on hover)
            if isHovered {
                HStack(spacing: 4) {
                    IconButton(icon: "eye", tooltip: "Preview") {
                        onPreview()
                    }

                    IconButton(icon: "folder", tooltip: "Show in Finder") {
                        onReveal()
                    }

                    IconButton(icon: "xmark", tooltip: "Remove", isDestructive: true) {
                        onRemove()
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture(count: 2) {
            onOpen()
        }
        .contextMenu {
            Button("Open") { onOpen() }
            Button("Preview") { onPreview() }
            Button("Show in Finder") { onReveal() }
            Divider()
            Button("Remove from JooDock", role: .destructive) { onRemove() }
        }
        .opacity(file.exists ? 1.0 : 0.5)
    }
}

struct FileIconView: View {
    let file: FileItem
    @State private var thumbnail: NSImage?

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Image(nsImage: file.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        // Only load thumbnails for images
        guard file.fileType == .image else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            if let image = NSImage(contentsOfFile: file.path) {
                let thumbnailSize = NSSize(width: 64, height: 64)
                let thumbnail = image.resized(to: thumbnailSize)

                DispatchQueue.main.async {
                    self.thumbnail = thumbnail
                }
            }
        }
    }
}

struct IconButton: View {
    let icon: String
    let tooltip: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(isDestructive ? .red : .secondary)
                .frame(width: 20, height: 20)
                .background(Color.primary.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }
}

// MARK: - NSImage Extension

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage {
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        self.draw(
            in: NSRect(origin: .zero, size: newSize),
            from: NSRect(origin: .zero, size: self.size),
            operation: .copy,
            fraction: 1.0
        )
        newImage.unlockFocus()
        return newImage
    }
}
