/// @description obj_player: Draw Event

/* Draw myself */
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * face_x, image_yscale * face_y, draw_angle, image_blend, image_alpha);

if (attack_swing)
{
	draw_sprite_ext(spr_axe_swing, image_index, x, y, image_xscale * face_x, image_yscale * face_y, draw_angle, image_blend, image_alpha);
}

if (invincibility_frames % 2 == 0)
{
	image_alpha = 1;
}
else
{
	image_alpha = 0.1;
}

if (obj_debug_manager.debug_screen)
{
	draw_text_color(x, y - 200, "slide: " + string(slide), c_white, c_white, c_white, c_white, 1);
	
	draw_set_alpha(0.5);
	draw_rectangle_color(bbox_left, bbox_top, bbox_right, bbox_bottom, c_red, c_red, c_red, c_red, false);
	draw_set_alpha(1);
	
	scr_player_draw_ledgegrab_sensors();
}

scr_get_slope_angle();