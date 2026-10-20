/// @description obj_player: Create Event

/* Custom functions for player */
function set_on_ground(val = true)
{
	if (val)
	{
		on_ground = true;
		coyote_hang_timer = coyote_hang_frames;
	}
	else
	{
		/* Before setting the "on ground" variable to false, reset the image index and image speed for the jump animation */
		if (on_ground)
		{
			image_index = 0;
			image_speed = 0.5;
		}
		
		on_ground = false;
		my_floor_plat = noone;
		coyote_hang_timer = 0;
	}
}

function check_for_semisolid_platform(_x, _y)
{
	/* Create a return variable */
	var _rtrn = noone;
	
	/* We must not be moving updwards, and then we check for a normal collision */
	if (yspd >= 0)
	&& (place_meeting(_x, _y, obj_semisolid_wall))
	{
		/* Create a DS list to store all colliding instances of obj_semisolid_wall */
		var list = ds_list_create();
		var list_size = instance_place_list(_x, _y, obj_semisolid_wall, list, false);
		
		/* Loop through the colliding instances and only return one if it's top is below the player */
		for(var i = 0; i < list_size; i++)
		{
			var list_inst = list[| i];
			if (list_inst != forget_semisolid)
			&& (floor(bbox_bottom) <= ceil(list_inst.bbox_top - list_inst.yspd))
			{
				/* Return the id of a semisolid platform */
				_rtrn = list_inst;
				/* Exit the loop early */
				i = list_size;
			}
		}
		
		/* Destroy DS list to free memory */
		ds_list_destroy(list);
	}
	
	/* Return our variable */
	return _rtrn;
}

depth = -30;

player_intro_animation = "";

global.hp = 12;
global.hp_max = 12;
global.piece_of_heart = 0;
invincibility_frames = 0;

/* Control setup */
scr_controls_setup();

/* Sprites */
spr_mask = spr_player_mask;
spr_mask_crouch = spr_player_mask_crouch;
spr_idle = spr_player_idle;
spr_walk = spr_player_walk;
spr_run = spr_player_run;
spr_jump = spr_player_jump;
spr_fall = spr_player_fall;
spr_slide = spr_player_slide;
spr_damaged = spr_player_damaged;
spr_death = spr_player_death;
spr_ledge_hang = spr_player_ledge_hang;
spr_ledge_climb = spr_player_ledge_hang;
spr_attack_swing = spr_player_attack_swing;

mask_index = spr_mask; /* Set the collision mask */
mask_idle_bbox_top = sprite_get_height(spr_mask);
mask_idle_bbox_left = sprite_get_width(spr_mask) * 0.5;
mask_idle_bbox_right = sprite_get_width(spr_mask) * 0.5;

draw_angle = 0;
slope_angle = 0;

/* Moving */
key_jump_pressed = false;
face_x = 1;
face_y = 1;
move_dir_x = 0; /* Move Direction Horizontally */
move_dir_y = 0; /* Move Direction Vertically, for when the character is underwater */
run_type = 0;
move_spd[0] = 4; /* Walk Speed */
move_spd[1] = 8; /* Run Speed */
xspd = 0; /* X Speed */
yspd = 0; /* Y Speed */
in_water = false;
can_move = true;
die = false;
grab_state = 0;
climb_timer = 0;
grab_wall = noone;
ledge_regrab_timer = 0;
attack_swing = false;

/* Moves */
slide = false;
kick = false;
kick_timer = 0;
crouch = false;
crouch_timer = 0;

#region /* Jumping */
grav = .5; /* Gravity */
term_vel = 32; /* Terminal Velocity. Cap falling speed */
on_ground = true;
jump_max = 1; /* How many times you can jump before landing on ground */
jump_count = 0;
jspd = -15; /* Jump Speed */
what_jump_sprite = 0;

/* Coyote Hang Time */
coyote_hang_frames = 2;
coyote_hang_timer = 0;
/* Coyote Jump Buffer Time */
coyote_jump_frames = 5;
coyote_jump_timer = 0;
#endregion /* Jumping END */

/* Moving Platforms */
my_floor_plat = noone;
down_slope_semisolid = noone;
forget_semisolid = noone;
move_plat_xspd = 0;
move_plat_max_yspd = term_vel; /* How fast can the player follow a downwards moving platform */
