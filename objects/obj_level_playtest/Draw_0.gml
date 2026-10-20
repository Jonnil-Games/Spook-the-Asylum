/// @description Draw the custom-level exit portal

var pulse = 4 + sin(current_time * 0.006) * 4;
draw_set_alpha(0.28);
draw_set_color(make_color_rgb(214, 88, 245));
draw_circle(goal_x, goal_y, 54 + pulse, false);
draw_set_alpha(0.72);
draw_circle(goal_x, goal_y, 36 + pulse * 0.5, true);
draw_circle(goal_x, goal_y, 24, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text(goal_x, goal_y - 62, "EXIT");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
