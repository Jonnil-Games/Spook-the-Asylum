/// @description obj_camera Room Start

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

/* Set camera coordinates at start of room */
final_cam_x = cam_x;
final_cam_y = cam_y;