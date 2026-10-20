/// @description Draw editor chrome, inspector, status, help, and pause menu

if (capture_pending)
{
	var thumbnail_path = global.le_root + level_data.folder + "/automatic_thumbnail.png";
	if (scr_le_capture_thumbnail(thumbnail_path))
	{
		set_status("Saved level and 16:9 thumbnail.");
	}
	else
	{
		set_status("The level saved, but its thumbnail could not be captured.", 5000);
	}
	capture_pending = false;
	capture_complete = true;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
mouse_x_gui = device_mouse_x_to_gui(0);
mouse_y_gui = device_mouse_y_to_gui(0);

var draw_editor_button = function(_x1, _y1, _x2, _y2, _label, _active = false, _enabled = true)
{
	var hovered = point_in_rectangle(mouse_x_gui, mouse_y_gui, _x1, _y1, _x2, _y2);
	var fill = make_color_rgb(53, 48, 65);
	if (_active || hovered) fill = make_color_rgb(110, 72, 126);
	if (!_enabled) fill = make_color_rgb(38, 38, 43);
	draw_set_color(fill);
	draw_roundrect(_x1, _y1, _x2, _y2, false);
	draw_set_color(_enabled ? c_white : make_color_rgb(130, 130, 135));
	draw_roundrect(_x1, _y1, _x2, _y2, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text((_x1 + _x2) * 0.5, (_y1 + _y2) * 0.5, _label);
}

if (!toolbar_visible)
{
	draw_set_alpha(0.85);
	draw_set_color(c_black);
	draw_roundrect(12, 12, 170, 48, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(91, 30, "T: Show Toolbar");
}
else
{
	// Top palette panel.
	draw_set_alpha(0.92);
	draw_set_color(make_color_rgb(12, 11, 17));
	draw_rectangle(0, 0, gui_w, 124, false);
	draw_set_alpha(1);

	for (var category_button = 0; category_button < array_length(categories); category_button++)
	{
		var category_x1 = 18 + category_button * 132;
		draw_editor_button(category_x1, 8, category_x1 + 122, 38, categories[category_button], category_button == category_index);
	}

	for (var palette_button = 0; palette_button < array_length(category_entries); palette_button++)
	{
		var palette_x1 = 18 + palette_button * 96;
		var palette_x2 = palette_x1 + 88;
		var active = palette_button == palette_index;
		draw_set_color(active ? make_color_rgb(110, 72, 126) : make_color_rgb(47, 43, 55));
		draw_rectangle(palette_x1, 44, palette_x2, 118, false);
		draw_set_color(active ? c_yellow : make_color_rgb(135, 130, 145));
		draw_rectangle(palette_x1, 44, palette_x2, 118, true);

		var entry = category_entries[palette_button];
		if (entry.sprite != -1 && sprite_exists(entry.sprite))
		{
			var sprite_w = sprite_get_width(entry.sprite);
			var sprite_h = sprite_get_height(entry.sprite);
			var icon_scale = min(54 / max(1, sprite_w), 46 / max(1, sprite_h));
			var icon_x = (palette_x1 + palette_x2) * 0.5 - (sprite_w * 0.5 - sprite_get_xoffset(entry.sprite)) * icon_scale;
			var icon_y = 68 - (sprite_h * 0.5 - sprite_get_yoffset(entry.sprite)) * icon_scale;
			draw_sprite_ext(entry.sprite, 0, icon_x, icon_y, icon_scale, icon_scale, 0, c_white, 1);
		}
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_text_ext((palette_x1 + palette_x2) * 0.5, 116, entry.label, 12, 84);
	}

	draw_editor_button(1120, 8, 1174, 38, grid_visible ? "Grid" : "No Grid", grid_visible);
	draw_editor_button(1180, 8, 1234, 38, "-", false);
	draw_editor_button(1240, 8, 1294, 38, "1:1", false);
	draw_editor_button(1300, 8, 1354, 38, "+", false);

	// Bottom tool panel.
	draw_set_alpha(0.92);
	draw_set_color(make_color_rgb(12, 11, 17));
	draw_rectangle(0, 704, gui_w, gui_h, false);
	draw_set_alpha(1);
	draw_editor_button(18, 714, 140, 758, "Select [V]", tool == "select");
	draw_editor_button(148, 714, 270, 758, "Paint " + string(brush_size) + " [P]", tool == "paint");
	draw_editor_button(278, 714, 400, 758, "Erase " + string(erase_size) + " [E]", tool == "erase");
	var fill_names = ["Full", "Row", "Column"];
	draw_editor_button(408, 714, 530, 758, "Fill " + fill_names[fill_mode] + " [F]", tool == "fill");
	draw_editor_button(538, 714, 660, 758, "Save", false);
	draw_editor_button(668, 714, 790, 758, "Quick Test", false);
	draw_editor_button(798, 714, 920, 758, "Pause", false);

	draw_set_halign(fa_right);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(gui_w - 16, 726, string(part_placement_count()) + "/" + string(global.le_max_parts) + " parts");
	draw_text(gui_w - 16, 748, "Grid " + string(grid_size) + "  View " + string(round(cam_w)) + "x" + string(round(cam_h)));

	// Selected object property inspector.
	if (instance_exists(selected_proxy))
	{
		var selected_entry = scr_le_registry_get(selected_proxy.type_id);
		draw_set_alpha(0.94);
		draw_set_color(make_color_rgb(20, 18, 28));
		draw_roundrect(1088, 136, 1356, 690, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_roundrect(1088, 136, 1356, 690, true);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed(1222, 164, is_undefined(selected_entry) ? selected_proxy.type_id : selected_entry.label, 1.2, 1.2, 0);
		draw_set_color(make_color_rgb(190, 225, 216));
		draw_text(1222, 198, "x " + string(round(selected_proxy.x)) + "   y " + string(round(selected_proxy.y)));

		draw_set_color(c_white);
		draw_text(1222, 232, "Scale X: " + string(selected_proxy.scale_x));
		draw_editor_button(1110, 250, 1160, 286, "-", false);
		draw_editor_button(1202, 250, 1252, 286, "Flip", false);
		draw_editor_button(1294, 250, 1344, 286, "+", false);

		draw_text(1222, 282, "Scale Y: " + string(selected_proxy.scale_y));
		draw_editor_button(1110, 300, 1160, 336, "-", false);
		draw_editor_button(1202, 300, 1252, 336, "Flip", false);
		draw_editor_button(1294, 300, 1344, 336, "+", false);

		draw_text(1222, 332, "Rotation: " + string(selected_proxy.rotation));
		draw_editor_button(1110, 350, 1160, 386, "-15", false);
		draw_editor_button(1294, 350, 1344, 386, "+15", false);

		draw_text(1222, 382, "Visual variant: " + string(selected_proxy.variant));
		draw_editor_button(1110, 400, 1160, 436, "<", false);
		draw_editor_button(1294, 400, 1344, 436, ">", false);

		if (selected_proxy.type_id == "moving_platform")
		{
			var radius = variable_struct_exists(selected_proxy.properties, "radius") ? selected_proxy.properties.radius : 320;
			draw_text(1222, 432, "Orbit radius: " + string(radius));
			draw_editor_button(1110, 450, 1160, 486, "-64", false);
			draw_editor_button(1294, 450, 1344, 486, "+64", false);
		}

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(make_color_rgb(190, 190, 200));
		if (!is_undefined(selected_entry)) draw_text_ext(1106, 512, selected_entry.help, 18, 232);
		draw_editor_button(1110, 620, 1344, 666, "Delete Selected", false);
	}
}

// Context text remains available even when the toolbar is hidden.
if (status_text != "")
{
	draw_set_alpha(0.94);
	draw_set_color(make_color_rgb(12, 11, 17));
	draw_roundrect(360, 648, 1006, 694, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(683, 671, status_text);
}

if (pause_open || help_open || folder_modal_open)
{
	draw_set_alpha(0.78);
	draw_set_color(c_black);
	draw_rectangle(0, 0, gui_w, gui_h, false);
	draw_set_alpha(1);
}

if (pause_open)
{
	draw_set_color(make_color_rgb(31, 25, 41));
	draw_roundrect(438, 166, 928, 642, false);
	draw_set_color(c_white);
	draw_roundrect(438, 166, 928, 642, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed(683, 204, "Level Editor", 1.45, 1.45, 0);
	draw_editor_button(478, 238, 888, 282, "Continue", false);
	draw_editor_button(478, 290, 888, 334, "Save", false);
	draw_editor_button(478, 342, 888, 386, "Save and Quit", false);
	draw_editor_button(478, 394, 888, 438, "Quick Test from View", false);
	draw_editor_button(478, 446, 888, 490, "Verify from Start", false);
	draw_editor_button(478, 498, 888, 542, "Open Custom Levels Folder", false, scr_le_folder_opening_is_enabled());
	draw_editor_button(478, 550, 888, 594, "Return to Gallery", false);
}

if (folder_modal_open)
{
	var can_copy_folder_path = scr_le_folder_clipboard_is_enabled();
	draw_set_color(make_color_rgb(31, 25, 41));
	draw_roundrect(390, 200, 976, 704, false);
	draw_set_color(c_white);
	draw_roundrect(390, 200, 976, 704, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed(683, 246, "Custom Levels Folder", 1.35, 1.35, 0);
	draw_set_valign(fa_top);
	draw_text_ext(683, 288, scr_le_folder_modal_text(folder_open_result), 22, 500);
	draw_set_color(make_color_rgb(190, 225, 216));
	draw_text_ext(683, 442, scr_le_censored_path(global.le_root), 22, 520);
	draw_set_valign(fa_middle);
	if (folder_copied_until > current_time)
	{
		draw_set_color(c_lime);
		draw_text(683, 536, "Copied");
	}
	if (can_copy_folder_path)
	{
		draw_editor_button(498, 562, 868, 608, "Copy to Clipboard");
		draw_editor_button(498, 616, 868, 664, "Back");
	}
	else
	{
		draw_editor_button(498, 590, 868, 638, "Back");
	}
}

if (help_open)
{
	draw_set_color(make_color_rgb(31, 25, 41));
	draw_roundrect(210, 42, 1156, 738, false);
	draw_set_color(c_white);
	draw_roundrect(210, 42, 1156, 738, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed(683, 78, "Level Editor Help", 1.5, 1.5, 0);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_text_ext(250, 120,
		"TOOLS\n"
		+ "V: Select and drag objects, START, EXIT, width, or height\n"
		+ "P: Paint; press again for brush sizes 1-6\n"
		+ "E: Erase; press again for sizes 1-6\n"
		+ "F: Fill visible area, row, or column\n"
		+ "Right mouse: temporary one-cell erase\n"
		+ "Alt: bypass the 128-pixel snap while placing or dragging\n\n"
		+ "VIEW\n"
		+ "WASD or arrows: pan   Shift: slow   Ctrl: fast\n"
		+ "Middle-drag or Space + left-drag: pan\n"
		+ "+/-: zoom   Ctrl+Enter: reset zoom   G: grid   T: toolbar\n\n"
		+ "WORKFLOW\n"
		+ "1/2 or mouse wheel: previous/next palette item\n"
		+ "Ctrl+S: save   Ctrl+Z/Y: undo/redo\n"
		+ "F5 or Enter: quick test from view; hold Shift to start at START\n"
		+ "Escape: pause, save/quit, folder, or verification\n"
		+ "F1: open or close this help",
		22, 866);

	draw_editor_button(478, 674, 888, 724, "Close Help", false);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
