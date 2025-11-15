shader_type spatial;
render_mode depth_prepass_alpha;

uniform sampler2D Albedo_Texture : source_color, filter_nearest;
uniform sampler2D Alpha_Texture  : source_color, filter_nearest;
uniform sampler2D Normal_Texture : source_color, filter_nearest;
uniform vec3 Alpha_Scroll_Speed;
varying vec3 Wave_World_Coords;
uniform float Emission_Power;

uniform float Uv1_Blend_Sharpness : hint_range(0.0, 150.0, 0.001);
varying vec3 Uv1_Triplanar_Pos;
varying vec3 Uv1_Power_Normal;
uniform vec3 Uv1_Scale = vec3(1.0);
uniform vec3 Modulate : source_color;
uniform vec3 Border_Modulate : source_color;

void vertex() {
	Wave_World_Coords = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	Uv1_Power_Normal = pow(abs(NORMAL), vec3(Uv1_Blend_Sharpness));
	Uv1_Triplanar_Pos = VERTEX * Uv1_Scale;
	Uv1_Power_Normal /= dot(Uv1_Power_Normal, vec3(1.0));
	Uv1_Triplanar_Pos *= vec3(1.0, -1.0, 1.0);
}

vec4 Triplanar_Texture(sampler2D P_Sampler, vec3 P_Weights, vec3 P_Triplanar_Pos) {
	vec4 Samp = vec4(0.0);
	Samp += texture(P_Sampler, P_Triplanar_Pos.xy) * P_Weights.z;
	Samp += texture(P_Sampler, P_Triplanar_Pos.xz) * P_Weights.y;
	Samp += texture(P_Sampler, P_Triplanar_Pos.zy * vec2(-1.0, 1.0)) * P_Weights.x;
	return Samp;
}

uniform float Wave_Outer_Radii = 2.0;
uniform float Wave_Inner_Radii = 1.0;
uniform float Added_Radii_Max = 1.0;
uniform float Added_Radii_Speed = 1.0;
varying float Added_Radii;
uniform vec3 Wave_Centers;

void fragment() {
	NORMAL = Triplanar_Texture(Normal_Texture, Uv1_Power_Normal, Uv1_Triplanar_Pos).rgb;

	vec3 Scrolling_UV = fract(TIME * Alpha_Scroll_Speed);
	float Alpha_Of_Texture = Triplanar_Texture(
		Alpha_Texture,
		Uv1_Power_Normal,
		Uv1_Triplanar_Pos + Scrolling_UV
	).r;

	vec3 Color = Triplanar_Texture(
		Albedo_Texture,
		Uv1_Power_Normal,
		Uv1_Triplanar_Pos
	).rgb;

	Added_Radii = sin(TIME * Added_Radii_Speed) * Added_Radii_Max;

	float Dist = distance(Wave_World_Coords, Wave_Centers);
	float Factor = smoothstep(
		Wave_Inner_Radii + Added_Radii,
		Wave_Outer_Radii + Added_Radii,
		Dist
	);

	if (Dist > Wave_Inner_Radii) {
		ALPHA = clamp(((1.0 - Factor) - Alpha_Of_Texture) * 3.0, 0.0, 1.0);
	} else {
		ALPHA = 1.0;
	}

	vec3 Mix_Color = mix(Color * Modulate, Color * Border_Modulate, Factor);
	ALBEDO = Mix_Color;
	EMISSION = Mix_Color * Emission_Power;
}
