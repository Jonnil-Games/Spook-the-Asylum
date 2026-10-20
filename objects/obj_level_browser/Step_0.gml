/// @description Main menu and gallery interaction

var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);
var clicked = mouse_check_button_released(mb_left);
var right_clicked = mouse_check_button_released(mb_right);

if (status_until != 0 && current_time >= status_until)
{
	status_text = "";
	status_until = 0;
}

if (modal == "name_input" || modal == "rename_input" || modal == "description_input")
{
	var max_length = (modal == "description_input") ? 75 : 32;
	if (string_length(keyboard_string) > max_length)
	{
		keyboard_string = string_copy(keyboard_string, 1, max_length);
	}

	if (keyboard_check_pressed(vk_escape))
	{
		keyboard_string = "";
		modal = input_return_modal;
		exit;
	}

	if (keyboard_check_pressed(vk_enter))
	{
		var entered_text = string_trim(keyboard_string);
		if (modal == "name_input")
		{
			if (entered_text != "")
			{
				var new_level = scr_le_make_level(entered_text, pending_creation_mode);
				if (!is_undefined(new_level))
				{
					global.le_current_folder = new_level.folder;
					keyboard_string = "";
					room_goto(room_level_editor);
				}
				else
				{
					set_status("The level could not be created.");
				}
			}
		}
		else if (selected_level >= 0 && selected_level < array_length(levels))
		{
			var entry = levels[selected_level];
			var current_name = entry.data.display_name;
			var current_description = entry.data.description;

			if (modal == "rename_input" && entered_text != "")
			{
				var updated_folder = entry.folder;
				if (scr_le_update_metadata(entry.folder, entered_text, current_description))
				{
					refresh_levels();
					selected_level = -1;
					for (var renamed_index = 0; renamed_index < array_length(levels); renamed_index++)
					{
						if (levels[renamed_index].folder == updated_folder)
						{
							selected_level = renamed_index;
							break;
						}
					}
					set_status("Level name updated. Its storage identity stayed the same.");
				}
			}
			else if (modal == "description_input")
			{
				if (scr_le_update_metadata(entry.folder, current_name, entered_text))
				{
					refresh_levels();
					set_status("Level description updated.");
				}
			}

			keyboard_string = "";
			modal = selected_level >= 0 ? "selected" : "";
		}
	}
	exit;
}

if (modal == "folder")
{
	var can_copy_folder_path = scr_le_folder_clipboard_is_enabled();
	var folder_back_y1 = can_copy_folder_path ? 616 : 590;
	var folder_back_y2 = can_copy_folder_path ? 664 : 638;
	if (keyboard_check_pressed(vk_escape)
	||  keyboard_check_pressed(vk_enter)
	||  right_clicked
	||  gamepad_button_check_pressed(0, gp_face2)
	||  (clicked && point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, folder_back_y1, 868, folder_back_y2)))
	{
		modal = "";
	}
	else if (can_copy_folder_path
	&& clicked
	&& point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 562, 868, 608))
	{
		clipboard_set_text(global.le_root);
		folder_copied_until = current_time + 1500;
		set_status("The uncensored folder path was copied.");
	}
	exit;
}

if (modal == "online_info")
{
	if (keyboard_check_pressed(vk_escape)
	||  keyboard_check_pressed(vk_enter)
	||  clicked)
	{
		modal = "";
	}
	exit;
}

if (modal == "delete_confirm")
{
	if (keyboard_check_pressed(vk_escape)
	||  (clicked && point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 518, 868, 564)))
	{
		modal = "selected";
	}
	else if (clicked && point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 464, 868, 510))
	{
		if (selected_level >= 0 && selected_level < array_length(levels))
		{
			var deleted_name = levels[selected_level].data.display_name;
			if (scr_le_delete_level(levels[selected_level].folder))
			{
				modal = "";
				selected_level = -1;
				refresh_levels();
				set_status("Deleted " + deleted_name + ".");
			}
			else
			{
				set_status("The level could not be completely deleted.");
			}
		}
	}
	exit;
}

if (modal == "create")
{
	if (keyboard_check_pressed(vk_escape))
	{
		modal = "";
	}
	else if (clicked)
	{
		if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 300, 888, 350)) begin_new_level("scratch");
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 358, 888, 408)) begin_new_level("template");
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 416, 888, 466)) begin_new_level("daily");
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 478, 474, 888, 524)) modal = "";
	}
	exit;
}

if (modal == "selected")
{
	if (selected_level < 0 || selected_level >= array_length(levels))
	{
		modal = "";
		exit;
	}

	var selected_entry = levels[selected_level];
	if (keyboard_check_pressed(vk_escape))
	{
		modal = "";
	}
	else if (clicked)
	{
		if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 258, 868, 300))
		{
			global.le_current_folder = selected_entry.folder;
			global.le_playtest_mode = "normal";
			global.le_playtest_return = "browser";
			global.le_spawn_override = false;
			room_goto(room_level_playtest);
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 306, 868, 348))
		{
			global.le_current_folder = selected_entry.folder;
			room_goto(room_level_editor);
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 354, 868, 396))
		{
			global.le_current_folder = selected_entry.folder;
			global.le_playtest_mode = "clear";
			global.le_playtest_return = "browser";
			global.le_spawn_override = false;
			global.le_clear_digest = scr_le_digest(selected_entry.data);
			global.le_debug_used = false;
			room_goto(room_level_playtest);
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 402, 868, 444))
		{
			open_text_input("rename_input", selected_entry.data.display_name, "selected");
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 450, 868, 492))
		{
			open_text_input("description_input", selected_entry.data.description, "selected");
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 498, 868, 540))
		{
			modal = "delete_confirm";
		}
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 498, 546, 868, 588))
		{
			modal = "";
		}
	}
	exit;
}

if (screen == "main")
{
	if (keyboard_check_pressed(vk_down)) main_index = (main_index + 1) mod 3;
	if (keyboard_check_pressed(vk_up)) main_index = (main_index + 2) mod 3;

	if (clicked)
	{
		if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 483, 370, 883, 424)) main_index = 0;
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 483, 434, 883, 488)) main_index = 1;
		else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 483, 498, 883, 552)) main_index = 2;
		else exit;
	}

	if (keyboard_check_pressed(vk_enter) || clicked)
	{
		switch (main_index)
		{
			case 0:
				global.le_active_level = false;
				room_goto(room_test);
				break;

			case 1:
				screen = "gallery";
				refresh_levels();
				break;

			case 2:
				game_end();
				break;
		}
	}
	exit;
}

// Gallery navigation
if (keyboard_check_pressed(vk_escape))
{
	screen = "main";
	exit;
}

var wheel_up = mouse_wheel_up();
var wheel_down = mouse_wheel_down();
var row_count = ceil((array_length(levels) + 1) / 3);
if (wheel_up) scroll_row = max(0, scroll_row - 1);
if (wheel_down) scroll_row = min(max(0, row_count - 2), scroll_row + 1);

if (clicked)
{
	if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 20, 20, 220, 64))
	{
		screen = "main";
	}
	else if (scr_le_folder_opening_is_enabled()
	&& point_in_rectangle(mouse_x_gui, mouse_y_gui, 232, 20, 514, 64))
	{
		folder_open_result = scr_le_open_levels_folder();
		folder_copied_until = 0;
		modal = "folder";
	}
	else if (point_in_rectangle(mouse_x_gui, mouse_y_gui, 526, 20, 766, 64))
	{
		modal = "online_info";
	}
	else
	{
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

			if (point_in_rectangle(mouse_x_gui, mouse_y_gui, x1, y1, x1 + card_w, y1 + card_h))
			{
				if (item_index == 0)
				{
					if (array_length(levels) < global.le_max_levels) modal = "create";
					else set_status("The local level limit has been reached.");
				}
				else
				{
					open_selected_level(item_index - 1);
				}
				break;
			}
		}
	}
}
