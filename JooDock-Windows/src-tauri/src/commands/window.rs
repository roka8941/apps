use std::sync::atomic::Ordering;
use tauri::Manager;

use crate::POPUP_VISIBLE;

#[tauri::command]
pub fn show_popup(app: tauri::AppHandle) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("main") {
        window.show().map_err(|e| e.to_string())?;
        window.set_focus().map_err(|e| e.to_string())?;
        POPUP_VISIBLE.store(true, Ordering::SeqCst);
    }
    Ok(())
}

#[tauri::command]
pub fn hide_popup(app: tauri::AppHandle) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("main") {
        window.hide().map_err(|e| e.to_string())?;
        POPUP_VISIBLE.store(false, Ordering::SeqCst);
    }
    Ok(())
}

#[tauri::command]
pub fn toggle_popup(app: tauri::AppHandle) -> Result<(), String> {
    let is_visible = POPUP_VISIBLE.load(Ordering::SeqCst);
    if is_visible {
        hide_popup(app)
    } else {
        show_popup(app)
    }
}