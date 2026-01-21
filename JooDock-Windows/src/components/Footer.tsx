import { Plus, FolderPlus, Settings } from "lucide-react";
import { useAppStore } from "../stores/appStore";
import { open } from "@tauri-apps/plugin-shell";

export function Footer() {
  const addFile = useAppStore((state) => state.addFile);
  const setAddGroupModalOpen = useAppStore(
    (state) => state.setAddGroupModalOpen
  );

  const handleAddFile = async () => {
    // Use native file picker via Tauri
    try {
      const { open: openDialog } = await import("@tauri-apps/plugin-dialog");
      const files = await openDialog({
        multiple: true,
        directory: false,
      });
      if (files) {
        const paths = Array.isArray(files) ? files : [files];
        for (const path of paths) {
          if (typeof path === "string") {
            addFile(path);
          }
        }
      }
    } catch (error) {
      console.error("Failed to open file picker:", error);
    }
  };

  return (
    <div className="flex items-center justify-between px-3 py-2">
      <button
        onClick={handleAddFile}
        className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
      >
        <Plus className="w-3.5 h-3.5" />
        Add File
      </button>

      <button
        onClick={() => setAddGroupModalOpen(true)}
        className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
      >
        <FolderPlus className="w-3.5 h-3.5" />
        New Group
      </button>

      <button className="p-1.5 text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors">
        <Settings className="w-4 h-4" />
      </button>
    </div>
  );
}
