#ifndef BULLET_CLEAR_KIT_H
#define BULLET_CLEAR_KIT_H

#include <Godot.hpp>

#include <Texture.hpp>
#include <PackedScene.hpp>
#include <Node2D.hpp>

#include "../bullet_kit.h"

using namespace godot;


// Bullet kit definition.
class BulletClearKit : public BulletKit {
	GODOT_CLASS(BulletClearKit, BulletKit)
public:
	BULLET_KIT(BulletClearsPool)

	Ref<Texture> texture;

	static void _register_methods() {
		register_property<BulletClearKit, Ref<Texture>>("texture", &BulletClearKit::texture, Ref<Texture>(), 
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_RESOURCE_TYPE, "Texture");
		
		BULLET_KIT_REGISTRATION(BulletClearKit, Bullet)
	}
};

// Bullets pool definition.
class BulletClearsPool : public AbstractBulletsPool<BulletClearKit, Bullet> {

	// void _init_bullet(Bullet* bullet); Use default implementation.

	void _enable_bullet(Bullet* bullet) {
		// Reset some bullet variables that are not set by the create_bullet functions
		bullet->layer = 0;
		bullet->lifetime = 0.0f;
		bullet->lifespan = 120.0f;
		Rect2 texture_rect = Rect2(-0.5f, -0.5f, 1.0f, 1.0f);
		RID texture_rid = kit->texture->get_rid();
		
		bullet->fade_time = kit->fade_time;
		bullet->fade_timer = kit->fade_time;

		// Configure the bullet to draw the kit texture each frame.
		VisualServer::get_singleton()->canvas_item_add_texture_rect(bullet->item_rid,
			texture_rect,
			texture_rid);
        VisualServer::get_singleton()->canvas_item_set_draw_index(bullet->item_rid, 0);
	}

	// void _disable_bullet(Bullet* bullet); Use default implementation.

	bool _process_bullet(Bullet* bullet, float delta) {
        Color c = bullet->fade_color;
        c.a = bullet->lifetime / bullet->lifespan;
        VisualServer::get_singleton()->canvas_item_set_modulate(bullet->item_rid, c);
        if (bullet->lifetime >= bullet->lifespan) {
            return true;
        }
		// Bullet is still alive, increase its lifetime.
		bullet->lifetime += delta;
		// Return false if the bullet should not be deleted yet.
		return false;
	}
};

BULLET_KIT_IMPLEMENTATION(BulletClearKit, BulletClearsPool)

#endif