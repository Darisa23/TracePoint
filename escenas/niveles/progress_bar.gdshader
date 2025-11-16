shader_type canvas_item;

// Parámetros personalizables
uniform vec4 color_base : source_color = vec4(0.0, 0.8, 1.0, 1.0); // Color cyan
uniform vec4 color_brillo : source_color = vec4(0.3, 1.0, 1.0, 1.0); // Brillo
uniform float velocidad_lineas : hint_range(0.1, 5.0) = 2.0;
uniform float grosor_lineas : hint_range(1.0, 20.0) = 8.0;
uniform float intensidad_scanline : hint_range(0.0, 1.0) = 0.5;
uniform float velocidad_pulso : hint_range(0.1, 3.0) = 1.5;
uniform float intensidad_brillo : hint_range(0.0, 2.0) = 0.8;
uniform float progreso : hint_range(0.0, 1.0) = 1.0; // Progreso de la barra (0-1)

void fragment() {
    vec2 uv = UV;

    // Obtener el color original del ProgressBar
    vec4 tex_color = texture(TEXTURE, uv);

    // La parte "llena" es donde el ProgressBar dibuja contenido Y donde uv.x <= progreso
    // La parte "vacía" es donde hay contenido pero uv.x > progreso
    bool en_parte_llena = (tex_color.a > 0.1) && (uv.x <= progreso);
    bool en_parte_vacia = (tex_color.a > 0.1) && (uv.x > progreso);

    if (en_parte_llena) {
        // === ZONA VIVA - APLICAR TODOS LOS EFECTOS ===

        // === LÍNEAS HORIZONTALES ===
        float lineas = sin(uv.y * grosor_lineas + TIME * velocidad_lineas) * 0.5 + 0.5;
        lineas = pow(lineas, 3.0);

        // === PULSO DE BRILLO ===
        float pulso = sin(TIME * velocidad_pulso) * 0.3 + 0.7;

        // === GRADIENTE VERTICAL ===
        float gradiente = smoothstep(0.0, 0.3, uv.y) * smoothstep(1.0, 0.7, uv.y);

        // === EFECTO DE BORDE BRILLANTE CON DIFUMINADO ===
        float borde_izq = smoothstep(0.0, 0.04, uv.x); // Difuminado suave
        float borde_der = smoothstep(1.0, 0.96, uv.x); // Difuminado suave
        float borde_arr = smoothstep(0.0, 0.06, uv.y); // Difuminado suave
        float borde_abj = smoothstep(1.0, 0.94, uv.y); // Difuminado suave

        float borde = 1.0 - (borde_izq * borde_der * borde_arr * borde_abj);
        borde = pow(borde, 1.5); // Suavizar el borde

        // === RUIDO DIGITAL ===
        float ruido = fract(sin(dot(uv * TIME * 0.1, vec2(12.9898, 78.233))) * 43758.5453);
        ruido = ruido * 0.1;

        // === COMBINAR TODOS LOS EFECTOS ===
        vec3 color_final = color_base.rgb;
        color_final += color_brillo.rgb * lineas * intensidad_scanline;
        color_final *= pulso;
        color_final *= (0.7 + gradiente * 0.3);
        color_final += color_brillo.rgb * borde * intensidad_brillo;
        color_final += vec3(ruido);

        COLOR = vec4(color_final, tex_color.a * 0.9);
        COLOR.rgb += vec3(borde * 0.5);

    } else if (en_parte_vacia) {
        // === ZONA VACÍA - COLOR #88D7CC MÁS TRANSPARENTE CON BLUR EN BORDES ===

        // === GRADIENTE VERTICAL ===
        float gradiente = smoothstep(0.0, 0.3, uv.y) * smoothstep(1.0, 0.7, uv.y);

        // === DIFUMINADO GAUSSIANO EN BORDES ===
        // Distancia a cada borde (0 = en el borde, 1 = lejos del borde)
        float dist_izq = smoothstep(0.0, 0.1, uv.x);
        float dist_der = smoothstep(1.0, 0.9, uv.x);
        float dist_arr = smoothstep(0.0, 0.15, uv.y);
        float dist_abj = smoothstep(1.0, 0.85, uv.y);

        // Multiplicar todas las distancias para crear fade en todos los bordes
        float fade_bordes = dist_izq * dist_der * dist_arr * dist_abj;
        fade_bordes = smoothstep(0.0, 1.0, fade_bordes); // Suavizar más

        // === COLOR #88D7CC (RGB: 136, 215, 204 -> normalizado 0-1) ===
        vec3 color_final = vec3(0.533, 0.843, 0.8); // #88D7CC

        // Aplicar gradiente
        color_final *= (0.7 + gradiente * 0.3);

        // Aplicar difuminado en bordes
        float alpha_final = 0.15 * fade_bordes; // Muy transparente (15% base * fade)

        COLOR = vec4(color_final, alpha_final);
    } else {
        // Zona transparente (fuera de la barra)
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}