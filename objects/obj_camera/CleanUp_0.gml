/// @description Release per-camera inventory data

if (variable_instance_exists(id, "inventory_id_grid")
&&  ds_exists(inventory_id_grid, ds_type_grid))
{
	ds_grid_destroy(inventory_id_grid);
}

if (variable_instance_exists(id, "inventory_amt_grid")
&&  ds_exists(inventory_amt_grid, ds_type_grid))
{
	ds_grid_destroy(inventory_amt_grid);
}
