/// @description Draw the editor world, grid, bounds, handles, and tool preview

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);
var mouse_world_x = cam_x + (mouse_x_gui / gui_w) * cam_w;
var mouse_world_y = cam_y + (mouse_y_gui / gui_h) * cam_h;
var alt_down = keyboard_check(vk_alt);
var snapped_x = alt_down ? mouse_world_x : round(mouse_world_x / grid_size) * grid_size;
var snapped_y = alt_down ? mouse_world_y : round(mouse_world_y / grid_size) * grid_size;

draw_set_alpha(1);
draw_set_color(make_color_rgb(18, 22, 27));
draw_rectangle(cam_x - 4, cam_y - 4, cam_x + cam_w + 4, cam_y + cam_h + 4, false);

draw_set_color(make_color_rgb(30, 40, 45));
draw_rectangle(0, 0, level_data.width, level_data.height, false);

if (grid_visible)
{
	var first_grid_x = max(0, floor(cam_x / grid_size) * grid_size);
	var final_grid_x = min(level_data.width, ceil((cam_x + cam_w) / grid_size) * grid_size);
	var first_grid_y = max(0, floor(cam_y / grid_size) * grid_size);
	var final_grid_y = min(level_data.height, ceil((cam_y + cam_h) / grid_size) * grid_size);

	draw_set_alpha(0.24);
	draw_set_color(make_color_rgb(150, 190, 184));
	for (var grid_x = first_grid_x; grid_x <= final_grid_x; grid_x += grid_size)
	{
		draw_line(grid_x, first_grid_y, grid_x, final_grid_y);
	}
	for (var grid_y = first_grid_y; grid_y <= final_grid_y; grid_y += grid_size)
	{
		draw_line(first_grid_x, grid_y, final_grid_x, grid_y);
	}
	draw_set_alpha(1);
}

// Playable bounds and draggable resize handles.
draw_set_color(make_color_rgb(245, 91, 95));
draw_set_alpha(0.9);
draw_rectangle(0, 0, level_data.width, level_data.height, true);
draw_rectangle(level_data.width - 10, max(0, cam_y), level_data.width + 10, min(level_data.height, cam_y + cam_h), false);
draw_rectangle(max(0, cam_x), level_data.height - 10, min(level_data.width, cam_x + cam_w), level_data.height + 10, false);
draw_set_alpha(1);

// Player start marker.
var start_x = level_data.player_start.x;
var start_y = level_data.player_start.y;
draw_set_color(make_color_rgb(80, 225, 125));
draw_circle(start_x, start_y, 28, false);
draw_triangle(start_x - 9, start_y - 14, start_x - 9, start_y + 14, start_x + 14, start_y, false);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text(start_x, start_y - 34, "START");

// Goal marker.
var goal_x = level_data.goal.x;
var goal_y = level_data.goal.y;
draw_set_color(make_color_rgb(222, 106, 245));
draw_circle(goal_x, goal_y, 31, true);
draw_circle(goal_x, goal_y, 22, true);
draw_circle(goal_x, goal_y, 10, false);
draw_text(goal_x, goal_y - 36, "EXIT");

if (selected_handle == "start")
{
	draw_set_color(c_yellow);
	draw_circle(start_x, start_y, 38, true);
}
else if (selected_handle == "goal")
{
	draw_set_color(c_yellow);
	draw_circle(goal_x, goal_y, 40, true);
}

// A moving platform's radius is visible instead of hidden in a property value.
if (instance_exists(selected_proxy) && selected_proxy.type_id == "moving_platform")
{
	var radius = 320;
	if (variable_struct_exists(selected_proxy.properties, "radius")) radius = selected_proxy.properties.radius;
	draw_set_alpha(0.55);
	draw_set_color(make_color_rgb(255, 215, 70));
	draw_circle(selected_proxy.x, selected_proxy.y, radius, true);
	draw_line(selected_proxy.x, selected_proxy.y, selected_proxy.x + radius, selected_proxy.y);
	draw_set_alpha(1);
}

// Paint/fill previews are editor-only; real gameplay instances are never active here.
var over_gui = toolbar_visible && (mouse_y_gui <= 124 || mouse_y_gui >= 704 || (instance_exists(selected_proxy) && mouse_x_gui >= 1080));
if (!pause_open && !help_open && !over_gui && (tool == "paint" || tool == "fill") && array_length(category_entries) > 0)
{
	var preview_entry = category_entries[palette_index];
	var preview_sprite = preview_entry.sprite;
	if (preview_sprite != -1 && sprite_exists(preview_sprite))
	{
		var footprint = (tool == "paint" && preview_entry.brush) ? brush_size : 1;
		draw_set_alpha(0.45);
		for (var preview_y = 0; preview_y < footprint; preview_y++)
		{
			for (var preview_x = 0; preview_x < footprint; preview_x++)
			{
				draw_sprite(preview_sprite, 0, snapped_x + preview_x * grid_size, snapped_y + preview_y * grid_size);
			}
		}
		draw_set_alpha(1);
	}
}

if (!over_gui && tool == "erase")
{
	var erase_world_size = erase_size * grid_size;
	draw_set_alpha(0.28);
	draw_set_color(c_red);
	draw_rectangle(snapped_x - erase_world_size * 0.5, snapped_y - erase_world_size * 0.5,
		snapped_x + erase_world_size * 0.5, snapped_y + erase_world_size * 0.5, false);
	draw_set_alpha(1);
}

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
