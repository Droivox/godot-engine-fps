shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

uniform float distortion : hint_range(-10.0, 10.0, 0.1);
uniform float blur : hint_range(0.0, 5.0, 0.1);
uniform float ditther_opacity : hint_range(0.0, 1.0, 0.01);

uniform bool enable_dither = true;
uniform float dither_size : hint_range(1.0, 16.0, 0.1) = 1.0;

uniform bool enable_color_reduction = true;
uniform float color_levels : hint_range(2.0, 256.0, 1.0) = 16.0;

uniform float pixel_size : hint_range(1.0, 32.0, 1.0) = 4.0;

float bayer(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int index = x + y * 4;

	float[16] matrix = float[](
		0.0, 8.0, 2.0, 10.0,
		12.0, 4.0, 14.0, 6.0,
		3.0, 11.0, 1.0, 9.0,
		15.0, 7.0, 13.0, 5.0
	);

	return matrix[index] / 16.0;
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// PIXELIZAÇÃO
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 pixel_grid = resolution / pixel_size;
	uv = floor(uv * pixel_grid) / pixel_grid;

	float d = distortion * 0.001;

	float r = textureLod(SCREEN_TEXTURE, uv + vec2(-d, d), blur).r;
	float g = textureLod(SCREEN_TEXTURE, uv, blur).g;
	float b = textureLod(SCREEN_TEXTURE, uv + vec2(d, -d), blur).b;

	vec3 color = vec3(r, g, b);

	if (enable_dither) {
		float noise = bayer(floor(FRAGCOORD.xy / dither_size));
		color += ((noise - 0.5) / color_levels) * ditther_opacity;
	}

	if (enable_color_reduction) {
		color = floor(color * color_levels) / color_levels;
	}

	COLOR = vec4(color, 1.0);
}