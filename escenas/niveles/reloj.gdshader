shader_type canvas_item;

// Parámetros personalizables (iguales a la barra)
uniform vec4 color_base : source_color = vec4(0.0, 0.8, 1.0, 1.0); // Color cyan
uniform vec4 color_brillo : source_color = vec4(0.3, 1.0, 1.0, 1.0); // Brillo
uniform float velocidad_lineas : hint_range(0.1, 5.0) = 2.0;
uniform float grosor_lineas : hint_range(1.0, 20.0) = 8.0;
uniform float intensidad_scanline : hint_range(0.0, 1.0) = 0.5;
uniform float velocidad_pulso : hint_range(0.1, 3.0) = 1.5;
uniform float intensidad_brillo : hint_range(0.0, 2.0) = 0.8;
uniform float progreso : hint_range(0.0, 1.0) = 1.0; // 1.0 = lleno, 0.0 = vacío
uniform float grosor : hint_range(0.05, 0.5) = 0.20; // Grosor del anillo (aumentado)

void fragment() {
    // Centrar coordenadas
    vec2 uv = UV - 0.5;
    
    // Calcular distancia desde el centro y ángulo
    float dist = length(uv);
    float angulo = atan(uv.y, uv.x);
    
    // Normalizar ángulo de -PI..PI a 0..1 (empezando desde arriba)
    float angulo_normalizado = (angulo + PI) / (2.0 * PI);
    angulo_normalizado = fract(angulo_normalizado + 0.75); // Rotar para empezar arriba
    
    // Calcular si estamos dentro del anillo CON BORDES MUY SUAVES
    float radio_exterior = 0.45;
    float radio_interior = radio_exterior - grosor;
    
    // Máscara del anillo con bordes MUY difuminados (como la barra)
    float suavizado = 0.08; // Más grande = más difuminado
    float anillo = smoothstep(radio_interior - suavizado, radio_interior + suavizado, dist) * 
                   smoothstep(radio_exterior + suavizado, radio_exterior - suavizado, dist);
    
    // Determinar si estamos en zona llena o vacía
    bool en_anillo = anillo > 0.1;
    bool en_parte_llena = en_anillo && (angulo_normalizado <= progreso);
    bool en_parte_vacia = en_anillo && (angulo_normalizado > progreso);
    
    if (en_parte_llena) {
        // === ZONA VIVA - TODOS LOS EFECTOS ===
        
        // Convertir coordenadas circulares a UV "virtual" para los efectos
        float uv_radial = (dist - radio_interior) / grosor; // 0 a 1 en el grosor
        
        // === MOVIMIENTO RADIAL (en vez de pulso) ===
        // Onda que se mueve circularmente alrededor del anillo
        float onda_radial = sin(angulo_normalizado * 6.28318 - TIME * velocidad_pulso * 2.0) * 0.2 + 0.9;
        
        // === GRADIENTE RADIAL (de interior a exterior) ===
        float gradiente = smoothstep(0.0, 0.3, uv_radial) * smoothstep(1.0, 0.7, uv_radial);
        
        // === DIFUMINADO EN BORDES ANGULARES (inicio/fin del progreso) ===
        float suavizado_angular = 0.03;
        float fade_inicio = smoothstep(0.0, suavizado_angular, angulo_normalizado);
        float fade_fin = smoothstep(progreso, progreso - suavizado_angular, angulo_normalizado);
        
        // === RUIDO DIGITAL ===
        vec2 ruido_uv = vec2(angulo_normalizado, uv_radial) * TIME * 0.1;
        float ruido = fract(sin(dot(ruido_uv, vec2(12.9898, 78.233))) * 43758.5453);
        ruido = ruido * 0.1;
        
        // === COMBINAR EFECTOS SIN BORDES BRILLANTES ===
        vec3 color_final = color_base.rgb;
        color_final *= onda_radial; // Movimiento circular en vez de pulso
        color_final *= (0.7 + gradiente * 0.3);
        color_final += vec3(ruido);
        
        // Aplicar fade angular suave
        float alpha_final = anillo * 0.9 * fade_inicio * fade_fin;
        COLOR = vec4(color_final, alpha_final);
        
    } else if (en_parte_vacia) {
        // === ZONA VACÍA - COLOR #88D7CC MÁS TRANSPARENTE CON BLUR ===
        
        float uv_radial = (dist - radio_interior) / grosor;
        
        // === GRADIENTE RADIAL ===
        float gradiente = smoothstep(0.0, 0.3, uv_radial) * smoothstep(1.0, 0.7, uv_radial);
        
        // === DIFUMINADO EN BORDES ===
        // Fade en los límites angulares
        float dist_inicio = smoothstep(progreso, progreso + 0.1, angulo_normalizado);
        float dist_fin = smoothstep(1.0, 0.9, angulo_normalizado);
        
        // Fade radial (interior y exterior)
        float dist_interior = smoothstep(0.0, 0.15, uv_radial);
        float dist_exterior = smoothstep(1.0, 0.85, uv_radial);
        
        // Combinar fades
        float fade_bordes = dist_inicio * dist_fin * dist_interior * dist_exterior;
        fade_bordes = smoothstep(0.0, 1.0, fade_bordes);
        
        // === COLOR #88D7CC ===
        vec3 color_final = vec3(0.533, 0.843, 0.8);
        color_final *= (0.7 + gradiente * 0.3);
        
        float alpha_final = 0.15 * fade_bordes;
        COLOR = vec4(color_final, alpha_final);
        
    } else {
        // Fuera del anillo - transparente
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}