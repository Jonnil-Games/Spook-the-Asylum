/// @description obj_debug_manager Draw GUI Event

/* Draw FPS info if enabled */
scr_debug_draw_fps();

/* Draw overall instance count info if enabled */
scr_debug_draw_instance_count();

/* Draw detailed (all) instance count info if enabled */
scr_debug_draw_all_instance_count();

/* Keep the always-on prototype label out of the level editor's own top bar. */
var level_editor_interface = room == room_level_browser
	|| room == room_level_editor
	|| room == room_level_playtest;
if (!level_editor_interface || debug_screen)
{
	/* Process the rest of the debug screen. Like telemetry, mouse toggles, extra debug text, etc. */
	scr_debug_draw_debug_logic();
}

/* Draw darken screen and cursor mouse */
//scr_draw_darken_screen_when_window_is_unfocused();
//scr_draw_cursor_mouse();
