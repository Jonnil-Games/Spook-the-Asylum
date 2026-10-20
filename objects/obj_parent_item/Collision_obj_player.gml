/// @description obj_parent_item Collision with obj_player Event

/* Cache our ID before we change context */
var iid = item_id;

/* Find your inventory and add the item */
var inv = instance_find(obj_camera, 0);

if (inv != noone)
{
	with (inv)
	{
		scr_add_item(iid, 1);
	}
}

/* Now remove the pickup */
instance_destroy();