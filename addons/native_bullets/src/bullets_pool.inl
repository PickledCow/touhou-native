#include <limits>

#include <Godot.hpp>
#include <VisualServer.hpp>
#include <Physics2DServer.hpp>
#include <Viewport.hpp>
#include <Font.hpp>

#include "bullets_pool.h"

using namespace godot;


//-- START Default "standard" implementations.

template <class Kit, class BulletType>
void AbstractBulletsPool<Kit, BulletType>::_init_bullet(BulletType* bullet) {}

template <class Kit, class BulletType>
void AbstractBulletsPool<Kit, BulletType>::_enable_bullet(BulletType* bullet) {
	bullet->lifetime = 0.0f;

	// Rect2 texture_rect = Rect2(-kit->texture->get_size() / 2.0f, kit->texture->get_size());
	Rect2 texture_rect = Rect2(-0.5f, -0.5f, 1.0f, 1.0f);
	RID texture_rid = kit->texture->get_rid();
	
	VisualServer::get_singleton()->canvas_item_add_texture_rect(bullet->item_rid,
		texture_rect,
		texture_rid);
}

template <class Kit, class BulletType>
void AbstractBulletsPool<Kit, BulletType>::_disable_bullet(BulletType* bullet) {
	VisualServer::get_singleton()->canvas_item_clear(bullet->item_rid);
}

template <class Kit, class BulletType>
bool AbstractBulletsPool<Kit, BulletType>::_process_bullet(BulletType* bullet, float delta) {
	bullet->transform.set_origin(bullet->transform.get_origin() + bullet->direction * bullet->speed * delta);
	if (bullet->accel) {
		bullet->speed += bullet->accel * delta;
		if (((bullet->speed - bullet->max_speed) * bullet->accel) > 0.0f) bullet->speed = bullet->max_speed;
	}

	if(!active_rect.has_point(bullet->transform.get_origin())) {
		return true;
	}

	bullet->lifetime += delta;
	return false;
}

//-- END Default "standard" implementation.

template <class Kit, class BulletType>
AbstractBulletsPool<Kit, BulletType>::~AbstractBulletsPool() {
	// Bullets node is responsible for clearing all the area and area shapes
	for(int32_t i = 0; i < pool_size; i++) {
		VisualServer::get_singleton()->free_rid(bullets[i]->item_rid);
		bullets[i]->free();
	}
	VisualServer::get_singleton()->free_rid(canvas_item);

	delete[] bullets;
	delete[] shapes_to_indices;
}

template <class Kit, class BulletType>
void AbstractBulletsPool<Kit, BulletType>::_init(CanvasItem* canvas_parent, RID shared_area, int32_t starting_shape_index,
		int32_t set_index, Ref<BulletKit> kit, int32_t pool_size, int32_t z_index, Vector2 origin) {
	
	// Check if collisions are enabled and if layer or mask are != 0, 
	// otherwise the bullets would not collide with anything anyways.
	this->collisions_enabled = kit->collisions_enabled && kit->collision_shape.is_valid() && ((int64_t)kit->collision_layer + (int64_t)kit->collision_mask) != 0;
	this->canvas_parent = canvas_parent;
	this->shared_area = shared_area;
	this->starting_shape_index = starting_shape_index;
	this->kit = kit;
	this->pool_size = pool_size;
	this->set_index = set_index;

	available_bullets = pool_size;
	active_bullets = 0;

	bullets = new BulletType*[pool_size];
	shapes_to_indices = new int32_t[pool_size];

	canvas_item = VisualServer::get_singleton()->canvas_item_create();
	VisualServer::get_singleton()->canvas_item_set_parent(canvas_item, canvas_parent->get_canvas_item());
	VisualServer::get_singleton()->canvas_item_set_z_index(canvas_item, z_index);
	
	// Vector2 origin = Physics2DServer::get_singleton()->area_get_transform(shared_area).get_origin();
	Transform2D xform = Transform2D(0.0f, origin);
	// VisualServer::get_singleton()->canvas_item_set_transform(canvas_item, xform);

	for(int32_t i = 0; i < pool_size; i++) {
		BulletType* bullet = BulletType::_new();
		bullets[i] = bullet;

		bullet->item_rid = VisualServer::get_singleton()->canvas_item_create();
		VisualServer::get_singleton()->canvas_item_set_parent(bullet->item_rid, canvas_item);
		VisualServer::get_singleton()->canvas_item_set_material(bullet->item_rid, kit->material->get_rid());

		if(collisions_enabled) {
			RID shared_shape_rid = kit->collision_shape->get_rid();
			Physics2DServer::get_singleton()->area_add_shape(shared_area, shared_shape_rid, Transform2D(), true);
			bullet->shape_index = starting_shape_index + i;
			shapes_to_indices[i] = i;
		}

		Color color = Color(1.0f, 1.0f, 1.0f, 0.0f);
		VisualServer::get_singleton()->canvas_item_set_modulate(bullet->item_rid, color);

		_init_bullet(bullet);
	}
}

template <class Kit, class BulletType>
int32_t AbstractBulletsPool<Kit, BulletType>::_process(float delta) {
	active_rect = kit->active_rect;
	bounce_rect = kit->bounce_rect;
	int32_t amount_variation = 0;

	if(collisions_enabled) {
		for(int32_t i = pool_size - 1; i >= available_bullets; i--) {
			BulletType* bullet = bullets[i];

			if(_process_bullet(bullet, delta)) {
				_release_bullet(i);
				amount_variation -= 1;
				i += 1;
				continue;
			}
			
			VisualServer::get_singleton()->canvas_item_set_transform(bullet->item_rid, bullet->transform);

			Transform2D xform = bullet->transform;
			Vector2 origin = xform.get_origin();
			xform = xform.scaled(bullet->hitbox_scale * Vector2(1.0f, 1.0f));
			xform.set_origin(origin);
			Physics2DServer::get_singleton()->area_set_shape_transform(shared_area, bullet->shape_index, xform);
		}
	} else {
		for(int32_t i = pool_size - 1; i >= available_bullets; i--) {
			BulletType* bullet = bullets[i];

			if(_process_bullet(bullet, delta)) {
				_release_bullet(i);
				amount_variation -= 1;
				i += 1;
				continue;
			}
			
			VisualServer::get_singleton()->canvas_item_set_transform(bullet->item_rid, bullet->transform);
		}
	}
	return amount_variation;
}

template <class Kit, class BulletType>
void AbstractBulletsPool<Kit, BulletType>::spawn_bullet(Dictionary properties) {
	if(available_bullets > 0) {
		available_bullets -= 1;
		active_bullets += 1;

		BulletType* bullet = bullets[available_bullets];

		if(collisions_enabled)
			Physics2DServer::get_singleton()->area_set_shape_disabled(shared_area, bullet->shape_index, false);

		Array keys = properties.keys();
		for(int32_t i = 0; i < keys.size(); i++) {
			bullet->set(keys[i], properties[keys[i]]);
		}

		VisualServer::get_singleton()->canvas_item_set_transform(bullet->item_rid, bullet->transform);
		if(collisions_enabled) {
			Transform2D xform = bullet->transform;
			Vector2 origin = xform.get_origin();
			//xform.set_origin(Vector2(0.0f, 0.0f));
			xform = xform.scaled(bullet->hitbox_scale * Vector2(1.0f, 1.0f));
			xform.set_origin(origin);
			Physics2DServer::get_singleton()->area_set_shape_transform(shared_area, bullet->shape_index, xform);
		}

		_enable_bullet(bullet);
	}
}

template <class Kit, class BulletType>
BulletID AbstractBulletsPool<Kit, BulletType>::obtain_bullet() {
	if(available_bullets > 0) {
		available_bullets -= 1;
		active_bullets += 1;

		BulletType* bullet = bullets[available_bullets];

		// if(collisions_enabled)
		// 	Physics2DServer::get_singleton()->area_set_shape_disabled(shared_area, bullet->shape_index, false);

		//VisualServer::get_singleton()->canvas_item_set_draw_index(bullet->item_rid, (draw_index++));
		bullet->draw_index = draw_index++;
		if (draw_index > 16777215) draw_index = 0; // 2^24
		
		_enable_bullet(bullet);

		return BulletID(bullet->shape_index, bullet->cycle, set_index);
	}
	return BulletID(-1, -1, -1);
}

template <class Kit, class BulletType>
bool AbstractBulletsPool<Kit, BulletType>::release_bullet(BulletID id) {
	if(id.index >= starting_shape_index && id.index < starting_shape_index + pool_size && id.set == set_index) {
		int32_t bullet_index = shapes_to_indices[id.index - starting_shape_index];
		if(bullet_index >= available_bullets && bullet_index < pool_size && id.cycle == bullets[bullet_index]->cycle) {
			_release_bullet(bullet_index);
			return true;
		}
	}
	return false;
}

template <class Kit, class BulletType>
void AbstractBulletsPool<Kit, BulletType>::_release_bullet(int32_t index) {
	BulletType* bullet = bullets[index];
	
	if(collisions_enabled)
		Physics2DServer::get_singleton()->area_set_shape_disabled(shared_area, bullet->shape_index, true);
	
	_disable_bullet(bullet);
	bullet->cycle += 1;

	_swap(shapes_to_indices[bullet->shape_index - starting_shape_index], shapes_to_indices[bullets[available_bullets]->shape_index - starting_shape_index]);
	_swap(bullets[index], bullets[available_bullets]);

	available_bullets += 1;
	active_bullets -= 1;
}

template <class Kit, class BulletType>
bool AbstractBulletsPool<Kit, BulletType>::is_bullet_valid(BulletID id) {
	if(id.index >= starting_shape_index && id.index < starting_shape_index + pool_size && id.set == set_index) {
		int32_t bullet_index = shapes_to_indices[id.index - starting_shape_index];
		if(bullet_index >= available_bullets && bullet_index < pool_size && id.cycle == bullets[bullet_index]->cycle) {
			return true;
		}
	}
	return false;
}

template <class Kit, class BulletType>
bool AbstractBulletsPool<Kit, BulletType>::is_bullet_existing(int32_t shape_index) {
	if(shape_index >= starting_shape_index && shape_index < starting_shape_index + pool_size) {
		int32_t bullet_index = shapes_to_indices[shape_index - starting_shape_index];
		if(bullet_index >= available_bullets) {
			return true;
		}
	}
	return false;
}

template <class Kit, class BulletType>
BulletID AbstractBulletsPool<Kit, BulletType>::get_bullet_from_shape(int32_t shape_index) {
	if(shape_index >= starting_shape_index && shape_index < starting_shape_index + pool_size) {
		int32_t bullet_index = shapes_to_indices[shape_index - starting_shape_index];
		if(bullet_index >= available_bullets) {
			return BulletID(shape_index, bullets[bullet_index]->cycle, set_index);
		}
	}
	return BulletID(-1, -1, -1);
}



template <class Kit, class BulletType>
void AbstractBulletsPool<Kit, BulletType>::set_bullet_property(BulletID id, String property, Variant value) {
	if(is_bullet_valid(id)) {
		int32_t bullet_index = shapes_to_indices[id.index - starting_shape_index];
		bullets[bullet_index]->set(property, value);

		switch (property.hash()) { // find a better way to do this 
			case (596893057): { // transform
				BulletType* bullet = bullets[bullet_index];
				VisualServer::get_singleton()->canvas_item_set_transform(bullet->item_rid, bullet->transform);
				Transform2D xform = bullet->transform;
				Vector2 origin = xform.get_origin();
				if(collisions_enabled) {
					xform = xform.scaled(bullet->hitbox_scale * Vector2(0.5f, 0.5f));
					xform.set_origin(origin);
					Physics2DServer::get_singleton()->area_set_shape_transform(shared_area, bullet->shape_index, xform);
				}
				bullets[bullet_index]->set("position", origin);
				break;
			}
			case (1290762938): { // position
				BulletType* bullet = bullets[bullet_index];
				Transform2D xform = get_bullet_property(id, "transform");
				xform.set_origin((Vector2)value);
				set_bullet_property(id, "transform", xform);
				break;
			}
			case (657950997): { // rotation
				BulletType* bullet = bullets[bullet_index];
				Transform2D xform = get_bullet_property(id, "transform");
				Vector2 origin = xform.get_origin();
				xform = xform.rotated(bullet->angle - xform.get_rotation() + 1.57079632679f + (float)value);
				xform.set_origin(origin);
				set_bullet_property(id, "transform", xform);
				break;
			}
			case (253255468): { // angle
				BulletType* bullet = bullets[bullet_index];
				Transform2D xform = get_bullet_property(id, "transform");
				Vector2 origin = xform.get_origin();
				xform = xform.rotated((float)value - xform.get_rotation() + 1.57079632679f + bullet->rotation);
				xform.set_origin(origin);
				set_bullet_property(id, "transform", xform);
				set_bullet_property(id, "direction", Vector2(1.0f, 0.0f).rotated((float)value));
				break;
			}
			case (373355782): { // bullet_data
				BulletType* bullet = bullets[bullet_index];
				Color color = bullet->bullet_data;
				VisualServer::get_singleton()->canvas_item_set_modulate(bullet->item_rid, color);
				break;
			}
			case (3334398746): { // hitbox_scale
				BulletType* bullet = bullets[bullet_index];
				if(collisions_enabled) {
					Transform2D xform = bullet->transform;
					Vector2 origin = xform.get_origin();
					//xform.set_origin(Vector2(0.0f, 0.0f));
					xform = xform.scaled(bullet->hitbox_scale * Vector2(1.0f, 1.0f));
					xform.set_origin(origin);
					Physics2DServer::get_singleton()->area_set_shape_transform(shared_area, bullet->shape_index, xform);
				}
				break;
			}
			case (265852802): { // layer
				BulletType* bullet = bullets[bullet_index];
				VisualServer::get_singleton()->canvas_item_set_draw_index(bullet->item_rid, (bullet->layer << 24) + bullet->draw_index);
				break;
			}
			case (274200205): { // scale
				BulletType* bullet = bullets[bullet_index];
				Transform2D xform = get_bullet_property(id, "transform");
				Vector2 origin = xform.get_origin();
				xform = xform.scaled((bullet->scale / xform.get_scale().x) * Vector2(1.0f, 1.0f));
				xform.set_origin(origin);
				set_bullet_property(id, "transform", xform);
				break;
			}
			default:
				break;
		}
	}
}


template <class Kit, class BulletType>
Variant AbstractBulletsPool<Kit, BulletType>::get_bullet_property(BulletID id, String property) {
	if(is_bullet_valid(id)) {
		int32_t bullet_index = shapes_to_indices[id.index - starting_shape_index];

		return bullets[bullet_index]->get(property);
	}
	return Variant();
}


// template <class Kit, class BulletType>
// bool AbstractBulletsPool<Kit, BulletType>::is_deleted(BulletID id) {
// 	if(id.index >= starting_shape_index && id.index < starting_shape_index + pool_size && id.set == set_index) {
// 		int32_t bullet_index = shapes_to_indices[id.index - starting_shape_index];
// 		return (bullets[bullet_index]->instance_id == id.id);
// 	}
// 	return false;
// }


