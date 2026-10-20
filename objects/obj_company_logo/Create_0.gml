scr_item_defs();

instance_create_depth(x, y, 0, obj_debug_manager);

global.default_text_size = 1;
global.draw_text_outline = true;

global.max_players = 1;
global.api_key = "";
global.base_url = "";
global.controls_used_for_navigation = "keyboard";
global.game_name = "Juni's Asylum";
global.dev_stage = "Prototype";
global.enable_option_for_pc = true;
global.level_name = "";
global.select_level_index = 1;
global.menu_navigation_speed = 50;
global.player_can_play = 1;
global.player_slot = 1;
global.playergame = 1;
global.checkpoint_x = 0;
global.checkpoint_y = 0;
global.actually_play_edited_level = true;
global.center_action_slots_x = display_get_gui_width() + 100;
global.center_action_slots_y = -100;

scr_le_init();

for(var i = 1; i <= global.max_players; i += 1)
{
	global.player_can_play[i] = true;
	global.character_for_player[i] = 1;
	global.voicepack_for_player[i] = 1;
	global.skin_for_player[i] = 1;
	global.level_player_start_x[i] = 0;
	global.level_player_start_y[i] = 0;
}

global.debug_collapsed_sections = ds_map_create(); /* A data structure that tracks which debug sections are collapsed. Each key represents a section name, and its value (true/false) indicates whether the section is currently collapsed. Helps organize and declutter the debug screen for better readability. */

ini_open(game_save_id + "save_file/config.ini");
global.debug_detailed_mode = ini_read_real("config", "debug_detailed_mode", false);
global.show_fps = ini_read_real("config", "show_fps", false);
global.show_instance_count = ini_read_real("config", "show_instance_count", false);
global.show_all_instance_count = ini_read_real("config", "show_all_instance_count", false);
global.send_crash_logs = ini_read_real("config", "send_crash_logs", true);

#region /* Debug Collapsed Sections */
var section_list = [
	"Instructions",
	"System Information",
	"Player Information",
	"Menu Information",
	"Gamepad Information",
	"Switch Information",
	"Background Information"
];
for (var i = 0; i < array_length(section_list); i++)
{
	var key = section_list[i];
	global.debug_collapsed_sections[? key] = ini_read_real("debug_collapsed_sections", key, false);
}
#endregion /* Debug Collapsed Sections END */

ini_close();

room_goto(room_level_browser);
