/// @description Shared data, persistence, proxy, and runtime helpers for the local level editor.
/// Level files are deliberately self-contained and use stable string type IDs rather than asset names.

enum LEFolderOpenResult
{
	Opened,
	ManualOpenNeeded,
	FailedToCreate,
	Disabled
}

function __scr_le_field(_source, _name, _fallback)
{
	if (is_struct(_source)
	&& variable_struct_exists(_source, _name))
	{
		return variable_struct_get(_source, _name);
	}

	return _fallback;
}

function __scr_le_number(_value, _fallback)
{
	if (is_real(_value))
	{
		return _value;
	}

	if (is_string(_value))
	{
		try
		{
			return real(_value);
		}
		catch (_exception)
		{
			return _fallback;
		}
	}

	return _fallback;
}

function __scr_le_bool(_value, _fallback)
{
	if (is_bool(_value))
	{
		return _value;
	}

	if (is_real(_value))
	{
		return _value != 0;
	}

	if (is_string(_value))
	{
		var _text = string_lower(_value);
		if (_text == "true" || _text == "1") return true;
		if (_text == "false" || _text == "0") return false;
	}

	return _fallback;
}

function __scr_le_text(_value, _fallback)
{
	if (is_undefined(_value))
	{
		return _fallback;
	}

	return string(_value);
}

function __scr_le_owner_has(_owner, _name)
{
	if (is_struct(_owner))
	{
		return variable_struct_exists(_owner, _name);
	}

	return instance_exists(_owner) && variable_instance_exists(_owner, _name);
}

function __scr_le_owner_get(_owner, _name, _fallback)
{
	if (is_struct(_owner))
	{
		return __scr_le_field(_owner, _name, _fallback);
	}

	if (instance_exists(_owner)
	&& variable_instance_exists(_owner, _name))
	{
		return variable_instance_get(_owner, _name);
	}

	return _fallback;
}

function __scr_le_owner_set(_owner, _name, _value)
{
	if (is_struct(_owner))
	{
		variable_struct_set(_owner, _name, _value);
		return true;
	}

	if (instance_exists(_owner))
	{
		variable_instance_set(_owner, _name, _value);
		return true;
	}

	return false;
}

function __scr_le_clone(_value)
{
	try
	{
		return json_parse(json_stringify(_value));
	}
	catch (_exception)
	{
		return _value;
	}
}

function __scr_le_pad2(_value)
{
	var _number = floor(abs(_value));
	return (_number < 10 ? "0" : "") + string(_number);
}

function scr_le_timestamp(_datetime = undefined)
{
	var _time = is_undefined(_datetime) ? date_current_datetime() : _datetime;
	return string(date_get_year(_time)) + "-"
		+ __scr_le_pad2(date_get_month(_time)) + "-"
		+ __scr_le_pad2(date_get_day(_time)) + "T"
		+ __scr_le_pad2(date_get_hour(_time)) + ":"
		+ __scr_le_pad2(date_get_minute(_time)) + ":"
		+ __scr_le_pad2(date_get_second(_time));
}

function scr_le_sanitize_folder(_raw_name)
{
	var _source = string(_raw_name);
	var _result = "";
	var _last_was_separator = false;

	for (var _i = 1; _i <= string_length(_source); _i++)
	{
		var _character = string_char_at(_source, _i);
		var _allowed = (_character >= "0" && _character <= "9")
			|| (_character >= "A" && _character <= "Z")
			|| (_character >= "a" && _character <= "z")
			|| _character == "-";

		if (_allowed)
		{
			_result += string_lower(_character);
			_last_was_separator = false;
		}
		else
		if (!_last_was_separator)
		{
			_result += "_";
			_last_was_separator = true;
		}
	}

	while (string_length(_result) > 0
	&& string_char_at(_result, 1) == "_")
	{
		_result = string_delete(_result, 1, 1);
	}

	while (string_length(_result) > 0
	&& string_char_at(_result, string_length(_result)) == "_")
	{
		_result = string_delete(_result, string_length(_result), 1);
	}

	if (string_length(_result) > 48)
	{
		_result = string_copy(_result, 1, 48);
	}

	if (_result == "")
	{
		_result = "untitled_level";
	}

	var _reserved = [
		"con", "prn", "aux", "nul",
		"com1", "com2", "com3", "com4", "com5", "com6", "com7", "com8", "com9",
		"lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9"
	];

	for (var _reserved_index = 0; _reserved_index < array_length(_reserved); _reserved_index++)
	{
		if (_result == _reserved[_reserved_index])
		{
			_result = "_" + _result;
			break;
		}
	}

	return _result;
}

function __scr_le_folder_is_safe(_folder)
{
	if (!is_string(_folder)
	|| _folder == ""
	|| _folder == "."
	|| _folder == "..")
	{
		return false;
	}

	return scr_le_sanitize_folder(_folder) == _folder;
}

function scr_le_init()
{
	if (variable_global_exists("le_ready")
	&& global.le_ready)
	{
		return true;
	}

	global.le_root = game_save_id + "custom_levels/";
	global.le_limits = {
		max_levels: 100,
		max_parts: 4000,
		max_entities: 100,
		max_name_length: 32,
		max_description_length: 75,
		min_width: 512,
		min_height: 512,
		max_width: 16384,
		max_height: 16384,
		default_grid: 128
	};
	/* Simple aliases keep UI code readable while the complete limits stay grouped above. */
	global.le_max_levels = global.le_limits.max_levels;
	global.le_max_parts = global.le_limits.max_parts;
	global.le_max_entities = global.le_limits.max_entities;

	/* This is the only editable-type registry. Save files contain its stable id values. */
	global.le_registry = [
		{
			id: "wall", label: "Wall", category: "terrain",
			help: "Solid 128 by 128 terrain. Drag with a larger brush to build rooms quickly.",
			sprite: spr_wall, object_asset: obj_wall,
			brush: true,
			entity_cost: 0, default_properties: {}
		},
		{
			id: "semisolid", label: "Semisolid Platform", category: "terrain",
			help: "A platform that the player can jump through from below.",
			sprite: spr_semisolid_wall, object_asset: obj_semisolid_wall,
			brush: true,
			entity_cost: 0, default_properties: {}
		},
		{
			id: "moving_platform", label: "Moving Platform", category: "terrain",
			help: "A semisolid platform that travels in a circle. Radius and rotation speed are editable.",
			sprite: spr_semisolid_move_plat, object_asset: obj_semisolid_move_plat,
			brush: false,
			entity_cost: 1, default_properties: { dir: 0, radius: 320, rot_spd: 2 }
		},
		{
			id: "slope_up", label: "Slope Up", category: "terrain",
			help: "A solid slope rising from left to right.",
			sprite: spr_slope_1, object_asset: obj_slope_1,
			brush: true,
			entity_cost: 0, default_properties: {}
		},
		{
			id: "slope_down", label: "Slope Down", category: "terrain",
			help: "A solid slope falling from left to right.",
			sprite: spr_slope_2, object_asset: obj_slope_2,
			brush: true,
			entity_cost: 0, default_properties: {}
		},
		{
			id: "spikes", label: "Spikes", category: "hazard",
			help: "Hazardous spikes. Rotate them to attach them to another surface.",
			sprite: spr_spike_trap, object_asset: obj_spike_trap,
			brush: true,
			entity_cost: 0, default_properties: {}
		},
		{
			id: "water", label: "Water", category: "terrain",
			help: "A 128 by 128 water cell that can be painted into pools.",
			sprite: spr_water, object_asset: obj_water,
			brush: true,
			entity_cost: 0, default_properties: {}
		},
		{
			id: "health", label: "Health", category: "item",
			help: "Restores player health when collected.",
			sprite: spr_hud_hearts, object_asset: obj_health_pickup,
			brush: false,
			entity_cost: 1, default_properties: {}
		},
		{
			id: "heart_piece", label: "Heart Piece", category: "item",
			help: "A collectible piece of a heart container.",
			sprite: spr_piece_of_heart, object_asset: obj_piece_of_heart,
			brush: false,
			entity_cost: 1, default_properties: {}
		},
		{
			id: "heart_container", label: "Heart Container", category: "item",
			help: "A full heart-container collectible.",
			sprite: spr_heart_container, object_asset: obj_heart_container_pickup,
			brush: false,
			entity_cost: 1, default_properties: {}
		},
		{
			id: "axe", label: "Axe", category: "item",
			help: "The axe inventory pickup.",
			sprite: spr_axe, object_asset: obj_axe,
			brush: false,
			entity_cost: 1, default_properties: {}
		}
	];

	global.le_ready = true;

	if (!directory_exists(global.le_root))
	{
		directory_create(global.le_root);
	}

	return directory_exists(global.le_root);
}

function scr_le_registry_index(_type_id)
{
	scr_le_init();
	var _id = string(_type_id);

	for (var _i = 0; _i < array_length(global.le_registry); _i++)
	{
		if (global.le_registry[_i].id == _id)
		{
			return _i;
		}
	}

	return -1;
}

function scr_le_registry_get(_type_id)
{
	var _index = scr_le_registry_index(_type_id);
	return _index >= 0 ? global.le_registry[_index] : undefined;
}

function scr_le_registry_for_level(_level_data)
{
	scr_le_init();
	var _palette = __scr_le_field(_level_data, "daily_palette", undefined);
	var _result = [];

	if (is_array(_palette)
	&& array_length(_palette) > 0)
	{
		for (var _palette_index = 0; _palette_index < array_length(_palette); _palette_index++)
		{
			var _entry = scr_le_registry_get(_palette[_palette_index]);
			if (!is_undefined(_entry))
			{
				_result[array_length(_result)] = _entry;
			}
		}

		return _result;
	}

	for (var _registry_index = 0; _registry_index < array_length(global.le_registry); _registry_index++)
	{
		_result[array_length(_result)] = global.le_registry[_registry_index];
	}

	return _result;
}

function scr_le_ensure_directories(_folder = "")
{
	scr_le_init();

	if (!directory_exists(global.le_root))
	{
		directory_create(global.le_root);
	}

	if (!directory_exists(global.le_root))
	{
		return false;
	}

	if (_folder != "")
	{
		if (!__scr_le_folder_is_safe(_folder))
		{
			return false;
		}

		var _level_directory = global.le_root + _folder + "/";
		if (!directory_exists(_level_directory))
		{
			directory_create(_level_directory);
		}

		return directory_exists(_level_directory);
	}

	return true;
}

function scr_le_level_path(_folder, _filename = "")
{
	scr_le_init();
	if (!__scr_le_folder_is_safe(_folder)) return "";
	var _file = string(_filename);
	if (_file != ""
	&& (string_pos("/", _file) > 0
	|| string_pos("\\", _file) > 0
	|| string_pos("..", _file) > 0)) return "";
	return global.le_root + _folder + "/" + _file;
}

function scr_le_read_text(_path)
{
	if (!file_exists(_path))
	{
		return "";
	}

	var _file = file_text_open_read(_path);
	var _text = "";
	var _first_line = true;

	while (!file_text_eof(_file))
	{
		if (!_first_line) _text += "\n";
		_text += file_text_read_string(_file);
		file_text_readln(_file);
		_first_line = false;
	}

	file_text_close(_file);
	return _text;
}

function scr_le_write_text(_path, _text)
{
	var _file = file_text_open_write(_path);
	file_text_write_string(_file, string(_text));
	file_text_close(_file);
	return file_exists(_path);
}

function scr_le_make_id(_folder = "")
{
	var _entropy = scr_le_timestamp() + "|" + string(_folder) + "|"
		+ string(get_timer()) + "|" + string(irandom(2147483646));
	return "level_" + string_copy(string_lower(sha1_string_utf8(_entropy)), 1, 24);
}

function scr_le_unique_folder(_raw_name)
{
	scr_le_init();
	var _base = scr_le_sanitize_folder(_raw_name);
	var _candidate = _base;
	var _suffix = 1;

	while (directory_exists(global.le_root + _candidate)
	&& _suffix <= 9999)
	{
		var _suffix_text = "_" + string(_suffix);
		var _base_length = max(1, 48 - string_length(_suffix_text));
		_candidate = string_copy(_base, 1, _base_length) + _suffix_text;
		_suffix++;
	}

	return _candidate;
}

function __scr_le_daily_palette(_seed)
{
	var _palette = ["wall", "semisolid", "slope_up", "slope_down"];
	var _candidates = ["moving_platform", "spikes", "water", "health", "heart_piece", "heart_container", "axe"];
	var _state = abs(floor(_seed)) mod 233280;

	repeat (5)
	{
		if (array_length(_candidates) <= 0) break;
		_state = (_state * 9301 + 49297) mod 233280;
		var _choice = floor((_state / 233280) * array_length(_candidates));
		_choice = clamp(_choice, 0, array_length(_candidates) - 1);
		_palette[array_length(_palette)] = _candidates[_choice];

		var _remaining = [];
		for (var _i = 0; _i < array_length(_candidates); _i++)
		{
			if (_i != _choice)
			{
				_remaining[array_length(_remaining)] = _candidates[_i];
			}
		}
		_candidates = _remaining;
	}

	return _palette;
}

function __scr_le_seed_from_timestamp(_timestamp)
{
	if (is_string(_timestamp)
	&& string_length(_timestamp) >= 10)
	{
		try
		{
			var _year = real(string_copy(_timestamp, 1, 4));
			var _month = real(string_copy(_timestamp, 6, 2));
			var _day = real(string_copy(_timestamp, 9, 2));
			return _year * 10000 + _month * 100 + _day;
		}
		catch (_exception)
		{
			/* Fall through to today's seed. */
		}
	}

	var _today = date_current_datetime();
	return date_get_year(_today) * 10000 + date_get_month(_today) * 100 + date_get_day(_today);
}

function __scr_le_sort_placements(_placements)
{
	for (var _i = 1; _i < array_length(_placements); _i++)
	{
		var _value = _placements[_i];
		var _value_uid = __scr_le_number(__scr_le_field(_value, "uid", 0), 0);
		var _j = _i - 1;

		while (_j >= 0
		&& __scr_le_number(__scr_le_field(_placements[_j], "uid", 0), 0) > _value_uid)
		{
			_placements[_j + 1] = _placements[_j];
			_j--;
		}

		_placements[_j + 1] = _value;
	}

	return _placements;
}

function __scr_le_normalize_placement(_raw, _fallback_uid)
{
	if (!is_struct(_raw))
	{
		return undefined;
	}

	var _type = __scr_le_text(
		__scr_le_field(_raw, "type", __scr_le_field(_raw, "type_id", "")), "");
	var _definition = scr_le_registry_get(_type);

	if (is_undefined(_definition))
	{
		return undefined;
	}

	var _properties = __scr_le_field(_raw, "properties", {});
	if (!is_struct(_properties)) _properties = {};

	var _defaults = _definition.default_properties;
	var _default_names = struct_get_names(_defaults);
	for (var _property_index = 0; _property_index < array_length(_default_names); _property_index++)
	{
		var _property_name = _default_names[_property_index];
		if (!variable_struct_exists(_properties, _property_name))
		{
			variable_struct_set(_properties, _property_name, variable_struct_get(_defaults, _property_name));
		}
	}

	var _placement = _raw;
	variable_struct_set(_placement, "uid", max(1, floor(__scr_le_number(
		__scr_le_field(_raw, "uid", __scr_le_field(_raw, "placement_uid", _fallback_uid)), _fallback_uid))));
	variable_struct_set(_placement, "type", _type);
	variable_struct_set(_placement, "x", clamp(__scr_le_number(__scr_le_field(_raw, "x", 0), 0), -32768, 32768));
	variable_struct_set(_placement, "y", clamp(__scr_le_number(__scr_le_field(_raw, "y", 0), 0), -32768, 32768));
	var _scale_x = clamp(__scr_le_number(__scr_le_field(_raw, "scale_x", 1), 1), -16, 16);
	var _scale_y = clamp(__scr_le_number(__scr_le_field(_raw, "scale_y", 1), 1), -16, 16);
	if (abs(_scale_x) < 0.125) _scale_x = _scale_x < 0 ? -0.125 : 0.125;
	if (abs(_scale_y) < 0.125) _scale_y = _scale_y < 0 ? -0.125 : 0.125;
	variable_struct_set(_placement, "scale_x", _scale_x);
	variable_struct_set(_placement, "scale_y", _scale_y);
	var _rotation = __scr_le_number(__scr_le_field(_raw, "rotation", 0), 0);
	variable_struct_set(_placement, "rotation", ((_rotation mod 360) + 360) mod 360);
	variable_struct_set(_placement, "variant", max(0, floor(__scr_le_number(__scr_le_field(_raw, "variant", 0), 0))));
	variable_struct_set(_placement, "properties", _properties);
	return _placement;
}

function __scr_le_normalize_level(_raw, _folder_hint = "")
{
	scr_le_init();
	if (!is_struct(_raw)) return undefined;

	var _existing_version = floor(__scr_le_number(__scr_le_field(_raw, "format_version", 0), 0));
	if (_existing_version > 1) return undefined;

	var _data = _raw;
	var _now = scr_le_timestamp();
	var _folder = __scr_le_text(__scr_le_field(_data, "folder", _folder_hint), _folder_hint);
	if (_folder == "" && _folder_hint != "") _folder = _folder_hint;
	if (!__scr_le_folder_is_safe(_folder)) return undefined;

	var _level_id = __scr_le_text(__scr_le_field(_data, "level_id", ""), "");
	if (_level_id == "")
	{
		_level_id = "legacy_" + string_copy(string_lower(sha1_string_utf8(_folder)), 1, 24);
	}

	var _display_name = __scr_le_text(
		__scr_le_field(_data, "display_name", __scr_le_field(_data, "name", _folder)), _folder);
	if (_display_name == "") _display_name = _folder;
	_display_name = string_copy(_display_name, 1, global.le_limits.max_name_length);
	var _description = string_copy(__scr_le_text(__scr_le_field(_data, "description", ""), ""),
		1, global.le_limits.max_description_length);

	var _dimensions_source = __scr_le_field(_data, "dimensions", {});
	if (!is_struct(_dimensions_source)) _dimensions_source = {};
	/* Root aliases are kept for the room controller; dimensions remains the canonical grouped record. */
	var _width = __scr_le_number(__scr_le_field(_dimensions_source, "width",
		__scr_le_field(_data, "width", 2048)), 2048);
	var _height = __scr_le_number(__scr_le_field(_dimensions_source, "height",
		__scr_le_field(_data, "height", 1152)), 1152);
	var _grid = __scr_le_number(__scr_le_field(_dimensions_source, "grid",
		__scr_le_field(_data, "grid", global.le_limits.default_grid)), global.le_limits.default_grid);
	var _dimensions = {
		width: round(clamp(_width, global.le_limits.min_width, global.le_limits.max_width)),
		height: round(clamp(_height, global.le_limits.min_height, global.le_limits.max_height)),
		grid: round(clamp(_grid, 16, 256))
	};

	var _start_source = __scr_le_field(_data, "player_start", {});
	if (!is_struct(_start_source)) _start_source = {};
	var _player_start = {
		x: clamp(__scr_le_number(__scr_le_field(_start_source, "x", 256), 256), 0, _dimensions.width),
		y: clamp(__scr_le_number(__scr_le_field(_start_source, "y", _dimensions.height - 256), _dimensions.height - 256), 0, _dimensions.height)
	};

	var _goal_source = __scr_le_field(_data, "goal", {});
	if (!is_struct(_goal_source)) _goal_source = {};
	var _goal = {
		x: clamp(__scr_le_number(__scr_le_field(_goal_source, "x", _dimensions.width - 256), _dimensions.width - 256), 0, _dimensions.width),
		y: clamp(__scr_le_number(__scr_le_field(_goal_source, "y", _dimensions.height - 256), _dimensions.height - 256), 0, _dimensions.height)
	};

	var _incoming_placements = __scr_le_field(_data, "placements", []);
	if (!is_array(_incoming_placements)) _incoming_placements = [];
	var _incoming_unknown = __scr_le_field(_data, "unknown_placements", []);
	if (!is_array(_incoming_unknown)) _incoming_unknown = [];
	var _placements = [];
	var _unknown = [];
	var _next_fallback_uid = 1;

	for (var _placement_index = 0; _placement_index < array_length(_incoming_placements); _placement_index++)
	{
		var _source_placement = _incoming_placements[_placement_index];
		var _placement = __scr_le_normalize_placement(_source_placement, _next_fallback_uid);
		if (is_undefined(_placement))
		{
			if (is_struct(_source_placement)) _unknown[array_length(_unknown)] = _source_placement;
		}
		else
		{
			_placements[array_length(_placements)] = _placement;
			_next_fallback_uid = max(_next_fallback_uid + 1, _placement.uid + 1);
		}
	}

	for (var _unknown_index = 0; _unknown_index < array_length(_incoming_unknown); _unknown_index++)
	{
		var _source_unknown = _incoming_unknown[_unknown_index];
		var _promoted = __scr_le_normalize_placement(_source_unknown, _next_fallback_uid);
		if (is_undefined(_promoted))
		{
			if (is_struct(_source_unknown)) _unknown[array_length(_unknown)] = _source_unknown;
		}
		else
		{
			_placements[array_length(_placements)] = _promoted;
			_next_fallback_uid = max(_next_fallback_uid + 1, _promoted.uid + 1);
		}
	}

	_placements = __scr_le_sort_placements(_placements);
	var _last_uid = 0;
	for (var _uid_index = 0; _uid_index < array_length(_placements); _uid_index++)
	{
		if (_placements[_uid_index].uid <= _last_uid)
		{
			_placements[_uid_index].uid = _last_uid + 1;
		}
		_last_uid = _placements[_uid_index].uid;
	}

	for (var _unknown_uid_index = 0; _unknown_uid_index < array_length(_unknown); _unknown_uid_index++)
	{
		var _unknown_uid = __scr_le_number(__scr_le_field(_unknown[_unknown_uid_index], "uid", 0), 0);
		_last_uid = max(_last_uid, _unknown_uid);
	}

	var _daily_build = __scr_le_bool(__scr_le_field(_data, "daily_build", false), false);
	var _daily_seed = floor(__scr_le_number(__scr_le_field(_data, "daily_seed",
		__scr_le_seed_from_timestamp(__scr_le_field(_data, "created_at", _now))),
		__scr_le_seed_from_timestamp(_now)));
	var _daily_source = __scr_le_field(_data, "daily_palette", []);
	if (!is_array(_daily_source)) _daily_source = [];
	var _daily_palette = [];
	for (var _daily_index = 0; _daily_index < array_length(_daily_source); _daily_index++)
	{
		var _daily_id = __scr_le_text(_daily_source[_daily_index], "");
		if (scr_le_registry_index(_daily_id) >= 0)
		{
			var _already_added = false;
			for (var _daily_check = 0; _daily_check < array_length(_daily_palette); _daily_check++)
			{
				if (_daily_palette[_daily_check] == _daily_id) _already_added = true;
			}
			if (!_already_added) _daily_palette[array_length(_daily_palette)] = _daily_id;
		}
	}
	if (_daily_build && array_length(_daily_palette) <= 0)
	{
		_daily_palette = __scr_le_daily_palette(_daily_seed);
	}

	var _camera_source = __scr_le_field(_data, "editor_camera", __scr_le_field(_data, "editor", {}));
	if (!is_struct(_camera_source)) _camera_source = {};
	var _editor_camera = {
		x: __scr_le_number(__scr_le_field(_camera_source, "x", 0), 0),
		y: __scr_le_number(__scr_le_field(_camera_source, "y", 0), 0),
		width: max(1, __scr_le_number(__scr_le_field(_camera_source, "width", 1280), 1280)),
		height: max(1, __scr_le_number(__scr_le_field(_camera_source, "height", 720), 720)),
		zoom: clamp(__scr_le_number(__scr_le_field(_camera_source, "zoom", 1), 1), 0.25, 4)
	};

	var _verification_source = __scr_le_field(_data, "verification", {});
	if (!is_struct(_verification_source)) _verification_source = {};
	var _verification = {
		verified: __scr_le_bool(__scr_le_field(_verification_source, "verified", false), false),
		digest: __scr_le_text(__scr_le_field(_verification_source, "digest", ""), ""),
		verified_at: __scr_le_text(__scr_le_field(_verification_source, "verified_at", ""), ""),
		game_version: __scr_le_text(__scr_le_field(_verification_source, "game_version", ""), ""),
		difficulty: __scr_le_text(__scr_le_field(_verification_source, "difficulty", "normal"), "normal"),
		character: __scr_le_text(__scr_le_field(_verification_source, "character", ""), ""),
		debug_used: __scr_le_bool(__scr_le_field(_verification_source, "debug_used", false), false)
	};

	variable_struct_set(_data, "format_version", 1);
	variable_struct_set(_data, "level_id", string_copy(_level_id, 1, 64));
	variable_struct_set(_data, "folder", _folder);
	variable_struct_set(_data, "display_name", _display_name);
	variable_struct_set(_data, "description", _description);
	variable_struct_set(_data, "creation_mode", __scr_le_text(__scr_le_field(_data, "creation_mode", "scratch"), "scratch"));
	variable_struct_set(_data, "created_at", __scr_le_text(__scr_le_field(_data, "created_at", _now), _now));
	variable_struct_set(_data, "modified_at", __scr_le_text(__scr_le_field(_data, "modified_at", _now), _now));
	variable_struct_set(_data, "dimensions", _dimensions);
	variable_struct_set(_data, "width", _dimensions.width);
	variable_struct_set(_data, "height", _dimensions.height);
	variable_struct_set(_data, "grid", _dimensions.grid);
	variable_struct_set(_data, "player_start", _player_start);
	variable_struct_set(_data, "goal", _goal);
	variable_struct_set(_data, "next_uid", max(_last_uid + 1,
		floor(__scr_le_number(__scr_le_field(_data, "next_uid", _last_uid + 1), _last_uid + 1))));
	variable_struct_set(_data, "placements", _placements);
	variable_struct_set(_data, "unknown_placements", _unknown);
	variable_struct_set(_data, "daily_build", _daily_build);
	variable_struct_set(_data, "daily_seed", _daily_seed);
	variable_struct_set(_data, "daily_palette", _daily_palette);
	variable_struct_set(_data, "editor_camera", _editor_camera);
	variable_struct_set(_data, "verification", _verification);
	return _data;
}

function scr_le_validate_level(_level_data)
{
	scr_le_init();
	if (!is_struct(_level_data)) return false;
	if (__scr_le_number(__scr_le_field(_level_data, "format_version", 0), 0) != 1) return false;
	if (!__scr_le_folder_is_safe(__scr_le_field(_level_data, "folder", ""))) return false;

	var _level_id = __scr_le_field(_level_data, "level_id", "");
	if (!is_string(_level_id)
	|| _level_id == ""
	|| string_pos("/", _level_id) > 0
	|| string_pos("\\", _level_id) > 0) return false;
	if (!is_struct(__scr_le_field(_level_data, "dimensions", undefined))) return false;
	if (!is_struct(__scr_le_field(_level_data, "player_start", undefined))) return false;
	if (!is_struct(__scr_le_field(_level_data, "goal", undefined))) return false;
	if (!is_array(__scr_le_field(_level_data, "placements", undefined))) return false;
	if (!is_array(__scr_le_field(_level_data, "unknown_placements", undefined))) return false;

	var _placements = _level_data.placements;
	var _unknown = _level_data.unknown_placements;
	if (array_length(_placements) + array_length(_unknown) > global.le_limits.max_parts) return false;

	var _entity_count = 0;
	var _last_uid = 0;
	for (var _i = 0; _i < array_length(_placements); _i++)
	{
		var _placement = _placements[_i];
		if (!is_struct(_placement)) return false;
		var _definition = scr_le_registry_get(__scr_le_field(_placement, "type", ""));
		if (is_undefined(_definition)) return false;
		var _uid = __scr_le_number(__scr_le_field(_placement, "uid", 0), 0);
		if (_uid <= _last_uid) return false;
		_last_uid = _uid;
		_entity_count += max(0, _definition.entity_cost);
	}

	return _entity_count <= global.le_limits.max_entities;
}

function __scr_le_document_from_text(_text, _folder)
{
	if (_text == "") return undefined;

	try
	{
		var _raw = json_parse(_text);
		if (!is_struct(_raw)) return undefined;
		var _stored_folder = __scr_le_field(_raw, "folder", "");
		if (_stored_folder != "" && _stored_folder != _folder) return undefined;
		var _data = __scr_le_normalize_level(_raw, _folder);
		return scr_le_validate_level(_data) ? _data : undefined;
	}
	catch (_exception)
	{
		return undefined;
	}
}

function __scr_le_read_document(_path, _folder)
{
	if (!file_exists(_path)) return undefined;
	return __scr_le_document_from_text(scr_le_read_text(_path), _folder);
}

function __scr_le_file_has_future_version(_path)
{
	if (!file_exists(_path)) return false;

	try
	{
		var _raw = json_parse(scr_le_read_text(_path));
		return is_struct(_raw)
			&& __scr_le_number(__scr_le_field(_raw, "format_version", 0), 0) > 1;
	}
	catch (_exception)
	{
		return false;
	}
}

function __scr_le_folder_names()
{
	scr_le_init();
	var _folders = [];
	var _found = string(file_find_first(global.le_root + "*", fa_directory));

	while (_found != "")
	{
		if (_found != "."
		&& _found != ".."
		&& __scr_le_folder_is_safe(_found)
		&& directory_exists(global.le_root + _found))
		{
			_folders[array_length(_folders)] = _found;
		}
		_found = string(file_find_next());
	}

	file_find_close();
	array_sort(_folders, true);
	return _folders;
}

function __scr_le_resolve_folder(_folder_or_id)
{
	scr_le_init();
	var _reference = string(_folder_or_id);

	if (__scr_le_folder_is_safe(_reference)
	&& directory_exists(global.le_root + _reference))
	{
		return _reference;
	}

	var _folders = __scr_le_folder_names();
	for (var _i = 0; _i < array_length(_folders); _i++)
	{
		var _folder = _folders[_i];
		var _data = __scr_le_read_document(scr_le_level_path(_folder, "level.json"), _folder);
		if (is_undefined(_data))
		{
			_data = __scr_le_read_document(scr_le_level_path(_folder, "level.json.bak"), _folder);
		}

		if (!is_undefined(_data)
		&& _data.level_id == _reference)
		{
			return _folder;
		}
	}

	return "";
}

function scr_le_load_level(_folder_or_id)
{
	var _folder = __scr_le_resolve_folder(_folder_or_id);
	if (_folder == "") return undefined;

	var _data = __scr_le_read_document(scr_le_level_path(_folder, "level.json"), _folder);
	if (!is_undefined(_data)) return _data;
	return __scr_le_read_document(scr_le_level_path(_folder, "level.json.bak"), _folder);
}

function scr_le_save_level(_level_data)
{
	scr_le_init();
	var _data = __scr_le_normalize_level(_level_data, __scr_le_field(_level_data, "folder", ""));
	if (is_undefined(_data) || !scr_le_validate_level(_data)) return false;

	var _folder = _data.folder;
	var _identity_folder = __scr_le_resolve_folder(_data.level_id);
	if (_identity_folder != "" && _identity_folder != _folder)
	{
		/* A copied/imported folder may duplicate an ID. Never redirect a save into another level. */
		return false;
	}
	if (!scr_le_ensure_directories(_folder)) return false;
	var _main_path = scr_le_level_path(_folder, "level.json");
	var _temp_path = scr_le_level_path(_folder, "level.json.tmp");
	var _backup_path = scr_le_level_path(_folder, "level.json.bak");
	/* Never downgrade a document written by a newer game build. */
	if (__scr_le_file_has_future_version(_main_path)) return false;
	var _existing = __scr_le_read_document(_main_path, _folder);
	if (is_undefined(_existing)) _existing = __scr_le_read_document(_backup_path, _folder);

	/* Folder and level ID are storage identity, not editable metadata. */
	if (!is_undefined(_existing))
	{
		_data.folder = _existing.folder;
		_data.level_id = _existing.level_id;
	}

	_data.modified_at = scr_le_timestamp();
	if (file_exists(_temp_path)) file_delete(_temp_path);

	var _json = "";
	try
	{
		_json = json_stringify(_data, true);
	}
	catch (_exception)
	{
		return false;
	}

	if (!scr_le_write_text(_temp_path, _json)) return false;
	var _temp_document = __scr_le_read_document(_temp_path, _folder);
	if (is_undefined(_temp_document)
	|| _temp_document.level_id != _data.level_id)
	{
		if (file_exists(_temp_path)) file_delete(_temp_path);
		return false;
	}

	/* Only a parsed, valid primary file is allowed to replace the last-known-good backup. */
	var _valid_primary = __scr_le_read_document(_main_path, _folder);
	if (!is_undefined(_valid_primary))
	{
		if (file_exists(_backup_path)) file_delete(_backup_path);
		file_copy(_main_path, _backup_path);
		if (is_undefined(__scr_le_read_document(_backup_path, _folder)))
		{
			file_delete(_temp_path);
			return false;
		}
	}

	if (file_exists(_main_path)) file_delete(_main_path);
	file_rename(_temp_path, _main_path);
	if (!file_exists(_main_path)
	&& file_exists(_temp_path))
	{
		file_copy(_temp_path, _main_path);
		if (file_exists(_main_path)) file_delete(_temp_path);
	}

	var _saved = __scr_le_read_document(_main_path, _folder);
	if (is_undefined(_saved)
	|| _saved.level_id != _data.level_id)
	{
		if (file_exists(_main_path)) file_delete(_main_path);
		if (!is_undefined(__scr_le_read_document(_backup_path, _folder)))
		{
			file_copy(_backup_path, _main_path);
		}
		return false;
	}

	return true;
}

function scr_le_scan_levels()
{
	scr_le_init();
	var _folders = __scr_le_folder_names();
	var _levels = [];

	for (var _i = 0; _i < array_length(_folders); _i++)
	{
		var _data = scr_le_load_level(_folders[_i]);
		if (!is_undefined(_data))
		{
			_levels[array_length(_levels)] = { folder: _data.folder, data: _data };
		}
	}

	/* Stable case-insensitive display-name order, then immutable folder order. */
	for (var _sort_index = 1; _sort_index < array_length(_levels); _sort_index++)
	{
		var _value = _levels[_sort_index];
		var _value_key = string_lower(_value.data.display_name) + "\n" + _value.folder;
		var _position = _sort_index - 1;
		while (_position >= 0
		&& string_lower(_levels[_position].data.display_name) + "\n" + _levels[_position].folder > _value_key)
		{
			_levels[_position + 1] = _levels[_position];
			_position--;
		}
		_levels[_position + 1] = _value;
	}

	if (array_length(_levels) > global.le_limits.max_levels)
	{
		array_resize(_levels, global.le_limits.max_levels);
	}

	return _levels;
}

function scr_le_delete_level(_folder_or_id)
{
	var _folder = __scr_le_resolve_folder(_folder_or_id);
	if (_folder == "") return false;
	var _directory = scr_le_level_path(_folder);
	var _managed_files = [
		"level.json", "level.json.tmp", "level.json.bak",
		"thumbnail.png", "automatic_thumbnail.png"
	];

	for (var _i = 0; _i < array_length(_managed_files); _i++)
	{
		var _path = _directory + _managed_files[_i];
		if (file_exists(_path)) file_delete(_path);
	}

	/* directory_destroy only succeeds when no unrecognized user files would be lost. */
	if (directory_exists(_directory)) directory_destroy(_directory);
	return !file_exists(_directory + "level.json")
		&& !file_exists(_directory + "level.json.bak");
}

function scr_le_update_metadata(_folder_or_id, _display_name, _description)
{
	var _data = scr_le_load_level(_folder_or_id);
	if (is_undefined(_data)) return false;
	var _name = string(_display_name);
	if (_name == "") _name = _data.display_name;
	_data.display_name = string_copy(_name, 1, global.le_limits.max_name_length);
	_data.description = string_copy(string(_description), 1, global.le_limits.max_description_length);
	return scr_le_save_level(_data);
}

function __scr_le_add_placement(_data, _type, _x, _y, _variant = 0, _properties = undefined)
{
	var _definition = scr_le_registry_get(_type);
	if (is_undefined(_definition)) return false;
	var _property_data = is_struct(_properties) ? _properties : __scr_le_clone(_definition.default_properties);
	_data.placements[array_length(_data.placements)] = {
		uid: _data.next_uid,
		type: _type,
		x: _x,
		y: _y,
		scale_x: 1,
		scale_y: 1,
		rotation: 0,
		variant: _variant,
		properties: _property_data
	};
	_data.next_uid++;
	return true;
}

function scr_le_make_level(_name, _creation_mode = "scratch")
{
	scr_le_init();
	if (array_length(scr_le_scan_levels()) >= global.le_limits.max_levels) return undefined;

	var _mode = string_lower(string(_creation_mode));
	if (_mode != "scratch" && _mode != "template" && _mode != "daily") _mode = "scratch";
	var _display_name = string_copy(string(_name), 1, global.le_limits.max_name_length);
	if (_display_name == "") _display_name = "Untitled Level";
	var _folder = scr_le_unique_folder(_display_name);
	var _now = scr_le_timestamp();
	var _today = date_current_datetime();
	var _daily_seed = date_get_year(_today) * 10000 + date_get_month(_today) * 100 + date_get_day(_today);

	var _data = {
		format_version: 1,
		level_id: scr_le_make_id(_folder),
		folder: _folder,
		display_name: _display_name,
		description: "",
		creation_mode: _mode,
		created_at: _now,
		modified_at: _now,
		dimensions: { width: 2048, height: 1152, grid: 128 },
		width: 2048,
		height: 1152,
		grid: 128,
		player_start: { x: 256, y: 896 },
		goal: { x: 1792, y: 896 },
		next_uid: 1,
		placements: [],
		unknown_placements: [],
		daily_build: _mode == "daily",
		daily_seed: _daily_seed,
		daily_palette: _mode == "daily" ? __scr_le_daily_palette(_daily_seed) : [],
		editor_camera: { x: 0, y: 432, width: 1280, height: 720, zoom: 1 },
		verification: {
			verified: false, digest: "", verified_at: "", game_version: "",
			difficulty: "normal", character: "", debug_used: false
		}
	};

	if (_mode == "template")
	{
		/* A compact, immediately playable starter built entirely from current assets. */
		for (var _floor_x = 0; _floor_x < _data.dimensions.width; _floor_x += 128)
		{
			__scr_le_add_placement(_data, "wall", _floor_x, 1024, (_floor_x div 128) mod 16);
		}
		__scr_le_add_placement(_data, "wall", 0, 896, 1);
		__scr_le_add_placement(_data, "wall", 1920, 896, 2);
		__scr_le_add_placement(_data, "semisolid", 512, 768, 3);
		__scr_le_add_placement(_data, "semisolid", 640, 768, 4);
		__scr_le_add_placement(_data, "semisolid", 1280, 640, 5);
		__scr_le_add_placement(_data, "semisolid", 1408, 640, 6);
		__scr_le_add_placement(_data, "spikes", 1024, 896);
		__scr_le_add_placement(_data, "health", 1472, 544);
	}

	if (!scr_le_save_level(_data)) return undefined;
	return _data;
}

function __scr_le_camera_value(_manager, _key, _fallback)
{
	var _primary = "camera_" + _key;
	if (__scr_le_owner_has(_manager, _primary)) return __scr_le_owner_get(_manager, _primary, _fallback);
	var _secondary = "editor_camera_" + _key;
	if (__scr_le_owner_has(_manager, _secondary)) return __scr_le_owner_get(_manager, _secondary, _fallback);
	var _room_field = "";
	switch (_key)
	{
		case "x": _room_field = "cam_x"; break;
		case "y": _room_field = "cam_y"; break;
		case "width": _room_field = "cam_w"; break;
		case "height": _room_field = "cam_h"; break;
		case "zoom": _room_field = "cam_zoom"; break;
	}
	if (_room_field != "" && __scr_le_owner_has(_manager, _room_field))
	{
		return __scr_le_owner_get(_manager, _room_field, _fallback);
	}
	return _fallback;
}

function scr_le_collect_editor(_manager)
{
	var _source = __scr_le_owner_get(_manager, "level_data", undefined);
	if (!is_struct(_source)) return undefined;
	var _level = __scr_le_normalize_level(_source, __scr_le_field(_source, "folder", ""));
	if (is_undefined(_level)) return undefined;
	var _placements = [];
	var _unknown = _level.unknown_placements;
	var _instance_count = instance_number(obj_level_editor_proxy);
	var _fallback_uid = max(1, _level.next_uid);

	for (var _i = 0; _i < _instance_count; _i++)
	{
		var _proxy = instance_find(obj_level_editor_proxy, _i);
		if (!instance_exists(_proxy)) continue;
		var _owner = __scr_le_owner_get(_proxy, "editor_manager", undefined);
		if (!is_undefined(_owner) && _owner != _manager) continue;

		var _type = __scr_le_text(__scr_le_owner_get(_proxy, "type_id",
			__scr_le_owner_get(_proxy, "type", "")), "");
		var _properties = __scr_le_owner_get(_proxy, "properties", {});
		if (!is_struct(_properties)) _properties = {};
		var _placement = {
			uid: max(1, floor(__scr_le_number(__scr_le_owner_get(_proxy, "placement_uid",
				__scr_le_owner_get(_proxy, "uid", _fallback_uid)), _fallback_uid))),
			type: _type,
			x: __scr_le_number(__scr_le_owner_get(_proxy, "x", 0), 0),
			y: __scr_le_number(__scr_le_owner_get(_proxy, "y", 0), 0),
			scale_x: __scr_le_number(__scr_le_owner_get(_proxy, "scale_x",
				__scr_le_owner_get(_proxy, "image_xscale", 1)), 1),
			scale_y: __scr_le_number(__scr_le_owner_get(_proxy, "scale_y",
				__scr_le_owner_get(_proxy, "image_yscale", 1)), 1),
			rotation: __scr_le_number(__scr_le_owner_get(_proxy, "rotation",
				__scr_le_owner_get(_proxy, "image_angle", 0)), 0),
			variant: max(0, floor(__scr_le_number(__scr_le_owner_get(_proxy, "variant",
				__scr_le_owner_get(_proxy, "image_index", 0)), 0))),
			properties: __scr_le_clone(_properties)
		};

		if (scr_le_registry_index(_type) >= 0)
		{
			_placements[array_length(_placements)] = _placement;
		}
		else
		{
			_unknown[array_length(_unknown)] = _placement;
		}
		_fallback_uid = max(_fallback_uid, _placement.uid + 1);
	}

	_level.placements = __scr_le_sort_placements(_placements);
	_level.unknown_placements = _unknown;
	_level.next_uid = _fallback_uid;
	var _camera = _level.editor_camera;
	_camera.x = __scr_le_number(__scr_le_camera_value(_manager, "x", _camera.x), _camera.x);
	_camera.y = __scr_le_number(__scr_le_camera_value(_manager, "y", _camera.y), _camera.y);
	_camera.width = max(1, __scr_le_number(__scr_le_camera_value(_manager, "width", _camera.width), _camera.width));
	_camera.height = max(1, __scr_le_number(__scr_le_camera_value(_manager, "height", _camera.height), _camera.height));
	_camera.zoom = clamp(__scr_le_number(__scr_le_camera_value(_manager, "zoom", _camera.zoom), _camera.zoom), 0.25, 4);
	_level.editor_camera = _camera;
	_level = __scr_le_normalize_level(_level, _level.folder);
	if (_level.verification.verified && !scr_le_verification_valid(_level))
	{
		_level.verification.verified = false;
	}
	__scr_le_owner_set(_manager, "level_data", _level);
	return _level;
}

function scr_le_save_editor(_manager)
{
	var _level = scr_le_collect_editor(_manager);
	if (is_undefined(_level)) return false;
	var _saved = scr_le_save_level(_level);
	if (_saved) __scr_le_owner_set(_manager, "level_data", _level);
	return _saved;
}

function __scr_le_clear_editor_proxies(_manager)
{
	for (var _i = instance_number(obj_level_editor_proxy) - 1; _i >= 0; _i--)
	{
		var _proxy = instance_find(obj_level_editor_proxy, _i);
		if (!instance_exists(_proxy)) continue;
		var _owner = __scr_le_owner_get(_proxy, "editor_manager", undefined);
		if (is_undefined(_owner) || _owner == _manager)
		{
			with (_proxy) instance_destroy();
		}
	}
}

function scr_le_spawn_editor_proxies(_manager)
{
	var _source = __scr_le_owner_get(_manager, "level_data", undefined);
	if (!is_struct(_source)) return 0;
	var _level = __scr_le_normalize_level(_source, __scr_le_field(_source, "folder", ""));
	if (is_undefined(_level)) return 0;
	__scr_le_clear_editor_proxies(_manager);
	var _count = 0;
	var _layer_id = layer_get_id("Instances");

	for (var _i = 0; _i < array_length(_level.placements); _i++)
	{
		var _placement = _level.placements[_i];
		var _definition = scr_le_registry_get(_placement.type);
		if (is_undefined(_definition)) continue;
		var _proxy = _layer_id == -1
			? instance_create_depth(_placement.x, _placement.y, -1000, obj_level_editor_proxy)
			: instance_create_layer(_placement.x, _placement.y, _layer_id, obj_level_editor_proxy);

		variable_instance_set(_proxy, "editor_manager", _manager);
		variable_instance_set(_proxy, "placement_uid", _placement.uid);
		variable_instance_set(_proxy, "uid", _placement.uid);
		variable_instance_set(_proxy, "type_id", _placement.type);
		variable_instance_set(_proxy, "type", _placement.type);
		variable_instance_set(_proxy, "scale_x", _placement.scale_x);
		variable_instance_set(_proxy, "scale_y", _placement.scale_y);
		variable_instance_set(_proxy, "rotation", _placement.rotation);
		variable_instance_set(_proxy, "variant", _placement.variant);
		variable_instance_set(_proxy, "properties", __scr_le_clone(_placement.properties));
		variable_instance_set(_proxy, "sprite_index", _definition.sprite);
		variable_instance_set(_proxy, "image_xscale", _placement.scale_x);
		variable_instance_set(_proxy, "image_yscale", _placement.scale_y);
		variable_instance_set(_proxy, "image_angle", _placement.rotation);
		variable_instance_set(_proxy, "image_index", _placement.variant);
		_count++;
	}

	__scr_le_owner_set(_manager, "level_data", _level);
	return _count;
}

function scr_le_snapshot(_manager)
{
	var _level = scr_le_collect_editor(_manager);
	if (is_undefined(_level)) return "";

	try
	{
		return json_stringify(_level);
	}
	catch (_exception)
	{
		return "";
	}
}

function scr_le_apply_editor_snapshot(_manager, _snapshot)
{
	if (!is_string(_snapshot) || _snapshot == "") return false;
	var _current = __scr_le_owner_get(_manager, "level_data", undefined);
	if (!is_struct(_current)) return false;

	try
	{
		var _raw = json_parse(_snapshot);
		if (!is_struct(_raw)) return false;
		/* Undo/redo may restore content, never another level's storage identity. */
		variable_struct_set(_raw, "folder", __scr_le_field(_current, "folder", ""));
		variable_struct_set(_raw, "level_id", __scr_le_field(_current, "level_id", ""));
		var _level = __scr_le_normalize_level(_raw, _raw.folder);
		if (is_undefined(_level) || !scr_le_validate_level(_level)) return false;
		__scr_le_owner_set(_manager, "level_data", _level);
		__scr_le_owner_set(_manager, "camera_x", _level.editor_camera.x);
		__scr_le_owner_set(_manager, "camera_y", _level.editor_camera.y);
		__scr_le_owner_set(_manager, "camera_width", _level.editor_camera.width);
		__scr_le_owner_set(_manager, "camera_height", _level.editor_camera.height);
		__scr_le_owner_set(_manager, "camera_zoom", _level.editor_camera.zoom);
		__scr_le_owner_set(_manager, "cam_x", _level.editor_camera.x);
		__scr_le_owner_set(_manager, "cam_y", _level.editor_camera.y);
		__scr_le_owner_set(_manager, "cam_w", _level.editor_camera.width);
		__scr_le_owner_set(_manager, "cam_h", _level.editor_camera.height);
		scr_le_spawn_editor_proxies(_manager);
		return true;
	}
	catch (_exception)
	{
		return false;
	}
}

function __scr_le_canonical(_value)
{
	if (is_undefined(_value)) return "null";
	if (is_bool(_value)) return _value ? "true" : "false";
	if (is_real(_value)) return string(_value);
	if (is_string(_value)) return json_stringify(_value);

	if (is_array(_value))
	{
		var _array_text = "[";
		for (var _i = 0; _i < array_length(_value); _i++)
		{
			if (_i > 0) _array_text += ",";
			_array_text += __scr_le_canonical(_value[_i]);
		}
		return _array_text + "]";
	}

	if (is_struct(_value))
	{
		var _names = struct_get_names(_value);
		array_sort(_names, true);
		var _struct_text = "{";
		for (var _name_index = 0; _name_index < array_length(_names); _name_index++)
		{
			if (_name_index > 0) _struct_text += ",";
			var _name = _names[_name_index];
			_struct_text += json_stringify(_name) + ":" + __scr_le_canonical(variable_struct_get(_value, _name));
		}
		return _struct_text + "}";
	}

	return json_stringify(string(_value));
}

function scr_le_digest(_level_data)
{
	var _copy = __scr_le_clone(_level_data);
	var _level = __scr_le_normalize_level(_copy, __scr_le_field(_copy, "folder", ""));
	if (is_undefined(_level)) return "";
	var _canonical_placements = [];

	for (var _i = 0; _i < array_length(_level.placements); _i++)
	{
		var _placement = _level.placements[_i];
		_canonical_placements[array_length(_canonical_placements)] = {
			uid: _placement.uid,
			type: _placement.type,
			x: _placement.x,
			y: _placement.y,
			scale_x: _placement.scale_x,
			scale_y: _placement.scale_y,
			rotation: _placement.rotation,
			variant: _placement.variant,
			properties: _placement.properties
		};
	}

	var _gameplay = {
		format_version: _level.format_version,
		dimensions: _level.dimensions,
		player_start: _level.player_start,
		goal: _level.goal,
		daily_build: _level.daily_build,
		daily_palette: _level.daily_palette,
		placements: _canonical_placements,
		unknown_placements: _level.unknown_placements
	};

	return string_lower(sha1_string_utf8(__scr_le_canonical(_gameplay)));
}

function scr_le_clear_verification(_level_data)
{
	if (!is_struct(_level_data)) return _level_data;
	_level_data.verification = {
		verified: false, digest: "", verified_at: "", game_version: "",
		difficulty: "normal", character: "", debug_used: false
	};
	return _level_data;
}

function scr_le_mark_verified(_level_data, _difficulty = "normal", _character = "", _debug_used = false)
{
	if (!is_struct(_level_data)) return _level_data;
	var _digest = scr_le_digest(_level_data);
	_level_data.verification = {
		verified: _digest != "" && !_debug_used,
		digest: _digest,
		verified_at: scr_le_timestamp(),
		game_version: scr_get_build_date(),
		difficulty: string(_difficulty),
		character: string(_character),
		debug_used: _debug_used
	};
	return _level_data;
}

function scr_le_verification_valid(_level_data)
{
	if (!is_struct(_level_data)) return false;
	var _verification = __scr_le_field(_level_data, "verification", undefined);
	if (!is_struct(_verification)) return false;
	if (!__scr_le_bool(__scr_le_field(_verification, "verified", false), false)) return false;
	if (__scr_le_bool(__scr_le_field(_verification, "debug_used", false), false)) return false;
	var _stored_digest = __scr_le_text(__scr_le_field(_verification, "digest", ""), "");
	return _stored_digest != "" && _stored_digest == scr_le_digest(_level_data);
}

function scr_le_verify_level(_folder_or_id, _expected_digest)
{
	var _level = scr_le_load_level(_folder_or_id);
	if (is_undefined(_level)) return false;
	var _current_digest = scr_le_digest(_level);
	if (_current_digest == "" || _current_digest != string(_expected_digest)) return false;
	scr_le_mark_verified(_level);
	return scr_le_save_level(_level);
}

function __scr_le_runtime_property(_saved_properties, _name, _fallback)
{
	var _value = __scr_le_field(_saved_properties, _name, _fallback);
	if (is_real(_fallback)) return __scr_le_number(_value, _fallback);
	if (is_bool(_fallback)) return __scr_le_bool(_value, _fallback);
	if (is_string(_fallback)) return __scr_le_text(_value, _fallback);
	return _value;
}

function scr_le_spawn_runtime(_level_data)
{
	var _copy = __scr_le_clone(_level_data);
	var _level = __scr_le_normalize_level(_copy, __scr_le_field(_copy, "folder", ""));
	if (is_undefined(_level) || !scr_le_validate_level(_level)) return [];
	var _created = [];
	var _layer_id = layer_get_id("Instances");

	for (var _i = 0; _i < array_length(_level.placements); _i++)
	{
		var _placement = _level.placements[_i];
		var _definition = scr_le_registry_get(_placement.type);
		if (is_undefined(_definition)) continue;
		var _instance = _layer_id == -1
			? instance_create_depth(_placement.x, _placement.y, 0, _definition.object_asset)
			: instance_create_layer(_placement.x, _placement.y, _layer_id, _definition.object_asset);
		_instance.image_xscale = _placement.scale_x;
		_instance.image_yscale = _placement.scale_y;
		_instance.image_angle = _placement.rotation;
		_instance.image_index = _placement.variant;

		var _property_names = struct_get_names(_definition.default_properties);
		for (var _property_index = 0; _property_index < array_length(_property_names); _property_index++)
		{
			var _property_name = _property_names[_property_index];
			var _default_value = variable_struct_get(_definition.default_properties, _property_name);
			var _property_value = __scr_le_runtime_property(_placement.properties, _property_name, _default_value);

			if (_placement.type == "moving_platform" && _property_name == "radius")
				_property_value = clamp(_property_value, 0, 4096);
			if (_placement.type == "moving_platform" && _property_name == "rot_spd")
				_property_value = clamp(_property_value, -20, 20);

			variable_instance_set(_instance, _property_name, _property_value);
		}

		_created[array_length(_created)] = _instance;
	}

	return _created;
}

function scr_le_folder_opening_is_enabled()
{
	// Linux keeps the manual folder fallback while the migrated extension awaits runtime validation.
	return os_type == os_windows
		|| os_type == os_macosx;
}

function scr_le_folder_clipboard_is_enabled()
{
	return os_type == os_windows || os_type == os_macosx;
}

function scr_le_folder_modal_text(_result)
{
	if (_result == LEFolderOpenResult.FailedToCreate)
	{
		return "The game could not create the custom-level folder. Check that it can write to its local save-data folder, then try again.";
	}

	if (_result == LEFolderOpenResult.Disabled)
	{
		return "Opening folders is not available on this platform.";
	}

	var _intro = _result == LEFolderOpenResult.Opened
		? "The game asked your operating system to open the custom-level folder."
		: "The folder is ready, but the file manager could not be started automatically.";

	if (os_type == os_windows)
	{
		return _intro + "\n\nIf Explorer did not appear, choose Copy to Clipboard, press Windows + R, paste the path, and press Enter.";
	}

	if (os_type == os_macosx)
	{
		return _intro + "\n\nIf Finder did not appear, choose Copy to Clipboard, press Shift + Command + G, paste the path, and press Return.";
	}

	return _intro + "\n\nIf your file manager did not appear, press Alt + F2, type the displayed path, and press Enter.";
}

function scr_le_censored_path(_path = "")
{
	scr_le_init();
	var _text = _path == "" ? global.le_root : string(_path);
	var _save_root = string(game_save_id);
	var _forward_root = string_replace_all(_save_root, "\\", "/");
	var _contains_save_root = string_pos(_save_root, _text) > 0
		|| string_pos(_forward_root, string_replace_all(_text, "\\", "/")) > 0;

	if (_contains_save_root)
	{
		var _username = environment_get_variable("USERNAME");
		if (_username == "") _username = environment_get_variable("USER");
		if (_username != "") _text = string_replace_all(_text, _username, "*");
	}

	return string_replace_all(_text, "\\", "/");
}

function scr_le_open_levels_folder()
{
	if (!scr_le_folder_opening_is_enabled()) return LEFolderOpenResult.Disabled;
	if (!scr_le_ensure_directories()) return LEFolderOpenResult.FailedToCreate;

	var _folder = string(global.le_root);
	while (string_length(_folder) > 0)
	{
		var _last_character = string_char_at(_folder, string_length(_folder));
		if (_last_character != "/" && _last_character != "\\") break;
		_folder = string_delete(_folder, string_length(_folder), 1);
	}

	var _shell_path = _folder;
	var _process_id = 0;

	try
	{
		if (os_type == os_windows)
		{
			_folder = string_replace_all(_folder, "/", "\\");
			_shell_path = string_replace_all(_folder, "\"", "\"\"");
			_process_id = execute_shell("explorer", "\"" + _shell_path + "\"");
		}
		else if (os_type == os_macosx)
		{
			_folder = string_replace_all(_folder, "\\", "/");
			_shell_path = string_replace_all(_folder, "\"", "\\\"");
			_process_id = execute_shell("open", "\"" + _shell_path + "\"");
		}
		else
		{
			_folder = string_replace_all(_folder, "\\", "/");
			_shell_path = string_replace_all(_folder, "\"", "\\\"");
			_process_id = execute_shell("xdg-open", "\"" + _shell_path + "\"");
		}
	}
	catch (_exception)
	{
		return LEFolderOpenResult.ManualOpenNeeded;
	}

	return _process_id > 0
		? LEFolderOpenResult.Opened
		: LEFolderOpenResult.ManualOpenNeeded;
}

function scr_le_capture_thumbnail(_path)
{
	if (!surface_exists(application_surface)) return false;
	var _directory = filename_dir(_path);
	if (_directory != "" && !directory_exists(_directory)) directory_create(_directory);
	var _thumbnail = surface_create(384, 216);
	if (!surface_exists(_thumbnail)) return false;

	surface_set_target(_thumbnail);
	draw_clear_alpha(c_black, 1);
	draw_surface_stretched(application_surface, 0, 0, 384, 216);
	surface_reset_target();
	surface_save(_thumbnail, _path);
	surface_free(_thumbnail);
	return file_exists(_path);
}
