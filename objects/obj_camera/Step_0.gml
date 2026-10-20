/// @description obj_camera Step

scr_inventory_step();

/* Fullscreen toggle */
if (keyboard_check_pressed(vk_f11))
{
	window_set_fullscreen(!window_get_fullscreen());
}

/* Exit if there is no player */
if (!instance_exists(obj_player)) exit;

/* Get camera size */
var cam_width = camera_get_view_width(view_camera[0]);
var cam_height = camera_get_view_height(view_camera[0]);

/* Get camera target coordinates */
var cam_x = obj_player.x - cam_width * 0.5;
var cam_y = obj_player.y - cam_height * 0.5;

/* Constrain camera to room borders */
cam_x = clamp(cam_x, 0, room_width - cam_width);
cam_y = clamp(cam_y, 0, room_height - cam_height);

/* Set camera coordinate variables */
final_cam_x += (cam_x - final_cam_x) * cam_trail_spd;
final_cam_y += (cam_y - final_cam_y) * cam_trail_spd;

/* Set camera coordinates */
camera_set_view_pos(view_camera[0], final_cam_x, final_cam_y);

/* Quick Restart */
if (keyboard_check_pressed(ord("R")))
{
	room_restart();
}

// Define parallax factors for each background layer
var parallax_background_1 = 0.3;
var parallax_background_2 = 0.2;

// Get the layer IDs (these names must match your layer names in the room)
var layer_background_1_id = layer_get_id("background_1");
var layer_background_2_id = layer_get_id("background_2");

// Update the layer positions based on camera movement and parallax factors
layer_x(layer_background_1_id, final_cam_x * parallax_background_1);
layer_y(layer_background_1_id, final_cam_y * parallax_background_1);

layer_x(layer_background_2_id, final_cam_x * parallax_background_2);
layer_y(layer_background_2_id, final_cam_y * parallax_background_2);

if (inventory_visible)
{
	global.center_action_slots_x = lerp(global.center_action_slots_x, 700, 0.1);
    global.center_action_slots_y = lerp(global.center_action_slots_y, 200, 0.1);
}
else
{
	global.center_action_slots_x = lerp(global.center_action_slots_x, display_get_gui_width() - 96, 0.1);
    global.center_action_slots_y = lerp(global.center_action_slots_y, 64, 0.1);
}