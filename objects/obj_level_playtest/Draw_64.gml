/// @description Draw playtest and verification guidance

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

draw_set_alpha(0.76);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, 46, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(18, 23, level_data.display_name);
draw_set_halign(fa_center);
var mode_label = (playtest_mode == "clear") ? "VERIFY FROM START" : ((playtest_mode == "quick") ? "QUICK TEST" : "PLAYING CUSTOM LEVEL");
draw_text(gui_w * 0.5, 23, mode_label);
draw_set_halign(fa_right);
draw_text(gui_w - 18, 23, "Esc: Return   R: Restart");

if (completed)
{
	draw_set_alpha(0.78);
	draw_set_color(c_black);
	draw_rectangle(0, 0, gui_w, gui_h, false);
	draw_set_alpha(1);

	var panel_color = completion_success ? make_color_rgb(28, 76, 58) : make_color_rgb(86, 42, 48);
	draw_set_color(panel_color);
	draw_roundrect(358, 236, 1008, 532, false);
	draw_set_color(completion_success ? make_color_rgb(112, 245, 166) : make_color_rgb(255, 145, 145));
	draw_roundrect(358, 236, 1008, 532, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed(683, 300, completion_title, 1.7, 1.7, 0);
	draw_set_color(c_white);
	draw_text_ext(683, 370, completion_detail, 24, 560);
	draw_text(683, 474, "Press Enter, Space, F5, or click to return");
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
