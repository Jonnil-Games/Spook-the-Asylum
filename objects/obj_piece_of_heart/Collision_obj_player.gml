global.piece_of_heart += 1;

if (global.piece_of_heart >= 4)
{
	global.hp_max += 4;
	global.hp += 4;
	global.piece_of_heart = 0;
}

instance_destroy();