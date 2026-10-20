/// @function scr_debug_draw_optimized_text()
/// @description Draws a series of collapsible debug text sections. System, Player, Menu, Gamepad, and Switch info
function scr_debug_draw_optimized_text()
{
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	var debug_text_y = 170; /* Starting Y position for debug text */
	var section_spacing = 3; /* Spacing between sections */
	
	#region /* Section 1: System Information */
	debug_text_y = scr_draw_debug_header("System Information", 32, debug_text_y);
	
	if (!global.debug_collapsed_sections[? "System Information"])
	{
		debug_text_y = scr_draw_highlighted_text(32, debug_text_y,
							"current_datetime", string(date_datetime_string(date_current_datetime())),
							"Current Date/Time", c_white, c_red, false);
	}
	#endregion /* Section 1: System Information END */
	
	debug_text_y += section_spacing;
	
	#region /* Section 2: Player Information */
	if (instance_exists(obj_camera))
	{
		debug_text_y = scr_draw_debug_header("Player Information", 32, debug_text_y);
		
		if (!global.debug_collapsed_sections[? "Player Information"])
		{
			var player_positions = scr_get_player_positions();
			for (var i = 0; i < array_length(player_positions); i++)
			{
				var player_info = player_positions[i];
				var player_variable_name = "player " + string(player_info.player_pos_id);
				var player_label_simplified = "Player " + string(player_info.player_pos_id);
				
				debug_text_y = scr_draw_highlighted_text(32, debug_text_y, player_variable_name + " xy",
									string(player_info.player_pos_x) + " / " + string(player_info.player_pos_y),
									player_label_simplified + " Position", c_white, c_red, false);
				
				debug_text_y = scr_draw_highlighted_text(32, debug_text_y, player_variable_name + " speed",
									string(player_info.player_speed),
									player_label_simplified + " Speed", c_white, c_red, false);
				
				debug_text_y = scr_draw_highlighted_text(32, debug_text_y, player_variable_name + " on_ground",
									string(player_info.player_on_ground),
									player_label_simplified + " On Ground", c_white, c_red, false);
				
				debug_text_y = scr_draw_highlighted_text(32, debug_text_y, player_variable_name + " crouch",
									string(player_info.crouch),
									player_label_simplified + " Crouch", c_white, c_red, false);
				
				debug_text_y = scr_draw_highlighted_text(32, debug_text_y, player_variable_name + " crouch_timer",
									string(player_info.crouch_timer),
									player_label_simplified + " Crouch Timer", c_white, c_red, false);
				
				debug_text_y = scr_draw_highlighted_text(32, debug_text_y, player_variable_name + " draw_angle",
									string(player_info.draw_angle),
									player_label_simplified + " Draw Angle", c_white, c_red, false);
				
			}
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "player_can_play", string(global.player_can_play), "Player Can Play", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "player_slot", string(global.player_slot), "Player Slots", c_white, c_red, false);
		}
	}
	#endregion /* Section 2: Player Information END */
	
	debug_text_y += section_spacing;
	
	#region /* Section 3: Menu Information */
	/* If a debug target was found, we can use a "with" block on it */
	if (debug_target != noone)
	{
		with (debug_target)
		{
			debug_text_y = scr_draw_debug_header("Menu Information", 32, debug_text_y);
			
			if (!global.debug_collapsed_sections[? "Menu Information"])
			{
				/* Debug output ordered by overall system state, control settings, then scroll values and delays */
				
				/* 1. Overall Menu States */
				if (variable_instance_exists(self, "menu"))
				{
				    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "menu", string(menu), "Current Menu", c_white, c_red, menu == 0);
				}
				
				if (variable_instance_exists(self, "level_editor_menu"))
				{
				    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "level_editor_menu", string(level_editor_menu), "Level Editor Menu", c_white, c_red, false);
				}
				
				if (variable_instance_exists(self, "in_character_select_menu"))
				{
				    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "in_character_select_menu", string(in_character_select_menu), "In Character Select Menu", c_white, c_red, false);
				}
				
				/* 2. Control Settings */
				debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "controls_used_for_navigation", string(global.controls_used_for_navigation), "Controls Used For Navigation", c_white, c_red, false);
				
				if (variable_instance_exists(self, "scrolling_menu_with_mousewheel"))
				{
					debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "scrolling_menu_with_mousewheel", string(scrolling_menu_with_mousewheel), "Scrolling Menu With Mousewheel", c_white, c_red, scrolling_menu_with_mousewheel);
				}
				
				/* 3. Navigation & Scrolling Variables */
				debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "menu_navigation_speed", string(global.menu_navigation_speed), "Menu Navigation Speed", c_white, c_red, false);
				
				if (variable_instance_exists(self, "menu_cursor_y_position"))
				{
				    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "menu_cursor_y_position", string(menu_cursor_y_position), "Menu Cursor Y Position", c_white, c_red, false);
				}
				
				if (variable_instance_exists(self, "menu_y_offset"))
				{
				    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "menu_y_offset", string(menu_y_offset), "Menu Y Offset", c_white, c_red, false);
				}
				
				if (variable_instance_exists(self, "menu_y_offset_real"))
				{
				    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "menu_y_offset_real", string(menu_y_offset_real), "Menu Y Offset (Real)", c_white, c_red, false);
				}
				
				/* 4. Delay Values */
				if (variable_instance_exists(self, "menu_delay"))
				{
				    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "menu_delay", string(menu_delay), "Menu Delay", c_white, c_red, menu_delay > 0);
				}
				
				if (variable_instance_exists(self, "menu_joystick_delay") && gamepad_is_connected(0))
				{
				    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "menu_joystick_delay", string(menu_joystick_delay), "Menu Joystick Delay", c_white, c_red, menu_joystick_delay > 0);
				}
				
			}
		}
	}
	#endregion /* Section 3: Menu Information END */
	
	debug_text_y += section_spacing;
	
	#region /* Section 4: Gamepad Information */
	var gamepad_connected = false;
	
	for (var g = 0; g < 5; g++)
	{
		if (gamepad_get_description(g) != "")
		{
			gamepad_connected = true;
			break;
		}
	}
	
	if (gamepad_connected)
	{
		debug_text_y = scr_draw_debug_header("Gamepad Information", 32, debug_text_y);
		
		if (!global.debug_collapsed_sections[? "Gamepad Information"])
		{
			for (var g = 0; g < 5; g++)
			{
				if (gamepad_get_description(g) != "")
				{
					debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "gamepad(" + string(g) + ")", gamepad_get_description(g), "Gamepad " + string(g) + " Description", c_white, c_red, false);
				}
			}
		}
	}
	#endregion /* Section 4: Gamepad Information END */
	
	debug_text_y += section_spacing;
	
	#region /* Section 5: Switch Information (only for Switch) */
	if (os_type == os_switch)
	{
		debug_text_y = scr_draw_debug_header("Switch Information", 32, debug_text_y);
		
		if (!global.debug_collapsed_sections[? "Switch Information"])
		{
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "switch_account_name", string(global.switch_account_name), "Switch Account Name", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "switch_account_open", string(global.switch_account_open), "Switch Account Open", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "switch_account_handle", string(global.switch_account_handle), "Switch Account Handle", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "online_token_validated", string(global.online_token_validated), "Online Token Validated", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "online_token_error_message", string(global.online_token_error_message), "Online Token Error Message", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "switch_account_netid", string(global.switch_account_netid), "Switch Account NetID", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "switch_account_is_user_online", string(global.switch_account_is_user_online), "Switch User Online", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "switch_account_network_service_available", string(global.switch_account_network_service_available), "Switch Network Service Available", c_white, c_red, !global.switch_account_network_service_available);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "switch_logged_in", string(global.switch_logged_in), "Switch Logged In", c_white, c_red, !global.switch_logged_in);
		}
	}
	#endregion /* Section 5: Switch Information (only for Switch) END */
	
	debug_text_y += section_spacing;

	#region /* Section 6: Background Information */
	debug_text_y = scr_draw_debug_header("Background Information", 32, debug_text_y);

	if (!global.debug_collapsed_sections[? "Background Information"])
	{
	    // Get the layer IDs for the background layers
	    var bg1_id = layer_get_id("background_1");
	    var bg2_id = layer_get_id("background_2");
	    var bg3_id = layer_get_id("background_3");
	    var bg4_id = layer_get_id("background_4");
		
		// Fog variables
		if (variable_instance_exists(debug_target, "fog_alpha"))
		{
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "fog_alpha", string(debug_target.fog_alpha), "Fog Alpha", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "fog_amplitude", string(debug_target.fog_amplitude), "Fog Amplitude", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "fog_frequency", string(debug_target.fog_frequency), "Fog Frequency", c_white, c_red, false);
			debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "fog_speed", string(debug_target.fog_speed), "Fog Speed", c_white, c_red, false);
		}
		
	    // Display the layer IDs
	    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_layer_id", string(bg1_id), "Background 1 Layer ID", c_white, c_red, false);
	    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg2_layer_id", string(bg2_id), "Background 2 Layer ID", c_white, c_red, false);
	    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg3_layer_id", string(bg3_id), "Background 3 Layer ID", c_white, c_red, false);
	    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg4_layer_id", string(bg4_id), "Background 4 Layer ID", c_white, c_red, false);
		
		with (debug_target)
		{
		    // Display the custom background sprite settings
		    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "custom_background_1", string(custom_background_1), "Custom Background 1 Sprite", c_white, c_red, false);
		    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "custom_background_2", string(custom_background_2), "Custom Background 2 Sprite", c_white, c_red, false);
		    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "custom_background_3", string(custom_background_3), "Custom Background 3 Sprite", c_white, c_red, false);
		    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "custom_background_4", string(custom_background_4), "Custom Background 4 Sprite", c_white, c_red, false);
			
		    // Optionally, display tiling info
		    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "custom_background_1_htiled", string(custom_background_1_htiled), "Background 1 H-Tiled", c_white, c_red, false);
		    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "custom_background_1_vtiled", string(custom_background_1_vtiled), "Background 1 V-Tiled", c_white, c_red, false);
		    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "custom_background_2_htiled", string(custom_background_2_htiled), "Background 2 H-Tiled", c_white, c_red, false);
		    debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "custom_background_2_vtiled", string(custom_background_2_vtiled), "Background 2 V-Tiled", c_white, c_red, false);
			
			// Show offset, scale, visibility, etc. for background 1
		    if (bg1_id != -1)
		    {
		        //var bg1_offset_x = layer_background_get_x(bg1_id);
		        //var bg1_offset_y = layer_background_get_y(bg1_id);
		        var bg1_xscale   = layer_background_get_xscale(bg1_id);
		        var bg1_yscale   = layer_background_get_yscale(bg1_id);
		        var bg1_visible  = layer_get_visible(bg1_id);
		        //var bg1_alpha    = layer_get_alpha(bg1_id);
		        var bg1_layer_x  = layer_get_x(bg1_id);    // The layer's overall X offset
		        var bg1_layer_y  = layer_get_y(bg1_id);    // The layer's overall Y offset
		        var bg1_hspeed   = layer_get_hspeed(bg1_id);
		        var bg1_vspeed   = layer_get_vspeed(bg1_id);

		        //debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_offset_x", string(bg1_offset_x), "BG 1 Offset X", c_white, c_red, false);
		        //debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_offset_y", string(bg1_offset_y), "BG 1 Offset Y", c_white, c_red, false);
		        debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_xscale", string(bg1_xscale), "BG 1 X Scale", c_white, c_red, false);
		        debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_yscale", string(bg1_yscale), "BG 1 Y Scale", c_white, c_red, false);
		        debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_visible", string(bg1_visible), "BG 1 Visible", c_white, c_red, false);
		        //debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_alpha", string(bg1_alpha), "BG 1 Alpha", c_white, c_red, false);
		        debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_layer_x", string(bg1_layer_x), "BG 1 Layer X", c_white, c_red, false);
		        debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_layer_y", string(bg1_layer_y), "BG 1 Layer Y", c_white, c_red, false);
		        debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_hspeed", string(bg1_hspeed), "BG 1 HSpeed", c_white, c_red, false);
		        debug_text_y = scr_draw_highlighted_text(32, debug_text_y, "bg1_vspeed", string(bg1_vspeed), "BG 1 VSpeed", c_white, c_red, false);
		    }
			
		}
	}
	#endregion /* Section 6: Background Information END */

	
}