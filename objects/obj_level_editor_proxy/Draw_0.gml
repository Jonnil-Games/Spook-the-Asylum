/// @description Draw the registry preview using the saved transform

var entry = scr_le_registry_get(type_id);
if (is_undefined(entry))
{
	draw_set_alpha(0.8);
	draw_set_color(c_red);
	draw_rectangle(x - 24, y - 24, x + 24, y + 24, false);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(x, y, "?");
	draw_set_alpha(1);
	exit;
}

var preview_sprite = entry.sprite;
if (preview_sprite != -1 && sprite_exists(preview_sprite))
{
	var frames = max(1, sprite_get_number(preview_sprite));
	var frame = ((round(variant) mod frames) + frames) mod frames;
	draw_sprite_ext(preview_sprite, frame, x, y, scale_x, scale_y, rotation, c_white, 0.88);
}

if (instance_exists(obj_level_editor) && obj_level_editor.selected_proxy == id)
{
	draw_set_alpha(0.95);
	draw_set_color(make_color_rgb(255, 215, 70));
	draw_circle(x, y, 12, true);
	draw_circle(x, y, 18, true);
	draw_set_alpha(1);
}

draw_set_color(c_white);
