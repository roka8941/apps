mod commands;
mod hotzone;
mod storage;
mod tray;

use tauri::{Manager, WindowEvent};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

pub static POPUP_VISIBLE: AtomicBool = AtomicBool::new(false);

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_dialog::init())
        .setup(|app| {
            let window = app.get_webview_window("main").unwrap();

            // Position window at top center
            if let Ok(monitor) = window.primary_monitor() {
                if let Some(monitor) = monitor {
                    let screen_size = monitor.size();
                    let window_width = 320;
                    let x = (screen_size.width as i32 - window_width) / 2;
                    let _ = window.set_position(tauri::Position::Physical(
                        tauri::PhysicalPosition { x, y: 5 }
                    ));
                }
            }

            // Setup system tray
            tray::setup_tray(app)?;

            // Start hotzone monitoring
            let app_handle = app.handle().clone();
            std::thread::spawn(move || {
                hotzone::start_monitoring(app_handle);
            });

            Ok(())
        })
        .on_window_event(|window, event| {
            match event {
                WindowEvent::Focused(false) => {
                    // Hide when focus is lost (click outside)
                    let _ = window.hide();
                    POPUP_VISIBLE.store(false, Ordering::SeqCst);
                }
                _ => {}
            }
        })
        .invoke_handler(tauri::generate_handler![
            commands::files::get_files,
            commands::files::add_file,
            commands::files::remove_file,
            commands::files::open_file,
            commands::files::get_recent_files,
            commands::groups::get_groups,
            commands::groups::add_group,
            commands::groups::remove_group,
            commands::groups::rename_group,
            commands::groups::toggle_group,
            commands::search::search_files,
            commands::settings::get_settings,
            commands::settings::save_settings,
            commands::window::show_popup,
            commands::window::hide_popup,
            commands::window::toggle_popup,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}