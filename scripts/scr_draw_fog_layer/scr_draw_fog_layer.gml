function scr_draw_fog_layer()
{
	if (obj_debug_manager.debug_screen)
	{
		// Decrease fog alpha
		if (keyboard_check(vk_subtract))
		{
			if (keyboard_check(ord("A"))) fog_alpha = clamp(fog_alpha - 0.01, 0, 1);
			if (keyboard_check(ord("M"))) fog_amplitude = clamp(fog_amplitude - 0.01, 0, 1);
			if (keyboard_check(ord("F"))) fog_frequency = clamp(fog_frequency - 0.01, 0, 1);
			if (keyboard_check(ord("S"))) fog_speed = clamp(fog_speed - 0.01, 0, 1);
		}
	
		// Increase fog alpha
		if (keyboard_check(vk_add))
		{
		    if (keyboard_check(ord("A"))) fog_alpha = clamp(fog_alpha + 0.01, 0, 1)
			if (keyboard_check(ord("M"))) fog_amplitude = clamp(fog_amplitude + 0.01, 0, 1);
			if (keyboard_check(ord("F"))) fog_frequency = clamp(fog_frequency + 0.01, 0, 1);
			if (keyboard_check(ord("S"))) fog_speed = clamp(fog_speed + 0.01, 0, 1);
		}
	}
	
	
	
    shader_set(shd_fog_wave);
	
    // Set the uniforms
    shader_set_uniform_f(shader_get_uniform(shd_fog_wave, "u_time"), fog_time);
    shader_set_uniform_f(shader_get_uniform(shd_fog_wave, "u_amplitude"), fog_amplitude);
    shader_set_uniform_f(shader_get_uniform(shd_fog_wave, "u_frequency"), fog_frequency);
    shader_set_uniform_f(shader_get_uniform(shd_fog_wave, "u_speed"), fog_speed);
	
    gpu_set_blendmode(bm_add);
	
    // Draw one large quad covering the camera view
    var view_x = camera_get_view_x(view_camera[0]);
    var view_y = camera_get_view_y(view_camera[0]);
    var view_w = camera_get_view_width(view_camera[0]);
    var view_h = camera_get_view_height(view_camera[0]);
	
    // We'll repeat the texture multiple times
    var repeat_u = (view_w / sprite_get_width(spr_fog)) * 2; 
    var repeat_v = (view_h / sprite_get_height(spr_fog)) * 2; 
	
    // Update fog offset for a slow scrolling effect
	fog_offset_x += fog_speed_x;
	fog_offset_y += fog_speed_y;
	fog_time += 0.01;
	
	draw_set_alpha(fog_alpha);
	
    scr_draw_fog_quad(view_x, view_y, view_w, view_h,
                      fog_offset_x, fog_offset_y,
                      repeat_u, repeat_v);
	
	draw_set_alpha(1);
	
    gpu_set_blendmode(bm_normal);
    shader_reset();
}
