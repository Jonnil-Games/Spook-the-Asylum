function scr_hud_hearts()
{
	/* Top-left of the first heart */
	var xx = inventory_x;
	var yy = inventory_y - 32;
	
	/* Bail if no player */
	if (!instance_exists(obj_player))
	{
		return;
	}
	
	/* Current and maximum HP (hp_max in HP units, 4 HP = 1 full heart) */
	var hud_hp		= global.hp;
	var hud_hp_max	= global.hp_max;
	
	/* How many heart sprites we need (round up so partial hearts get their icon) */
	var heart_count = ceil(hud_hp_max / 4);
	
	/* Get sprite width so we can space them nicely */
	var heart_w = sprite_get_width(spr_hud_hearts);
	var spacing = heart_w + 2; /* 2px padding between hearts */
	var last_heart_x = xx;
	
	#region /* Draw each heart */
	for (var i = 0; i < heart_count; i++)
	{
		/* How many HP remain in this heart slot (0–4) */
		var hp_this_heart = clamp(hud_hp - i * 4, 0, 4);
		
		/* Map HP to subimage: 4HP→0 (full), 3HP→1 (¾), 2HP→2 (½), 1HP→3 (¼), 0HP→4 (empty) */
		var subimg = 4 - hp_this_heart;
		
		/* Shake the hearts when health is dangerously low */
		if (hud_hp <= 8)
		{
			yy += random_range(-5, +5);
		}
		
		last_heart_x = xx + i * spacing;
		
		/* Draw it */
		draw_sprite_ext(
			spr_hud_hearts,
			subimg,
			last_heart_x,
			yy,
			1, 1,		/* Scale x/y */
			0,			/* Rotation */
			c_white, 1	/* Color & alpha */
		);
		
		yy = inventory_y - 32;
	}
	#endregion /* Draw each heart END */
	
	#region /* Piece of Heart Progression */
	if (global.piece_of_heart >= 1)
	{
		draw_sprite_ext(
			spr_piece_of_heart,
			0,
			last_heart_x + 40,
			yy,
			1, 1,		/* Scale x/y */
			0,			/* Rotation */
			c_white, 1	/* Color & alpha */
		);
	}
	
	if (global.piece_of_heart >= 2)
	{
		draw_sprite_ext(
			spr_piece_of_heart,
			1,
			last_heart_x + 40,
			yy,
			1, 1,		/* Scale x/y */
			0,			/* Rotation */
			c_white, 1	/* Color & alpha */
		);
	}
	
	if (global.piece_of_heart >= 3)
	{
		draw_sprite_ext(
			spr_piece_of_heart,
			2,
			last_heart_x + 40,
			yy,
			1, 1,		/* Scale x/y */
			0,			/* Rotation */
			c_white, 1	/* Color & alpha */
		);
	}
	
	if (global.piece_of_heart >= 4)
	{
		draw_sprite_ext(
			spr_piece_of_heart,
			3,
			last_heart_x + 40,
			yy,
			1, 1,		/* Scale x/y */
			0,			/* Rotation */
			c_white, 1	/* Color & alpha */
		);
	}
	#endregion /* Piece of Heart Progression END */
	
}