use crate::storage::{self, Settings};

#[tauri::command]
pub fn get_settings() -> Settings {
    storage::load_settings()
}

#[tauri::command]
pub fn save_settings(settings: Settings) -> Result<(), String> {
    storage::save_settings(&settings)
}