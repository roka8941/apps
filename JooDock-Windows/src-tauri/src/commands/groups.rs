use crate::storage::{self, FileGroup, FileItem};

#[tauri::command]
pub fn get_groups() -> Vec<FileGroup> {
    storage::load_groups()
}

#[tauri::command]
pub fn add_group(name: String, icon: String) -> Result<FileGroup, String> {
    let mut groups = storage::load_groups();

    let group = FileGroup {
        id: uuid::Uuid::new_v4().to_string(),
        name,
        icon,
        sort_order: groups.len() as i32,
        is_expanded: true,
        created_at: chrono::Utc::now().to_rfc3339(),
    };

    groups.push(group.clone());
    storage::save_groups(&groups)?;

    Ok(group)
}

#[tauri::command]
pub fn remove_group(id: String) -> Result<(), String> {
    // Move files to ungrouped
    let mut files = storage::load_files();
    for file in files.iter_mut() {
        if file.group_id.as_ref() == Some(&id) {
            file.group_id = None;
        }
    }
    storage::save_files(&files)?;

    // Remove group
    let mut groups = storage::load_groups();
    groups.retain(|g| g.id != id);
    storage::save_groups(&groups)
}

#[tauri::command]
pub fn rename_group(id: String, new_name: String) -> Result<(), String> {
    let mut groups = storage::load_groups();
    if let Some(group) = groups.iter_mut().find(|g| g.id == id) {
        group.name = new_name;
    }
    storage::save_groups(&groups)
}

#[tauri::command]
pub fn toggle_group(id: String) -> Result<(), String> {
    let mut groups = storage::load_groups();
    if let Some(group) = groups.iter_mut().find(|g| g.id == id) {
        group.is_expanded = !group.is_expanded;
    }
    storage::save_groups(&groups)
}