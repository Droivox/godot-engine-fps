shader_type spatial;
render_mode alpha_to_coverage;

uniform vec4 color : source_color = vec4(1.0, 0.95, 0.69, 1.0);
uniform float emission_force : hint_range(1.0, 1000.0, 0.01) = 10.0;

void vertex() {
}

void fragment() {
	ALBEDO.rgb = color.rgb;
	EMISSION = color.rgb * emission_force;
}