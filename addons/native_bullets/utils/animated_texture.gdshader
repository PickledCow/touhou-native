shader_type canvas_item;
// advert your eyes pls

uniform float animation_speed = 8.0;
const float FACTOR = 2.61799387799;

float fade(float x) {
	return 2.0 * sin(FACTOR * sqrt(min(x, 1.0)));
}

void vertex() {
	float ONE = 1.0;
	VERTEX.y += floor(MODULATE.b) / floor(MODULATE.g);
	VERTEX *= fade(1.0 - modf(MODULATE.b, ONE));
}

void fragment() {
	float ONE = 1.0;
	vec2 texSize = vec2(textureSize(TEXTURE, 0));
	vec2 texPixel = vec2(1.0, 1.0 / texSize.y);
	
	vec2 position = vec2(modf(MODULATE.r, ONE), floor(MODULATE.r));
	vec2 size = vec2(modf(MODULATE.g, ONE),floor(MODULATE.g));
	vec2 uv = texPixel * position + texPixel * size * UV;
	
	float frame_count = floor(MODULATE.a);
	float frame = mod(floor(animation_speed * TIME), frame_count);
	uv.x += size.x * frame;
	
	vec4 tex = texture(TEXTURE, uv);
	
	float alpha = 1.0 - modf(MODULATE.b, ONE);
	tex.a *= alpha;
	
	COLOR = tex;
}
