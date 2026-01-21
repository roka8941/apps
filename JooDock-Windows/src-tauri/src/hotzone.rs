use std::sync::atomic::Ordering;
use std::time::{Duration, Instant};
use tauri::{AppHandle, Manager};

#[cfg(windows)]
use windows::Win32::UI::WindowsAndMessaging::GetCursorPos;
#[cfg(windows)]
use windows::Win32::Foundation::POINT;
#[cfg(windows)]
use windows::Win32::Graphics::Gdi::{GetSystemMetrics, SM_CXSCREEN};

use crate::POPUP_VISIBLE;

const HOVER_ZONE_WIDTH: i32 = 300;
const HOVER_ZONE_HEIGHT: i32 = 50;
const HOVER_DELAY_MS: u64 = 300;
const HIDE_DELAY_MS: u64 = 2000;
const CHECK_INTERVAL_MS: u64 = 100;

pub fn start_monitoring(app: AppHandle) {
    let mut hover_start: Option<Instant> = None;
    let mut hide_start: Option<Instant> = None;

    loop {
        std::thread::sleep(Duration::from_millis(CHECK_INTERVAL_MS));

        #[cfg(windows)]
        {
            let (mouse_x, mouse_y) = get_cursor_position();
            let screen_width = get_screen_width();

            // Calculate hover zone bounds (top center)
            let zone_left = (screen_width - HOVER_ZONE_WIDTH) / 2;
            let zone_right = zone_left + HOVER_ZONE_WIDTH;
            let zone_bottom = HOVER_ZONE_HEIGHT;

            let in_hover_zone = mouse_x >= zone_left
                && mouse_x <= zone_right
                && mouse_y >= 0
                && mouse_y <= zone_bottom;

            let is_visible = POPUP_VISIBLE.load(Ordering::SeqCst);

            // Check if mouse is in popup area (320x450, 5px from top)
            let popup_left = (screen_width - 320) / 2;
            let popup_right = popup_left + 320;
            let popup_top = 5;
            let popup_bottom = 5 + 450;

            let in_popup_area = is_visible
                && mouse_x >= popup_left - 30
                && mouse_x <= popup_right + 30
                && mouse_y >= popup_top
                && mouse_y <= popup_bottom + 30;

            if !is_visible {
                // Not visible - check if should show
                if in_hover_zone {
                    if hover_start.is_none() {
                        hover_start = Some(Instant::now());
                    } else if hover_start.unwrap().elapsed() >= Duration::from_millis(HOVER_DELAY_MS) {
                        // Show popup
                        if let Some(window) = app.get_webview_window("main") {
                            let _ = window.show();
                            let _ = window.set_focus();
                            POPUP_VISIBLE.store(true, Ordering::SeqCst);
                        }
                        hover_start = None;
                    }
                } else {
                    hover_start = None;
                }
                hide_start = None;
            } else {
                // Visible - check if should hide
                hover_start = None;

                if in_hover_zone || in_popup_area {
                    // Mouse is in safe area, reset hide timer
                    hide_start = None;
                } else {
                    // Mouse left the area
                    if hide_start.is_none() {
                        hide_start = Some(Instant::now());
                    } else if hide_start.unwrap().elapsed() >= Duration::from_millis(HIDE_DELAY_MS) {
                        // Hide popup
                        if let Some(window) = app.get_webview_window("main") {
                            let _ = window.hide();
                            POPUP_VISIBLE.store(false, Ordering::SeqCst);
                        }
                        hide_start = None;
                    }
                }
            }
        }

        #[cfg(not(windows))]
        {
            // Non-Windows platforms - just sleep
            std::thread::sleep(Duration::from_millis(1000));
        }
    }
}

#[cfg(windows)]
fn get_cursor_position() -> (i32, i32) {
    unsafe {
        let mut point = POINT { x: 0, y: 0 };
        let _ = GetCursorPos(&mut point);
        (point.x, point.y)
    }
}

#[cfg(windows)]
fn get_screen_width() -> i32 {
    unsafe { GetSystemMetrics(SM_CXSCREEN) }
}

#[cfg(not(windows))]
fn get_cursor_position() -> (i32, i32) {
    (0, 0)
}

#[cfg(not(windows))]
fn get_screen_width() -> i32 {
    1920
}