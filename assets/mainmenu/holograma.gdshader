
shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec3 color: source_color = vec3(0.302, 0.620, 0.910); // #4d9ee8
uniform float lines1:hint_range(0.0, 200.0, 1.0) = 50.0;
uniform float lines2:hint_range(0.0, 100.0, 1.0) = 3.0; // Mucho menos frecuencia
uniform float _emission:hint_range(0.0, 20.0) = 10.0;
uniform float _fresnel:hint_range(0.0, 10.0) = 2.5;
uniform float overall_brightness:hint_range(0.1, 5.0) = 2.5;
uniform float noise_min:hint_range(0.0, 1.0) = 0.5;
uniform float scan_intensity:hint_range(0.0, 1.0) = 0.15; // Control de cuánto afectan

varying float rand_dist;
float random(float x){
    return fract(sin(x * 12.9898 + 78.233) * 43758.5453);
}
float random2_1 (vec2 uv) {
    return fract(sin(dot(uv.xy + vec2(sin(TIME), cos(TIME)), 
                      vec2(12.9898,78.233))) * 43758.5453123);
}
float fresnel(float amount, vec3 normal, vec3 view){
    return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
void vertex(){
	float distortion = sin(TIME*10.0 + VERTEX.y*20.0) * 0.04;
	float rand_time = random(TIME);
	rand_dist = step(rand_time, 0.01);
	
	VERTEX.x += distortion * rand_dist;
}

void fragment(){
	// Ruido pero más visible
	float n = random2_1(SCREEN_UV);
	n = mix(noise_min, 1.0, n);
	
	// Fresnel
	float f = fresnel(_fresnel, NORMAL, VIEW);
	
	// Líneas horizontales
	vec2 igrid = floor(SCREEN_UV * lines1);
	float l1 = mod(igrid.y, 2.0);
	l1 = mix(0.5, 1.0, l1);
	
	// Líneas de escaneo - MUY REDUCIDAS
	vec2 uv2 = SCREEN_UV;
	uv2.y -= TIME * 0.06;
	vec2 igrid2 = floor(uv2 * lines2); // Ahora 3.0
	float l2 = random(igrid2.y);
	l2 = step(0.2, l2);
	l2 = mix(1.0 - scan_intensity, 1.0, l2); // Menos impacto visual
	
	// Combinar efectos
	float m = f * n * l1 * l2 * overall_brightness;
	
	// El color NO se multiplica por el glitch, solo la intensidad
	float intensity = _emission * mix(1.0, 2.0, rand_dist);
	
	ALPHA = m;
	ALBEDO = color * intensity;
	EMISSION = color * intensity;
}