function scr_inventory_create()
{
	/* Inventory Grid Setup. Where should the inventory be placed on the screen */
	inventory_x = 100;
	inventory_y = 100;
	inventory_width = 12;
	inventory_height = 4; /* Last row is the hotbar */
	slot_size = 40;
	margin = 5;
	hotbar_y = display_get_gui_height() - 50;
	hotbar_color_bg = c_white;
	hotbar_color_slot = c_dkgray;
	selected_hotbar_slot = 0;
	selected_hotbar_slot_x = inventory_x;
	
	/* How much extra space between main grid and hotbar */
	hotbar_sep = margin * 3;
	hotbar_row = inventory_height - 1;
	
	inventory_id_grid = ds_grid_create(inventory_width, inventory_height);
	inventory_amt_grid = ds_grid_create(inventory_width, inventory_height);
	
	for (var i = 0; i < inventory_width; i++)
	{
		for (var j = 0; j < inventory_height; j++)
		{
			inventory_id_grid[# i, j] = 0;
			inventory_amt_grid[# i, j] = 0;
		}
	}
	
	inventory_visible = false;
	dragging = false;
	dragged_item_id = 0;
	dragged_item_amt = 0;
	drag_src_x = -1;
	drag_src_y = -1;
	
	/* ---- Special quick-slots setup ---- */
	action_slot_count	= 4;
	// Holds item_id, item_amt for each of the 4 slots
	action_id_array		= array_create(action_slot_count, 0);
	action_amt_array	= array_create(action_slot_count, 0);
	/* Diamond offsets: up, left, right, down */
	action_offset_x		= [  0, -1,  1,  0 ];
	action_offset_y		= [ -1,  0,  0,  1 ];
	/* We'll compute the center point in draw step, after hotbar_y has settled */
}

function scr_inventory_step()
{
    /* Toggle with E or I */
    if (keyboard_check_pressed(ord("E")))
    || (keyboard_check_pressed(ord("I")))
    {
        inventory_visible = !inventory_visible;
    }

    #region /* Controlling the Hotbar */
    if (!inventory_visible)
    {
        if (mouse_wheel_up())
        {
            selected_hotbar_slot --;
            if (selected_hotbar_slot <= -1)
            {
                selected_hotbar_slot = inventory_width - 1;
            }
        }

        if (mouse_wheel_down())
        {
            selected_hotbar_slot ++;
            if (selected_hotbar_slot >= inventory_width)
            {
                selected_hotbar_slot = 0;
            }
        }

        #region /* Hotbar Hotkeys */
        var keycodes = [
            ord("1"), ord("2"), ord("3"), ord("4"), ord("5"),
            ord("6"), ord("7"), ord("8"), ord("9"), ord("0"),
            187, 219
        ];

        for (var i = 0; i < array_length(keycodes); i++)
        {
            if (keyboard_check_pressed(keycodes[i]))
            {
                selected_hotbar_slot = i;
                break;
            }
        }
        #endregion /* Hotbar Hotkeys END */

        return;
    }
    #endregion /* Controlling the Hotbar END */

    /* Get mouse in GUI coords */
    var mx_gui = device_mouse_x_to_gui(0);
    var my_gui = device_mouse_y_to_gui(0);

    /* Check main inventory */
    var over_main = false;
    var mcol = floor((mx_gui - inventory_x - margin) / (slot_size + margin));
    var mrow = floor((my_gui - inventory_y - margin) / (slot_size + margin));
    if (mcol >= 0
    &&  mcol < inventory_width
    &&  mrow >= 0
    &&  mrow < inventory_height - 1)
    {
        over_main = true;
    }

    /* Check hotbar */
    var over_hot = false;
    var hcol = floor((mx_gui - inventory_x - margin) / (slot_size + margin));
    if (hcol >= 0
    &&  hcol < inventory_width)
    {
        var hy = hotbar_y + margin;
        if (my_gui >= hy
        &&  my_gui < hy + slot_size)
        {
            over_hot = true;
        }
    }

    /* Check special “diamond” action-slots */
    var over_special	= false;
    var special_idx		= -1;
    var total_w			= (slot_size + margin) * inventory_width + margin;
    
    for (var i = 0; i < action_slot_count; i++)
    {
        var sx = global.center_action_slots_x
            + action_offset_x[i] * (slot_size + margin);
        var sy = global.center_action_slots_y
            + action_offset_y[i] * (slot_size + margin);

        if (mx_gui >= sx
        &&  mx_gui <  sx + slot_size
        &&  my_gui >= sy
        &&  my_gui <  sy + slot_size)
        {
            over_special = true;
            special_idx  = i;
            break;
        }
    }

    /* PICK UP on press */
    if (mouse_check_button_pressed(mb_left)
    &&  !dragging)
    {
        if (over_main)
        {
            var item_id = inventory_id_grid[# mcol, mrow];
            if (item_id != 0)
            {
                dragging         = true;
                dragged_item_id  = item_id;
                dragged_item_amt = inventory_amt_grid[# mcol, mrow];
                drag_src_x       = mcol;
                drag_src_y       = mrow;
                inventory_id_grid[# mcol, mrow]   = 0;
                inventory_amt_grid[# mcol, mrow]  = 0;
            }
        }
        else if (over_hot)
        {
            var item_id = inventory_id_grid[# hcol, hotbar_row];
            if (item_id != 0)
            {
                dragging         = true;
                dragged_item_id  = item_id;
                dragged_item_amt = inventory_amt_grid[# hcol, hotbar_row];
                drag_src_x       = hcol;
                drag_src_y       = hotbar_row;
                inventory_id_grid[# hcol, hotbar_row]  = 0;
                inventory_amt_grid[# hcol, hotbar_row] = 0;
            }
        }
        else if (over_special)
        {
            var item_id = action_id_array[special_idx];
            if (item_id != 0)
            {
                dragging         = true;
                dragged_item_id  = item_id;
                dragged_item_amt = action_amt_array[special_idx];
                drag_src_special = special_idx;
                action_id_array[special_idx]  = 0;
                action_amt_array[special_idx] = 0;
            }
        }
    }

    #region /* DROP item on release */
    if (mouse_check_button_released(mb_left)
    &&  dragging)
    {
        var drop_col     = -1;
        var drop_row     = -1;
        var drop_special = -1;

        if (over_main)
        {
            drop_col = mcol;
            drop_row = mrow;
        }
        else if (over_hot)
        {
            drop_col = hcol;
            drop_row = hotbar_row;
        }
        else if (over_special)
        {
            drop_special = special_idx;
        }

        if (drop_special >= 0)
        {
            /* Handle special slots as before… */
            var target_id  = action_id_array[drop_special];
            var target_amt = action_amt_array[drop_special];
            var cap        = global.item_maxstack[dragged_item_id];

            if (target_id == 0
            ||  target_id == dragged_item_id)
            {
                var total = target_amt + dragged_item_amt;
                action_id_array[drop_special]  = dragged_item_id;
                action_amt_array[drop_special] = min(total, cap);
                var leftover = total - action_amt_array[drop_special];
                if (leftover > 0)
                {
                    if (drag_src_special >= 0)
                    {
                        action_id_array[drag_src_special]  = dragged_item_id;
                        action_amt_array[drag_src_special] = leftover;
                    }
                    else
                    {
                        inventory_id_grid[# drag_src_x, drag_src_y]   = dragged_item_id;
                        inventory_amt_grid[# drag_src_x, drag_src_y]  = leftover;
                    }
                }
            }
            else
            {
                var old_id  = action_id_array[drop_special];
                var old_amt = action_amt_array[drop_special];
                action_id_array[drop_special]  = dragged_item_id;
                action_amt_array[drop_special] = dragged_item_amt;

                if (drag_src_special >= 0)
                {
                    action_id_array[drag_src_special]  = old_id;
                    action_amt_array[drag_src_special] = old_amt;
                }
                else
                {
                    inventory_id_grid[# drag_src_x, drag_src_y]   = old_id;
                    inventory_amt_grid[# drag_src_x, drag_src_y]  = old_amt;
                }
            }
        }
        else
        {
            /* main/hotbar (your existing logic) */
            /* — copy your original main/hot drop code here — */

            /* Figure out where to drop */
            var drop_col2, drop_row2;
            if (over_main)
            {
                drop_col2 = mcol;
                drop_row2 = mrow;
            }
            else if (over_hot)
            {
                drop_col2 = hcol;
                drop_row2 = hotbar_row;
            }

            /* Now handle drop */
            if (over_main
            ||  over_hot)
            {
                var target_id = inventory_id_grid[# drop_col2, drop_row2];
                var target_amt = inventory_amt_grid[# drop_col2, drop_row2];
                var cap = global.item_maxstack[dragged_item_id];

                if (target_id == 0
                ||  target_id == dragged_item_id)
                {
                    /* Stack into the slot */
                    var total = target_amt + dragged_item_amt;
                    inventory_id_grid[# drop_col2, drop_row2] = dragged_item_id;
                    inventory_amt_grid[# drop_col2, drop_row2] = min(total, cap);
                    var leftover = total - inventory_amt_grid[# drop_col2, drop_row2];

                    if (leftover > 0)
                    {
                        /* Return any extra back to origin */
                        inventory_id_grid[# drag_src_x, drag_src_y]   = dragged_item_id;
                        inventory_amt_grid[# drag_src_x, drag_src_y]  = leftover;
                    }
                }
                else
                {
                    /* Swap items and put dragged into target */
                    inventory_id_grid[# drop_col2, drop_row2]   = dragged_item_id;
                    inventory_amt_grid[# drop_col2, drop_row2] = dragged_item_amt;
                    /* Send the old target back to origin */
                    inventory_id_grid[# drag_src_x, drag_src_y]   = target_id;
                    inventory_amt_grid[# drag_src_x, drag_src_y]  = target_amt;
                }
            }
            else
            {
                /* Dropped outside both grids, return to origin */
                inventory_id_grid[# drag_src_x, drag_src_y]   = dragged_item_id;
                inventory_amt_grid[# drag_src_x, drag_src_y]  = dragged_item_amt;
            }
        }

        /* Done dragging */
        dragging = false;
    }
    #endregion /* DROP item on release END */
	
}

function scr_inventory_draw_gui()
{
	/* Draw Backgrounds */
	draw_set_alpha(0.5);
	var total_w = (slot_size + margin) * inventory_width + margin;
	var main_h  = (slot_size + margin) * (inventory_height - 1) + margin;
	
	if (inventory_visible)
	{
		/* Main Inventory Background */
		draw_set_color(c_white);
		draw_rectangle(
			inventory_x,
			inventory_y,
			inventory_x + total_w,
			inventory_y + main_h,
			false
		);
	}
	
	draw_set_alpha(1);
	
	#region /* Draw Main Slots */
	if (inventory_visible)
	{
		for (var i = 0; i < inventory_width; i++)
		{
			for (var j = 0; j < inventory_height - 1; j++)
			{
				var sx = inventory_x + margin + i * (slot_size + margin);
				var sy = inventory_y + margin + j * (slot_size + margin);
				
				draw_set_color(c_dkgray);
				draw_rectangle(sx, sy, sx + slot_size, sy + slot_size, false);
				
				var item_id = inventory_id_grid[# i, j];
				var amt	 = inventory_amt_grid[# i, j];
				
				if (item_id != 0)
				{
					var spr   = global.item_sprites[item_id];
					var sw	= sprite_get_width(spr);
					var sh	= sprite_get_height(spr);
					var scale = min(slot_size / sw, slot_size / sh);
					
					draw_sprite_ext(
						spr, 0,
						sx + slot_size/2,
						sy + slot_size/2,
						scale, scale,
						0, c_white, 1
					);
					
					if (amt != 1)
					{
						draw_set_halign(fa_right);
						scr_draw_text_outlined(
							sx + slot_size - 2,
							sy + slot_size - 2,
							string(amt)
						);
					}
				}
			}
		}
		
		hotbar_y		 = lerp(hotbar_y, inventory_y + main_h + hotbar_sep, 0.25);
		hotbar_color_bg  = c_white;
		hotbar_color_slot= c_dkgray;
	}
	else
	{
		hotbar_y		 = lerp(hotbar_y, display_get_gui_height() - 50, 0.25);
		hotbar_color_bg  = c_dkgray;
		hotbar_color_slot= c_black;
	}
	#endregion /* Draw Main Slots END */
	
	/* Hotbar Background */
	draw_set_alpha(0.5);
	draw_set_color(hotbar_color_bg);
	draw_rectangle(
		inventory_x,
		hotbar_y,
		inventory_x + total_w,
		hotbar_y + slot_size + (margin * 2),
		false
	);
	
	draw_set_alpha(1);
	
	#region /* Highlight Selected Hotbar Item */
	if (!inventory_visible)
	{
		selected_hotbar_slot_x = lerp(
			selected_hotbar_slot_x,
			inventory_x + (slot_size + margin) * selected_hotbar_slot + margin,
			0.5
		);
		
		draw_rectangle_color(
			selected_hotbar_slot_x - 5,
			hotbar_y,
			selected_hotbar_slot_x + slot_size + 5,
			hotbar_y + slot_size + 10,
			c_white, c_white, c_white, c_white,
			false
		);
	}
	#endregion /* Highlight Selected Hotbar Item END */
	
	#region /* Draw Hotbar Slots */
	for (var i = 0; i < inventory_width; i++)
	{
		var sx = inventory_x + margin + i * (slot_size + margin);
		var sy = hotbar_y + margin;
		
		draw_set_color(hotbar_color_slot);
		draw_rectangle(sx, sy, sx + slot_size, sy + slot_size, false);
		
		var item_id = inventory_id_grid[# i, hotbar_row];
		var amt	 = inventory_amt_grid[# i, hotbar_row];
		
		if (item_id != 0)
		{
			var spr   = global.item_sprites[item_id];
			var sw	= sprite_get_width(spr);
			var sh	= sprite_get_height(spr);
			var scale = min(slot_size / sw, slot_size / sh);
			
			/* Scale up the selected hotbar slot when closed */
			if (!inventory_visible
			&&  selected_hotbar_slot == i)
			{
				scale += 0.1;
			}
			
			draw_sprite_ext(
				spr, 0,
				sx + slot_size/2,
				sy + slot_size/2,
				scale, scale,
				0, c_white, 1
			);
			
			if (amt != 1)
			{
				draw_set_halign(fa_right);
				scr_draw_text_outlined(
					sx + slot_size - 2,
					sy + slot_size - 2,
					string(amt)
				);
			}
		}
	}
	#endregion /* Draw Hotbar Slots END */
	
	/* Draw Diamond “Action Slots” */
	#region /* Draw Special Slots */
	for (var i = 0; i < action_slot_count; i++)
	{
		var sx = global.center_action_slots_x
			+ action_offset_x[i] * (slot_size + margin);
		var sy = global.center_action_slots_y
			+ action_offset_y[i] * (slot_size + margin);
		
		/* slot background */
		draw_set_color(c_dkgray);
		draw_rectangle(sx, sy, sx + slot_size, sy + slot_size, false);
		
		/* draw item if present */
		var item_id = action_id_array[i];
		var amt	 = action_amt_array[i];
		
		if (item_id != 0)
		{
			var spr   = global.item_sprites[item_id];
			var sw	= sprite_get_width(spr);
			var sh	= sprite_get_height(spr);
			var scale = min(slot_size / sw, slot_size / sh);
			
			draw_sprite_ext(
				spr, 0,
				sx + slot_size/2,
				sy + slot_size/2,
				scale, scale,
				0, c_white, 1
			);
			
			if (amt != 1)
			{
				draw_set_halign(fa_right);
				scr_draw_text_outlined(
					sx + slot_size - 2,
					sy + slot_size - 2,
					string(amt)
				);
			}
		}
	}
	#endregion /* Draw Special Slots END */
	
	draw_set_color(c_white);
	
	/* Draw Dragging Sprite */
	if (dragging)
	{
		var mx  = device_mouse_x_to_gui(0);
		var my  = device_mouse_y_to_gui(0);
		var spr = global.item_sprites[dragged_item_id];
		var sw  = sprite_get_width(spr);
		var sh  = sprite_get_height(spr);
		var scale = min(slot_size / sw, slot_size / sh);
		
		draw_sprite_ext(
			spr, 0,
			mx, my,
			scale, scale,
			0, c_white, 1
		);
		
		if (dragged_item_amt != 1)
		{
			draw_set_halign(fa_right);
			scr_draw_text_outlined(
				mx + slot_size/2 - 2,
				my + slot_size/2 - 2,
				string(dragged_item_amt)
			);
		}
	}
}

/* scr_add_item(item_id, amount) */
function scr_add_item(item_id, amount)
{
	/* --- Stack into Hotbar first --- */
	for (var i = 0; i < inventory_width; i++)
	{
		if (inventory_id_grid[# i, hotbar_row] == item_id)
		{
			var space = global.item_maxstack[item_id] - inventory_amt_grid[# i, hotbar_row];
			
			if (space > 0)
			{
				var add_amt = min(space, amount);
				inventory_amt_grid[# i, hotbar_row] += add_amt;
				amount -= add_amt;
				
				if (amount <= 0)
				{
					return;
				}
			}
		}
	}
	
	/* --- Stack into Main Inventory area --- */
	for (var j = 0; j < inventory_height - 1; j++)
	{
		for (var i = 0; i < inventory_width; i++)
		{
			if (inventory_id_grid[# i, j] == item_id)
			{
				var space = global.item_maxstack[item_id] - inventory_amt_grid[# i, j];
				
				if (space > 0)
				{
					var add_amt = min(space, amount);
					inventory_amt_grid[# i, j] += add_amt;
					amount -= add_amt;
					
					if (amount <= 0)
					{
						return;
					}
				}
			}
		}
	}
	
	/* --- Fill empty Hotbar slots --- */
	for (var i = 0; i < inventory_width; i++)
	{
		if (inventory_id_grid[# i, hotbar_row] == 0)
		{
			var add_amt = min(global.item_maxstack[item_id], amount);
			inventory_id_grid[# i, hotbar_row]  = item_id;
			inventory_amt_grid[# i, hotbar_row] = add_amt;
			amount -= add_amt;
			
			if (amount <= 0)
			{
				return;
			}
		}
	}
	
	/* --- Fill empty Main Inventory slots --- */
	for (var j = 0; j < inventory_height - 1; j++)
	{
		for (var i = 0; i < inventory_width; i++)
		{
			if (inventory_id_grid[# i, j] == 0)
			{
				var add_amt = min(global.item_maxstack[item_id], amount);
				inventory_id_grid[# i, j]  = item_id;
				inventory_amt_grid[# i, j] = add_amt;
				amount -= add_amt;
				
				if (amount <= 0)
				{
					return;
				}
			}
		}
	}

	/* --- Stack into Action Slots last --- */
	for (var i = 0; i < action_slot_count; i++)
	{
		if (action_id_array[i] == item_id)
		{
			var space = global.item_maxstack[item_id] - action_amt_array[i];

			if (space > 0)
			{
				var add_amt = min(space, amount);
				action_amt_array[i] += add_amt;
				amount -= add_amt;

				if (amount <= 0)
				{
					return;
				}
			}
		}
	}

	/* --- Fill empty Action Slots last --- */
	for (var i = 0; i < action_slot_count; i++)
	{
		if (action_id_array[i] == 0)
		{
			var add_amt = min(global.item_maxstack[item_id], amount);
			action_id_array[i]  = item_id;
			action_amt_array[i] = add_amt;
			amount -= add_amt;

			if (amount <= 0)
			{
				return;
			}
		}
	}
}
