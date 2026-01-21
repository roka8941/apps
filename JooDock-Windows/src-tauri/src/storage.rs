use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FileItem {
    pub id: String,
    pub name: String,
    pub path: String,
    #[serde(rename = "groupId")]
    pub group_id: Option<String>,
    #[serde(rename = "addedAt")]
    pub added_at: String,
    #[serde(rename = "lastAccessedAt")]
    pub last_accessed_at: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FileGroup {
    pub id: String,
    pub name: String,
    pub icon: String,
    #[serde(rename = "sortOrder")]
    pub sort_order: i32,
    #[serde(rename = "isExpanded")]
    pub is_expanded: bool,
    #[serde(rename = "createdAt")]
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Settings {
    #[serde(rename = "hoverZoneWidth")]
    pub hover_zone_width: f64,
    #[serde(rename = "hoverZoneHeight")]
    pub hover_zone_height: f64,
    #[serde(rename = "hoverDelay")]
    pub hover_delay: f64,
}

impl Default for Settings {
    fn default() -> Self {
        Settings {
            hover_zone_width: 300.0,
            hover_zone_height: 50.0,
            hover_delay: 0.3,
        }
    }
}

pub fn get_data_dir() -> PathBuf {
    let base = dirs::data_local_dir().unwrap_or_else(|| PathBuf::from("."));
    let dir = base.join("JooDock");
    if !dir.exists() {
        let _ = fs::create_dir_all(&dir);
    }
    dir
}

pub fn load_files() -> Vec<FileItem> {
    let path = get_data_dir().join("files.json");
    if path.exists() {
        if let Ok(content) = fs::read_to_string(&path) {
            if let Ok(files) = serde_json::from_str(&content) {
                return files;
            }
        }
    }
    Vec::new()
}

pub fn save_files(files: &[FileItem]) -> Result<(), String> {
    let path = get_data_dir().join("files.json");
    let content = serde_json::to_string_pretty(files).map_err(|e| e.to_string())?;
    fs::write(path, content).map_err(|e| e.to_string())
}

pub fn load_groups() -> Vec<FileGroup> {
    let path = get_data_dir().join("groups.json");
    if path.exists() {
        if let Ok(content) = fs::read_to_string(&path) {
            if let Ok(groups) = serde_json::from_str(&content) {
                return groups;
            }
        }
    }
    // Return default groups
    vec![
        FileGroup {
            id: uuid::Uuid::new_v4().to_string(),
            name: "Work".to_string(),
            icon: "briefcase".to_string(),
            sort_order: 0,
            is_expanded: true,
            created_at: chrono::Utc::now().to_rfc3339(),
        },
        FileGroup {
            id: uuid::Uuid::new_v4().to_string(),
            name: "Personal".to_string(),
            icon: "user".to_string(),
            sort_order: 1,
            is_expanded: true,
            created_at: chrono::Utc::now().to_rfc3339(),
        },
    ]
}

pub fn save_groups(groups: &[FileGroup]) -> Result<(), String> {
    let path = get_data_dir().join("groups.json");
    let content = serde_json::to_string_pretty(groups).map_err(|e| e.to_string())?;
    fs::write(path, content).map_err(|e| e.to_string())
}

pub fn load_settings() -> Settings {
    let path = get_data_dir().join("settings.json");
    if path.exists() {
        if let Ok(content) = fs::read_to_string(&path) {
            if let Ok(settings) = serde_json::from_str(&content) {
                return settings;
            }
        }
    }
    Settings::default()
}

pub fn save_settings(settings: &Settings) -> Result<(), String> {
    let path = get_data_dir().join("settings.json");
    let content = serde_json::to_string_pretty(settings).map_err(|e| e.to_string())?;
    fs::write(path, content).map_err(|e| e.to_string())
}