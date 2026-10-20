/// @description obj_camera Alarm 0

#region /* Set Backgrounds */
layer_background_sprite(layer_background_get_id(layer_get_id("background_1")), custom_background_1);
layer_background_sprite(layer_background_get_id(layer_get_id("background_2")), custom_background_2);
layer_background_sprite(layer_background_get_id(layer_get_id("background_3")), custom_background_3);
layer_background_sprite(layer_background_get_id(layer_get_id("background_4")), custom_background_4);
#endregion /* Set Backgrounds END */

if (custom_background_1 == noone)
{
	layer_background_visible(layer_background_get_id(layer_get_id("background_1")), false);
}
if (custom_background_2 == noone)
{
	layer_background_visible(layer_background_get_id(layer_get_id("background_2")), false);
}
if (custom_background_3 == noone)
{
	layer_background_visible(layer_background_get_id(layer_get_id("background_3")), false);
}
if (custom_background_4 == noone)
{
	layer_background_visible(layer_background_get_id(layer_get_id("background_4")), false);
}

#region /* Set if background is horizontally or vertically tiled */
layer_background_htiled(layer_background_get_id(layer_get_id("background_1")), custom_background_1_htiled);
layer_background_vtiled(layer_background_get_id(layer_get_id("background_1")), custom_background_1_vtiled);
layer_background_htiled(layer_background_get_id(layer_get_id("background_2")), custom_background_2_htiled);
layer_background_vtiled(layer_background_get_id(layer_get_id("background_2")), custom_background_2_vtiled);
layer_background_htiled(layer_background_get_id(layer_get_id("background_3")), custom_background_3_htiled);
layer_background_vtiled(layer_background_get_id(layer_get_id("background_3")), custom_background_3_vtiled);
layer_background_htiled(layer_background_get_id(layer_get_id("background_4")), custom_background_4_htiled);
layer_background_vtiled(layer_background_get_id(layer_get_id("background_4")), custom_background_4_vtiled);
#endregion /* Set if background is horizontally or vertically tiled END */

layer_background_alpha(layer_background_get_id(layer_get_id("background_1")), custom_background_1_alpha);
layer_background_alpha(layer_background_get_id(layer_get_id("background_2")), custom_background_2_alpha);
layer_background_alpha(layer_background_get_id(layer_get_id("background_3")), custom_background_3_alpha);
layer_background_alpha(layer_background_get_id(layer_get_id("background_4")), custom_background_4_alpha);

layer_background_blend(layer_background_get_id(layer_get_id("background_1")), custom_background_1_color);
layer_background_blend(layer_background_get_id(layer_get_id("background_2")), custom_background_2_color);
layer_background_blend(layer_background_get_id(layer_get_id("background_3")), custom_background_3_color);
layer_background_blend(layer_background_get_id(layer_get_id("background_4")), custom_background_4_color);