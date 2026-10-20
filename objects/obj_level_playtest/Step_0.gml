/// @description Playtest completion, verification, and return controls

if (keyboard_check_pressed(vk_f2)
||  keyboard_check_pressed(vk_f3)
||  keyboard_check_pressed(vk_f4))
{
	global.le_debug_used = true;
}

if (instance_exists(obj_debug_manager) && obj_debug_manager.debug_screen)
{
	global.le_debug_used = true;
}

if (keyboard_check_pressed(vk_escape))
{
	return_from_playtest();
	exit;
}

if (completed)
{
	if (keyboard_check_pressed(vk_enter)
	||  keyboard_check_pressed(vk_space)
	||  keyboard_check_pressed(vk_f5)
	||  mouse_check_button_pressed(mb_left))
	{
		return_from_playtest();
	}
	exit;
}

if (instance_exists(obj_player))
{
	var nearest_player = instance_nearest(goal_x, goal_y, obj_player);
	if (instance_exists(nearest_player)
	&&  point_distance(nearest_player.x, nearest_player.y, goal_x, goal_y) <= 72)
	{
		finish_level();
	}
}
