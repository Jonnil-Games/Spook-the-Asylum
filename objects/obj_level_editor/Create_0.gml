/// @description Local level editor controller

scr_le_init();
display_set_gui_size(1366, 768);
depth = 1000;

if (!variable_global_exists("le_current_folder") || global.le_current_folder == "")
{
	room_goto(room_level_browser);
	exit;
}

level_data = scr_le_load_level(global.le_current_folder);
if (is_undefined(level_data))
{
	room_goto(room_level_browser);
	exit;
}

global.le_active_level = false;
global.level_name = level_data.display_name;

room_width = max(1366, level_data.width + 1024);
room_height = max(768, level_data.height + 1024);

grid_size = level_data.grid;
grid_visible = true;
toolbar_visible = true;
tool = "paint";
brush_size = 1;
erase_size = 1;
fill_mode = 0;

palette = scr_le_registry_for_level(level_data);
categories = [];
category_index = 0;
category_entries = [];
palette_index = 0;

selected_proxy = noone;
selected_handle = "";
dragging_proxy = false;
dragging_handle = "";
drag_offset_x = 0;
drag_offset_y = 0;
drag_changed = false;
stroke_active = false;
panning = false;
pan_mouse_x = 0;
pan_mouse_y = 0;
pan_cam_x = 0;
pan_cam_y = 0;

history_undo = [];
history_redo = [];
history_limit = 50;

dirty = false;
autosave_at = current_time + 300000;
status_text = "";
status_until = 0;
pause_open = false;
help_open = false;
folder_modal_open = false;
folder_open_result = LEFolderOpenResult.Disabled;
folder_copied_until = 0;
capture_pending = false;
capture_complete = false;
exit_after_capture = false;

var saved_camera = level_data.editor_camera;
cam_w = clamp(saved_camera.width, 696, 3840);
cam_h = cam_w * (768 / 1366);
cam_x = clamp(saved_camera.x, 0, max(0, room_width - cam_w));
cam_y = clamp(saved_camera.y, 0, max(0, room_height - cam_h));

camera_set_view_size(view_camera[0], cam_w, cam_h);
camera_set_view_pos(view_camera[0], cam_x, cam_y);

rebuild_categories = function()
{
	categories = [];
	for (var i = 0; i < array_length(palette); i++)
	{
		var category = palette[i].category;
		var found = false;
		for (var j = 0; j < array_length(categories); j++)
		{
			if (categories[j] == category)
			{
				found = true;
				break;
			}
		}
		if (!found) categories[array_length(categories)] = category;
	}
	category_index = clamp(category_index, 0, max(0, array_length(categories) - 1));
}

rebuild_category_entries = function()
{
	category_entries = [];
	if (array_length(categories) <= 0) exit;
	var selected_category = categories[category_index];
	for (var i = 0; i < array_length(palette); i++)
	{
		if (palette[i].category == selected_category)
		{
			category_entries[array_length(category_entries)] = palette[i];
		}
	}
	palette_index = clamp(palette_index, 0, max(0, array_length(category_entries) - 1));
}

set_status = function(_text, _milliseconds = 3000)
{
	status_text = _text;
	status_until = current_time + _milliseconds;
}

mark_dirty = function()
{
	dirty = true;
	level_data.verification = { verified: false, digest: "", verified_at: "", game_version: "" };
}

push_history = function()
{
	var snapshot = scr_le_snapshot(id);
	if (!is_undefined(snapshot) && snapshot != "")
	{
		history_undo[array_length(history_undo)] = snapshot;
		if (array_length(history_undo) > history_limit) array_delete(history_undo, 0, 1);
		history_redo = [];
	}
}

undo_edit = function()
{
	var count = array_length(history_undo);
	if (count <= 0)
	{
		set_status("Nothing to undo.");
		exit;
	}

	history_redo[array_length(history_redo)] = scr_le_snapshot(id);
	var snapshot = history_undo[count - 1];
	array_delete(history_undo, count - 1, 1);
	if (scr_le_apply_editor_snapshot(id, snapshot))
	{
		selected_proxy = noone;
		selected_handle = "";
		mark_dirty();
		set_status("Undo");
	}
}

redo_edit = function()
{
	var count = array_length(history_redo);
	if (count <= 0)
	{
		set_status("Nothing to redo.");
		exit;
	}

	history_undo[array_length(history_undo)] = scr_le_snapshot(id);
	var snapshot = history_redo[count - 1];
	array_delete(history_redo, count - 1, 1);
	if (scr_le_apply_editor_snapshot(id, snapshot))
	{
		selected_proxy = noone;
		selected_handle = "";
		mark_dirty();
		set_status("Redo");
	}
}

proxy_contains_point = function(_proxy, _world_x, _world_y)
{
	if (!instance_exists(_proxy)) return false;
	var entry = scr_le_registry_get(_proxy.type_id);
	if (is_undefined(entry) || entry.sprite == -1 || !sprite_exists(entry.sprite))
	{
		return point_in_rectangle(_world_x, _world_y, _proxy.x - 32, _proxy.y - 32, _proxy.x + 32, _proxy.y + 32);
	}

	var scale_x_safe = (_proxy.scale_x == 0) ? 0.001 : _proxy.scale_x;
	var scale_y_safe = (_proxy.scale_y == 0) ? 0.001 : _proxy.scale_y;
	var dx = _world_x - _proxy.x;
	var dy = _world_y - _proxy.y;
	var cosine = dcos(_proxy.rotation);
	var sine = dsin(_proxy.rotation);
	var local_x = (dx * cosine + dy * sine) / scale_x_safe;
	var local_y = (-dx * sine + dy * cosine) / scale_y_safe;
	var origin_x = sprite_get_xoffset(entry.sprite);
	var origin_y = sprite_get_yoffset(entry.sprite);
	return local_x >= -origin_x && local_y >= -origin_y
		&& local_x <= sprite_get_width(entry.sprite) - origin_x
		&& local_y <= sprite_get_height(entry.sprite) - origin_y;
}

proxy_at = function(_world_x, _world_y)
{
	var found = noone;
	var count = instance_number(obj_level_editor_proxy);
	for (var i = 0; i < count; i++)
	{
		var candidate = instance_find(obj_level_editor_proxy, i);
		if (proxy_contains_point(candidate, _world_x, _world_y)) found = candidate;
	}
	return found;
}

anchor_occupied = function(_world_x, _world_y)
{
	var count = instance_number(obj_level_editor_proxy);
	for (var i = 0; i < count; i++)
	{
		var candidate = instance_find(obj_level_editor_proxy, i);
		if (abs(candidate.x - _world_x) < 1 && abs(candidate.y - _world_y) < 1) return true;
	}
	return false;
}

entity_placement_count = function()
{
	var total = 0;
	var count = instance_number(obj_level_editor_proxy);
	for (var i = 0; i < count; i++)
	{
		var proxy = instance_find(obj_level_editor_proxy, i);
		var definition = scr_le_registry_get(proxy.type_id);
		if (!is_undefined(definition)) total += max(0, definition.entity_cost);
	}
	return total;
}

part_placement_count = function()
{
	return instance_number(obj_level_editor_proxy) + array_length(level_data.unknown_placements);
}

create_proxy = function(_entry, _world_x, _world_y)
{
	if (part_placement_count() >= global.le_max_parts)
	{
		set_status("The level has reached its " + string(global.le_max_parts) + "-part limit.");
		return noone;
	}
	if (_entry.entity_cost > 0
	&& entity_placement_count() + _entry.entity_cost > global.le_max_entities)
	{
		set_status("The level has reached its " + string(global.le_max_entities) + "-entity limit.");
		return noone;
	}
	if (anchor_occupied(_world_x, _world_y)) return noone;
	if (_world_x < 0 || _world_y < 0 || _world_x > level_data.width || _world_y > level_data.height) return noone;

	var proxy = instance_create_depth(_world_x, _world_y, -5, obj_level_editor_proxy);
	proxy.type_id = _entry.id;
	proxy.placement_uid = level_data.next_uid;
	level_data.next_uid += 1;
	proxy.scale_x = 1;
	proxy.scale_y = 1;
	proxy.rotation = 0;
	proxy.variant = 0;
	proxy.properties = {};
	if (variable_struct_exists(_entry, "default_properties"))
	{
		proxy.properties = json_parse(json_stringify(_entry.default_properties));
	}
	mark_dirty();
	return proxy;
}

save_now = function(_message = "Level saved.")
{
	level_data.editor_camera.x = cam_x;
	level_data.editor_camera.y = cam_y;
	level_data.editor_camera.width = cam_w;
	level_data.editor_camera.height = cam_h;
	if (scr_le_save_editor(id))
	{
		dirty = false;
		autosave_at = current_time + 300000;
		set_status(_message);
		return true;
	}
	set_status("Save failed. The previous level and backup were kept.", 5000);
	return false;
}

begin_playtest = function(_mode, _from_view)
{
	if (!save_now("Saved before playtest.")) exit;
	global.le_current_folder = level_data.folder;
	global.le_playtest_mode = _mode;
	global.le_playtest_return = "editor";
	global.le_spawn_override = _from_view;
	global.le_spawn_x = cam_x + cam_w * 0.5;
	global.le_spawn_y = cam_y + cam_h * 0.5;
	global.le_debug_used = false;
	if (_mode == "clear") global.le_clear_digest = scr_le_digest(level_data);
	room_goto(room_level_playtest);
}

request_save_and_quit = function()
{
	if (save_now("Saved. Creating thumbnail..."))
	{
		capture_pending = true;
		exit_after_capture = true;
		pause_open = false;
	}
}

rebuild_categories();
rebuild_category_entries();
scr_le_spawn_editor_proxies(id);
