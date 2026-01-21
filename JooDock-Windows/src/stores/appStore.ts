import { create } from "zustand";
import { invoke } from "@tauri-apps/api/core";
import { FileItem, FileGroup, Settings, UNGROUPED_ID } from "../types";

interface AppState {
  // Data
  files: FileItem[];
  groups: FileGroup[];
  recentFiles: FileItem[];
  searchResults: FileItem[];
  settings: Settings;

  // UI State
  searchQuery: string;
  isSearching: boolean;
  isAddGroupModalOpen: boolean;

  // Actions
  loadData: () => Promise<void>;
  setSearchQuery: (query: string) => void;
  addFile: (path: string, groupId?: string | null) => Promise<void>;
  removeFile: (id: string) => Promise<void>;
  openFile: (path: string) => Promise<void>;
  addGroup: (name: string, icon: string) => Promise<void>;
  removeGroup: (id: string) => Promise<void>;
  renameGroup: (id: string, newName: string) => Promise<void>;
  toggleGroup: (id: string) => Promise<void>;
  setAddGroupModalOpen: (open: boolean) => void;
  performSearch: (query: string) => Promise<void>;

  // Computed
  getFilesInGroup: (groupId: string | null) => FileItem[];
  getGroupsWithUngrouped: () => FileGroup[];
}

export const useAppStore = create<AppState>((set, get) => ({
  // Initial State
  files: [],
  groups: [],
  recentFiles: [],
  searchResults: [],
  settings: {
    hoverZoneWidth: 300,
    hoverZoneHeight: 50,
    hoverDelay: 0.3,
  },
  searchQuery: "",
  isSearching: false,
  isAddGroupModalOpen: false,

  // Load initial data
  loadData: async () => {
    try {
      const [files, groups, recentFiles, settings] = await Promise.all([
        invoke<FileItem[]>("get_files"),
        invoke<FileGroup[]>("get_groups"),
        invoke<FileItem[]>("get_recent_files"),
        invoke<Settings>("get_settings"),
      ]);
      set({ files, groups, recentFiles, settings });
    } catch (error) {
      console.error("Failed to load data:", error);
    }
  },

  // Search
  setSearchQuery: (query: string) => {
    set({ searchQuery: query });
    if (query.trim()) {
      get().performSearch(query);
    } else {
      set({ searchResults: [], isSearching: false });
    }
  },

  performSearch: async (query: string) => {
    set({ isSearching: true });
    try {
      const results = await invoke<FileItem[]>("search_files", { query });
      set({ searchResults: results, isSearching: false });
    } catch (error) {
      console.error("Search failed:", error);
      set({ searchResults: [], isSearching: false });
    }
  },

  // File Actions
  addFile: async (path: string, groupId?: string | null) => {
    try {
      const file = await invoke<FileItem>("add_file", { path, groupId });
      set((state) => ({ files: [...state.files, file] }));
    } catch (error) {
      console.error("Failed to add file:", error);
    }
  },

  removeFile: async (id: string) => {
    try {
      await invoke("remove_file", { id });
      set((state) => ({ files: state.files.filter((f) => f.id !== id) }));
    } catch (error) {
      console.error("Failed to remove file:", error);
    }
  },

  openFile: async (path: string) => {
    try {
      await invoke("open_file", { path });
    } catch (error) {
      console.error("Failed to open file:", error);
    }
  },

  // Group Actions
  addGroup: async (name: string, icon: string) => {
    try {
      const group = await invoke<FileGroup>("add_group", { name, icon });
      set((state) => ({ groups: [...state.groups, group] }));
    } catch (error) {
      console.error("Failed to add group:", error);
    }
  },

  removeGroup: async (id: string) => {
    try {
      await invoke("remove_group", { id });
      set((state) => ({
        groups: state.groups.filter((g) => g.id !== id),
        files: state.files.map((f) =>
          f.groupId === id ? { ...f, groupId: null } : f
        ),
      }));
    } catch (error) {
      console.error("Failed to remove group:", error);
    }
  },

  renameGroup: async (id: string, newName: string) => {
    try {
      await invoke("rename_group", { id, newName });
      set((state) => ({
        groups: state.groups.map((g) =>
          g.id === id ? { ...g, name: newName } : g
        ),
      }));
    } catch (error) {
      console.error("Failed to rename group:", error);
    }
  },

  toggleGroup: async (id: string) => {
    try {
      await invoke("toggle_group", { id });
      set((state) => ({
        groups: state.groups.map((g) =>
          g.id === id ? { ...g, isExpanded: !g.isExpanded } : g
        ),
      }));
    } catch (error) {
      console.error("Failed to toggle group:", error);
    }
  },

  setAddGroupModalOpen: (open: boolean) => {
    set({ isAddGroupModalOpen: open });
  },

  // Computed getters
  getFilesInGroup: (groupId: string | null) => {
    const { files, searchQuery } = get();
    let filtered = files;

    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      filtered = files.filter(
        (f) =>
          f.name.toLowerCase().includes(q) || f.path.toLowerCase().includes(q)
      );
    }

    if (groupId === null || groupId === UNGROUPED_ID) {
      return filtered.filter((f) => !f.groupId);
    }
    return filtered.filter((f) => f.groupId === groupId);
  },

  getGroupsWithUngrouped: () => {
    const { groups, files } = get();
    const sorted = [...groups].sort((a, b) => a.sortOrder - b.sortOrder);
    const ungroupedFiles = files.filter((f) => !f.groupId);

    if (ungroupedFiles.length > 0) {
      sorted.push({
        id: UNGROUPED_ID,
        name: "Ungrouped",
        icon: "folder",
        sortOrder: groups.length,
        isExpanded: true,
        createdAt: "",
      });
    }

    return sorted;
  },
}));