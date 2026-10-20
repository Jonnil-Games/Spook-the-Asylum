///////////////////////////////////////////////////////////////
// Debug Toggle
///////////////////////////////////////////////////////////////

/// @function scr_debug_toggle_screen()
/* Toggles the debug screen visibility based on keyboard/gamepad input */
function scr_debug_toggle_screen()
{
	/* Use parentheses to group conditions for clarity */
	if (keyboard_check_pressed(vk_f3))
	{
		debug_screen = !debug_screen;
	}
}


///////////////////////////////////////////////////////////////
// FPS Display
///////////////////////////////////////////////////////////////

/// @function scr_debug_draw_fps()
/* Draws the FPS and "real" FPS information on screen */
function scr_debug_draw_fps()
{
	if (global.show_fps
	|| debug_screen)
	{
		var fps_y = 64;
		
		/* If both options are active, show an icon next to the FPS display */
		if (global.show_fps
		&& debug_screen)
		{
			draw_sprite_ext(spr_icon_lock, 0, 16, fps_y, 1, 1, 0, c_white, 1);
		}
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		
		/* Choose a green color if the FPS meets or exceeds the max. Otherwise, compute a hue */
		var fps_color = (fps >= max_fps)
						? c_lime
						: make_color_hsv(50 / max_fps * fps, 255, 255);
		draw_text_color(32, fps_y, "FPS: " + string(fps) + "/" + string(max_fps), fps_color, fps_color, fps_color, fps_color, 1);
		
		/* Adjust target based on OS. On Switch, target a lower FPS */
		var fps_real_target = (os_type == os_switch) ? 60 : 600;
		var fps_real_color = (fps_real >= fps_real_target)
							 ? c_lime
							 : make_color_hsv(50 / fps_real_target * fps_real, 255, 255);
		draw_text_color(200, fps_y, "FPS Real: " + string(fps_real), fps_real_color, fps_real_color, fps_real_color, fps_real_color, 1);
	}
}


///////////////////////////////////////////////////////////////
// Instance Count Display
///////////////////////////////////////////////////////////////

/// @function scr_debug_draw_instance_count()
/* Draws a simple instance count on screen */
function scr_debug_draw_instance_count()
{
	if (global.show_instance_count
	|| debug_screen)
	{
		var instance_count_y = 96;
		
		if (global.show_instance_count
		&& debug_screen)
		{
			draw_sprite_ext(spr_icon_lock, 0, 16, instance_count_y, 1, 1, 0, c_white, 1);
		}
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_text_color(32, instance_count_y, "Instance Count: " + string(instance_count), c_white, c_white, c_white, c_white, 1);
	}
}

/// @function scr_debug_draw_all_instance_count()
/* Draws detailed instance counts for each object type. Iterates through a fixed range */
function scr_debug_draw_all_instance_count()
{
	if (global.show_all_instance_count)
	{
		var all_instance_count_y = 128;
		
		if (global.show_all_instance_count
		&& debug_screen)
		{
			draw_sprite_ext(spr_icon_lock, 0, 16, all_instance_count_y, 1, 1, 0, c_white, 1);
		}
		/* NOTE: Looping over a fixed range (0-99) assumes your object IDs fall within this range */
		for (var i = 0; i < 100; ++i)
		{
			if (instance_number(i) >= 1)
			{
				var all_instance_count_color = make_color_hsv(instance_number(i), 255, 255);
				draw_text_color(32, all_instance_count_y + (8 * i), string(object_get_name(i)) + ": " + string(instance_number(i)), all_instance_count_color, all_instance_count_color, all_instance_count_color, all_instance_count_color, 1);
			}
		}
	}
}


///////////////////////////////////////////////////////////////
// Controller Ports Handling
///////////////////////////////////////////////////////////////

/// @function scr_debug_handle_controller_ports()
/* Assigns gamepad indices to players based on platform and input */
function scr_debug_handle_controller_ports()
{
	/* Count how many players are active based on the "player_can_play" flags */
	global.playergame = 0;
	for (var i = 1; i <= global.max_players; i += 1)
	{
		if (global.player_can_play[i])
		{
			global.playergame += 1;
		}
	}
	
	/* Platform-specific handling for Switch */
	if (os_type == os_switch)
	{
		/* If gamepad 0 is "Handheld", then assign gamepad 0 as player 1 */
		if (gamepad_get_description(0) == "Handheld")
		{
			global.player_slot[0] = 1;
			
			/* Check which gamepad is active and assign it to player 1 */
			if (global.player_slot[1] != 0)
			{
				if (gamepad_button_check(0, gp_face1)
				|| gamepad_button_check(0, gp_face2)
				|| gamepad_button_check(0, gp_face3)
				|| gamepad_button_check(0, gp_face4)
				|| gamepad_button_check(0, gp_padd)
				|| gamepad_button_check(0, gp_padl)
				|| gamepad_button_check(0, gp_padr)
				|| gamepad_button_check(0, gp_padu)
				|| gamepad_button_check(0, gp_select)
				|| gamepad_button_check(0, gp_shoulderl)
				|| gamepad_button_check(0, gp_shoulderlb)
				|| gamepad_button_check(0, gp_shoulderr)
				|| gamepad_button_check(0, gp_shoulderrb)
				|| gamepad_button_check(0, gp_start)
				|| gamepad_button_check(0, gp_stickl)
				|| gamepad_button_check(0, gp_stickr)
				|| (gamepad_axis_value(0, gp_axislh) < -0.3)
				|| (gamepad_axis_value(0, gp_axislv) < -0.3)
				|| (gamepad_axis_value(0, gp_axisrh) < -0.3)
				|| (gamepad_axis_value(0, gp_axisrv) < -0.3)
				|| (gamepad_axis_value(0, gp_axislh) > 0.3)
				|| (gamepad_axis_value(0, gp_axislv) > 0.3)
				|| (gamepad_axis_value(0, gp_axisrh) > 0.3)
				|| (gamepad_axis_value(0, gp_axisrv) > 0.3))
				{
					global.player_slot[1] = 0;
				}
			}
			else
			if (global.player_slot[1] != 1)
			{
				if (gamepad_button_check(1, gp_face1)
				|| gamepad_button_check(1, gp_face2)
				|| gamepad_button_check(1, gp_face3)
				|| gamepad_button_check(1, gp_face4)
				|| gamepad_button_check(1, gp_padd)
				|| gamepad_button_check(1, gp_padl)
				|| gamepad_button_check(1, gp_padr)
				|| gamepad_button_check(1, gp_padu)
				|| gamepad_button_check(1, gp_select)
				|| gamepad_button_check(1, gp_shoulderl)
				|| gamepad_button_check(1, gp_shoulderlb)
				|| gamepad_button_check(1, gp_shoulderr)
				|| gamepad_button_check(1, gp_shoulderrb)
				|| gamepad_button_check(1, gp_start)
				|| gamepad_button_check(1, gp_stickl)
				|| gamepad_button_check(1, gp_stickr)
				|| (gamepad_axis_value(1, gp_axislh) < -0.3)
				|| (gamepad_axis_value(1, gp_axislv) < -0.3)
				|| (gamepad_axis_value(1, gp_axisrh) < -0.3)
				|| (gamepad_axis_value(1, gp_axisrv) < -0.3)
				|| (gamepad_axis_value(1, gp_axislh) > 0.3)
				|| (gamepad_axis_value(1, gp_axislv) > 0.3)
				|| (gamepad_axis_value(1, gp_axisrh) > 0.3)
				|| (gamepad_axis_value(1, gp_axisrv) > 0.3))
				{
					global.player_slot[1] = 1;
				}
			}
		}
	}
	else
	{
		/* For non-Switch platforms, assign gamepad indices sequentially */
		for (var i = 1; i <= global.max_players; i += 1)
		{
			global.player_slot[i] = i - 1;
		}
	}
}


///////////////////////////////////////////////////////////////
// Controller Connection/Disconnection Detection
///////////////////////////////////////////////////////////////

/// @function scr_debug_detect_controller_disconnections()
/* Checks for changes in gamepad connection status and updates debug info accordingly */
function scr_debug_detect_controller_disconnections()
{
	for (var i = 0; i < gamepad_get_device_count(); i++)
	{
		var connected = gamepad_is_connected(i);
		
		/* If a gamepad that was not connected is now connected... */
		if (!global.initial_gamepad_status[i]
		&& connected)
		{
			show_debug_message("Gamepad " + string(i) + " connected!");
			global.initial_gamepad_status[i] = true;
			
			if (!gamepad_is_connected(0) || (gamepad_get_description(0) == "Handheld"))
			{
				for (var j = 1; j <= global.max_players; j += 1)
				{
					global.player_slot[j] = j;
				}
			}
			else
			{
				for (var j = 1; j <= global.max_players; j += 1)
				{
					global.player_slot[j] = j - 1;
				}
			}
		}
		/* If a gamepad that was connected is now disconnected... */
		else
		if (global.initial_gamepad_status[i]
		&& !connected)
		{
			show_debug_message("Gamepad " + string(i) + " disconnected!");
			global.initial_gamepad_status[i] = false;
			
			if (os_type == os_switch)
			{
				switch_controller_support_show();
			}
			var time_source = time_source_create(time_source_game, 2, time_source_units_frames, function()
			{
				set_controller_sprites_to_use();
			}, [], 1);
			time_source_start(time_source);
			
			if (!gamepad_is_connected(0)
			|| (gamepad_get_description(0) == "Handheld"))
			{
				for (var j = 1; j <= global.max_players; j += 1)
				{
					global.player_slot[j] = j;
				}
			}
			else
			{
				for (var j = 1; j <= global.max_players; j += 1)
				{
					global.player_slot[j] = j - 1;
				}
			}
		}
	}
}


///////////////////////////////////////////////////////////////
// Debug Screen Logic & Additional Debug Info
///////////////////////////////////////////////////////////////

/// @function scr_debug_draw_debug_logic()
/* Handles additional debug screen logic such as debug logging, mode toggling, */
/* mouse-based toggles, player info, and drawing extra debug sections */
function scr_debug_draw_debug_logic()
{
	if (global.dev_stage != "")
	|| (debug_screen)
	{
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		/* When the game is in development, say the game name, dev stage, and version number in the top-left corner of the screen */
		draw_text_color(32, 32, string(global.game_name) + " " + string(global.dev_stage) + " v" + scr_get_build_date(), c_white, c_white, c_white, c_white, 1);
	}
	
	if (debug_screen)
	{
		
		#region /* Save debug info when F2 is pressed */
		if (keyboard_check_pressed(vk_f2))
		{
			var logs_folder = game_save_id + "debug_logs/";
			if (!directory_exists(logs_folder))
			{
				directory_create(logs_folder);
			}
			
			#region /* Save Date */
			var current_dt = date_current_datetime();
			
			var year_str  = string(date_get_year(current_dt));
			
			var month_val = date_get_month(current_dt);
			var month_str = (month_val < 10) ? "0" + string(month_val) : string(month_val);
			
			var day_val   = date_get_day(current_dt);
			var day_str   = (day_val < 10) ? "0" + string(day_val) : string(day_val);
			
			var hour_val  = date_get_hour(current_dt);
			var hour_str  = (hour_val < 10) ? "0" + string(hour_val) : string(hour_val);
			
			var minute_val = date_get_minute(current_dt);
			var minute_str = (minute_val < 10) ? "0" + string(minute_val) : string(minute_val);
			
			var second_val = date_get_second(current_dt);
			var second_str = (second_val < 10) ? "0" + string(second_val) : string(second_val);
			
			var save_date = year_str + "-" + month_str + "-" + day_str + "_" + hour_str + "." + minute_str + "." + second_str;
			#endregion /* Save Date END */
			
			var log_file_path = logs_folder + "debug_info-" + string(global.game_name) + "_v" + string(scr_get_build_date()) + "_" + save_date + ".ini";
			
			ini_open(log_file_path);
			scr_write_debug_info();
			ini_close();
			
			show_debug_message("Debug information saved to: " + log_file_path);
		}
		#endregion /* Save debug info when F2 is pressed END */
		
		/* Toggle detailed/simplified debug mode when F4 is pressed */
		if (keyboard_check_pressed(vk_f4))
		{
			global.debug_detailed_mode = !global.debug_detailed_mode;
			ini_open(game_save_id + "save_file/config.ini");
			ini_write_real("config", "debug_detailed_mode", global.debug_detailed_mode);
			ini_close();
		}
		
		var mouse_get_x = device_mouse_x_to_gui(0);
		var mouse_get_y = device_mouse_y_to_gui(0);
		var display_y = 32;
		var d3d11_y = 64;
		
		/* --- Mouse Toggle Areas --- */
		/* Define header positions for the toggles */
		var fps_y = 64;
		scr_debug_handle_mouse_toggle(fps_y, "show_fps");
		scr_debug_handle_mouse_toggle(96, "show_instance_count");
		scr_debug_handle_mouse_toggle(128, "show_all_instance_count");
		
		#region /* --- On-Screen Instructions (for PC) --- */
		if (global.enable_option_for_pc
		&& global.controls_used_for_navigation != "gamepad")
		{
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			
			/* Determine the starting Y position for instructions */
			var instructions_y = 8;
			
			/* Draw the header for the Instructions section */
			instructions_y = scr_draw_debug_header("Instructions", display_get_gui_width() * 0.5 - 100, instructions_y);
			
			/* Only display the instructions if the section is expanded */
			if (!global.debug_collapsed_sections[? "Instructions"])
			{
				draw_set_halign(fa_center);
				
				draw_text_color(display_get_gui_width() * 0.5, instructions_y,
					"Press the F2 key to save debug information",
					c_white, c_white, c_white, c_white, 1);
				instructions_y += 25;
				
				draw_text_color(display_get_gui_width() * 0.5, instructions_y,
					"Press the F3 key to toggle debug screen",
					c_white, c_white, c_white, c_white, 1);
				instructions_y += 25;
				
				draw_text_color(display_get_gui_width() * 0.5, instructions_y,
					"Press the F4 key to toggle debug detailed mode",
					c_white, c_white, c_white, c_white, 1);
				instructions_y += 25;
				
				draw_text_color(display_get_gui_width() * 0.5, instructions_y,
					"Click on the debug headers to collapse sections",
					c_white, c_white, c_white, c_white, 1);
			}
		}
		#endregion /* --- On-Screen Instructions (for PC) --- END */
		
		/* --- Top-right Display Info --- */
		draw_set_halign(fa_right);
		draw_text_color(display_get_gui_width() - 32, display_y, "Display: " + string(window_get_width()) + "x" + string(window_get_height()), c_white, c_white, c_white, c_white, 1);
		
		if (ds_exists(os_info, ds_type_map))
		{
			if (ds_map_exists(os_info, "video_adapter_description"))
			{
				if (os_info[? "video_adapter_description"] != undefined)
				{
					draw_text_color(display_get_gui_width() - 32, d3d11_y, string(os_info[? "video_adapter_description"]), c_white, c_white, c_white, c_white, 1);
				}
			}
		}
		
		/* --- Current Room Info at Bottom --- */
		draw_set_halign(fa_center);
		draw_text_color(display_get_gui_width() * 0.5, display_get_gui_height() - 32, 
			"current room: '" + string(global.level_name) + "' " + string(global.select_level_index) + " " + string(room_get_name(room)) + " " + string(room_width) + "x" + string(room_height),
			c_white, c_white, c_white, c_white, 1);
		
		/* --- Optimized Debug Text Sections --- */
		scr_debug_draw_optimized_text();
	}
}


///////////////////////////////////////////////////////////////
// Mouse Toggle Helper
///////////////////////////////////////////////////////////////

/// @function scr_debug_handle_mouse_toggle(mouse_x, mouse_y, header_y, config_name)
/* Checks if the mouse is over a toggle area for FPS, Instance Count, etc. and toggles the option on click */
function scr_debug_handle_mouse_toggle(header_y, config_name)
{
	if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 0, header_y - 15, 370, header_y + 15))
	{
		draw_set_alpha(0.5);
		draw_roundrect_color_ext(0, header_y - 16, 370, header_y + 16, 50, 50, c_white, c_white, false);
		draw_set_alpha(1);
		
		if (mouse_check_button_released(mb_left))
		{
			/* Toggle the appropriate global variable and update the ini. Except for "show_all_instance_count" */
			if (config_name == "show_fps")
			{
				global.show_fps = !global.show_fps;
				ini_open(game_save_id + "save_file/config.ini");
				ini_write_real("config", "show_fps", global.show_fps);
				ini_close();
			}
			else
			if (config_name == "show_instance_count")
			{
				global.show_instance_count = !global.show_instance_count;
				ini_open(game_save_id + "save_file/config.ini");
				ini_write_real("config", "show_instance_count", global.show_instance_count);
				ini_close();
			}
			else
			if (config_name == "show_all_instance_count")
			{
				global.show_all_instance_count = !global.show_all_instance_count;
			}
		}
	}
}


///////////////////////////////////////////////////////////////
// Optimized Debug Text Sections
///////////////////////////////////////////////////////////////

/// @function scr_draw_debug_header(section_name, xx, yy)
/* Draws a clickable header for a debug section that can be collapsed/expanded */
function scr_draw_debug_header(section_name, xx, yy)
{
	var line_spacing = 25;
	var debug_header_text_color = c_yellow;
	
	if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), xx, yy, xx + 400, yy + line_spacing + 10))
	{
		/* Highlight the header when the mouse is over it */
		debug_header_text_color = c_orange;
		
		if (mouse_check_button_released(mb_left))
		{
			/* Toggle collapse state for this section */
			global.debug_collapsed_sections[? section_name] = !global.debug_collapsed_sections[? section_name];
			
			ini_open(game_save_id + "save_file/config.ini");
			ini_write_real("debug_collapsed_sections", string(section_name), global.debug_collapsed_sections[? section_name]);
			ini_close();
		}
	}
	
	var debug_header_icon = (!global.debug_collapsed_sections[? string(section_name)]) ? "[+]" : "[-]";
	draw_text_color(xx, yy, section_name + " " + string(debug_header_icon), debug_header_text_color, debug_header_text_color, debug_header_text_color, debug_header_text_color, 1);
	return yy + line_spacing;
}

/// @function scr_draw_highlighted_text(xx, yy, variable_name, value, label_simplified, color_normal, color_alert, alert_condition)
/* Draws a line of debug text with optional alert coloring */
function scr_draw_highlighted_text(xx, yy, variable_name, value, label_simplified, color_normal, color_alert, alert_condition)
{
	var display_label = (global.debug_detailed_mode) ? variable_name : label_simplified;
	var line_spacing = 25;
	var color = (alert_condition) ? color_alert : color_normal;
	draw_text_color(xx, yy, display_label + ": " + string(value), color, color, color, color, 1);
	return yy + line_spacing;
}