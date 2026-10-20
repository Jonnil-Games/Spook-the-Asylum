/// @description Draw main menu, gallery, and modal panels

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
mouse_x_gui = device_mouse_x_to_gui(0);
mouse_y_gui = device_mouse_y_to_gui(0);

draw_set_alpha(1);
draw_set_color(make_color_rgb(16, 12, 24));
draw_rectangle(0, 0, gui_w, gui_h, false);

// Subtle asylum bars in the background.
draw_set_alpha(0.16);
draw_set_color(make_color_rgb(114, 156, 151));
for (var bar_x = -40; bar_x < gui_w + 80; bar_x += 96)
{
	draw_rectangle(bar_x, 0, bar_x + 18, gui_h, false);
}
draw_set_alpha(1);

var draw_browser_button = function(_x1, _y1, _x2, _y2, _label, _active, _enabled = true)
{
	var hovered = point_in_rectangle(mouse_x_gui, mouse_y_gui, _x1, _y1, _x2, _y2);
	var fill = make_color_rgb(64, 48, 82);
	if (_active || hovered) fill = make_color_rgb(112, 70, 126);
	if (!_enabled) fill = make_color_rgb(42, 39, 48);

	draw_set_color(fill);
	draw_roundrect(_x1, _y1, _x2, _y2, false);
	draw_set_color(_enabled ? c_white : make_color_rgb(130, 130, 135));
	draw_roundrect(_x1, _y1, _x2, _y2, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text((_x1 + _x2) * 0.5, (_y1 + _y2) * 0.5, _label);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);

if (screen == "main")
{
	draw_set_halign(fa_center);
	draw_text_transformed(gui_w * 0.5, 190, "JUNI'S ASYLUM", 3, 3, 0);
	draw_set_color(make_color_rgb(180, 225, 216));
	draw_text_transformed(gui_w * 0.5, 252, "Prototype", 1.4, 1.4, 0);
	draw_set_color(c_white);

	draw_browser_button(483, 370, 883, 424, "Play Prototype Room", main_index == 0);
	draw_browser_button(483, 434, 883, 488, "Level Editor", main_index == 1);
	draw_browser_button(483, 498, 883, 552, "Quit", main_index == 2);

	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_set_color(make_color_rgb(180, 180, 190));
	draw_text(18, gui_h - 18, "Arrow keys + Enter or mouse");
}
else
{
	var row_count = ceil((array_length(levels) + 1) / 3);
	draw_browser_button(20, 20, 220, 64, "Back", false);
	draw_browser_button(232, 20, 514, 64, "Open Custom Levels Folder", false, scr_le_folder_opening_is_enabled());
	draw_browser_button(526, 20, 766, 64, "Online Level List", false, false);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text_transformed(gui_w * 0.5, 94, string(array_length(levels)) + " Local Levels", 1.35, 1.35, 0);

	var card_w = 390;
	var card_h = 270;
	var start_x = 68;
	var start_y = 126;
	var gap_x = 28;
	var gap_y = 24;
	var first_index = scroll_row * 3;

	for (var local_index = 0; local_index < 6; local_index++)
	{
		var item_index = first_index + local_index;
		if (item_index >= array_length(levels) + 1) break;

		var column = local_index mod 3;
		var row = floor(local_index / 3);
		var x1 = start_x + column * (card_w + gap_x);
		var y1 = start_y + row * (card_h + gap_y);
		var x2 = x1 + card_w;
		var y2 = y1 + card_h;
		var hovered = point_in_rectangle(mouse_x_gui, mouse_y_gui, x1, y1, x2, y2);

		draw_set_color(hovered ? make_color_rgb(118, 74, 132) : make_color_rgb(46, 38, 58));
		draw_rectangle(x1, y1, x2, y2, false);
		draw_set_color(hovered ? c_white : make_color_rgb(135, 118, 150));
		draw_rectangle(x1, y1, x2, y2, true);

		if (item_index == 0)
		{
			var create_enabled = array_length(levels) < global.le_max_levels;
			draw_set_color(create_enabled ? make_color_rgb(190, 225, 216) : make_color_rgb(100, 100, 105));
			draw_set_halign(fa_center);
			draw_text_transformed((x1 + x2) * 0.5, y1 + 105, "+", 5, 5, 0);
			draw_set_color(c_white);
			draw_text((x1 + x2) * 0.5, y1 + 205, create_enabled ? "Create" : "Level limit reached");
		}
		else
		{
			var level_index = item_index - 1;
			var entry = levels[level_index];
			var thumbnail = thumbnail_sprites[level_index];
			if (thumbnail != -1 && sprite_exists(thumbnail))
			{
				draw_sprite_stretched(thumbnail, 0, x1 + 5, y1 + 5, card_w - 10, 210);
			}
			else
			{
				draw_set_color(make_color_rgb(25, 29, 35));
				draw_rectangle(x1 + 5, y1 + 5, x2 - 5, y1 + 215, false);
				draw_set_color(make_color_rgb(170, 170, 180));
				draw_set_halign(fa_center);
				draw_text((x1 + x2) * 0.5, y1 + 110, "No thumbnail yet");
			}

			draw_set_color(make_color_rgb(18, 15, 24));
			draw_set_alpha(0.86);
			draw_rectangle(x1 + 5, y1 + 178, x2 - 5, y2 - 5, false);
			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(c_white);
			draw_text((x1 + x2) * 0.5, y1 + 202, entry.data.display_name);

			var badge_x = x1 + 12;
			if (scr_le_verification_valid(entry.data))
			{
				draw_set_color(make_color_rgb(80, 210, 120));
				draw_text(badge_x + 42, y1 + 238, "Verified");
				badge_x += 92;
			}
			if (entry.data.daily_build)
			{
				draw_set_color(make_color_rgb(245, 190, 65));
				draw_text(badge_x + 54, y1 + 238, "Daily Palette");
			}
		}
	}

	if (row_count > 2)
	{
		draw_set_halign(fa_right);
		draw_set_color(make_color_rgb(190, 190, 200));
		draw_text(gui_w - 24, gui_h - 18, "Mouse wheel to scroll  " + string(scroll_row + 1) + "/" + string(max(1, row_count - 1)));
	}
}

if (status_text != "")
{
	draw_set_alpha(0.94);
	draw_set_color(make_color_rgb(15, 12, 20));
	draw_roundrect(250, gui_h - 62, gui_w - 250, gui_h - 18, false);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(gui_w * 0.5, gui_h - 40, status_text);
}

if (modal != "")
{
	draw_set_alpha(0.78);
	draw_set_color(c_black);
	draw_rectangle(0, 0, gui_w, gui_h, false);
	draw_set_alpha(1);

	if (modal == "create")
	{
		draw_set_color(make_color_rgb(31, 25, 41));
		draw_roundrect(438, 210, 928, 570, false);
		draw_set_color(c_white);
		draw_roundrect(438, 210, 928, 570, true);
		draw_set_halign(fa_center);
		draw_text_transformed(683, 254, "Create a Level", 1.5, 1.5, 0);
		draw_browser_button(478, 300, 888, 350, "Create from Scratch", false);
		draw_browser_button(478, 358, 888, 408, "Create Starter Template", false);
		draw_browser_button(478, 416, 888, 466, "Create Daily Palette", false);
		draw_browser_button(478, 474, 888, 524, "Back", false);
	}
	else if (modal == "selected" && selected_level >= 0 && selected_level < array_length(levels))
	{
		var selected_entry = levels[selected_level];
		draw_set_color(make_color_rgb(31, 25, 41));
		draw_roundrect(458, 160, 908, 632, false);
		draw_set_color(c_white);
		draw_roundrect(458, 160, 908, 632, true);
		draw_set_halign(fa_center);
		draw_text_transformed(683, 202, selected_entry.data.display_name, 1.35, 1.35, 0);
		draw_browser_button(498, 258, 868, 300, "Play", false);
		draw_browser_button(498, 306, 868, 348, "Make", false);
		draw_browser_button(498, 354, 868, 396, scr_le_verification_valid(selected_entry.data) ? "Verify Again" : "Verify from Start", false);
		draw_browser_button(498, 402, 868, 444, "Edit Name", false);
		draw_browser_button(498, 450, 868, 492, "Edit Description", false);
		draw_browser_button(498, 498, 868, 540, "Delete", false);
		draw_browser_button(498, 546, 868, 588, "Back", false);
	}
	else if (modal == "name_input" || modal == "rename_input" || modal == "description_input")
	{
		var is_description = modal == "description_input";
		var maximum = is_description ? 75 : 32;
		draw_set_color(make_color_rgb(31, 25, 41));
		draw_roundrect(358, 254, 1008, 512, false);
		draw_set_color(c_white);
		draw_roundrect(358, 254, 1008, 512, true);
		draw_set_halign(fa_center);
		draw_text_transformed(683, 302, is_description ? "Level Description" : "Level Name", 1.4, 1.4, 0);
		draw_set_color(make_color_rgb(12, 11, 17));
		draw_rectangle(398, 352, 968, is_description ? 438 : 404, false);
		draw_set_color(c_white);
		draw_rectangle(398, 352, 968, is_description ? 438 : 404, true);
		draw_set_valign(fa_top);
		draw_text_ext(412, 364, keyboard_string + "|", 20, 540);
		draw_set_valign(fa_middle);
		draw_text(683, 462, string(string_length(keyboard_string)) + "/" + string(maximum) + "    Enter: confirm    Escape: cancel");
	}
	else if (modal == "delete_confirm")
	{
		draw_set_color(make_color_rgb(49, 25, 35));
		draw_roundrect(438, 270, 928, 604, false);
		draw_set_color(c_white);
		draw_roundrect(438, 270, 928, 604, true);
		draw_set_halign(fa_center);
		draw_text_transformed(683, 326, "Delete this local level?", 1.35, 1.35, 0);
		draw_text_ext(683, 382, "The managed level data and thumbnails will be removed. This cannot be undone inside the game.", 22, 410);
		draw_browser_button(498, 464, 868, 510, "Delete", false);
		draw_browser_button(498, 518, 868, 564, "Cancel", false);
	}
	else if (modal == "folder")
	{
		var can_copy_folder_path = scr_le_folder_clipboard_is_enabled();
		draw_set_color(make_color_rgb(31, 25, 41));
		draw_roundrect(390, 200, 976, 704, false);
		draw_set_color(c_white);
		draw_roundrect(390, 200, 976, 704, true);
		draw_set_halign(fa_center);
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
			draw_browser_button(498, 562, 868, 608, "Copy to Clipboard", false);
			draw_browser_button(498, 616, 868, 664, "Back", false);
		}
		else
		{
			draw_browser_button(498, 590, 868, 638, "Back", false);
		}
	}
	else if (modal == "online_info")
	{
		draw_set_color(make_color_rgb(31, 25, 41));
		draw_roundrect(390, 268, 976, 548, false);
		draw_set_color(c_white);
		draw_roundrect(390, 268, 976, 548, true);
		draw_set_halign(fa_center);
		draw_text_transformed(683, 320, "Online Levels", 1.45, 1.45, 0);
		draw_text_ext(683, 382, "Local creation and playtesting are ready. Online publishing needs a server, moderation rules, and validated package import, so it is intentionally not enabled yet.", 22, 500);
		draw_text(683, 500, "Click, Enter, or Escape to close");
	}
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
