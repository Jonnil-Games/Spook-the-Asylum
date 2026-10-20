/// @description Load a saved custom level into real gameplay objects

scr_le_init();
display_set_gui_size(1366, 768);
depth = -200;

if (!variable_global_exists("le_current_folder") || global.le_current_folder == "")
{
	room_goto(room_level_browser);
	exit;
}

level_data = scr_le_load_level(global.le_current_folder);
if (is_undefined(level_data))
{
	global.le_active_level = false;
	room_goto(room_level_browser);
	exit;
}

global.le_active_level = true;
global.level_name = level_data.display_name;
global.checkpoint_x = 0;
global.checkpoint_y = 0;
global.actually_play_edited_level = true;

room_width = max(1366, level_data.width);
room_height = max(768, level_data.height);

goal_x = level_data.goal.x;
goal_y = level_data.goal.y;
playtest_mode = variable_global_exists("le_playtest_mode") ? global.le_playtest_mode : "normal";
return_target = variable_global_exists("le_playtest_return") ? global.le_playtest_return : "browser";
starting_digest = scr_le_digest(level_data);
completed = false;
completion_success = false;
completion_title = "";
completion_detail = "";

var use_override = variable_global_exists("le_spawn_override") && global.le_spawn_override;
if (use_override)
{
	global.le_spawn_x = clamp(global.le_spawn_x, 0, room_width);
	global.le_spawn_y = clamp(global.le_spawn_y, 0, room_height);
}
else
{
	global.le_spawn_x = level_data.player_start.x;
	global.le_spawn_y = level_data.player_start.y;
}

global.level_player_start_x[1] = global.le_spawn_x;
global.level_player_start_y[1] = global.le_spawn_y;

scr_le_spawn_runtime(level_data);
instance_create_depth(0, 0, -100, obj_camera);

return_from_playtest = function()
{
	global.le_active_level = false;
	audio_stop_sound(snd_ambient);
	if (return_target == "editor") room_goto(room_level_editor);
	else
	{
		global.le_browser_screen = "gallery";
		room_goto(room_level_browser);
	}
}

finish_level = function()
{
	if (completed) exit;
	completed = true;

	if (instance_exists(obj_player))
	{
		with (obj_player)
		{
			can_move = false;
			xspd = 0;
			yspd = 0;
		}
	}

	if (playtest_mode == "clear")
	{
		var expected_digest = variable_global_exists("le_clear_digest") ? global.le_clear_digest : starting_digest;
		var current_level = scr_le_load_level(global.le_current_folder);
		var digest_unchanged = !is_undefined(current_level) && scr_le_digest(current_level) == expected_digest;
		var debug_used = variable_global_exists("le_debug_used") && global.le_debug_used;

		if (debug_used)
		{
			completion_title = "Clear not verified";
			completion_detail = "Debug controls were active during this run. Try again without them.";
		}
		else if (!digest_unchanged)
		{
			completion_title = "Clear not verified";
			completion_detail = "The saved level changed during the run. Save it, then verify again.";
		}
		else if (scr_le_verify_level(global.le_current_folder, expected_digest))
		{
			completion_success = true;
			completion_title = "Level verified!";
			completion_detail = "This exact saved version now carries a clear badge.";
		}
		else
		{
			completion_title = "Clear not verified";
			completion_detail = "The verification record could not be saved.";
		}
	}
	else
	{
		completion_success = true;
		completion_title = "Level complete!";
		completion_detail = (playtest_mode == "quick")
			? "Quick Test checks the route but does not award verification."
			: "You reached the exit.";
	}
}
