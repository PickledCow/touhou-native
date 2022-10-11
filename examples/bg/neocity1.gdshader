// NOTE: Shader automatically converted from Godot Engine 3.5.stable's SpatialMaterial.

shader_type spatial;
uniform float density;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec3 albedo;
uniform sampler2D texture_emission : hint_black_albedo;
uniform vec4 emission : hint_color;
uniform float emission_energy;
uniform vec3 uv1_scale;
uniform vec2 window_margin;


float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898+density,78.233+density))) * 43758.5453);
}

float lit(float val, float thresh, vec2 coord) {
	return float(val < thresh) * float(abs(coord.x - 0.5) < 0.5-window_margin.x) * float(abs(coord.y - 0.5) < 0.5-window_margin.y);
}



void vertex() {
	UV=UV*uv1_scale.xy;
}


void fragment() {
	vec2 base_uv = UV;
	ALBEDO = albedo;
	vec3 emission_tex = texture(texture_emission,base_uv).rgb;
	vec2 cell = floor(UV) * 15.0;
	EMISSION = (emission.rgb) * emission_energy * lit(rand(cell), density, mod(UV, 1.0));
}
