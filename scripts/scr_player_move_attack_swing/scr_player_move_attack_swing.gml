function scr_player_move_attack_swing()
{
	if (attack_swing)
	{
		sprite_index = spr_attack_swing;
		image_speed = 0.5;
		
		if (image_index > image_number - 1)
		{
			attack_swing = false;
		}
	}
}