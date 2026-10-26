shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_nearest;
uniform sampler2D normal_texture : source_color, hint_normal_roughness_texture, filter_nearest;

uniform float depth_threshold : hint_range(0.0, 1.0) = 0.01;
uniform float depth_softness : hint_range(0.0, 0.1) = 0.005;

uniform float reverse_depth_threshold : hint_range(0.0, 1.0) = 0.01;
uniform float reverse_depth_softness : hint_range(0.0, 0.1) = 0.005;

uniform float normal_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float normal_softness : hint_range(0.0, 0.1) = 0.05;

uniform float border_scale : hint_range(0.5, 5.0, 0.1) = 1.0;
uniform vec3 border_color : source_color = vec3(0.0, 0.0, 0.0);

uniform vec3 normal_edge_bias = vec3(1, 1, 1);

float get_depth(vec2 screen_uv, mat4 inv_projection_matrix) {
    float depth = texture(depth_texture, screen_uv).r;

    if (depth >= 0.9999 || depth <= 0.0001) {
        discard;
    }

    vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
    vec4 view = inv_projection_matrix * vec4(ndc, 1.0);

    if (view.w == 0.0) {
        discard;
    }

    view.xyz /= view.w;
    return -view.z;
}

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    float depth = get_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
    vec3 normal = texture(normal_texture, SCREEN_UV).xyz * 2.0 - 1.0;
    vec2 texel_size = border_scale / VIEWPORT_SIZE.xy;

    vec2 uvs[4];
    uvs[0] = vec2(SCREEN_UV.x, min(1.0 - 0.001, SCREEN_UV.y + texel_size.y));
    uvs[1] = vec2(SCREEN_UV.x, max(0.0, SCREEN_UV.y - texel_size.y));
    uvs[2] = vec2(min(1.0 - 0.001, SCREEN_UV.x + texel_size.x), SCREEN_UV.y);
    uvs[3] = vec2(max(0.0, SCREEN_UV.x - texel_size.x), SCREEN_UV.y);

    float depth_diff = 0.0;
    float depth_diff_reversed = 0.0;
    float nearest_depth = depth;

    float normal_sum = 0.0;

    for (int i = 0; i < 4; i++) {
        float d = get_depth(uvs[i], INV_PROJECTION_MATRIX);

        depth_diff += depth - d;
        depth_diff_reversed += d - depth;

        if (d < nearest_depth) {
            nearest_depth = d;
        }

        vec3 n = texture(normal_texture, uvs[i]).xyz * 2.0 - 1.0;
        vec3 normal_diff = normal - n;

        float normal_bias_diff = dot(normal_diff, normal_edge_bias);
        float normal_indicator = smoothstep(-0.01, 0.01, normal_bias_diff);

        normal_sum += dot(normal_diff, normal_diff) * normal_indicator;
    }

    float depth_edge = smoothstep(depth_threshold, depth_threshold + depth_softness, depth_diff);
    float reverse_depth_edge = smoothstep(reverse_depth_threshold, reverse_depth_threshold + reverse_depth_softness, depth_diff_reversed);

    float indicator = sqrt(normal_sum);
    float normal_edge = smoothstep(normal_threshold, normal_threshold + normal_softness, indicator - reverse_depth_edge);

    vec3 edge_color = border_color;

    float final_edge = mix(depth_edge, normal_edge, 0.5);

    if (final_edge > 0.0) {
        ALBEDO = edge_color;
    } else {
        vec4 screen = texture(screen_texture, SCREEN_UV);
        ALBEDO = screen.rgb;
    }
}
