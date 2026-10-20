/// @function scr_player_move_ledgegrab()
/// @description Handles ledge detection, grabbing, hanging, climbing, and dropping for the player.

function scr_player_move_ledgegrab()
{
	// CONFIGURATION
	var grab_x_reach          = 2;			// distance beyond the collision mask to check for a wall
	var grab_sensor_from_top  = 60;			// arm position measured down from bbox_top
	var grab_vertical_range   = 64;			// how far below a ledge the arm sensor may be
	var hang_hand_depth       = 8;			// how far below the ledge the hand rests while hanging
	var climb_forward_spd     = move_spd[0];
	var climb_timeout         = 90;			// failsafe if the climb is blocked by another wall
	var regrab_delay          = 10;			// prevents a drop from immediately grabbing the same ledge

	if (ledge_regrab_timer > 0)
	{
		ledge_regrab_timer--;
	}

	// Landing completes a climb and returns normal movement control.
	if (on_ground && grab_state != 0)
	{
		grab_state = 0;
		climb_timer = 0;
		grab_wall = noone;
		xspd = 0;
		sprite_index = spr_idle;
		image_index = 0;
		return;
	}

	// While climbing, normal collision and gravity move the player. Reapply the
	// forward speed each frame so the player keeps travelling over the ledge.
	if (grab_state == 2)
	{
		climb_timer++;

		if (climb_timer >= climb_timeout)
		{
			grab_state = 0;
			climb_timer = 0;
			grab_wall = noone;
			ledge_regrab_timer = regrab_delay;
			xspd = 0;
		}
		else
		{
			xspd = face_x * climb_forward_spd;
		}

		return;
	}

	// Hanging behavior and ledge options.
	if (grab_state == 1)
	{
		if (!instance_exists(grab_wall))
		{
			grab_state = 0;
			ledge_regrab_timer = regrab_delay;
			return;
		}

		// Keep the collision mask one pixel outside the wall.
		if (face_x == 1)
		{
			x += (grab_wall.bbox_left - 1) - bbox_right;
		}
		else
		{
			x += (grab_wall.bbox_right + 1) - bbox_left;
		}

		// Align the character's hand with the top of the grabbed wall.
		var hand_y = bbox_top + grab_sensor_from_top;
		y += (grab_wall.bbox_top + hang_hand_depth) - hand_y;

		xspd = 0;
		yspd = 0;
		attack_swing = false;
		kick = false;
		kick_timer = 0;
		sprite_index = spr_ledge_hang;
		image_speed = 0.5;

		if (image_index > image_number - 1)
		{
			image_index = image_number - 1;
			image_speed = 0;
		}

		var toward_pressed = (face_x == 1 && key_right_pressed)
							|| (face_x == -1 && key_left_pressed);
		var away_pressed = (face_x == 1 && key_left_pressed)
						|| (face_x == -1 && key_right_pressed);

		// Jump straight up with the same impulse as a ground jump.
		if (key_jump_buffered)
		{
			key_jump_buffered = false;
			key_jump_buffer_timer = 0;
			grab_state = 0;
			climb_timer = 0;
			grab_wall = noone;
			ledge_regrab_timer = regrab_delay;
			jump_count = jump_max;
			xspd = 0;
			// Gravity is applied before movement on the next Step, so offset it here.
			yspd = jspd - grav;
			set_on_ground(false);
			what_jump_sprite = 1;
			sprite_index = spr_jump;
			image_index = 0;
			image_speed = 0.5;
			return;
		}

		// Up or a direction toward the ledge starts the automatic climb.
		if (key_up_pressed || toward_pressed)
		{
			grab_state = 2;
			climb_timer = 0;
			jump_count = jump_max;
			xspd = face_x * climb_forward_spd;
			// Use the regular jump height, then keep moving toward the platform.
			yspd = jspd - grav;
			set_on_ground(false);
			what_jump_sprite = 1;
			sprite_index = spr_jump;
			image_index = 0;
			image_speed = 0.5;
			return;
		}

		// Down or a direction away from the ledge lets go.
		if (key_down_pressed || away_pressed)
		{
			grab_state = 0;
			climb_timer = 0;
			grab_wall = noone;
			ledge_regrab_timer = regrab_delay;
			xspd = 0;
			yspd = 1;
			what_jump_sprite = 2;
			sprite_index = spr_fall;
			image_index = 0;
			image_speed = 0.5;
		}

		return;
	}

	// Look for a nearby ledge while falling. Holding down deliberately prevents
	// a grab, matching the expected drop-through behavior.
	if (grab_state == 0
	&& ledge_regrab_timer <= 0
	&& crouch == 0
	&& !in_water
	&& !on_ground
	&& yspd > 0
	&& !key_down)
	{
		var preferred_dir = face_x;

		if (xspd != 0)
		{
			preferred_dir = sign(xspd);
		}

		if (key_right != key_left)
		{
			preferred_dir = key_right - key_left;
		}

		if (preferred_dir == 0)
		{
			preferred_dir = 1;
		}

		// Check the preferred side first, then allow a modern Smash-style grab
		// behind the character if the opposite ledge is the one in range.
		for (var side_check = 0; side_check < 2; side_check++)
		{
			var check_dir = (side_check == 0) ? preferred_dir : -preferred_dir;
			var check_x = (check_dir == 1) ? bbox_right + grab_x_reach : bbox_left - grab_x_reach;
			var check_y = bbox_top + grab_sensor_from_top;
			var wall_inst = instance_position(check_x, check_y, obj_wall);

			if (instance_exists(wall_inst))
			{
				var distance_below_top = check_y - wall_inst.bbox_top;
				var above_ledge_is_free = (instance_position(check_x, wall_inst.bbox_top - 1, obj_wall) == noone);

				if (distance_below_top >= 0
				&& distance_below_top <= grab_vertical_range
				&& above_ledge_is_free)
				{
					var target_x = x;

					if (check_dir == 1)
					{
						target_x += (wall_inst.bbox_left - 1) - bbox_right;
					}
					else
					{
						target_x += (wall_inst.bbox_right + 1) - bbox_left;
					}

					var target_y = y + (wall_inst.bbox_top + hang_hand_depth) - check_y;

					if (!place_meeting(target_x, target_y, obj_wall))
					{
						grab_wall = wall_inst;
						grab_state = 1;
						climb_timer = 0;
						face_x = check_dir;
						x = target_x;
						y = target_y;
						xspd = 0;
						yspd = 0;
						jump_count = jump_max;
						set_on_ground(false);
						attack_swing = false;
						kick = false;
						kick_timer = 0;
						sprite_index = spr_ledge_hang;
						image_index = 0;
						image_speed = 0.5;
						return;
					}
				}
			}
		}
	}
}

/// @function scr_player_draw_ledgegrab_sensors()
/// @description Draws debug visuals for the ledge grab sensors.
function scr_player_draw_ledgegrab_sensors()
{
	var grab_x_reach = 2;
	var grab_sensor_from_top = 60;
	var grab_vertical_range = 64;
	var check_y = bbox_top + grab_sensor_from_top;
	var radius = 4;

	draw_set_alpha(0.5);

	for (var check_dir = -1; check_dir <= 1; check_dir += 2)
	{
		var check_x = (check_dir == 1) ? bbox_right + grab_x_reach : bbox_left - grab_x_reach;

		draw_set_color(c_red);
		draw_circle(check_x, check_y, radius, false);
		draw_set_color(c_blue);
		draw_line(check_x, check_y, check_x, check_y - grab_vertical_range);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
}
