#ifndef BASIC_ITEM_KIT_H
#define BASIC_ITEM_KIT_H

#include <Godot.hpp>

#include <Texture.hpp>
#include <PackedScene.hpp>
#include <Node2D.hpp>

#include "../bullet_kit.h"

using namespace godot;


// Bullet kit definition.
class BasicItemKit : public BulletKit {
	GODOT_CLASS(BasicItemKit, BulletKit)
public:
	BULLET_KIT(BasicItemsPool)

	Ref<Texture> texture;
	// Vector of what directions items naturally fall at. 
	Vector2 gravity = Vector2();
	float damp = 0.95f;
	//float spin = 1.0f;
    float magnet_strength = 10.0f;

	static void _register_methods() {
		register_property<BasicItemKit, Ref<Texture>>("texture", &BasicItemKit::texture, Ref<Texture>(), 
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_RESOURCE_TYPE, "Texture");
		register_property<BasicItemKit, Vector2>("gravity", &BasicItemKit::gravity, Vector2());
		register_property<BasicItemKit, float>("damp", &BasicItemKit::damp, 0.9f);
		//register_property<BasicItemKit, float>("spin", &BasicItemKit::spin, 1.0f);
		register_property<BasicItemKit, float>("magnet_strength", &BasicItemKit::magnet_strength, 1.0f);
		
		BULLET_KIT_REGISTRATION(BasicItemKit, Bullet)
	}
};

// Bullets pool definition.
class BasicItemsPool : public AbstractBulletsPool<BasicItemKit, Bullet> {

	// void _init_bullet(Bullet* bullet); Use default implementation.

	void _enable_bullet(Bullet* bullet) {
		// Reset some bullet variables that are not set by the create_bullet functions
		bullet->grazed = false;
		bullet->fading = false;
		bullet->magnet_target_id = 0;
		bullet->layer = 0;
		bullet->lifetime = 0.0f;
		bullet->lifespan = std::numeric_limits<float>::infinity();
        bullet->hitbox_scale = 1.0f;
		Rect2 texture_rect = Rect2(-0.5f, -0.5f, 1.0f, 1.0f);
		RID texture_rid = kit->texture->get_rid();
		
		bullet->fade_time = kit->fade_time;
		bullet->fade_timer = kit->fade_time;

		// Configure the bullet to draw the kit texture each frame.
		VisualServer::get_singleton()->canvas_item_add_texture_rect(bullet->item_rid,
			texture_rect,
			texture_rid);
        VisualServer::get_singleton()->canvas_item_set_draw_index(bullet->item_rid, 0);
        if (collisions_enabled) {
            Physics2DServer::get_singleton()->area_set_shape_disabled(shared_area, bullet->shape_index, false);
        }
	}

	// void _disable_bullet(Bullet* bullet); Use default implementation.

	bool _process_bullet(Bullet* bullet, float delta) {
        Vector2 last_pos = bullet->position;
        if (bullet->magnet_target_id) {
            if (bullet->fade_timer) {
                bullet->fade_timer = 0.0f;
                bullet->transform = bullet->transform.rotated(-bullet->transform.get_rotation());
            }
            Node2D *node = bullet->magnet_target;
            godot_int instance_id = bullet->magnet_target_id;
            if (core_1_1_api->godot_is_instance_valid(core_1_2_api->godot_instance_from_id(instance_id))) {
                float angle = ((Vector2)node->get_position()).angle_to_point(bullet->position);
                bullet->position += Vector2(kit->magnet_strength * delta, 0.0f).rotated(angle);
            }
        } else if (bullet->fade_timer) {
            bullet->fade_timer -= delta;
            bullet->position += bullet->speed * bullet->direction * delta;
            if (delta == 1) {
                bullet->speed *= kit->damp;
            } else {
                bullet->speed *= powf(kit->damp, delta);
            }
            Transform2D xform = bullet->transform.rotated(bullet->spin);
            if (bullet->fade_timer <= 0.0f) {
                bullet->fade_timer = 0.0f;
                xform = xform.rotated(-xform.get_rotation());
            }
            xform.set_origin(bullet->position);
            bullet->transform = xform;
        } else {
            bullet->position += kit->gravity * delta;
        }
        if (bullet->position.y < bullet->scale * -0.5f) {
            Vector2 pos = bullet->position;
            pos.y = bullet->scale * 0.5f;
            bullet->transform = bullet->transform.rotated(-bullet->transform.get_rotation());
            bullet->transform.set_origin(pos);
            Color color = bullet->bullet_data;
            color.b = 1.0f;
            VisualServer::get_singleton()->canvas_item_set_modulate(bullet->item_rid, color);
        } else { 
            if (last_pos.y < bullet->scale * -0.5f) {
                Color color = bullet->bullet_data;
                VisualServer::get_singleton()->canvas_item_set_modulate(bullet->item_rid, color);
            }
            bullet->transform.set_origin(bullet->position);
        }
        
        if(!active_rect.has_point(bullet->position) || bullet->lifetime >= bullet->lifespan) {
            return true;
        }
		// Bullet is still alive, increase its lifetime.
		bullet->lifetime += delta;
		// Return false if the bullet should not be deleted yet.
		return false;
	}
};

BULLET_KIT_IMPLEMENTATION(BasicItemKit, BasicItemsPool)

#endif