import { useState, useCallback } from "react";
import {
  ChevronRight,
  ChevronDown,
  MoreHorizontal,
  Plus,
  Pencil,
  Trash2,
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
  Folder,
} from "lucide-react";
import { useAppStore } from "../stores/appStore";
import { FileGroup, UNGROUPED_ID } from "../types";
import { FileRow } from "./FileRow";

interface GroupSectionProps {
  group: FileGroup;
  isUngrouped?: boolean;
}

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
  folder: Folder,
};

export function GroupSection({ group, isUngrouped = false }: GroupSectionProps) {
  const [showMenu, setShowMenu] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editName, setEditName] = useState(group.name);
  const [isDragOver, setIsDragOver] = useState(false);

  const getFilesInGroup = useAppStore((state) => state.getFilesInGroup);
  const toggleGroup = useAppStore((state) => state.toggleGroup);
  const renameGroup = useAppStore((state) => state.renameGroup);
  const removeGroup = useAppStore((state) => state.removeGroup);
  const removeFile = useAppStore((state) => state.removeFile);
  const openFile = useAppStore((state) => state.openFile);
  const addFile = useAppStore((state) => state.addFile);

  const files = getFilesInGroup(isUngrouped ? null : group.id);
  const Icon = iconComponents[group.icon] || Folder;

  const handleToggle = () => {
    if (!isUngrouped) {
      toggleGroup(group.id);
    }
  };

  const handleRename = () => {
    if (editName.trim() && editName !== group.name) {
      renameGroup(group.id, editName.trim());
    }
    setIsEditing(false);
    setShowMenu(false);
  };

  const handleDelete = () => {
    removeGroup(group.id);
    setShowMenu(false);
  };

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      setIsDragOver(false);
      const droppedFiles = Array.from(e.dataTransfer.files);
      droppedFiles.forEach((file) => {
        // @ts-ignore
        const path = file.path || file.name;
        if (path) {
          addFile(path, isUngrouped ? null : group.id);
        }
      });
    },
    [addFile, group.id, isUngrouped]
  );

  return (
    <div
      className={`space-y-1 ${
        isDragOver ? "bg-blue-50 dark:bg-blue-900/20 rounded-lg" : ""
      }`}
      onDragOver={(e) => {
        e.preventDefault();
        setIsDragOver(true);
      }}
      onDragLeave={() => setIsDragOver(false)}
      onDrop={handleDrop}
    >
      {/* Header */}
      <div className="flex items-center gap-1.5 px-1 py-1.5 bg-gray-100/50 dark:bg-gray-800/50 rounded-lg">
        {!isUngrouped && (
          <button
            onClick={handleToggle}
            className="p-0.5 hover:bg-gray-200 dark:hover:bg-gray-700 rounded transition-colors"
          >
            {group.isExpanded ? (
              <ChevronDown className="w-3 h-3 text-gray-500" />
            ) : (
              <ChevronRight className="w-3 h-3 text-gray-500" />
            )}
          </button>
        )}

        <Icon className="w-3 h-3 text-blue-500" />

        {isEditing ? (
          <input
            type="text"
            value={editName}
            onChange={(e) => setEditName(e.target.value)}
            onBlur={handleRename}
            onKeyDown={(e) => e.key === "Enter" && handleRename()}
            className="flex-1 px-1 py-0.5 text-xs font-semibold bg-white dark:bg-gray-800 rounded outline-none focus:ring-1 focus:ring-blue-500"
            autoFocus
          />
        ) : (
          <span className="text-xs font-semibold text-gray-700 dark:text-gray-300">
            {group.name}
          </span>
        )}

        <span className="text-xs text-gray-500">({files.length})</span>

        <div className="flex-1" />

        {!isUngrouped && (
          <div className="relative">
            <button
              onClick={() => setShowMenu(!showMenu)}
              className="p-1 hover:bg-gray-200 dark:hover:bg-gray-700 rounded transition-colors"
            >
              <MoreHorizontal className="w-3 h-3 text-gray-500" />
            </button>

            {showMenu && (
              <>
                <div
                  className="fixed inset-0 z-10"
                  onClick={() => setShowMenu(false)}
                />
                <div className="absolute right-0 top-full mt-1 w-32 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 py-1 z-20">
                  <button
                    onClick={() => {
                      setEditName(group.name);
                      setIsEditing(true);
                      setShowMenu(false);
                    }}
                    className="w-full flex items-center gap-2 px-3 py-1.5 text-xs hover:bg-gray-100 dark:hover:bg-gray-700"
                  >
                    <Pencil className="w-3 h-3" />
                    Rename
                  </button>
                  <button
                    onClick={handleDelete}
                    className="w-full flex items-center gap-2 px-3 py-1.5 text-xs text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20"
                  >
                    <Trash2 className="w-3 h-3" />
                    Delete
                  </button>
                </div>
              </>
            )}
          </div>
        )}
      </div>

      {/* Files */}
      {(group.isExpanded || isUngrouped) && (
        <div className="space-y-0.5">
          {files.length === 0 ? (
            <div
              className={`flex flex-col items-center justify-center py-4 border border-dashed rounded-lg transition-colors ${
                isDragOver
                  ? "border-blue-400 bg-blue-50/50 dark:bg-blue-900/10"
                  : "border-gray-300 dark:border-gray-600"
              }`}
            >
              <Plus className="w-5 h-5 text-gray-400 mb-1" />
              <span className="text-[10px] text-gray-400">
                Drop files here
              </span>
            </div>
          ) : (
            files.map((file) => (
              <FileRow
                key={file.id}
                file={file}
                onOpen={() => openFile(file.path)}
                onRemove={() => removeFile(file.id)}
              />
            ))
          )}
        </div>
      )}
    </div>
  );
}
