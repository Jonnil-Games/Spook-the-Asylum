/// @description Juni's Asylum main menu and local custom-level gallery

scr_le_init();
display_set_gui_size(1366, 768);

screen = variable_global_exists("le_browser_screen") ? global.le_browser_screen : "main";
global.le_browser_screen = "main";
modal = "";
folder_open_result = LEFolderOpenResult.Disabled;
folder_copied_until = 0;
main_index = 0;
selected_level = -1;
scroll_row = 0;
pending_creation_mode = "scratch";
input_return_modal = "";
status_text = "";
status_until = 0;

levels = [];
thumbnail_sprites = [];

cleanup_thumbnails = function()
{
	for (var i = 0; i < array_length(thumbnail_sprites); i++)
	{
		var thumbnail = thumbnail_sprites[i];
		if (thumbnail != -1 && sprite_exists(thumbnail))
		{
			sprite_delete(thumbnail);
		}
	}
	thumbnail_sprites = [];
}

refresh_levels = function()
{
	cleanup_thumbnails();
	levels = scr_le_scan_levels();
	thumbnail_sprites = array_create(array_length(levels), -1);

	for (var i = 0; i < array_length(levels); i++)
	{
		var folder = levels[i].folder;
		var level_dir = global.le_root + folder + "/";
		var thumbnail_path = "";

		if (file_exists(level_dir + "thumbnail.png"))
		{
			thumbnail_path = level_dir + "thumbnail.png";
		}
		else if (file_exists(level_dir + "automatic_thumbnail.png"))
		{
			thumbnail_path = level_dir + "automatic_thumbnail.png";
		}

		if (thumbnail_path != "")
		{
			thumbnail_sprites[i] = sprite_add(thumbnail_path, 1, false, false, 0, 0);
		}
	}

	var rows = ceil((array_length(levels) + 1) / 3);
	scroll_row = clamp(scroll_row, 0, max(0, rows - 2));
}

set_status = function(_text)
{
	status_text = _text;
	status_until = current_time + 4000;
}

open_text_input = function(_mode, _initial, _return_modal)
{
	input_return_modal = _return_modal;
	modal = _mode;
	keyboard_string = _initial;
}

begin_new_level = function(_creation_mode)
{
	pending_creation_mode = _creation_mode;
	open_text_input("name_input", "", "create");
}

open_selected_level = function(_index)
{
	if (_index >= 0 && _index < array_length(levels))
	{
		selected_level = _index;
		modal = "selected";
	}
}

refresh_levels();
