/// @function scr_draw_fog_quad(x, y, w, h, u_offset, v_offset, u_scale, v_scale)
/// x, y: where to place the quad
/// w, h: width and height of the quad
/// u_offset, v_offset: how much to offset the texture coordinates
/// u_scale, v_scale: how many times the texture repeats
function scr_draw_fog_quad(x, y, w, h, u_offset, v_offset, u_scale, v_scale)
{
    // Get the texture ID from the sprite
    var tex_fog = sprite_get_texture(spr_fog, 0);

    // If you want the UV to wrap automatically (0..2, etc.), enable repeating
    // (Only works if the sprite is power-of-two in size, e.g. 256x256)
    gpu_set_tex_repeat(true);

    draw_primitive_begin_texture(pr_trianglestrip, tex_fog);

    // Top-left vertex
    draw_vertex_texture(x,     y,     u_offset,           v_offset);
    // Bottom-left vertex
    draw_vertex_texture(x,     y + h, u_offset,           v_offset + v_scale);
    // Top-right vertex
    draw_vertex_texture(x + w, y,     u_offset + u_scale, v_offset);
    // Bottom-right vertex
    draw_vertex_texture(x + w, y + h, u_offset + u_scale, v_offset + v_scale);

    draw_primitive_end();

    // Disable texture repeat again if you only want it for this draw
    gpu_set_tex_repeat(false);
}
