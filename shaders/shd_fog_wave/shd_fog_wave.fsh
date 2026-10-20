// shd_fog_wave.frag
varying vec2 v_vTexcoord;   // The texture coordinate passed from the vertex shader
varying vec4 v_vColour;     // The color passed from the vertex shader

// Uniforms you can set from GML
uniform float u_time;       // A time variable to animate the wave
uniform float u_amplitude;  // How large the wave distortion is
uniform float u_frequency;  // How frequent the waves are
uniform float u_speed;      // How fast the waves move

void main() {
    // Calculate wave offset using sine
    float wave = sin((v_vTexcoord.y * u_frequency) + (u_time * u_speed)) * u_amplitude;

    // Shift the x coordinate (horizontal wave), you can also shift y if desired
    vec2 uv = vec2(v_vTexcoord.x + wave, v_vTexcoord.y);
	uv = fract(uv); // ensures the texture wraps cleanly
	
    // Sample the texture at the distorted UV
    gl_FragColor = texture2D(gm_BaseTexture, uv) * v_vColour;
}
