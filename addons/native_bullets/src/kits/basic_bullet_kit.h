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
		// Reset the bullet lifetime.
		bullet->lifetime = 0.0f;
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
		bullet->transform.set_origin(origin + bullet->direction * bullet->speed * delta);
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

		if(!active_rect.has_point(bullet->transform.get_origin())) {
			// Return true if the bullet should be deleted.
			return true;
		}

		// Iterate over existing transformations
		int j = 0;
		for (int i = 0; i < bullet->patterns.size(); i++) {
			Array pattern = bullet->patterns[i];
			if (pattern[1]) {
				pattern[1] = (float)pattern[1] - delta;
				if ((float)pattern[1] <= 0.0f) {
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


		// Bullet is still alive, increase its lifetime.
		bullet->lifetime += delta;
		// Return false if the bullet should not be deleted yet.
		return false;
	}
};

BULLET_KIT_IMPLEMENTATION(BasicBulletKit, BasicBulletsPool)

#endif