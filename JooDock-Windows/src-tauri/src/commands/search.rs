use crate::storage::FileItem;
use std::path::Path;
use walkdir::WalkDir;

#[tauri::command]
pub fn search_files(query: String) -> Vec<FileItem> {
    if query.is_empty() {
        return Vec::new();
    }

    let query_lower = query.to_lowercase();
    let mut results = Vec::new();

    // Search common user directories
    let search_paths = get_search_paths();

    for search_path in search_paths {
        if !Path::new(&search_path).exists() {
            continue;
        }

        for entry in WalkDir::new(&search_path)
            .max_depth(4) // Limit depth for performance
            .follow_links(false)
            .into_iter()
            .filter_map(|e| e.ok())
        {
            let path = entry.path();
            let name = path
                .file_name()
                .map(|n| n.to_string_lossy().to_string())
                .unwrap_or_default();

            // Skip hidden files and system directories
            if name.starts_with('.') || name.starts_with('$') {
                continue;
            }

            // Skip common system/cache directories
            let path_str = path.to_string_lossy().to_lowercase();
            if path_str.contains("\\appdata\\local\\")
                || path_str.contains("\\appdata\\locallow\\")
                || path_str.contains("\\windows\\")
                || path_str.contains("\\program files")
                || path_str.contains("\\.git\\")
                || path_str.contains("\\node_modules\\")
                || path_str.contains("\\__pycache__\\")
            {
                continue;
            }

            // Match by filename
            if name.to_lowercase().contains(&query_lower) {
                results.push(FileItem {
                    id: uuid::Uuid::new_v4().to_string(),
                    name,
                    path: path.to_string_lossy().to_string(),
                    group_id: None,
                    added_at: chrono::Utc::now().to_rfc3339(),
                    last_accessed_at: None,
                });

                if results.len() >= 20 {
                    return results;
                }
            }
        }
    }

    results
}

fn get_search_paths() -> Vec<String> {
    let mut paths = Vec::new();

    if let Some(home) = dirs::home_dir() {
        paths.push(home.join("Documents").to_string_lossy().to_string());
        paths.push(home.join("Downloads").to_string_lossy().to_string());
        paths.push(home.join("Desktop").to_string_lossy().to_string());
        paths.push(home.join("Pictures").to_string_lossy().to_string());
        paths.push(home.join("Videos").to_string_lossy().to_string());
        paths.push(home.join("Music").to_string_lossy().to_string());
    }

    paths
}