import { useState } from "react";
import {
  File,
  FileText,
  Image,
  Film,
  Music,
  Archive,
  Code,
  Folder,
  Table,
  Presentation,
  X,
} from "lucide-react";
import { FileItem, getFileType, FileType } from "../types";

interface FileRowProps {
  file: FileItem;
  onOpen: () => void;
  onRemove?: () => void;
  showRemove?: boolean;
}

const iconMap: Record<FileType, React.ComponentType<{ className?: string }>> = {
  pdf: FileText,
  word: FileText,
  excel: Table,
  powerpoint: Presentation,
  text: FileText,
  image: Image,
  video: Film,
  audio: Music,
  archive: Archive,
  code: Code,
  folder: Folder,
  other: File,
};

export function FileRow({
  file,
  onOpen,
  onRemove,
  showRemove = true,
}: FileRowProps) {
  const [isHovered, setIsHovered] = useState(false);

  const fileType = getFileType(file.name, file.path.endsWith("/") || file.path.endsWith("\\"));
  const Icon = iconMap[fileType];

  // Truncate path in the middle
  const truncatePath = (path: string, maxLen: number = 40) => {
    if (path.length <= maxLen) return path;
    const start = path.slice(0, maxLen / 2 - 2);
    const end = path.slice(-(maxLen / 2 - 2));
    return `${start}...${end}`;
  };

  return (
    <div
      className="group flex items-center gap-3 px-2 py-1.5 rounded-lg hover:bg-gray-100/80 dark:hover:bg-gray-800/80 cursor-pointer transition-colors"
      onClick={onOpen}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Icon */}
      <div className="flex-shrink-0 w-8 h-8 flex items-center justify-center bg-gray-100 dark:bg-gray-800 rounded-lg">
        <Icon className="w-4 h-4 text-gray-500 dark:text-gray-400" />
      </div>

      {/* File info */}
      <div className="flex-1 min-w-0">
        <div className="text-xs font-medium text-gray-800 dark:text-gray-200 truncate">
          {file.name}
        </div>
        <div className="text-[10px] text-gray-400 truncate">
          {truncatePath(file.path)}
        </div>
      </div>

      {/* Remove button */}
      {showRemove && onRemove && isHovered && (
        <button
          onClick={(e) => {
            e.stopPropagation();
            onRemove();
          }}
          className="flex-shrink-0 p-1 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-full transition-colors"
        >
          <X className="w-3 h-3 text-gray-400 hover:text-red-500" />
        </button>
      )}
    </div>
  );
}
