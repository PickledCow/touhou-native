#ifndef BASIC_BULLET_KIT_H
#define BASIC_BULLET_KIT_H

#include <Godot.hpp>

#include <Texture.hpp>
#include <PackedScene.hpp>
#include <Node2D.hpp>

#include "../bullet_kit.h"

using namespace godot;


// Bullet kit definition.
class BasicBulletKit : public BulletKit {
	GODOT_CLASS(BasicBulletKit, BulletKit)
public:
	BULLET_KIT(BasicBulletsPool)

	Ref<Texture> texture;

	static void _register_methods() {
		register_property<BasicBulletKit, Ref<Texture>>("texture", &BasicBulletKit::texture, Ref<Texture>(), 
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_RESOURCE_TYPE, "Texture");
		
		BULLET_KIT_REGISTRATION(BasicBulletKit, Bullet)
	}
};

// Bullets pool definition.
class BasicBulletsPool : public AbstractBulletsPool<BasicBulletKit, Bullet> {

	// void _init_bullet(Bullet* bullet); Use default implementation.

	void _enable_bullet(Bullet* bullet) {
		// Reset some bullet variables that are not set by the create_bullet functions
		bullet->max_scale = 0.0f;
		bullet->scale_vel = 0.0f;
		bullet->layer = 0;
		bullet->lifetime = 0.0f;
		bullet->lifespan = std::numeric_limits<float>::infinity();
		bullet->wvel = 0.0f;
		bullet->max_wvel = 0.0f;
		bullet->waccel = 0.0f;
		bullet->rotation = 0.0f;
		bullet->fade_delete = false;
		bullet->fading = false;
		bullet->patterns.clear();
		Rect2 texture_rect = Rect2(-0.5f, -0.5f, 1.0f, 1.0f);
		RID texture_rid = kit->texture->get_rid();
		
		bullet->fade_time = kit->fade_time;
		bullet->fade_timer = kit->fade_time;

		// Configure the bullet to draw the kit texture each frame.
		VisualServer::get_singleton()->canvas_item_add_texture_rect(bullet->item_rid,
			texture_rect,
			texture_rid);
	}

	// void _disable_bullet(Bullet* bullet); Use default implementation.

	bool _process_bullet(Bullet* bullet, float delta) {
		Vector2 origin = bullet->transform.get_origin();
		if (bullet->waccel && bullet->wvel != bullet->max_wvel) {
			bullet->wvel += bullet->waccel * delta;
			if (((bullet->wvel - bullet->max_wvel) * bullet->waccel) > 0.0f) bullet->wvel = bullet->max_wvel;
		}
		if (bullet->wvel) {
			bullet->direction = bullet->direction.rotated(bullet->wvel * delta);
			bullet->angle += bullet->wvel * delta;
			bullet->transform = bullet->transform.rotated(bullet->wvel * delta);
		}
		if (bullet->scale_vel && bullet->scale != bullet->max_scale) {
			bullet->scale += bullet->scale_vel * delta;
			if (((bullet->scale - bullet->max_scale) * bullet->scale_vel) > 0.0f) bullet->scale = bullet->max_scale;
			bullet->transform = bullet->transform.scaled((bullet->scale / bullet->transform.get_scale().x) * Vector2(1.0f, 1.0f));
		}
		bullet->transform = bullet->transform.rotated(bullet->spin * delta);
		bullet->rotation += bullet->spin * delta;
		bullet->position += bullet->direction * bullet->speed * delta;
		bullet->transform.set_origin(bullet->position);
		if (bullet->accel && bullet->speed != bullet->max_speed) {
			bullet->speed += bullet->accel * delta;
			if (((bullet->speed - bullet->max_speed) * bullet->accel) > 0.0f) bullet->speed = bullet->max_speed;
		}

		// Decrease fade timer
		if (bullet->fade_timer) {
			bullet->fade_timer -= delta;

			if (!bullet->fading) {
				if (bullet->fade_timer <= 0.0f) {
					bullet->fade_timer = 0.0f;
					if (collisions_enabled) {
						Physics2DServer::get_singleton()->area_set_shape_disabled(shared_area, bullet->shape_index, false);
					}
					bullet->bullet_data.b = bullet->texture_offset;
					VisualServer::get_singleton()->canvas_item_set_modulate(bullet->item_rid, bullet->bullet_data);
				} else {
					Color color = bullet->bullet_data;
					color.b = bullet->texture_offset + bullet->fade_timer / bullet->fade_time;
					VisualServer::get_singleton()->canvas_item_set_modulate(bullet->item_rid, color);
				}
			} else {
				if (bullet->fade_timer <= 0.0f) {
					bullet->fade_timer = 0.0f;
				}
				Color color = bullet->bullet_data;
				color.b = -(bullet->texture_offset + 1.0f - bullet->fade_timer / bullet->fade_time);
				VisualServer::get_singleton()->canvas_item_set_modulate(bullet->item_rid, color);
			}
		}

		if(!active_rect.has_point(bullet->transform.get_origin()) || bullet->lifetime >= bullet->lifespan) {
			if (!bullet->fade_delete || (bullet->fade_timer <= 0.0f && bullet->fading)) {
				// Return true if the bullet should be deleted.
				return true;
			} else if (!bullet->fading) {
				// Start fading and disable collision
				bullet->fading = true;
				bullet->fade_timer = bullet->fade_time;
				Physics2DServer::get_singleton()->area_set_shape_disabled(shared_area, bullet->shape_index, true);
			}
		}

		// Iterate over existing transformations
		bool pattern_applied = false;
		int j = 0;
		for (int i = 0; i < bullet->patterns.size(); i++) {
			Array pattern = bullet->patterns[i]; // trigger, type, time, properties
			bool should_apply = false;
			int trigger = pattern[0];
			// Time triggered
			if (trigger == 0) {
				pattern[2] = (float)pattern[2] - delta;
				if ((float)pattern[2] <= 0.0f) {
					should_apply = true;
					pattern_applied = true;
					pattern[2] = 0.0f;
				} else {
					bullet->patterns[j] = pattern;
					j++;
				}
			}


			if (should_apply) {
				// what type of pattern is this?
				int type = (int)pattern[1];
				switch (type) {
					case 0: { // Set
						Dictionary properties = (Dictionary)pattern[3];
						Array keys = properties.keys();
						for(int32_t i = 0; i < keys.size(); i++) {
							bullet->set(keys[i], properties[keys[i]]);
						}
						break;
					}
						
					case 1: { // Add
						Dictionary properties = (Dictionary)pattern[3];
						Array keys = properties.keys();
						for(int32_t i = 0; i < keys.size(); i++) {
							switch (properties[keys[i]].get_type()) {
								case (Variant::Type::REAL):
									bullet->set(keys[i], (float)bullet->get(keys[i]) + (float)properties[keys[i]]);
									break;
								case (Variant::Type::VECTOR2):
									bullet->set(keys[i], (Vector2)bullet->get(keys[i]) + (Vector2)properties[keys[i]]);
									break;
								default:
									break;
							}
						}
						break;
					}
					
					case 2: { // aim at point
						Vector2 point = (Vector2)pattern[3];
						bullet->angle = (point).angle_to_point(bullet->position);
						break;
					}

					case 3: { // aim at object
						Node2D *node = (Node2D*)pattern[3];
						godot_int instance_id = (int)pattern[4];
						if (core_1_1_api->godot_is_instance_valid(core_1_2_api->godot_instance_from_id(instance_id))) {
							bullet->angle = ((Vector2)node->get_position()).angle_to_point(bullet->position);
						}
						break;
					}

					case 4: { // go to object
						Node2D *node = (Node2D*)pattern[3];
						godot_int instance_id = (int)pattern[4];
						if (core_1_1_api->godot_is_instance_valid(core_1_2_api->godot_instance_from_id(instance_id))) {
							bullet->position = node->get_position();
						}
						break;
					}

					default:
						break;
				}

			}
		}
		bullet->patterns.resize(j);

		// Update position and other data if a transformation has been made
		if (pattern_applied) {
			bullet->direction = Vector2(1.0f, 0.0f).rotated(bullet->angle);
			//bullet->transform.set_rotation(bullet->angle);
			bullet->transform = bullet->transform.scaled((bullet->scale / bullet->transform.get_scale().x) * Vector2(1.0f, 1.0f)).rotated(bullet->angle - bullet->transform.get_rotation() + 1.57079632679f + bullet->rotation);
			bullet->transform.set_origin(bullet->position);
			VisualServer::get_singleton()->canvas_item_set_draw_index(bullet->item_rid, (bullet->layer << 24) + bullet->draw_index);
		}


		// Bullet is still alive, increase its lifetime.
		bullet->lifetime += delta;
		// Return false if the bullet should not be deleted yet.
		return false;
	}
};

BULLET_KIT_IMPLEMENTATION(BasicBulletKit, BasicBulletsPool)

#endif