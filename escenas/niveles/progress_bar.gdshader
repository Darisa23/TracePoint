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

    // Solo aplicar efecto donde hay contenido (la barra llena)
    if (tex_color.a > 0.1) {
        // Determinar si estamos en la zona "viva" (llena) o "congelada" (vacía)
        bool zona_viva = uv.x <= progreso;

        // === LÍNEAS HORIZONTALES ===
        float lineas;
        if (zona_viva) {
            // Zona viva: animación normal
            lineas = sin(uv.y * grosor_lineas + TIME * velocidad_lineas) * 0.5 + 0.5;
        } else {
            // Zona congelada: líneas estáticas (sin TIME)
            lineas = sin(uv.y * grosor_lineas) * 0.5 + 0.5;
        }
        lineas = pow(lineas, 3.0); // Hacer líneas más definidas

        // === PULSO DE BRILLO ===
        float pulso;
        if (zona_viva) {
            // Solo pulsa en la zona viva
            pulso = sin(TIME * velocidad_pulso) * 0.3 + 0.7;
        } else {
            // Zona congelada: brillo constante
            pulso = 0.7; // Valor base sin animación
        }

        // === GRADIENTE VERTICAL ===
        float gradiente = smoothstep(0.0, 0.3, uv.y) * smoothstep(1.0, 0.7, uv.y);

        // === EFECTO DE BORDE BRILLANTE ===
        float borde_izq = smoothstep(0.0, 0.05, uv.x);
        float borde_der = smoothstep(1.0, 0.95, uv.x);
        float borde = 1.0 - (borde_izq * borde_der);

        // === RUIDO DIGITAL ===
        float ruido;
        if (zona_viva) {
            // Ruido animado en zona viva
            ruido = fract(sin(dot(uv * TIME * 0.1, vec2(12.9898, 78.233))) * 43758.5453);
        } else {
            // Ruido estático en zona congelada
            ruido = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
        }
        ruido = ruido * 0.1;

        // === COMBINAR TODOS LOS EFECTOS ===
        vec3 color_final = color_base.rgb;

        // Aplicar scanlines
        color_final += color_brillo.rgb * lineas * intensidad_scanline;

        // Aplicar pulso
        color_final *= pulso;

        // Aplicar gradiente
        color_final *= (0.7 + gradiente * 0.3);

        // Aplicar brillo en bordes
        color_final += color_brillo.rgb * borde * intensidad_brillo;

        // Añadir ruido sutil
        color_final += vec3(ruido);

        // Oscurecer ligeramente la zona congelada para distinguirla
        if (!zona_viva) {
            color_final *= 0.7; // 70% de brillo en zona congelada
        }

        // Color final con transparencia
        COLOR = vec4(color_final, tex_color.a * 0.9);

        // Efecto de brillo adicional en los bordes
        COLOR.rgb += vec3(borde * 0.3);
    } else {
        // Si es transparente, mantener transparente
        COLOR = tex_color;
    }
}