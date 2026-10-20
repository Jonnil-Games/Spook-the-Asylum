/// @description Editor input, camera, tools, history, and autosave

if (capture_complete && exit_after_capture)
{
	global.le_current_folder = level_data.folder;
	global.le_browser_screen = "gallery";
	room_goto(room_level_browser);
	exit;
}

if (status_until != 0 && current_time >= status_until)
{
	status_text = "";
	status_until = 0;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);
var left_pressed = mouse_check_button_pressed(mb_left);
var left_down = mouse_check_button(mb_left);
var left_released = mouse_check_button_released(mb_left);
var right_pressed = mouse_check_button_pressed(mb_right);
var right_down = mouse_check_button(mb_right);
var right_released = mouse_check_button_released(mb_right);
var alt_down = keyboard_check(vk_alt);
var ctrl_down = keyboard_check(vk_control);
var shift_down = keyboard_check(vk_shift);

var mouse_world_x = cam_x + (mouse_x_gui / gui_w) * cam_w;
var mouse_world_y = cam_y + (mouse_y_gui / gui_h) * cam_h;
var snapped_x = alt_down ? mouse_world_x : round(mouse_world_x / grid_size) * grid_size;
var snapped_y = alt_down ? mouse_world_y : round(mouse_world_y / grid_size) * grid_size;
snapped_x = clamp(snapped_x, 0, level_data.width);
snapped_y = clamp(snapped_y, 0, level_data.height);

if (folder_modal_open)
{
	var can_copy_folder_path = scr_le_folder_clipboard_is_enabled();
	var folder_back_y1 = can_copy_folder_path ? 616 : 590;
	var folder_back_y2 = can_copy_folder_path ? 664 : 638;
	if (keyboard_check_pressed(vk_escape)
	||  keyboard_check_pressed(vk_enter)
	||  right_pressed
	||  gamepad_button_check_pressed(0, gp_face2)
	||  (left_pressed && point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, folder_back_y1, 868, folder_back_y2)))
	{
		folder_modal_open = false;
	}
	else if (can_copy_folder_path
	&& left_pressed
	&& point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 562, 868, 608))
	{
		clipboard_set_text(global.le_root);
		folder_copied_until = current_time + 1500;
		set_status("The uncensored folder path was copied.");
	}
	exit;
}

// Help is intentionally generated from the active editor behavior, not copied from Sticky Paws.
if (help_open)
{
	if (keyboard_check_pressed(vk_escape)
	||  keyboard_check_pressed(vk_f1)
	||  (left_pressed && point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 674, 888, 724)))
	{
		help_open = false;
	}
	exit;
}

if (pause_open)
{
	if (keyboard_check_pressed(vk_escape))
	{
		pause_open = false;
		exit;
	}

	if (left_pressed)
	{
		if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 238, 888, 282))
		{
			pause_open = false;
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 290, 888, 334))
		{
			save_now();
			pause_open = false;
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 342, 888, 386))
		{
			request_save_and_quit();
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 394, 888, 438))
		{
			pause_open = false;
			begin_playtest("quick", true);
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 446, 888, 490))
		{
			pause_open = false;
			begin_playtest("clear", false);
		}
		else if (scr_le_folder_opening_is_enabled()
		&& point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 498, 888, 542))
		{
			folder_open_result = scr_le_open_levels_folder();
			folder_copied_until = 0;
			folder_modal_open = true;
			pause_open = false;
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 550, 888, 594))
		{
			if (!dirty || save_now("Saved before returning to the gallery."))
			{
				global.le_current_folder = level_data.folder;
				global.le_browser_screen = "gallery";
				room_goto(room_level_browser);
			}
		}
	}
	exit;
}

if (keyboard_check_pressed(vk_f1))
{
	help_open = true;
	exit;
}
if (keyboard_check_pressed(vk_escape))
{
	pause_open = true;
	exit;
}

if (ctrl_down && keyboard_check_pressed(ord("S"))) save_now();
if (ctrl_down && keyboard_check_pressed(ord("Z"))) undo_edit();
if (ctrl_down && keyboard_check_pressed(ord("Y"))) redo_edit();

if (keyboard_check_pressed(vk_f5) || (keyboard_check_pressed(vk_enter) && !ctrl_down))
{
	begin_playtest("quick", !shift_down);
	exit;
}

if (keyboard_check_pressed(ord("T"))) toolbar_visible = !toolbar_visible;
if (keyboard_check_pressed(ord("G"))) grid_visible = !grid_visible;

if (keyboard_check_pressed(ord("P")))
{
	if (tool == "paint") brush_size = (brush_size mod 6) + 1;
	else tool = "paint";
}
if (keyboard_check_pressed(ord("E")))
{
	if (tool == "erase") erase_size = (erase_size mod 6) + 1;
	else tool = "erase";
}
if (keyboard_check_pressed(ord("F")))
{
	if (tool == "fill") fill_mode = (fill_mode + 1) mod 3;
	else tool = "fill";
}
if (keyboard_check_pressed(ord("V"))) tool = "select";

// Palette selection supports the same quick 1/2 and wheel rhythm as the reference editor.
var previous_palette = keyboard_check_pressed(ord("1")) || gamepad_button_check_pressed(0, gp_shoulderl);
var next_palette = keyboard_check_pressed(ord("2")) || gamepad_button_check_pressed(0, gp_shoulderr);
if (!stroke_active && !dragging_proxy && dragging_handle == "")
{
	previous_palette = previous_palette || mouse_wheel_up();
	next_palette = next_palette || mouse_wheel_down();
}

if (array_length(category_entries) > 0)
{
	if (previous_palette)
	{
		palette_index--;
		if (palette_index < 0)
		{
			category_index = (category_index + array_length(categories) - 1) mod array_length(categories);
			rebuild_category_entries();
			palette_index = max(0, array_length(category_entries) - 1);
		}
	}
	if (next_palette)
	{
		palette_index++;
		if (palette_index >= array_length(category_entries))
		{
			category_index = (category_index + 1) mod array_length(categories);
			rebuild_category_entries();
			palette_index = 0;
		}
	}
}

// GUI controls. No click that activates chrome is allowed to fall through into the world.
var gui_consumed = false;
if (toolbar_visible && left_pressed)
{
	// Category tabs.
	for (var category_button = 0; category_button < array_length(categories); category_button++)
	{
		var category_x1 = 18 + category_button * 132;
		if (point_in_rectangle(mouse_x_gui, mouse_y_gui, category_x1, 8, category_x1 + 122, 38))
		{
			category_index = category_button;
			palette_index = 0;
			rebuild_category_entries();
			gui_consumed = true;
			break;
		}
	}

	// Palette cells.
	if (!gui_consumed)
	{
		for (var palette_button = 0; palette_button < array_length(category_entries); palette_button++)
		{
			var palette_x1 = 18 + palette_button * 96;
			if (point_in_rectangle(mouse_x_gui, mouse_y_gui, palette_x1, 44, palette_x1 + 88, 118))
			{
				palette_index = palette_button;
				tool = "paint";
				gui_consumed = true;
				break;
			}
		}
	}

	// View buttons.
	if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1120, 8, 1174, 38))
	{
		grid_visible = !grid_visible;
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1180, 8, 1234, 38))
	{
		var old_w = cam_w;
		cam_w = min(3840, cam_w * 1.2);
		cam_h = cam_w * (768 / 1366);
		cam_x -= (cam_w - old_w) * 0.5;
		cam_y -= (cam_w - old_w) * (768 / 1366) * 0.5;
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1240, 8, 1294, 38))
	{
		cam_w = 1366;
		cam_h = 768;
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1300, 8, 1354, 38))
	{
		var old_w_zoom = cam_w;
		cam_w = max(696, cam_w / 1.2);
		cam_h = cam_w * (768 / 1366);
		cam_x += (old_w_zoom - cam_w) * 0.5;
		cam_y += (old_w_zoom - cam_w) * (768 / 1366) * 0.5;
		gui_consumed = true;
	}

	// Bottom tool buttons.
	if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 18, 714, 140, 758))
	{
		tool = "select";
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 148, 714, 270, 758))
	{
		if (tool == "paint") brush_size = (brush_size mod 6) + 1;
		else tool = "paint";
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 278, 714, 400, 758))
	{
		if (tool == "erase") erase_size = (erase_size mod 6) + 1;
		else tool = "erase";
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 408, 714, 530, 758))
	{
		if (tool == "fill") fill_mode = (fill_mode + 1) mod 3;
		else tool = "fill";
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 538, 714, 660, 758))
	{
		save_now();
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 668, 714, 790, 758))
	{
		begin_playtest("quick", true);
		gui_consumed = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 798, 714, 920, 758))
	{
		pause_open = true;
		gui_consumed = true;
	}
}

// Inspector mutations use one central history/dirty path.
if (toolbar_visible && instance_exists(selected_proxy) && left_pressed && mouse_x_gui >= 1088 && mouse_y_gui >= 142 && mouse_y_gui <= 690)
{
	gui_consumed = true;
	var changed_property = false;
	if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1110, 250, 1160, 286))
	{
		push_history();
		selected_proxy.scale_x = sign(selected_proxy.scale_x) * max(0.25, abs(selected_proxy.scale_x) - 0.25);
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1294, 250, 1344, 286))
	{
		push_history();
		selected_proxy.scale_x = sign(selected_proxy.scale_x) * min(16, abs(selected_proxy.scale_x) + 0.25);
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1202, 250, 1252, 286))
	{
		push_history();
		selected_proxy.scale_x *= -1;
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1110, 300, 1160, 336))
	{
		push_history();
		selected_proxy.scale_y = sign(selected_proxy.scale_y) * max(0.25, abs(selected_proxy.scale_y) - 0.25);
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1294, 300, 1344, 336))
	{
		push_history();
		selected_proxy.scale_y = sign(selected_proxy.scale_y) * min(16, abs(selected_proxy.scale_y) + 0.25);
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1202, 300, 1252, 336))
	{
		push_history();
		selected_proxy.scale_y *= -1;
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1110, 350, 1160, 386))
	{
		push_history();
		selected_proxy.rotation = (selected_proxy.rotation - 15 + 360) mod 360;
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1294, 350, 1344, 386))
	{
		push_history();
		selected_proxy.rotation = (selected_proxy.rotation + 15) mod 360;
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1110, 400, 1160, 436))
	{
		push_history();
		selected_proxy.variant = max(0, selected_proxy.variant - 1);
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1294, 400, 1344, 436))
	{
		push_history();
		var selected_entry = scr_le_registry_get(selected_proxy.type_id);
		var variant_count = (is_undefined(selected_entry) || selected_entry.sprite == -1) ? 1 : max(1, sprite_get_number(selected_entry.sprite));
		selected_proxy.variant = (selected_proxy.variant + 1) mod variant_count;
		changed_property = true;
	}
	else if (selected_proxy.type_id == "moving_platform"
	&& point_in_rectangle(mouse_x_gui, mouse_y_gui, 1110, 450, 1160, 486))
	{
		push_history();
		if (!variable_struct_exists(selected_proxy.properties, "radius")) selected_proxy.properties.radius = 320;
		selected_proxy.properties.radius = max(0, selected_proxy.properties.radius - 64);
		changed_property = true;
	}
	else if (selected_proxy.type_id == "moving_platform"
	&& point_in_rectangle(mouse_x_gui, mouse_y_gui, 1294, 450, 1344, 486))
	{
		push_history();
		if (!variable_struct_exists(selected_proxy.properties, "radius")) selected_proxy.properties.radius = 320;
		selected_proxy.properties.radius = min(2048, selected_proxy.properties.radius + 64);
		changed_property = true;
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 1110, 620, 1344, 666))
	{
		push_history();
		with (selected_proxy) instance_destroy();
		selected_proxy = noone;
		changed_property = true;
	}

	if (changed_property) mark_dirty();
}

if (keyboard_check_pressed(vk_delete) && instance_exists(selected_proxy))
{
	push_history();
	with (selected_proxy) instance_destroy();
	selected_proxy = noone;
	mark_dirty();
}

// Camera pan and keyboard motion.
if (mouse_check_button_pressed(mb_middle) || (keyboard_check(vk_space) && left_pressed && !gui_consumed))
{
	panning = true;
	pan_mouse_x = mouse_x_gui;
	pan_mouse_y = mouse_y_gui;
	pan_cam_x = cam_x;
	pan_cam_y = cam_y;
}
if (panning)
{
	var pan_button_down = mouse_check_button(mb_middle) || (keyboard_check(vk_space) && left_down);
	if (pan_button_down)
	{
		cam_x = pan_cam_x - (mouse_x_gui - pan_mouse_x) * (cam_w / gui_w);
		cam_y = pan_cam_y - (mouse_y_gui - pan_mouse_y) * (cam_h / gui_h);
	}
	else
	{
		panning = false;
	}
}
else
{
	var move_speed = shift_down ? 2 : (ctrl_down ? 24 : 8);
	move_speed *= cam_w / 1366;
	var move_x = keyboard_check(ord("D")) + keyboard_check(vk_right) - keyboard_check(ord("A")) - keyboard_check(vk_left);
	var move_y = keyboard_check(ord("S")) + keyboard_check(vk_down) - keyboard_check(ord("W")) - keyboard_check(vk_up);
	cam_x += clamp(move_x, -1, 1) * move_speed;
	cam_y += clamp(move_y, -1, 1) * move_speed;
}

if (keyboard_check_pressed(vk_subtract) || keyboard_check_pressed(ord("-")))
{
	var old_view_w = cam_w;
	cam_w = min(3840, cam_w * 1.2);
	cam_h = cam_w * (768 / 1366);
	cam_x -= (cam_w - old_view_w) * 0.5;
	cam_y -= (cam_w - old_view_w) * (768 / 1366) * 0.5;
}
if (keyboard_check_pressed(vk_add) || keyboard_check_pressed(ord("+")))
{
	var old_view_w_in = cam_w;
	cam_w = max(696, cam_w / 1.2);
	cam_h = cam_w * (768 / 1366);
	cam_x += (old_view_w_in - cam_w) * 0.5;
	cam_y += (old_view_w_in - cam_w) * (768 / 1366) * 0.5;
}
if (ctrl_down && keyboard_check_pressed(vk_enter))
{
	cam_w = 1366;
	cam_h = 768;
}

cam_x = clamp(cam_x, 0, max(0, room_width - cam_w));
cam_y = clamp(cam_y, 0, max(0, room_height - cam_h));
camera_set_view_size(view_camera[0], cam_w, cam_h);
camera_set_view_pos(view_camera[0], cam_x, cam_y);

var over_top_gui = toolbar_visible && mouse_y_gui <= 124;
var over_bottom_gui = toolbar_visible && mouse_y_gui >= 704;
var over_inspector = toolbar_visible && instance_exists(selected_proxy) && mouse_x_gui >= 1080;
var world_allowed = !gui_consumed && !over_top_gui && !over_bottom_gui && !over_inspector && !panning;

// Select and drag proxies or essential handles.
if (tool == "select" && world_allowed && left_pressed)
{
	var world_pixel_radius = 28 * (cam_w / gui_w);
	if (point_distance(mouse_world_x, mouse_world_y, level_data.player_start.x, level_data.player_start.y) <= world_pixel_radius)
	{
		push_history();
		selected_proxy = noone;
		selected_handle = "start";
		dragging_handle = "start";
	}
	else if (point_distance(mouse_world_x, mouse_world_y, level_data.goal.x, level_data.goal.y) <= world_pixel_radius)
	{
		push_history();
		selected_proxy = noone;
		selected_handle = "goal";
		dragging_handle = "goal";
	}
	else if (abs(mouse_world_x - level_data.width) <= world_pixel_radius && mouse_world_y >= 0 && mouse_world_y <= level_data.height)
	{
		push_history();
		selected_proxy = noone;
		selected_handle = "width";
		dragging_handle = "width";
	}
	else if (abs(mouse_world_y - level_data.height) <= world_pixel_radius && mouse_world_x >= 0 && mouse_world_x <= level_data.width)
	{
		push_history();
		selected_proxy = noone;
		selected_handle = "height";
		dragging_handle = "height";
	}
	else
	{
		var hit_proxy = proxy_at(mouse_world_x, mouse_world_y);
		selected_proxy = hit_proxy;
		selected_handle = "";
		if (instance_exists(hit_proxy))
		{
			push_history();
			dragging_proxy = true;
			drag_offset_x = mouse_world_x - hit_proxy.x;
			drag_offset_y = mouse_world_y - hit_proxy.y;
			drag_changed = false;
		}
	}
}

if (dragging_proxy && instance_exists(selected_proxy))
{
	if (left_down)
	{
		var target_x = mouse_world_x - drag_offset_x;
		var target_y = mouse_world_y - drag_offset_y;
		if (!alt_down)
		{
			target_x = round(target_x / grid_size) * grid_size;
			target_y = round(target_y / grid_size) * grid_size;
		}
		target_x = clamp(target_x, 0, level_data.width);
		target_y = clamp(target_y, 0, level_data.height);
		if (selected_proxy.x != target_x || selected_proxy.y != target_y)
		{
			selected_proxy.x = target_x;
			selected_proxy.y = target_y;
			drag_changed = true;
			mark_dirty();
		}
	}
	else
	{
		dragging_proxy = false;
	}
}

if (dragging_handle != "")
{
	if (left_down)
	{
		var handle_x = alt_down ? mouse_world_x : round(mouse_world_x / grid_size) * grid_size;
		var handle_y = alt_down ? mouse_world_y : round(mouse_world_y / grid_size) * grid_size;
		switch (dragging_handle)
		{
			case "start":
				level_data.player_start.x = clamp(handle_x, 0, level_data.width);
				level_data.player_start.y = clamp(handle_y, 0, level_data.height);
				break;
			case "goal":
				level_data.goal.x = clamp(handle_x, 0, level_data.width);
				level_data.goal.y = clamp(handle_y, 0, level_data.height);
				break;
			case "width":
				level_data.width = clamp(round(handle_x / grid_size) * grid_size,
					global.le_limits.min_width, global.le_limits.max_width);
				level_data.dimensions.width = level_data.width;
				room_width = max(1366, level_data.width + 1024);
				level_data.player_start.x = min(level_data.player_start.x, level_data.width);
				level_data.goal.x = min(level_data.goal.x, level_data.width);
				break;
			case "height":
				level_data.height = clamp(round(handle_y / grid_size) * grid_size,
					global.le_limits.min_height, global.le_limits.max_height);
				level_data.dimensions.height = level_data.height;
				room_height = max(768, level_data.height + 1024);
				level_data.player_start.y = min(level_data.player_start.y, level_data.height);
				level_data.goal.y = min(level_data.goal.y, level_data.height);
				break;
		}
		mark_dirty();
	}
	else
	{
		dragging_handle = "";
	}
}

// Paint stroke.
if (tool == "paint" && world_allowed && left_pressed)
{
	push_history();
	stroke_active = true;
}
if (tool == "paint" && stroke_active && world_allowed && left_down && array_length(category_entries) > 0)
{
	var paint_entry = category_entries[palette_index];
	var footprint = paint_entry.brush ? brush_size : 1;
	for (var brush_y = 0; brush_y < footprint; brush_y++)
	{
		for (var brush_x = 0; brush_x < footprint; brush_x++)
		{
			var placed = create_proxy(paint_entry, snapped_x + brush_x * grid_size, snapped_y + brush_y * grid_size);
			if (instance_exists(placed)) selected_proxy = placed;
		}
	}
}

// Erase is a tool or a temporary right-button gesture.
var erasing_now = (tool == "erase" && left_down) || right_down;
var erase_started = (tool == "erase" && left_pressed) || right_pressed;
if (world_allowed && erase_started)
{
	push_history();
	stroke_active = true;
}
if (world_allowed && erasing_now)
{
	var erase_footprint = (tool == "erase") ? erase_size : 1;
	var erase_radius = grid_size * erase_footprint * 0.5;
	var proxy_count = instance_number(obj_level_editor_proxy);
	for (var erase_index = proxy_count - 1; erase_index >= 0; erase_index--)
	{
		var erase_proxy = instance_find(obj_level_editor_proxy, erase_index);
		if (proxy_contains_point(erase_proxy, mouse_world_x, mouse_world_y)
		|| (abs(erase_proxy.x - snapped_x) <= erase_radius && abs(erase_proxy.y - snapped_y) <= erase_radius))
		{
			if (selected_proxy == erase_proxy) selected_proxy = noone;
			with (erase_proxy) instance_destroy();
			mark_dirty();
		}
	}
}

// Fill affects the visible grid only and enforces the part limit before every creation.
if (tool == "fill" && world_allowed && left_pressed && array_length(category_entries) > 0)
{
	push_history();
	var fill_entry = category_entries[palette_index];
	var min_grid_x = max(0, floor(cam_x / grid_size) * grid_size);
	var max_grid_x = min(level_data.width, ceil((cam_x + cam_w) / grid_size) * grid_size);
	var min_grid_y = max(0, floor(cam_y / grid_size) * grid_size);
	var max_grid_y = min(level_data.height, ceil((cam_y + cam_h) / grid_size) * grid_size);

	if (fill_mode == 1)
	{
		min_grid_y = snapped_y;
		max_grid_y = snapped_y;
	}
	else if (fill_mode == 2)
	{
		min_grid_x = snapped_x;
		max_grid_x = snapped_x;
	}

	for (var fill_y = min_grid_y; fill_y <= max_grid_y; fill_y += grid_size)
	{
		for (var fill_x = min_grid_x; fill_x <= max_grid_x; fill_x += grid_size)
		{
			if (part_placement_count() >= global.le_max_parts) break;
			create_proxy(fill_entry, fill_x, fill_y);
		}
		if (part_placement_count() >= global.le_max_parts) break;
	}
	var fill_labels = ["area", "row", "column"];
	set_status("Filled the visible " + fill_labels[fill_mode] + ".");
}

if (left_released || right_released) stroke_active = false;

// Autosave uses elapsed wall-clock time and never fires during a gesture.
if (dirty && current_time >= autosave_at && !stroke_active && !dragging_proxy && dragging_handle == "")
{
	save_now("Autosaved.");
}
