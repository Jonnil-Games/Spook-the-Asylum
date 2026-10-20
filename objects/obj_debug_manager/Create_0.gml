/// @description obj_debug_manager Create Event
persistent = true;
depth = -9900;

/* Define a priority list of objects by their object names that the debugger should consider */
debug_target_list = [
	obj_camera,
];

max_fps = 60;
debug_target = noone;
debug_screen = false;
os_info = os_get_info();

//scr_debug_init_cheat_codes();