import SwiftUI
import QuickLookUI

struct PopupView: View {
    @StateObject private var appState = AppState.shared
    @State private var isAddingGroup = false
    @State private var newGroupName = ""
    @State private var previewURL: URL?
    @State private var isDraggingOver = false

    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header with search
            HeaderView(searchQuery: $appState.searchQuery)

            Divider()

            // File list
            ScrollView {
                LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {
                    // Spotlight 검색 결과 (검색 중일 때)
                    if !appState.searchQuery.isEmpty {
                        Section {
                            if appState.isSearching {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Searching...")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            } else if appState.searchResults.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 24))
                                            .foregroundColor(.secondary)
                                        Text("No results for \"\(appState.searchQuery)\"")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            } else {
                                ForEach(appState.searchResults) { file in
                                    FileRowView(
                                        file: file,
                                        onOpen: {
                                            NSWorkspace.shared.open(file.url)
                                        },
                                        onRemove: { }  // 검색 결과는 제거 불가
                                    )
                                }
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 12))
                                    .foregroundColor(.accentColor)
                                Text("Search Results")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)
                                if !appState.searchResults.isEmpty {
                                    Text("(\(appState.searchResults.count))")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 4)
                            .background(Color.primary.opacity(0.03))
                            .cornerRadius(6)
                        }
                    } else {
                        // Recent Files Section (검색 중이 아닐 때만 표시)
                        if !appState.recentFiles.isEmpty {
                            Section {
                                ForEach(appState.recentFiles) { file in
                                    FileRowView(
                                        file: file,
                                        onOpen: {
                                            appState.openFile(file)
                                        },
                                        onRemove: { }  // 시스템 최근파일은 제거 불가
                                    )
                                }
                            } header: {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 12))
                                        .foregroundColor(.accentColor)
                                    Text("Recent")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("(\(appState.recentFiles.count))")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 4)
                                .background(Color.primary.opacity(0.03))
                                .cornerRadius(6)
                            }
                        }

                        ForEach(appState.groupsWithUngrouped) { group in
                            GroupSection(
                                group: group,
                                files: appState.filesInGroup(group),
                                onFileOpen: { file in
                                    appState.openFile(file)
                                },
                                onFileRemove: { file in
                                    appState.removeFile(file)
                                },
                                onFileDrop: { urls in
                                    appState.addFiles(from: urls, toGroup: group.isUngrouped ? nil : group.id)
                                },
                                onToggleExpand: {
                                    if !group.isUngrouped {
                                        appState.toggleGroupExpanded(group)
                                    }
                                },
                                onRename: { newName in
                                    appState.renameGroup(group, to: newName)
                                },
                                onDelete: {
                                    appState.removeGroup(group)
                                },
                                onAddFileClick: {
                                    addFilesToGroup(group.isUngrouped ? nil : group.id)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }

            Divider()

            // Footer with actions
            FooterView(
                onAddFile: addFilesFromPicker,
                onAddGroup: { isAddingGroup = true }
            )
        }
        .frame(width: 320, height: 450)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .overlay(
            // Drop zone overlay
            Group {
                if isDraggingOver {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.2))
                        .overlay(
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                Text("Drop files here")
                                    .font(.headline)
                            }
                            .foregroundColor(.accentColor)
                        )
                }
            }
        )
        .onDrop(of: [.fileURL], isTargeted: $isDraggingOver) { providers in
            handleDrop(providers: providers)
            return true
        }
        .sheet(isPresented: $isAddingGroup) {
            AddGroupSheet(
                groupName: $newGroupName,
                onSave: {
                    if !newGroupName.isEmpty {
                        appState.addGroup(name: newGroupName)
                        newGroupName = ""
                    }
                    isAddingGroup = false
                },
                onCancel: {
                    newGroupName = ""
                    isAddingGroup = false
                }
            )
        }
        .quickLookPreview($previewURL)
    }

    private func addFilesFromPicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            appState.addFiles(from: panel.urls)
        }
    }

    private func addFilesToGroup(_ groupId: UUID?) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            appState.addFiles(from: panel.urls, toGroup: groupId)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

                DispatchQueue.main.async {
                    appState.addFile(from: url)
                }
            }
        }
    }
}

// MARK: - QuickLook Extension

extension View {
    func quickLookPreview(_ url: Binding<URL?>) -> some View {
        self.background(
            QuickLookPreviewController(url: url)
        )
    }
}

struct QuickLookPreviewController: NSViewRepresentable {
    @Binding var url: URL?

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let url = url {
            context.coordinator.url = url
            DispatchQueue.main.async {
                let panel = QLPreviewPanel.shared()
                panel?.dataSource = context.coordinator
                panel?.delegate = context.coordinator
                panel?.makeKeyAndOrderFront(nil)
                self.url = nil
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
        var url: URL?

        func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
            url != nil ? 1 : 0
        }

        func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
            guard let url = url else { return nil }
            return url as NSURL
        }
    }
}
