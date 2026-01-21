use crate::storage::{self, FileItem};
use std::fs;
use std::path::Path;
use tauri_plugin_shell::ShellExt;

#[tauri::command]
pub fn get_files() -> Vec<FileItem> {
    storage::load_files()
}

#[tauri::command]
pub fn add_file(path: String, group_id: Option<String>) -> Result<FileItem, String> {
    let path_obj = Path::new(&path);
    if !path_obj.exists() {
        return Err("File does not exist".to_string());
    }

    let name = path_obj
        .file_name()
        .map(|n| n.to_string_lossy().to_string())
        .unwrap_or_else(|| path.clone());

    let mut files = storage::load_files();

    // Check for duplicates
    if files.iter().any(|f| f.path == path) {
        return Err("File already exists".to_string());
    }

    let file = FileItem {
        id: uuid::Uuid::new_v4().to_string(),
        name,
        path,
        group_id,
        added_at: chrono::Utc::now().to_rfc3339(),
        last_accessed_at: None,
    };

    files.push(file.clone());
    storage::save_files(&files)?;

    Ok(file)
}

#[tauri::command]
pub fn remove_file(id: String) -> Result<(), String> {
    let mut files = storage::load_files();
    files.retain(|f| f.id != id);
    storage::save_files(&files)
}

#[tauri::command]
pub async fn open_file(app: tauri::AppHandle, path: String) -> Result<(), String> {
    // Update last accessed time
    let mut files = storage::load_files();
    if let Some(file) = files.iter_mut().find(|f| f.path == path) {
        file.last_accessed_at = Some(chrono::Utc::now().to_rfc3339());
        let _ = storage::save_files(&files);
    }

    // Open file with default application
    app.shell()
        .open(&path, None)
        .map_err(|e| e.to_string())
}

#[tauri::command]
pub fn get_recent_files() -> Vec<FileItem> {
    let mut recent_files = Vec::new();

    #[cfg(windows)]
    {
        // Get Windows Recent folder
        if let Some(app_data) = dirs::data_dir() {
            let recent_path = app_data
                .parent()
                .unwrap()
                .join("Roaming")
                .join("Microsoft")
                .join("Windows")
                .join("Recent");

            if recent_path.exists() {
                let seven_days_ago = chrono::Utc::now() - chrono::Duration::days(7);

                if let Ok(entries) = fs::read_dir(&recent_path) {
                    let mut files_with_time: Vec<(std::path::PathBuf, std::time::SystemTime)> = entries
                        .filter_map(|e| e.ok())
                        .filter_map(|entry| {
                            let path = entry.path();
                            if path.extension().map(|e| e == "lnk").unwrap_or(false) {
                                if let Ok(metadata) = entry.metadata() {
                                    if let Ok(modified) = metadata.modified() {
                                        return Some((path, modified));
                                    }
                                }
                            }
                            None
                        })
                        .collect();

                    // Sort by modification time (newest first)
                    files_with_time.sort_by(|a, b| b.1.cmp(&a.1));

                    // Take first 5
                    for (path, _) in files_with_time.into_iter().take(5) {
                        // Try to resolve shortcut target (simplified - just show the .lnk name)
                        let name = path
                            .file_stem()
                            .map(|n| n.to_string_lossy().to_string())
                            .unwrap_or_default();

                        if !name.is_empty() && !name.starts_with('.') {
                            recent_files.push(FileItem {
                                id: uuid::Uuid::new_v4().to_string(),
                                name,
                                path: path.to_string_lossy().to_string(),
                                group_id: None,
                                added_at: chrono::Utc::now().to_rfc3339(),
                                last_accessed_at: None,
                            });
                        }
                    }
                }
            }
        }
    }

    recent_files
}
