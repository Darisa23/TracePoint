shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

float random(float x){
    return fract(sin(x * 12.9898 + 78.233) * 43758.5453);
}

float random2_1 (vec2 uv) {
    return fract(sin(dot(uv.xy + vec2(sin(TIME), cos(TIME)), 
                      vec2(12.9898,78.233))) * 43758.5453123);
}

uniform vec3 color: source_color = vec3(0.302, 0.620, 0.910);
uniform sampler2D texture_albedo : source_color, hint_default_white;
uniform float lines1:hint_range(0.0, 200.0, 1.0) = 50.0;
uniform float lines2:hint_range(0.0, 100.0, 1.0) = 3.0;
uniform float _emission:hint_range(0.0, 20.0) = 10.0;
uniform float brightness:hint_range(0.1, 5.0) = 2.0;
uniform float noise_min:hint_range(0.0, 1.0) = 0.5;
uniform float scan_intensity:hint_range(0.0, 1.0) = 0.15;

varying float rand_dist;

void vertex(){
	// Pequeña distorsión glitch
	float distortion = sin(TIME*10.0 + VERTEX.y*20.0) * 0.02;
	float rand_time = random(TIME + float(INSTANCE_ID));
	rand_dist = step(rand_time, 0.01);
	VERTEX.x += distortion * rand_dist;
}

void fragment(){
	// Textura de la partícula
	vec4 tex = texture(texture_albedo, UV);
	
	// Ruido holográfico (igual que el personaje)
	float n = random2_1(SCREEN_UV);
	n = mix(noise_min, 1.0, n);
	
	// Líneas horizontales (igual que el personaje)
	vec2 igrid = floor(SCREEN_UV * lines1);
	float l1 = mod(igrid.y, 2.0);
	l1 = mix(0.5, 1.0, l1);
	
	// Líneas de escaneo (igual que el personaje)
	vec2 uv2 = SCREEN_UV;
	uv2.y -= TIME * 0.06;
	vec2 igrid2 = floor(uv2 * lines2);
	float l2 = random(igrid2.y);
	l2 = step(0.2, l2);
	l2 = mix(1.0 - scan_intensity, 1.0, l2);
	
	// Combinar efectos
	float m = n * l1 * l2 * brightness;
	
	// Glitch ocasional
	float intensity = _emission * mix(1.0, 2.0, rand_dist);
	
	// Color final con textura
	vec3 final_color = color * tex.rgb;
	
	ALPHA = m * tex.a;
	ALBEDO = final_color * intensity;
	EMISSION = final_color * intensity;
}