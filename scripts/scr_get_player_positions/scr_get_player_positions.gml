/// @function scr_get_player_positions()
/* Returns an array of player positions from obj_camera, if available */
function scr_get_player_positions()
{
	var positions = [];
	
	if (instance_exists(obj_camera)
	&& variable_instance_exists(obj_camera, "player")
	&& is_array(obj_camera.player))
	{
		for (var i = 1; i <= global.max_players; i++)
		{
			if (array_length(obj_camera.player) > i
			&& instance_exists(obj_camera.player[i])
			&& obj_camera.player[i] > 0)
			{
				array_push(positions,
				{
					player_pos_id: i,
					player_pos_x: obj_camera.player[i].x,
					player_pos_y: obj_camera.player[i].y,
					player_speed: obj_camera.player[i].speed,
					player_on_ground: obj_camera.player[i].on_ground,
					crouch: obj_camera.player[i].crouch,
					crouch_timer: obj_camera.player[i].crouch_timer,
					draw_angle: obj_camera.player[i].draw_angle
				});
			}
		}
	}
	return positions;
}