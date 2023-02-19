shader_type canvas_item;
render_mode blend_mix;

uniform float speed_x;
uniform float speed_y;

void fragment () {
	COLOR = texture(TEXTURE, vec2(UV.x + TIME * speed_x, UV.y + TIME * speed_y));
}