export interface FileItem {
  id: string;
  name: string;
  path: string;
  groupId: string | null;
  addedAt: string;
  lastAccessedAt: string | null;
}

export interface FileGroup {
  id: string;
  name: string;
  icon: string;
  sortOrder: number;
  isExpanded: boolean;
  createdAt: string;
}

export interface Settings {
  hoverZoneWidth: number;
  hoverZoneHeight: number;
  hoverDelay: number;
}

export const UNGROUPED_ID = "00000000-0000-0000-0000-000000000000";

export const PRESET_ICONS = [
  { name: "briefcase", label: "Work" },
  { name: "user", label: "Personal" },
  { name: "hammer", label: "Development" },
  { name: "file-text", label: "Documents" },
  { name: "download", label: "Downloads" },
  { name: "folder-cog", label: "Projects" },
  { name: "image", label: "Images" },
  { name: "music", label: "Music" },
  { name: "video", label: "Videos" },
  { name: "archive", label: "Archive" },
] as const;

export type FileType =
  | "pdf"
  | "word"
  | "excel"
  | "powerpoint"
  | "text"
  | "image"
  | "video"
  | "audio"
  | "archive"
  | "code"
  | "folder"
  | "other";

export function getFileType(name: string, isDirectory: boolean): FileType {
  if (isDirectory) return "folder";

  const ext = name.split(".").pop()?.toLowerCase() || "";

  const typeMap: Record<string, FileType> = {
    pdf: "pdf",
    doc: "word",
    docx: "word",
    xls: "excel",
    xlsx: "excel",
    ppt: "powerpoint",
    pptx: "powerpoint",
    txt: "text",
    md: "text",
    rtf: "text",
    jpg: "image",
    jpeg: "image",
    png: "image",
    gif: "image",
    webp: "image",
    heic: "image",
    svg: "image",
    mp4: "video",
    mov: "video",
    avi: "video",
    mkv: "video",
    mp3: "audio",
    wav: "audio",
    aac: "audio",
    m4a: "audio",
    zip: "archive",
    rar: "archive",
    "7z": "archive",
    tar: "archive",
    gz: "archive",
    swift: "code",
    py: "code",
    js: "code",
    ts: "code",
    tsx: "code",
    jsx: "code",
    java: "code",
    go: "code",
    rs: "code",
    html: "code",
    css: "code",
    json: "code",
    xml: "code",
    yml: "code",
    yaml: "code",
  };

  return typeMap[ext] || "other";
}

export function getFileIcon(fileType: FileType): string {
  const iconMap: Record<FileType, string> = {
    pdf: "file-text",
    word: "file-text",
    excel: "table",
    powerpoint: "presentation",
    text: "file-text",
    image: "image",
    video: "film",
    audio: "music",
    archive: "archive",
    code: "code",
    folder: "folder",
    other: "file",
  };

  return iconMap[fileType];
}