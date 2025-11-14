shader_type canvas_item;

uniform float glitch_strength : hint_range(0.0, 1.0) = 0.0;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    
    if (glitch_strength > 0.01) {
        // Desplazamiento horizontal en bloques
        float block_y = floor(UV.y * 20.0);
        float shake = (random(vec2(TIME * 10.0, block_y)) - 0.5) * 0.05 * glitch_strength;
        uv.x += shake;
        
        // Aberración cromática más fuerte
        float aberration = 0.02 * glitch_strength;
        vec4 color_r = texture(TEXTURE, uv + vec2(aberration, 0.0));
        vec4 color_g = texture(TEXTURE, uv);
        vec4 color_b = texture(TEXTURE, uv - vec2(aberration, 0.0));
        
        COLOR = vec4(color_r.r, color_g.g, color_b.b, color_g.a);
        
        // Líneas de escaneo horizontales
        float line_y = floor(UV.y * 100.0);
        float line = step(0.95, random(vec2(TIME * 8.0, line_y)));
        COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 1.0, 1.0), line * glitch_strength * 0.7);
        
        // Bloques de distorsión
        float block_distortion = step(0.92, random(vec2(TIME * 6.0, floor(UV.y * 10.0))));
        if (block_distortion > 0.5) {
            uv.x += (random(vec2(TIME, block_y)) - 0.5) * 0.1 * glitch_strength;
            COLOR = texture(TEXTURE, uv);
        }
        
        // Parpadeo de brillo
        float flicker = sin(TIME * 30.0) * 0.1 * glitch_strength;
        COLOR.rgb += flicker;
        
    } else {
        COLOR = texture(TEXTURE, uv);
    }
}