/// @description scr_use_item(item_id, origin_x, origin_y)
function scr_use_item(item_id)
{
	switch (item_id)
	{
		case ITEM_ID.Axe:
			if (!attack_swing)
			{
				attack_swing = true;
				image_index = 0;
			}
	        break;
		
	    // ...and so on for each ITEM_ID
		
	    default:
	        // nothing to do (e.g. consumable, or unimplemented)
	        break;
	}
}
