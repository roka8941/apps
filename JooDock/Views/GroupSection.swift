import SwiftUI

struct GroupSection: View {
    let group: FileGroup
    let files: [FileItem]
    let onFileOpen: (FileItem) -> Void
    let onFileRemove: (FileItem) -> Void
    let onFileDrop: ([URL]) -> Void
    let onToggleExpand: () -> Void
    let onRename: (String) -> Void
    let onDelete: () -> Void
    var onAddFileClick: (() -> Void)? = nil

    @State private var isEditing = false
    @State private var editedName = ""
    @State private var isDraggingOver = false

    var body: some View {
        Section {
            if group.isExpanded || group.isUngrouped {
                if files.isEmpty {
                    EmptyGroupView(isDraggingOver: isDraggingOver, onTap: onAddFileClick)
                } else {
                    ForEach(files) { file in
                        FileRowView(
                            file: file,
                            onOpen: { onFileOpen(file) },
                            onRemove: { onFileRemove(file) }
                        )
                    }
                }
            }
        } header: {
            GroupHeaderView(
                group: group,
                fileCount: files.count,
                isEditing: $isEditing,
                editedName: $editedName,
                onToggleExpand: onToggleExpand,
                onRename: onRename,
                onDelete: onDelete,
                onAddFiles: onAddFileClick
            )
        }
        .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                defer { group.leave() }
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                urls.append(url)
            }
        }

        group.notify(queue: .main) {
            onFileDrop(urls)
        }
    }
}

struct GroupHeaderView: View {
    let group: FileGroup
    let fileCount: Int
    @Binding var isEditing: Bool
    @Binding var editedName: String
    let onToggleExpand: () -> Void
    let onRename: (String) -> Void
    let onDelete: () -> Void
    var onAddFiles: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 6) {
            if !group.isUngrouped {
                Button(action: onToggleExpand) {
                    Image(systemName: group.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                }
                .buttonStyle(.plain)
            }

            Image(systemName: group.icon)
                .font(.system(size: 12))
                .foregroundColor(.accentColor)

            if isEditing {
                TextField("Group name", text: $editedName, onCommit: {
                    onRename(editedName)
                    isEditing = false
                })
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .semibold))
            } else {
                Text(group.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
            }

            Text("(\(fileCount))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            Spacer()

            if !group.isUngrouped {
                Menu {
                    Button {
                        onAddFiles?()
                    } label: {
                        Label("Add Files", systemImage: "plus")
                    }
                    Button("Rename") {
                        editedName = group.name
                        isEditing = true
                    }
                    Divider()
                    Button("Delete Group", role: .destructive) {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 20)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(6)
    }
}

struct EmptyGroupView: View {
    let isDraggingOver: Bool
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "plus.circle.dashed")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary.opacity(0.5))
                Text("Drop or click to add files")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.vertical, 16)
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(isDraggingOver ? .accentColor : .secondary.opacity(0.3))
        )
        .background(isDraggingOver ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}