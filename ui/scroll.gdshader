shader_type canvas_item;
render_mode blend_mix;

uniform float speed_x;
uniform float speed_y;

void fragment () {
	vec2 scale = mod(vec2(TIME * speed_x, TIME * speed_y), 1.0f);
	COLOR = texture(TEXTURE, vec2(UV.x + scale.x, UV.y + scale.y));
}