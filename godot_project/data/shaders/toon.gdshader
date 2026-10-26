shader_type spatial;
render_mode blend_mix, cull_back, diffuse_toon, specular_toon, depth_prepass_alpha;

// Albedo
group_uniforms Albedo;

uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);

// Roughness
group_uniforms Roughness;

uniform sampler2D roughness_texture : hint_default_white, filter_nearest;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.5;

// Metallic
group_uniforms Metallic;

uniform sampler2D metallic_texture : hint_default_black, filter_nearest;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 1.0;

// Specular
group_uniforms Specular;

uniform sampler2D specular_texture : hint_default_white, filter_nearest;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;

// Emission
group_uniforms Emission;

uniform bool use_emission = false;
uniform sampler2D emission_texture : source_color, filter_nearest;
uniform float emission_strength : hint_range(0.0, 10.0, 0.1) = 1.0;

// Lighting
group_uniforms Lighting;

uniform float shadow_threshold : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float light_smoothness : hint_range(0.01, 1.0, 0.01) = 0.5;

varying float material_roughness;
varying float material_metallic;
varying float material_specular;

void fragment() {
	vec4 albedo = texture(albedo_texture, UV) * albedo_color;
	
	material_roughness = clamp(texture(roughness_texture, UV).r * roughness, 0.0, 1.0);
	material_metallic = clamp(texture(metallic_texture, UV).r * metallic, 0.0, 1.0);
	material_specular = clamp(texture(specular_texture, UV).r * specular, 0.0, 1.0);
	
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
	
	ROUGHNESS = material_roughness;
	METALLIC = material_metallic;
	SPECULAR = material_specular;
	
	if (use_emission) {
		EMISSION = texture(emission_texture, UV).rgb * emission_strength;
	}
}

void light() {
	float NdotL = max(dot(NORMAL, LIGHT), 0.0);
	
	float diffuse = smoothstep(
		shadow_threshold,
		shadow_threshold + light_smoothness,
		NdotL
	);
	
	vec3 diffuse_color = mix(ALBEDO, vec3(0.0), material_metallic);
	
	DIFFUSE_LIGHT += diffuse_color * LIGHT_COLOR * diffuse * ATTENUATION;
	
	vec3 half_vector = normalize(LIGHT + VIEW);
	float NdotH = max(dot(NORMAL, half_vector), 0.0);
	
	float shininess = mix(256.0, 2.0, material_roughness);
	float specular_light = pow(NdotH, shininess) * material_specular;
	
	vec3 specular_color = mix(vec3(0.04), ALBEDO, material_metallic);
	
	SPECULAR_LIGHT += specular_color * LIGHT_COLOR
		* specular_light * NdotL * ATTENUATION;
}
