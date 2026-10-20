/// @description obj_camera Create

scr_inventory_create();

depth = -100;

can_spawn_players = true;
camera_intro_animation = "";

if (variable_global_exists("le_active_level") && global.le_active_level)
{
	global.level_player_start_x[1] = global.le_spawn_x;
	global.level_player_start_y[1] = global.le_spawn_y;
}
else
{
	global.level_player_start_x[1] = 3456;
	global.level_player_start_y[1] = 128;
}

final_cam_x = 0;
final_cam_y = 0;
cam_trail_spd = .25;

audio_stop_all();
audio_play_sound(snd_ambient, 0, true);

custom_background_1 = spr_background;
custom_background_2 = spr_background2;
custom_background_3 = spr_background;
custom_background_4 = noone;

custom_background_1_htiled = true;
custom_background_1_vtiled = true;
custom_background_2_htiled = true;
custom_background_2_vtiled = true;
custom_background_3_htiled = true;
custom_background_3_vtiled = true;
custom_background_4_htiled = true;
custom_background_4_vtiled = true;

custom_background_1_alpha = 1;
custom_background_2_alpha = 1;
custom_background_3_alpha = 0.9;
custom_background_4_alpha = 1;

custom_background_1_color = c_white;
custom_background_2_color = c_white;
custom_background_3_color = c_black;
custom_background_4_color = c_white;

alarm[0] = 1;

// Fog movement offsets and speed
fog_offset_x = 0;
fog_offset_y = 0;
fog_speed_x  = 0.01;
fog_speed_y  = 0.01;
fog_alpha    = 0.1; // Adjust for desired transparency
fog_amplitude = 1;
fog_frequency = 1;
fog_speed = 0.5;
fog_sprite_width = sprite_get_width(spr_fog);
fog_sprite_height = sprite_get_height(spr_fog);
fog_time = 0;

#region /* Spawn Players */
if (can_spawn_players)
{
	for(var i = 1; i <= global.max_players; i += 1)
	{
		if (global.player_can_play[i])
		{
			var level_start_x = global.level_player_start_x[i];
			var level_start_y = global.level_player_start_y[i];
			
			if (global.checkpoint_x > 0
			&& global.checkpoint_y > 0
			&& global.actually_play_edited_level
			&& (!variable_global_exists("le_active_level") || !global.le_active_level))
			{
				level_start_x = global.checkpoint_x;
				level_start_y = global.checkpoint_y;
			}
			
			player[i] = instance_create_depth(level_start_x, level_start_y, 0, obj_player);
			
			with (player[i])
			{
				custom_character = global.character_for_player[i];
				selected_voicepack = global.voicepack_for_player[i];
				selected_skin = global.skin_for_player[i];
				//player_intro_animation = instance_nearest(level_start_x, level_start_y, obj_camera).camera_intro_animation;
				player = i;
			}
		}
		else
		{
			player[i] = noone;
		}
	}
	
	if (global.actually_play_edited_level)
	{
		player_has_spawned = true;
	}
	else
	{
		player_has_spawned = false;
	}
}
else
{
	for(var i = 1; i <= global.max_players; i += 1)
	{
		player[i] = noone;
	}
	
	player_has_spawned = false;
}
#endregion /* Spawn Players END */
