/// @description obj_player: Step Event

/* Get Inputs */
scr_get_controls();

#region /* X Movement */
/* Determine movement direction */
move_dir_x = key_right - key_left;

/* Get my face */
if (move_dir_x != 0)
&& (!in_water)
&& (grab_state == 0)
{
	face_x = move_dir_x;
}

/* Determine target speed based on input and run state */
var run_type = key_run;
var maxSpeed = move_spd[run_type];
var target_speed = move_dir_x * maxSpeed;

/* Define acceleration and friction */
var accel = 0.5; /* Adjust for desired acceleration rate */
var _friction = 0.3; /* Adjust for desired deceleration rate */

/* Apply momentum physics */
if (move_dir_x != 0)
{
    if (xspd < target_speed)
        xspd = min(xspd + accel, target_speed);
    else if (xspd > target_speed)
        xspd = max(xspd - accel, target_speed);
}
else
{
    /* Decelerate when no directional input is given */
    if (xspd > 0)
        xspd = max(xspd - _friction, 0);
    else if (xspd < 0)
        xspd = min(xspd + _friction, 0);
}

/* X Collision */
var sub_pixel = .5;
if (place_meeting(x + xspd, y, obj_wall))
{
	
	/* First check if there is a slope to go up */
	if (!place_meeting(x + xspd, y - abs(xspd) - 1, obj_wall))
	{
		while (place_meeting(x + xspd, y, obj_wall))
		{
			y -= sub_pixel;
		}
	}
	/* Next, check for ceiling slopes, otherwise, do a regular collision */
	else
	{
		/* Ceiling Slopes */
		if (!place_meeting(x + xspd, y + abs(xspd * 2) + 1, obj_wall))
		{
			while (place_meeting(x + xspd, y, obj_wall))
			{
				y += sub_pixel;
			}
		}
		/* Normal X Collision */
		else
		{
			/* Scoot up to wall precisely before setting xspd to zero */
			var pixel_check = sub_pixel * sign(xspd);
			while (!place_meeting(x + pixel_check, y, obj_wall))
			{
				x += pixel_check;
			}
			
			/* Set xspd to zero to "collide" after scooting up to a wall */
			xspd = 0;
		}
	}
}

/* Go Down Slopes */
down_slope_semisolid = noone;
if (yspd >= 0)
&& (!place_meeting(x + xspd, y + 1, obj_wall))
&& (place_meeting(x + xspd, y + abs(xspd) + 1, obj_wall))
{
	/* Check for a semisolid in the way */
	down_slope_semisolid = check_for_semisolid_platform(x + xspd, y + abs(xspd) + 1);
	/* Precisely move down slope if there isn't a semisolid in the way */
	if (!instance_exists(down_slope_semisolid))
	{
		while (!place_meeting(x + xspd, y + sub_pixel, obj_wall))
		{
			y += sub_pixel;
		}
	}
}

/* X Move */
x += xspd;
#endregion /* X Movement END */

#region /* Y Movement */
/* Gravity */
if (coyote_hang_timer > 0)
{
	/* Count the coyote hang timer down */
	coyote_hang_timer--;
}
else
{
	/* Apply gravity to the player*/
	yspd += grav;
	/* We're no longer on the ground */
	set_on_ground(false);
}

/* Reset / Prepare jumping variables */
if (on_ground)
{
	jump_count = 0
	coyote_jump_timer = coyote_jump_frames;
}
else
{
	/* If the player is in the air, make sure they can't do an extra jump */
	coyote_jump_timer--;
	
	if (jump_count == 0)
	&& (coyote_jump_timer <= 0)
	{
		jump_count = 1;
	}
}

/* Initiate the Jump */
var floor_is_solid = false;
if (instance_exists(my_floor_plat))
&& (my_floor_plat.object_index == obj_wall
|| object_is_ancestor(my_floor_plat.object_index, obj_wall))
{
	floor_is_solid = true;
}

if (key_jump_buffered
&& jump_count < jump_max
&& (!key_down
|| floor_is_solid))
&& (!place_meeting(x, y - 1, obj_wall))
{
	/* Reset the buffer */
	key_jump_buffered = false;
	key_jump_buffer_timer = 0;
	
	/* Increase the number of performed jumps */
	jump_count++;
	
	/* Set yspd to jump speed */
	yspd = jspd;
	
	/* Tell ourself we're no longer on the ground */
	set_on_ground(false);
	
	/* Set the sprite to jumping upward sprite */
	what_jump_sprite = 1;
	image_index = 0;
	image_speed = 0.5;
}

/* Cut off the jump by releasing the jump button */
if (key_jump_released
&& yspd < 0)
{
	yspd = yspd * 0.5;
}

#region /* Y Collision and movement */
/* Cap falling speed */
if (yspd > term_vel)
{
	yspd = term_vel;
}

/* Y Collision */
sub_pixel = .5;

#region /* Upwards Y Collision with Ceiling Slopes */
if (yspd < 0)
&& (place_meeting(x, y + yspd, obj_wall))
{
	/* Jump into sloped ceilings */
	var slope_slide = false;
	
	/* Slide Up Left Slope */
	if (move_dir_x == 0)
	&& (!place_meeting(x - abs(yspd) - 1, y + yspd, obj_wall))
	{
		while (place_meeting(x, y + yspd, obj_wall))
		{
			x -= 1;
		}
		slope_slide = true;
	}
	
	/* Slide Up Right Slope */
	if (move_dir_x == 0)
	&& (!place_meeting(x + abs(yspd) + 1, y + yspd, obj_wall))
	{
		while (place_meeting(x, y + yspd, obj_wall))
		{
			x += 1;
		}
		slope_slide = true;
	}
	
	/* Normal Y Collide */
	if (!slope_slide)
	{
		/* Scoot up to wall precisely before setting yspd to zero */
		var pixel_check = sub_pixel * sign(yspd);
		while (!place_meeting(x, y + pixel_check, obj_wall))
		{
			y += pixel_check;
		}
		
		/* Set yspd to zero to "collide" after scooting up to a wall */
		yspd = 0;
	}
}
#endregion /* Upwards Y Collision with Ceiling Slopes END */

#region /* Floor Y Collision */
/* Check for solid and semisolid platforms under me */
var clamp_yspd = max(0, yspd);
var list = ds_list_create(); /* Create a DS list to store all of the objects we run into */
var array = array_create(0);
array_push(array, obj_wall, obj_semisolid_wall);

/* Do the actual check and add objects to list */
var list_size = instance_place_list(x, y + 1 + clamp_yspd + move_plat_max_yspd, array, list, false);

/* Fix for high resolution/high speed projects - same principal as how we fixed the downwards slope issue. Check for a semisolid platform below me */
var y_check = y + 1 + clamp_yspd;

if (instance_exists(my_floor_plat))
{
	y_check += max(0, my_floor_plat.yspd);
}
var _semisolid = check_for_semisolid_platform(x, y_check)

/* Loop trought the colliding instances and only return one if it's top is below the player */
for(var i = 0; i < list_size; i++)
{
	/* Get an instance of obj_wall or obj_semisolid_wall from the list */
	var list_inst = list[| i];
	
	/* Avoid magnetism */
	if (list_inst != forget_semisolid
	&& (list_inst.yspd <= yspd || instance_exists(my_floor_plat))
	&& (list_inst.yspd > 0 || place_meeting(x, y + 1 + clamp_yspd, list_inst)))
	|| (list_inst == _semisolid) /* High speed fix */
	{
		/* Return a solid wall or any semisolid walls that are below the player */
		if (list_inst.object_index == obj_wall)
		|| (object_is_ancestor(list_inst.object_index, obj_wall))
		|| (floor(bbox_bottom) <= ceil(list_inst.bbox_top - list_inst.yspd))
		{
			/* Return the "highest" wall object */
			if (!instance_exists(my_floor_plat))
			|| (list_inst.bbox_top + list_inst.yspd <= my_floor_plat.bbox_top + my_floor_plat.yspd)
			|| (list_inst.bbox_top + list_inst.yspd <= my_floor_plat.bbox_bottom)
			{
				my_floor_plat = list_inst;
			}
		}
	}
}
/* Destroy the DS list to avoid a memory leak */
ds_list_destroy(list);

/* Downlope semisolid for making sure we don't miss semisolids while going down slopes */
if (instance_exists(down_slope_semisolid))
{
	my_floor_plat = down_slope_semisolid;
}

/* One last check to make sure the floor platform is actually below us */
if (instance_exists(my_floor_plat))
&& (!place_meeting(x, y + move_plat_max_yspd, my_floor_plat))
{
	my_floor_plat = noone;
}

/* Land on the ground platform if there is one */
if (instance_exists(my_floor_plat))
{
	/* Scoot up to our wall precisely */
	sub_pixel = .5;
	while (!place_meeting(x, y + sub_pixel, my_floor_plat))
	&& (!place_meeting(x, y, obj_wall))
	{
		y += sub_pixel;
	}
	
	/* Make sure we don't end up below the top of a semisolid */
	if (my_floor_plat.object_index == obj_semisolid_wall)
	|| (object_is_ancestor(my_floor_plat.object_index, obj_semisolid_wall))
	{
		while (place_meeting(x, y, my_floor_plat))
		{
			y -= sub_pixel;
		}
	}
	
	/* Floor the y variable */
	y = floor(y);
	
	/* collide with the ground */
	yspd = 0;
	set_on_ground(true);
}

/* Manually fall through a semisolid platform */
if (key_down
&& key_jump_pressed)
{
	/* Make sure we have a floor platform that is a semisolid */
	if (instance_exists(my_floor_plat))
	&& (my_floor_plat.object_index == obj_semisolid_wall
	|| object_is_ancestor(my_floor_plat.object_index, obj_semisolid_wall))
	{
		/* Check if we CAN go below the semisolid */
		y_check = max(1, my_floor_plat.yspd + 1);
		
		if (!place_meeting(x, y + y_check, obj_wall))
		{
			/* Move below the platform */
			y += 1;
			
			/* Inherit any downward speed from my floor platform so it doesn't catch me */
			yspd = y_check - 1;
			
			/* Forget this platform for a brief time so we don't get caught again */
			forget_semisolid = my_floor_plat;
			
			/* No more floor platform */
			set_on_ground(false);
		}
	}
}

/* Y Move */
y += yspd;

/* Reset forget_semisolid variable after moving y position */
if (instance_exists(forget_semisolid))
&& (!place_meeting(x, y, forget_semisolid))
{
	forget_semisolid = noone;
}
#endregion /* Floor Y Collision END */

#region /* Final moving platform collisions and movement */

#region /* X - move_plat_xspd and collision */
/* Get the move_plat_xspd */
move_plat_xspd = 0;
if (instance_exists(my_floor_plat))
{
	move_plat_xspd = my_floor_plat.xspd;
}

/* Move with move_play_xspd */
if (place_meeting(x + move_plat_xspd, y, obj_wall))
{
	/* Scoot up to wall precisely */
	sub_pixel = .5;
	var pixel_check = sub_pixel * sign(move_plat_xspd);
	while (!place_meeting(x + pixel_check, y, obj_wall))
	{
		x += pixel_check;
	}
	
	/* Set move_plat_xspd to 0 to finish collision */
	move_plat_xspd = 0;
}

/* Move x with move_plat_xspd */
x += move_plat_xspd;
#endregion /* X - move_plat_xspd and collision END */

#region /* Y - Snap myself to my_floor_plat if it's moving vertically */
if (instance_exists(my_floor_plat))
&& (my_floor_plat.yspd != 0
|| my_floor_plat.object_index == obj_semisolid_move_plat
|| object_is_ancestor(my_floor_plat.object_index, obj_semisolid_move_plat))
{
	/* Snap to the top of the floor platform (un-floor our y variable so it's not choppy) */
	if (!place_meeting(x, my_floor_plat.bbox_top, obj_wall))
	&& (my_floor_plat.bbox_top >= bbox_bottom - move_plat_max_yspd)
	{
		y = my_floor_plat.bbox_top;
	}
	
	/* Going up into a solid wall while on a semisolid platform */
	if (my_floor_plat.yspd < 0 && (place_meeting(x, y + my_floor_plat.yspd, obj_wall)))
	{
		/* Get pushed down throught the semisolid floor platform */
		if (my_floor_plat.object_index == obj_semisolid_wall)
		|| (object_is_ancestor(my_floor_plat.object_index, obj_semisolid_wall))
		{
			/* Get pushed down through the semisolid */
			sub_pixel = .25;
			while (place_meeting(x, y + my_floor_plat.yspd, obj_wall))
			{
				y += sub_pixel;
			}
			/* If we got pushed into a solid wall while going downwards, push ourselves back out */
			while (place_meeting(x, y, obj_wall))
			{
				y -= sub_pixel;
			}
			y = round(y);
		}
		
		/* Cancel the my_floor_plat variable */
		set_on_ground(false);
	}
}
#endregion /* Y - Snap myself to my_floor_plat if it's moving vertically END */

#endregion /* Final moving platform collisions and movement END */

#endregion /* Y Collision and movement END */

#endregion /* Y Movement END */

#region /* Crouch Movement */
if (key_crouch)
&& (slide == 0)
&& (on_ground)
&& (xspd <= +move_spd[0]
&& xspd >= -move_spd[0])
&& (!kick)
&& (!attack_swing)
&& (!crouch)
{
	crouch = 1; /* Crouch */
	crouch_timer = 0;
}

/* Crouching */
if (crouch == 1)
{
	sprite_index = spr_player_crouch;
	mask_index = spr_player_mask_crouch;
	image_speed = abs(xspd) * 0.1;
	
	if (key_crouch)
	{
		crouch_timer++;
	}
	
	if (crouch_timer >= 10)
	{
		crouch = 2; /* Crawl */
	}
}

/* Crawling */
if (crouch == 2)
{
	sprite_index = spr_player_crawl;
	mask_index = spr_player_mask_slide;
	image_speed = abs(xspd) * 0.1;
}

if (!key_crouch)
&& (crouch != 0)
{
	if (!collision_rectangle(bbox_left, bbox_top - 32, bbox_right, bbox_bottom, obj_wall, true, true))
	{
		crouch_timer = clamp(crouch_timer - 1, 0, 10);
	}
	
	if (crouch_timer <= 0)
	&& (!collision_rectangle(bbox_left, bbox_top - 128, bbox_right, bbox_bottom, obj_wall, true, true))
	{
		crouch = 0;
		mask_index = spr_player_mask;
	}
	else
	if (crouch_timer <= 10)
	&& (!collision_rectangle(bbox_left, bbox_top - 32, bbox_right, bbox_bottom, obj_wall, true, true))
	{
		crouch = 1;
	}
}
#endregion /* Crouch Movement END */

#region /* Slide */
if (key_crouch)
&& (slide == 0)
&& (on_ground)
&& (xspd < -move_spd[0] || xspd > +move_spd[0])
&& (!kick)
&& (!attack_swing)
&& (!crouch)
{
	slide = 1;
	image_index = 0;
	image_speed = 0.5;
}
else
if (slide == 1)
&& (!key_crouch
|| !on_ground
|| (xspd > -move_spd[0] + 1 && xspd < +move_spd[0] - 1))
&& (!collision_rectangle(x - mask_idle_bbox_left, y - mask_idle_bbox_top, x + mask_idle_bbox_right, bbox_bottom, obj_wall, true, true)) /* Needs to be precise for slopes to work */
&& (!kick)
&& (!attack_swing)
&& (!crouch)
{
	slide = 2;
	image_index = image_number - 1;
	image_speed = -0.5;
}
#endregion /* Slide END */

#region /* Kick Move */
if (key_kick_pressed)
&& (slide == 0)
&& (!kick)
&& (!attack_swing)
&& (!crouch)
&& (!in_water)
&& (kick_timer == 0)
{
	kick = true;
	sprite_index = spr_player_kick;
	image_index = 0;
	image_speed = 0.2;
}

if (kick)
{
	kick_timer++;
	
	if (kick_timer == 10)
	&& (!place_meeting(x, y - 1, obj_wall))
	{
		/* The kick flings you upward a little */
		yspd = -5;
		
		/* Tell ourself we're no longer on the ground */
		set_on_ground(false);
	}
	
	if (kick_timer >= 30)
	{
		kick = false;
	}
	
	if (image_index > image_number - 1)
	{
		image_index = image_number - 1;
	}
}

if (on_ground)
&& (kick_timer >= 30)
{
	kick_timer = 0;
}
#endregion /* Kick Move END */

#region /* In Water */
if (in_water)
{
	grav = 0;
	
	/* Determine movement direction vertically underwater */
	move_dir_y = key_down - key_up;
	var target_speed_y = move_dir_y * maxSpeed;
	
	/* Apply momentum physics in up and down movements underwater */
	if (move_dir_y != 0)
	{
	    if (yspd < target_speed_y)
	        yspd = min(yspd + accel, target_speed_y);
	    else if (yspd > target_speed_y)
	        yspd = max(yspd - accel, target_speed_y);
	}
	else
	{
	    /* Decelerate when no directional input is given */
	    if (yspd > 0)
	        yspd = max(yspd - _friction, 0);
	    else if (yspd < 0)
	        yspd = min(yspd + _friction, 0);
	}
	
	#region /* Only rotate if there's some actual movement */
	if (xspd != 0
	|| yspd != 0)
	{
		/* Compute where we want to face */
		var target_ang = point_direction(0, 0, xspd, yspd);
		
		/* Compute the signed shortest difference*/
		var diff = scr_delta_angle(draw_angle, target_ang);
		
		/* 0,0 to (xspd, yspd) gives the direction of the velocity vector */
		draw_angle = target_ang; //lerp(draw_angle, target_ang, 0.2);
	}
	else
	{
		if (draw_angle <= 90)
		&& (face_y != -1)
		{
			draw_angle = lerp(draw_angle, 0, 0.1);
		}
		
		if (draw_angle >= 270)
		&& (face_y != -1)
		{
			draw_angle = lerp(draw_angle, 360, 0.1);
		}
		
		if (draw_angle < 270)
		&& (draw_angle > 90)
		|| (face_y == -1)
		{
			draw_angle = lerp(draw_angle, 180, 0.1);
		}
	}
	#endregion /* Only rotate if there's some actual movement END */
	
	if (draw_angle < 90)
	{
		face_x = 1;
		face_y = +1;
	}
	
	if (draw_angle > 270)
	{
		face_x = 1;
		face_y = +1;
	}
	
	if (draw_angle < 270)
	&& (draw_angle > 90)
	{
		face_x = 1;
		face_y = -1;
	}
	
	sprite_index = spr_player_swim;
	
	if (!place_meeting(x, y, obj_water))
	{
		if (face_y == -1)
		{
			face_x = -1;
		}
		else
		{
			face_x = +1;
		}
		
		face_y = 1;
		draw_angle = 0;
		in_water = false;
		grav = .5; /* Return to normal gravity when out of water */
	}
}
else
{
	face_y = 1;
	
	if (place_meeting(x, y, obj_water))
	{
		in_water = true;
	}
}
#endregion /* In Water END */

#region /* Touching Spikes */
if (!die)
&& (invincibility_frames == 0)
&& (collision_rectangle(bbox_left - 1, bbox_top - 1, bbox_right + 1, bbox_bottom + 1, obj_spike_trap, false, true))
{
	invincibility_frames = 60;
	global.hp -= 0.5;
	
	yspd = -10;
	set_on_ground(false);
}
#endregion /* Touching Spikes END*/

if (global.hp > global.hp_max)
{
	global.hp = global.hp_max;
}

#region /* Sprite Control */
/* Walking Sprite */
if (abs(xspd) > 0)
&& (on_ground)
&& (slide == 0)
&& (!kick)
&& (!attack_swing)
&& (!crouch)
&& (!in_water)
{
	sprite_index = spr_walk;
	image_speed = abs(xspd) * 0.1;
}

/* Running Sprite */
if (abs(xspd) >= move_spd[1])
&& (on_ground)
&& (slide == 0)
&& (!kick)
&& (!attack_swing)
&& (!crouch)
&& (!in_water)
{
	sprite_index = spr_run;
	image_speed = abs(xspd) * 0.1;
}

/* Not Moving Sprite */
if (abs(xspd) == 0)
&& (on_ground)
&& (slide == 0)
&& (!kick)
&& (!attack_swing)
&& (!crouch)
&& (!in_water)
{
	sprite_index = spr_idle;
	image_speed = 0.5;
}

#region /* In the air Sprite */
if (!on_ground)
&& (slide == 0)
&& (!kick)
&& (!attack_swing)
&& (!crouch)
&& (!in_water)
{
	if (yspd < 0)
	&& (what_jump_sprite == 0
	|| what_jump_sprite == 2
	&& image_index > image_number - 1)
	{
		what_jump_sprite = 1;
		
		if (image_index > image_number - 1)
		{
			image_index = 0;
			image_speed = 0.5;
		}
	}
	else
	if (yspd > 0)
	&& (what_jump_sprite == 0
	|| what_jump_sprite == 1
	&& image_index > image_number - 1)
	{
		what_jump_sprite = 2;
		
		if (image_index > image_number - 1)
		{
			image_index = 0;
			image_speed = 0.5;
		}
	}
	
	if (what_jump_sprite == 1)
	{
		sprite_index = spr_jump;
	}
	else
	if (what_jump_sprite == 2)
	{
		sprite_index = spr_fall;
	}
	
	if (image_index > image_number - 1)
	{
		image_index = image_number - 1;
		image_speed = 0;
	}
	else
	
	/* If you are in the upward jumping sprite and falling down, speedup the animation so that it transitions faster into falling sprite */
	if (what_jump_sprite == 1)
	&& (yspd > 0)
	{
		image_speed = 1.5;
	}
	else
	{
		image_speed = 0.5;
	}
}
else
{
	what_jump_sprite = 0;
}
#endregion /* In the air Sprite END */

/* Sliding Sprite */
if (slide == 1)
&& (!kick)
&& (!attack_swing)
&& (!crouch)
&& (!in_water)
{
	sprite_index = spr_slide;
	mask_index = spr_mask_crouch;
	if (image_index > image_number - 1)
	{
		image_index = image_number - 1;
		image_speed = 0;
	}
	else
	{
		image_speed = 0.5;
	}
}
else
if (slide == 2)
&& (!kick)
&& (!attack_swing)
&& (!crouch)
&& (!in_water)
{
	sprite_index = spr_slide;
	mask_index = spr_mask;
	if (image_index <= 0)
	{
		slide = 0;
	}
	else
	{
		image_speed = -0.5;
	}
}
#endregion /* Sprite Control END */

if (!in_water)
{
	draw_angle = lerp(draw_angle, slope_angle, 0.25);
}

if (invincibility_frames != 0)
{
	invincibility_frames = clamp(invincibility_frames -1, 0, 60);
	
	if (invincibility_frames > 30)
	{
		sprite_index = spr_damaged;
		xspd = 0;
		if (yspd > 0)
		{
			yspd = 0;
		}
	}
}

if (global.hp <= 0)
{
	die = true;
	invincibility_frames = 0;
	sprite_index = spr_death;
	can_move = false;
}

scr_player_move_ledgegrab();
scr_player_move_attack_swing();

/// --- universal “use” on LMB ---
if (!obj_camera.inventory_visible
&& !obj_camera.dragging)
{
	// 1) hotbar
	var _hot_id = obj_camera.inventory_id_grid[# obj_camera.selected_hotbar_slot, obj_camera.hotbar_row];
	
	if (mouse_check_button_pressed(mb_left)
	&& _hot_id != 0)
	{
		scr_use_item(_hot_id);
		exit; // prevent double-firing into quick-slots
	}
	
	// 2) diamond quick-slots
	if (key_quick_slot_1
	&& obj_camera.action_id_array[0] != 0)
	{
		scr_use_item(obj_camera.action_id_array[0]);
	}
	
	if (key_quick_slot_2
	&& obj_camera.action_id_array[1] != 0)
	{
		scr_use_item(obj_camera.action_id_array[1]);
	}
	
	if (key_quick_slot_3
	&& obj_camera.action_id_array[2] != 0)
	{
		scr_use_item(obj_camera.action_id_array[2]);
	}
	
	if (key_quick_slot_4
	&& obj_camera.action_id_array[3] != 0)
	{
		scr_use_item(obj_camera.action_id_array[3]);
	}
}