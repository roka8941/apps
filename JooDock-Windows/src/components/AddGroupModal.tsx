import { useState } from "react";
import {
  X,
  Briefcase,
  User,
  Hammer,
  FileText,
  Download,
  FolderCog,
  Image,
  Music,
  Video,
  Archive,
} from "lucide-react";
import { useAppStore } from "../stores/appStore";
import { PRESET_ICONS } from "../types";

const iconComponents: Record<
  string,
  React.ComponentType<{ className?: string }>
> = {
  briefcase: Briefcase,
  user: User,
  hammer: Hammer,
  "file-text": FileText,
  download: Download,
  "folder-cog": FolderCog,
  image: Image,
  music: Music,
  video: Video,
  archive: Archive,
};

export function AddGroupModal() {
  const [name, setName] = useState("");
  const [selectedIcon, setSelectedIcon] = useState("folder");

  const addGroup = useAppStore((state) => state.addGroup);
  const setAddGroupModalOpen = useAppStore(
    (state) => state.setAddGroupModalOpen
  );

  const handleCreate = () => {
    if (name.trim()) {
      addGroup(name.trim(), selectedIcon);
      setAddGroupModalOpen(false);
    }
  };

  const handleClose = () => {
    setAddGroupModalOpen(false);
  };

  return (
    <div className="fixed inset-0 bg-black/30 backdrop-blur-sm flex items-center justify-center z-50">
      <div className="bg-white dark:bg-gray-900 rounded-xl shadow-2xl w-72 overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-4 py-3 border-b border-gray-200 dark:border-gray-700">
          <h3 className="text-sm font-semibold text-gray-800 dark:text-gray-200">
            New Group
          </h3>
          <button
            onClick={handleClose}
            className="p-1 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full transition-colors"
          >
            <X className="w-4 h-4 text-gray-500" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4 space-y-4">
          {/* Name input */}
          <div>
            <label className="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1.5">
              Group Name
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Enter group name"
              className="w-full px-3 py-2 text-sm bg-gray-100 dark:bg-gray-800 rounded-lg outline-none focus:ring-2 focus:ring-blue-500/50"
              autoFocus
              onKeyDown={(e) => e.key === "Enter" && handleCreate()}
            />
          </div>

          {/* Icon picker */}
          <div>
            <label className="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1.5">
              Icon
            </label>
            <div className="grid grid-cols-5 gap-2">
              {PRESET_ICONS.map((preset) => {
                const Icon = iconComponents[preset.name];
                return (
                  <button
                    key={preset.name}
                    onClick={() => setSelectedIcon(preset.name)}
                    className={`p-2 rounded-lg transition-colors ${
                      selectedIcon === preset.name
                        ? "bg-blue-100 dark:bg-blue-900/50 text-blue-600"
                        : "hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-500"
                    }`}
                    title={preset.label}
                  >
                    {Icon && <Icon className="w-4 h-4 mx-auto" />}
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="flex justify-end gap-2 px-4 py-3 border-t border-gray-200 dark:border-gray-700">
          <button
            onClick={handleClose}
            className="px-4 py-1.5 text-xs font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleCreate}
            disabled={!name.trim()}
            className="px-4 py-1.5 text-xs font-medium text-white bg-blue-500 hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed rounded-lg transition-colors"
          >
            Create
          </button>
        </div>
      </div>
    </div>
  );
}
