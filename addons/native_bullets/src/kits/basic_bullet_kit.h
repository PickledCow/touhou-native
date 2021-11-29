#ifndef BASIC_BULLET_KIT_H
#define BASIC_BULLET_KIT_H

#include <Texture.hpp>
#include <PackedScene.hpp>

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
		bullet->lifetime = 0.0f;
		bullet->lifespan = std::numeric_limits<float>::infinity();
		bullet->wvel = 0.0f;
		bullet->rotation = 0.0f;
		bullet->fade_timer = 0.0001f;
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
		if (bullet->wvel) {
			bullet->direction = bullet->direction.rotated(bullet->wvel * delta);
			bullet->angle += bullet->wvel * delta;
			bullet->transform = bullet->transform.rotated(bullet->wvel * delta);
		}
		bullet->transform = bullet->transform.rotated(bullet->spin * delta);
		bullet->rotation += bullet->spin * delta;
		bullet->position += bullet->direction * bullet->speed * delta;
		bullet->transform.set_origin(bullet->position);
		if (bullet->accel) {
			bullet->speed += bullet->accel * delta;
			if (((bullet->speed - bullet->max_speed) * bullet->accel) > 0.0f) bullet->speed = bullet->max_speed;
		}

		// Decrease fade timer
		if (bullet->fade_timer) {
			bullet->fade_timer -= delta;


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
		}

		if(!active_rect.has_point(bullet->transform.get_origin()) || bullet->lifetime >= bullet->lifespan) {
			// Return true if the bullet should be deleted.
			return true;
		}

		// Iterate over existing transformations
		bool pattern_applied = false;
		int j = 0;
		for (int i = 0; i < bullet->patterns.size(); i++) {
			Array pattern = bullet->patterns[i];
			if (pattern[1]) {
				pattern[1] = (float)pattern[1] - delta;
				if ((float)pattern[1] <= 0.0f) {
					pattern_applied = true;
					pattern[1] = 0.0f;

					Dictionary properties = (Dictionary)pattern[2];
					Array keys = properties.keys();
					for(int32_t i = 0; i < keys.size(); i++) {
						bullet->set(keys[i], properties[keys[i]]);
					}
				} else {
					bullet->patterns[j] = pattern;
					j++;
				}
			}
		}
		bullet->patterns.resize(j);

		// Update position and other data if a transformation has been made
		if (pattern_applied) {
			bullet->direction = Vector2(1.0f, 0.0f).rotated(bullet->angle);
			//bullet->transform.set_rotation(bullet->angle);
			bullet->transform = bullet->transform.rotated(bullet->angle - bullet->transform.get_rotation() + 1.57079632679f + bullet->rotation);
			bullet->transform.set_origin(bullet->position);
		}


		// Bullet is still alive, increase its lifetime.
		bullet->lifetime += delta;
		// Return false if the bullet should not be deleted yet.
		return false;
	}
};

BULLET_KIT_IMPLEMENTATION(BasicBulletKit, BasicBulletsPool)

#endif