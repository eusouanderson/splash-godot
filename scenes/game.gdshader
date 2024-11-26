shader_type canvas_item;

uniform vec4 start_color; // Cor inicial da partícula
uniform vec4 end_color;   // Cor final da partícula
uniform float time;       // Tempo normalizado entre 0 e 1

void fragment() {
    // Calcular a idade da partícula com base no tempo
    float age = time;

    // Interpolar a cor com base na idade da partícula
    vec4 color = mix(start_color, end_color, age);

    // Ajustar a cor com a opacidade
    color.a *= 1.0 - age; // Fade out com o tempo

    // Definir a cor do fragmento
    COLOR = color;
}
