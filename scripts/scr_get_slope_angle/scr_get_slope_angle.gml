function scr_get_slope_angle()
{
	
	#region /* Slope detection with continuous raycasting */
	if (on_ground) 
	&& (slide >= 1 /* Only align yourself to slope if you are sliding */
	|| crouch >= 1 && key_crouch) /* or if you are crouching */
	{
		var left_x = x - sprite_width / 2; // Left edge of the player
		var right_x = x + sprite_width / 2; // Right edge of the player
		var top_y = y - 128;
		var sample_steps = 4; // How many horizontal steps to take
		var check_distance = 300; // Max distance downward to detect ground
		
		// Track ground points
		var ground_points = []; // Array to store Y positions for valid points
		var valid_count = 0;
		
		// Cast rays across the player's width
		for (var i = 0; i <= sample_steps; i++)
		{
			var xx = lerp(left_x, right_x, i / sample_steps);
			var ground_y = -1;
			
			for (var yy = 0; yy <= check_distance; yy++)
			{
				if (collision_point(xx, top_y + yy, obj_slope_parent, true, false))
				{
					ground_y = top_y + yy;
					break; // Stop when ground is detected
				}
			}
			
			// Store valid ground points
			if (ground_y != -1)
			{
				ground_points[i] = ground_y;
				valid_count++;
			}
			else
			{
				ground_points[i] = -1; // Mark invalid points
			}
			
			// Debug: Draw sampling points
			if (obj_debug_manager.debug_screen)
			{
				draw_circle_color(xx, ground_y, 4, c_green, c_green, false);
			}
		}
		
		// Slope calculation: Use first and last valid ground points
		var left_y = -1;
		var right_y = -1;
		
		// Find the first valid ground point (leftmost)
		for (var i = 0; i <= sample_steps; i++)
		{
			if (ground_points[i] != -1)
			{
				left_y = ground_points[i];
				break;
			}
		}
		
		// Find the last valid ground point (rightmost)
		for (var i = sample_steps; i >= 0; i--)
		{
			if (ground_points[i] != -1)
			{
				right_y = ground_points[i];
				break;
			}
		}
		
		// Calculate slope angle if at least 2 valid points are found
		if (left_y != -1
		&& right_y != -1
		&& left_y != right_y)
		{
			var dx = right_x - left_x;
			var dy = left_y - right_y;
			
			slope_angle = radtodeg(arctan2(dy, dx));
			
			// Debug: Draw slope line
			if (obj_debug_manager.debug_screen)
			{
				draw_line_width_color(left_x, left_y, right_x, right_y, 4, c_blue, c_blue);
				draw_set_halign(fa_left);
				draw_text(x + 100, y - 20, "Slope Angle: " + string(slope_angle));
				draw_text(x + 100, y - 30, "Left Y: " + string(left_y) + ", Right Y: " + string(right_y));
			}
		}
		else
		{
			slope_angle = 0; // No valid slope
		}
	}
	else
	{
		slope_angle = 0; /* Note: Only use slope_angle, don't use image_angle */
	}
	#endregion
	
}