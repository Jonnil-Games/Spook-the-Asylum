function scr_item_defs()
{
	/* These are your master IDs. You can add more entries here as you go */
	enum ITEM_ID
	{
		Stone = 0,
		Wood,
		IronOre,
		Diamond,
		Axe,
		
		Count /* Always keep a 'Count' at the end */
	}
	
	/* Make sure we only do this once */
	if (!variable_global_exists("item_data_ready"))
	{
		item_data_ready = true;
		
		/* Make parallel arrays of length ITEM_ID.Count */
		global.item_sprites		= array_create(ITEM_ID.Count);
		global.item_names		= array_create(ITEM_ID.Count);
		global.item_maxstack	= array_create(ITEM_ID.Count);
		
		/* Fill in each entry
		[ID]	sprite		display name		stack cap */
		global.item_sprites		[ ITEM_ID.Stone  ] = spr_missing_texture_1;
		global.item_names		[ ITEM_ID.Stone  ] = "Stone Block";
		global.item_maxstack	[ ITEM_ID.Stone  ] = 64;
		
		global.item_sprites		[ ITEM_ID.Wood   ] = spr_missing_texture_2;
		global.item_names		[ ITEM_ID.Wood   ] = "Wood Log";
		global.item_maxstack	[ ITEM_ID.Wood   ] = 64;
		
		global.item_sprites		[ ITEM_ID.IronOre] = spr_missing_texture_3;
		global.item_names		[ ITEM_ID.IronOre] = "Iron Ore";
		global.item_maxstack	[ ITEM_ID.IronOre] = 64;
		
		global.item_sprites		[ ITEM_ID.Diamond ] = spr_missing_texture_4;
		global.item_names		[ ITEM_ID.Diamond ] = "Diamond";
		global.item_maxstack	[ ITEM_ID.Diamond ] = 64;
		
		global.item_sprites		[ ITEM_ID.Axe ] = spr_axe;
		global.item_names		[ ITEM_ID.Axe ] = "Axe";
		global.item_maxstack	[ ITEM_ID.Axe ] = 1;
	}
}
