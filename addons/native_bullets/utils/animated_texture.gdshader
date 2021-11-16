shader_type canvas_item;

void fragment() {
	vec2 texPixel = 1.0 / vec2(textureSize(TEXTURE, 0));
	vec2 position = MODULATE.rg;
	float size = MODULATE.b;
	float alpha = COLOR.a;
	vec2 uv = texPixel * position + texPixel * size * UV;
	vec4 tex = texture(TEXTURE, uv);
	tex.a *= alpha;
	COLOR = tex;
}
