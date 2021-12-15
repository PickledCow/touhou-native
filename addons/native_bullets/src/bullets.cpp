#include <VisualServer.hpp>
#include <Physics2DServer.hpp>
#include <World2D.hpp>
#include <Viewport.hpp>
#include <OS.hpp>
#include <Engine.hpp>
#include <Font.hpp>
#include <RegExMatch.hpp>
#include <Transform2D.hpp>
#include <Array.hpp>

#include "bullets.h"

using namespace godot;


void Bullets::_register_methods() {
	register_method("_physics_process", &Bullets::_physics_process);

	register_method("mount", &Bullets::mount);
	register_method("unmount", &Bullets::unmount);
	register_method("get_bullets_environment", &Bullets::get_bullets_environment);

	register_method("spawn_bullet", &Bullets::spawn_bullet);
	register_method("obtain_bullet", &Bullets::obtain_bullet);
	register_method("release_bullet", &Bullets::release_bullet);

	register_method("is_bullet_valid", &Bullets::is_bullet_valid);
	register_method("is_kit_valid", &Bullets::is_kit_valid);

	register_method("get_available_bullets", &Bullets::get_available_bullets);
	register_method("get_active_bullets", &Bullets::get_active_bullets);
	register_method("get_pool_size", &Bullets::get_pool_size);
	register_method("get_z_index", &Bullets::get_z_index);

	register_method("get_total_available_bullets", &Bullets::get_total_available_bullets);
	register_method("get_total_active_bullets", &Bullets::get_total_active_bullets);

	register_method("is_bullet_existing", &Bullets::is_bullet_existing);
	register_method("get_bullet_from_shape", &Bullets::get_bullet_from_shape);
	register_method("get_kit_from_bullet", &Bullets::get_kit_from_bullet);

	register_method("set_bullet_property", &Bullets::set_bullet_property);
	register_method("get_bullet_property", &Bullets::get_bullet_property);

	// New stuff
	register_method("create_shot_a1", &Bullets::create_shot_a1);
	register_method("create_shot_a2", &Bullets::create_shot_a2);
	register_method("create_pattern_a1", &Bullets::create_pattern_a1);
	register_method("create_pattern_a2", &Bullets::create_pattern_a2);

	register_method("add_pattern", &Bullets::add_pattern);
	register_method("add_transform", &Bullets::add_pattern);
	register_method("add_translate", &Bullets::add_translate);
	register_method("add_aim_at_point", &Bullets::add_aim_at_point);
	register_method("add_aim_at_object", &Bullets::add_aim_at_object);
	register_method("add_go_to_object", &Bullets::add_go_to_object);
	register_method("add_change_bullet", &Bullets::add_change_bullet);

	register_method("add_pattern_bulk", &Bullets::add_pattern_bulk);
	register_method("add_transform_bulk", &Bullets::add_pattern_bulk);
	register_method("add_translate_bulk", &Bullets::add_translate_bulk);
	register_method("add_aim_at_point_bulk", &Bullets::add_aim_at_point_bulk);
	register_method("add_aim_at_object_bulk", &Bullets::add_aim_at_object_bulk);
	register_method("add_go_to_object_bulk", &Bullets::add_go_to_object_bulk);
	register_method("add_change_bullet_bulk", &Bullets::add_change_bullet_bulk);

	register_method("is_deleted", &Bullets::is_deleted);
	
	register_method("set_bullet_properties", &Bullets::set_bullet_properties);
	register_method("set_properties", &Bullets::set_bullet_properties);
	register_method("set_bullet_properties_bulk", &Bullets::set_bullet_properties_bulk);
	register_method("set_properties_bulk", &Bullets::set_bullet_properties_bulk);

	// Aliases of existing 
	register_method("set_property", &Bullets::set_bullet_property);
	register_method("get_property", &Bullets::get_bullet_property);
	register_method("delete", &Bullets::release_bullet);
}

Bullets::Bullets() { }

Bullets::~Bullets() {
	_clear_rids();
}

void Bullets::_init() {
	available_bullets = 0;
	active_bullets = 0;
	total_bullets = 0;
	invalid_id = PoolIntArray();
	invalid_id.resize(3);
	invalid_id.set(0, -1);
	invalid_id.set(1, -1);
	invalid_id.set(2, -1);
}

void Bullets::_physics_process(float delta) {
	if(Engine::get_singleton()->is_editor_hint()) {
		return;
	}
	int32_t bullets_variation = 0;

	for(int32_t i = 0; i < pool_sets.size(); i++) {
		for(int32_t j = 0; j < pool_sets[i].pools.size(); j++) {
			float time_scale = pool_sets[i].pools[j].bullet_kit->time_scale;
			bullets_variation = pool_sets[i].pools[j].pool->_process(time_scale);
			available_bullets -= bullets_variation;
			active_bullets += bullets_variation;
		}
	}
	// Increase by golden-ration - 1 to have "maximum" "randomness"
	animation_random += 0.61803398875f;
	if (animation_random >= 1.0f) animation_random -= 1.0f;
}

void Bullets::_clear_rids() {
	for(int32_t i = 0; i < shared_areas.size(); i++) {
		Physics2DServer::get_singleton()->area_clear_shapes(shared_areas[i]);
		Physics2DServer::get_singleton()->free_rid(shared_areas[i]);
	}
}

int32_t Bullets::_get_pool_index(int32_t set_index, int32_t bullet_index) {
	if(bullet_index >= 0 && set_index >= 0 && set_index < pool_sets.size() && bullet_index < pool_sets[set_index].bullets_amount) {
		int32_t pool_threshold = pool_sets[set_index].pools[0].size;
		int32_t pool_index = 0;

		while(bullet_index >= pool_threshold) {
			pool_index++;
			pool_threshold += pool_sets[set_index].pools[pool_index].size;
		}
		if(pool_index < pool_sets[set_index].pools.size()) {
			return pool_index;
		}
	}
	return -1;
}

void Bullets::mount(Node* bullets_environment) {
	if(bullets_environment == nullptr || this->bullets_environment == bullets_environment) {
		return;
	}
	if(this->bullets_environment != nullptr) {
		this->bullets_environment->set("current", false);
	}
	
	this->bullets_environment = bullets_environment;
	this->bullets_environment->set("current", true);

	Array bullet_kits = bullets_environment->get("bullet_kits");
	Array pools_sizes = bullets_environment->get("pools_sizes");
	Array z_indices = bullets_environment->get("z_indices");
	Vector2 origin = bullets_environment->get_parent()->get("position");

	pool_sets.clear();
	areas_to_pool_set_indices.clear();
	kits_to_set_pool_indices.clear();
	_clear_rids();
	shared_areas.clear();

	available_bullets = 0;
	active_bullets = 0;

	Dictionary collision_layers_masks_to_kits;
	
	for(int32_t i = 0; i < bullet_kits.size(); i++) {
		Ref<BulletKit> kit = bullet_kits[i];
		// By default add the the BulletKit to a no-collisions list. (layer and mask = 0)
		int64_t layer_mask = 0;
		if(kit->collisions_enabled && kit->collision_shape.is_valid()) {
			// If collisions are enabled, add the BulletKit to another list.
			layer_mask = (int64_t)kit->collision_layer + ((int64_t)kit->collision_mask << 32);
		}
		if(collision_layers_masks_to_kits.has(layer_mask)) {
			collision_layers_masks_to_kits[layer_mask].operator Array().append(kit);
		}
		else {
			Array array = Array();
			array.append(kit);
			collision_layers_masks_to_kits[layer_mask] = array;
		}
	}
	// Create the PoolKitSets array. If they exist, a set will be allocated for no-collisions pools.
	pool_sets.resize(collision_layers_masks_to_kits.size());
	
	Array layer_mask_keys = collision_layers_masks_to_kits.keys();
	for(int32_t i = 0; i < layer_mask_keys.size(); i++) {
		Array kits = collision_layers_masks_to_kits[layer_mask_keys[i]];
		Ref<BulletKit> first_kit = kits[0];

		pool_sets[i].pools.resize(kits.size());

		Transform2D xform = Transform2D(0.0f, origin);

		RID shared_area = RID();
		if(layer_mask_keys[i].operator int64_t() != 0) {
			// This is a collisions-enabled set, create the shared area.
			shared_area = Physics2DServer::get_singleton()->area_create();
			Physics2DServer::get_singleton()->area_set_collision_layer(shared_area, first_kit->collision_layer);
			Physics2DServer::get_singleton()->area_set_collision_mask(shared_area, first_kit->collision_mask);
			Physics2DServer::get_singleton()->area_set_monitorable(shared_area, true);
			Physics2DServer::get_singleton()->area_set_space(shared_area, get_world_2d()->get_space());
			Physics2DServer::get_singleton()->area_set_transform(shared_area, xform);

			shared_areas.append(shared_area);
			areas_to_pool_set_indices[shared_area] = i;
		}
		int32_t pool_set_available_bullets = 0;

		for(int32_t j = 0; j < kits.size(); j++) {
			Ref<BulletKit> kit = kits[j];
			
			// Transform2D xform = Transform2D(0.0f, (Vector2)kit->origin);

			// RID shared_area = RID();
			// if(layer_mask_keys[i].operator int64_t() != 0) {
			// 	// This is a collisions-enabled set, create the shared area.
			// 	shared_area = Physics2DServer::get_singleton()->area_create();
			// 	Physics2DServer::get_singleton()->area_set_collision_layer(shared_area, first_kit->collision_layer);
			// 	Physics2DServer::get_singleton()->area_set_collision_mask(shared_area, first_kit->collision_mask);
			// 	Physics2DServer::get_singleton()->area_set_monitorable(shared_area, true);
			// 	Physics2DServer::get_singleton()->area_set_space(shared_area, get_world_2d()->get_space());
			// 	Physics2DServer::get_singleton()->area_set_transform(shared_area, xform);

			// 	shared_areas.append(shared_area);
			// 	areas_to_pool_set_indices[shared_area] = i;
			// }


			PoolIntArray set_pool_indices = PoolIntArray();
			set_pool_indices.resize(2);
			set_pool_indices.set(0, i);
			set_pool_indices.set(1, j);
			kits_to_set_pool_indices[kit] = set_pool_indices;
			
			int32_t kit_index_in_node = bullet_kits.find(kit);
			int32_t pool_size = pools_sizes[kit_index_in_node];

			pool_sets[i].pools[j].pool = kit->_create_pool();
			pool_sets[i].pools[j].bullet_kit = kit;
			pool_sets[i].pools[j].size = pool_size;
			pool_sets[i].pools[j].z_index = z_indices[kit_index_in_node];

			pool_sets[i].pools[j].pool->_init(this, shared_area, pool_set_available_bullets,
				i, kit, pool_size, z_indices[kit_index_in_node]);

			pool_set_available_bullets += pool_size;
		}
		pool_sets[i].bullets_amount = pool_set_available_bullets;
		available_bullets += pool_set_available_bullets;
	}
	total_bullets = available_bullets;
}

void Bullets::unmount(Node* bullets_environment) {
	if(this->bullets_environment == bullets_environment) {
		pool_sets.clear();
		areas_to_pool_set_indices.clear();
		kits_to_set_pool_indices.clear();
		_clear_rids();
		shared_areas.clear();

		available_bullets = 0;
		active_bullets = 0;
		total_bullets = 0;

		this->bullets_environment = nullptr;
	}
	if(bullets_environment != nullptr) {
		bullets_environment->set("current", false);
	}
}

Node* Bullets::get_bullets_environment() {
	return bullets_environment;
}

bool Bullets::spawn_bullet(Ref<BulletKit> kit, Dictionary properties) {
	if(available_bullets > 0 && kits_to_set_pool_indices.has(kit)) {
		PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit].operator PoolIntArray();
		BulletsPool* pool = pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool.get();

		if(pool->get_available_bullets() > 0) {
			available_bullets -= 1;
			active_bullets += 1;

			pool->spawn_bullet(properties);
			return true;
		}
	}
	return false;
}

Variant Bullets::obtain_bullet(Ref<BulletKit> kit) {
	if(available_bullets > 0 && kits_to_set_pool_indices.has(kit)) {
		PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit].operator PoolIntArray();
		BulletsPool* pool = pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool.get();

		if(pool->get_available_bullets() > 0) {
			available_bullets -= 1;
			active_bullets += 1;

			BulletID bullet_id = pool->obtain_bullet();
			PoolIntArray to_return = invalid_id;
			to_return.set(0, bullet_id.index);
			to_return.set(1, bullet_id.cycle);
			to_return.set(2, bullet_id.set);
			return to_return;
		}
	}
	return invalid_id;
}

bool Bullets::release_bullet(Variant id) {
	PoolIntArray bullet_id = id.operator PoolIntArray();
	bool result = false;

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		result = pool_sets[bullet_id[2]].pools[pool_index].pool->release_bullet(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]));
		if(result) {
			available_bullets += 1;
			active_bullets -= 1;
		}
	}
	return result;
}

bool Bullets::is_bullet_valid(Variant id) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		return pool_sets[bullet_id[2]].pools[pool_index].pool->is_bullet_valid(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]));
	}
	return false;
}

bool Bullets::is_kit_valid(Ref<BulletKit> kit) {
	return kits_to_set_pool_indices.has(kit);
}

int32_t Bullets::get_available_bullets(Ref<BulletKit> kit) {
	if(kits_to_set_pool_indices.has(kit)) {
		PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit];
		return pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool->get_available_bullets();
	}
	return 0;
}

int32_t Bullets::get_active_bullets(Ref<BulletKit> kit) {
	if(kits_to_set_pool_indices.has(kit)) {
		PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit];
		return pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool->get_active_bullets();
	}
	return 0;
}

int32_t Bullets::get_pool_size(Ref<BulletKit> kit) {
	if(kits_to_set_pool_indices.has(kit)) {
		PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit];
		return pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].size;
	}
	return 0;
}

int32_t Bullets::get_z_index(Ref<BulletKit> kit) {
	if(kits_to_set_pool_indices.has(kit)) {
		PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit];
		return pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].z_index;
	}
	return 0;
}

int32_t Bullets::get_total_available_bullets() {
	return available_bullets;
}

int32_t Bullets::get_total_active_bullets() {
	return active_bullets;
}

bool Bullets::is_bullet_existing(RID area_rid, int32_t shape_index) {
	if(!areas_to_pool_set_indices.has(area_rid)) {
		return false;
	}
	int32_t set_index = areas_to_pool_set_indices[area_rid];
	int32_t pool_index = _get_pool_index(set_index, shape_index);
	if(pool_index >= 0) {
		return pool_sets[set_index].pools[pool_index].pool->is_bullet_existing(shape_index);
	}
	return false;
}

Variant Bullets::get_bullet_from_shape(RID area_rid, int32_t shape_index) {
	if(!areas_to_pool_set_indices.has(area_rid)) {
		return invalid_id;
	}
	int32_t set_index = areas_to_pool_set_indices[area_rid];
	int32_t pool_index = _get_pool_index(set_index, shape_index);
	if(pool_index >= 0) {
		BulletID result = pool_sets[set_index].pools[pool_index].pool->get_bullet_from_shape(shape_index);

		PoolIntArray to_return = invalid_id;
		to_return.set(0, result.index);
		to_return.set(1, result.cycle);
		to_return.set(2, result.set);
		return to_return;
	}
	return invalid_id;
}

Ref<BulletKit> Bullets::get_kit_from_bullet(Variant id) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0 && pool_sets[bullet_id[2]].pools[pool_index].pool->is_bullet_valid(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]))) {
		return pool_sets[bullet_id[2]].pools[pool_index].bullet_kit;
	}
	return Ref<BulletKit>();
}

void Bullets::set_bullet_property(Variant id, String property, Variant value) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		pool_sets[bullet_id[2]].pools[pool_index].pool->set_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), property, value);
	}
}


Variant Bullets::get_bullet_property(Variant id, String property) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		return pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), property);
	}
	return Variant();
}


Variant Bullets::create_shot_a1(Ref<BulletKit> kit, Vector2 pos, float speed, float angle, PoolRealArray bullet_data, bool fade_in) {
	if(available_bullets > 0 && kits_to_set_pool_indices.has(kit)) {
		PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit].operator PoolIntArray();
		BulletsPool* pool = pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool.get();

		if(pool->get_available_bullets() > 0) {
			available_bullets -= 1;
			active_bullets += 1;

			BulletID bullet_id = pool->obtain_bullet();
			PoolIntArray to_return = invalid_id;
			to_return.set(0, bullet_id.index);
			to_return.set(1, bullet_id.cycle);
			to_return.set(2, bullet_id.set);

			int32_t pool_index = _get_pool_index(bullet_id.set, bullet_id.index);

			Transform2D xform = Transform2D(0.0f, Vector2(0.0f, 0.0f)).scaled(bullet_data[4] * Vector2(1.0f, 1.0f)).rotated(angle + 1.57079632679f);
			xform.set_origin(pos);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "transform", xform);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "scale", bullet_data[4]);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "direction",  Vector2(1.0f, 0.0f).rotated(angle));
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "angle", angle);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "speed", speed);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "accel", 0.0f);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "max_speed", 0.0f);
			Color compressed_data = Color();
			compressed_data.r = bullet_data[1] + bullet_data[0] / kit->texture_width;
			compressed_data.g = bullet_data[3] + bullet_data[2] / kit->texture_width;
			compressed_data.b = floor(bullet_data[6]) + 0.99999f;
			compressed_data.a = floor(bullet_data[7]) + animation_random;
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "texture_offset", floor(bullet_data[6]));
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "bullet_data", compressed_data);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "hitbox_scale", bullet_data[5]);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "spin", bullet_data[8]);

			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "layer", bullet_data[9]);
			
			return to_return;
		}
	}
	return invalid_id;
}


Variant Bullets::create_shot_a2(Ref<BulletKit> kit, Vector2 pos, float speed, float angle, float accel, float max_speed, PoolRealArray bullet_data, bool fade_in) {
	if(available_bullets > 0 && kits_to_set_pool_indices.has(kit)) {
		PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit].operator PoolIntArray();
		BulletsPool* pool = pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool.get();

		if(pool->get_available_bullets() > 0) {
			available_bullets -= 1;
			active_bullets += 1;

			BulletID bullet_id = pool->obtain_bullet();
			PoolIntArray to_return = invalid_id;
			to_return.set(0, bullet_id.index);
			to_return.set(1, bullet_id.cycle);
			to_return.set(2, bullet_id.set);

			int32_t pool_index = _get_pool_index(bullet_id.set, bullet_id.index);

			Transform2D xform = Transform2D(0.0f, Vector2(0.0f, 0.0f)).scaled(bullet_data[4] * Vector2(1.0f, 1.0f)).rotated(angle + 1.57079632679f);
			xform.set_origin(pos);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "transform", xform);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "scale", bullet_data[4]);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "direction",  Vector2(1.0f, 0.0f).rotated(angle));
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "angle", angle);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "speed", speed);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "accel", accel);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "max_speed", max_speed);
			Color compressed_data = Color();
			compressed_data.r = bullet_data[1] + bullet_data[0] / kit->texture_width;
			compressed_data.g = bullet_data[3] + bullet_data[2] / kit->texture_width;
			compressed_data.b = floor(bullet_data[6]) + 0.99999f;
			compressed_data.a = floor(bullet_data[7]) + animation_random;
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "texture_offset", floor(bullet_data[6]));
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "bullet_data", compressed_data);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "hitbox_scale", bullet_data[5]);
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "spin", bullet_data[8]);
			
			pool_sets[bullet_id.set].pools[pool_index].pool->set_bullet_property(bullet_id, "layer", bullet_data[9]);

			return to_return;
		}
	}
	return invalid_id;
}


Variant Bullets::create_pattern_a1(Ref<BulletKit> kit, int mode, Vector2 pos, float r1, float speed1, float angle, int density, float spread, PoolRealArray bullet_data, bool fade_in) {
	Array bullets = Array();
	switch (mode) {
		case 0: { // ring
			if(available_bullets > 0 && kits_to_set_pool_indices.has(kit)) {
				PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit].operator PoolIntArray();
				BulletsPool* pool = pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool.get();

				float step = 6.28318530718f / (float)density;

				for (int i = 0; i < std::min(density, pool->get_available_bullets()); i++) {
					float a = angle + i * step;
					Vector2 p = pos + r1 * Vector2(cos(a), sin(a));
					Variant bullet = create_shot_a1(kit, p, speed1, a, bullet_data, fade_in);
					bullets.append(bullet);
				}
			}
			break;
		}
		
		case 1: { // fan
			if(available_bullets > 0 && kits_to_set_pool_indices.has(kit)) {
				PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit].operator PoolIntArray();
				BulletsPool* pool = pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool.get();

				float step = spread / ((float)density - 1.0f);

				float oset = density % 2 == 0 ? -0.5f : 0.0f;

				for (int i = std::min(density / 2, pool->get_available_bullets()); i > 0; i--) {
					float a = angle + (i + oset) * step;
					Vector2 p = pos + r1 * Vector2(cos(a), sin(a));
					Variant bullet = create_shot_a1(kit, p, speed1, a, bullet_data, fade_in);
					bullets.append(bullet);
					
					a = angle - (i + oset) * step;
					p = pos + r1 * Vector2(cos(a), sin(a));
					bullet = create_shot_a1(kit, p, speed1, a, bullet_data, fade_in);
					bullets.append(bullet);
				}
				if (density % 2 == 1) {
					Vector2 p = pos + r1 * Vector2(cos(angle), sin(angle));
					Variant bullet = create_shot_a1(kit, p, speed1, angle, bullet_data, fade_in);
					bullets.append(bullet);
				}
			}
			break;
		}

		case 2: { // polygon
			if(available_bullets > 0 && kits_to_set_pool_indices.has(kit)) {
				PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit].operator PoolIntArray();
				BulletsPool* pool = pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool.get();

				int sides = (int)spread;

				float step = 6.28318530718f / ((float)density * floor(spread));
				float face_step = 6.28318530718f / floor(spread);

				float oset = -density / 2.0f;

				for (int j = 0; j < sides; j++) {
					for (int i = 0; i < std::min(density, pool->get_available_bullets()); i++) {
						float tilt = (i + oset) * step;
						float a = angle + tilt + j * face_step;
						float skew = 1.0f / cos(tilt);
						Vector2 p = pos + r1 * Vector2(cos(a), sin(a)) * skew;
						float speed = speed1 * skew;
						Variant bullet = create_shot_a1(kit, p, speed, a, bullet_data, fade_in);
						bullets.append(bullet);
					}
				}

			}
			break;
		}
		
		default:
			break;
	}
	return bullets;
}


Variant Bullets::create_pattern_a2(Ref<BulletKit> kit, int mode, Vector2 pos, float r1, float r2, float speed1, float speed2, float angle, int density, int stack, float spread, PoolRealArray bullet_data, bool fade_in) {
	Array bullets = Array();
	switch (mode) {
	case 0: {
		if(available_bullets > 0 && kits_to_set_pool_indices.has(kit)) {
			PoolIntArray set_pool_indices = kits_to_set_pool_indices[kit].operator PoolIntArray();
			BulletsPool* pool = pool_sets[set_pool_indices[0]].pools[set_pool_indices[1]].pool.get();

			float step = 6.28318530718f / (float)density;

			for (int i = 0; i < std::min(density, pool->get_available_bullets()); i++) {
				float a = angle + i * step;
				Vector2 p = pos + r1 * Vector2(cos(a), sin(a));
				Variant bullet = create_shot_a1(kit, p, speed1, a, bullet_data, fade_in);
				bullets.append(bullet);
			}
		}
		break;
	}
	
	default:
		break;
	}
	return bullets;
}


void Bullets::set_bullet_properties(Variant id, Dictionary properties) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		Array keys = properties.keys();
		for(int32_t i = 0; i < keys.size(); i++) {
			pool_sets[bullet_id[2]].pools[pool_index].pool->set_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), keys[i], properties[keys[i]]);
		}
	}
	
}

void Bullets::set_bullet_properties_bulk(Array bullets, Dictionary properties) {
	for (int i = 0; i < bullets.size(); i++) {
		PoolIntArray bullet_id = bullets[i].operator PoolIntArray();

		int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
		if(pool_index >= 0) {
			Array keys = properties.keys();
			for(int32_t i = 0; i < keys.size(); i++) {
				pool_sets[bullet_id[2]].pools[pool_index].pool->set_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), keys[i], properties[keys[i]]);
			}
		}
	}
	
}


void Bullets::add_pattern(Variant id, int32_t trigger, int32_t time, Dictionary properties) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
		Array pattern = Array();
		pattern.append(trigger);
		pattern.append(0);
		pattern.append(time);
		pattern.append(properties);

		patterns.append(pattern);
	}
}

void Bullets::add_translate(Variant id, int32_t trigger, int32_t time, Dictionary properties) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
		Array pattern = Array();
		pattern.append(trigger);
		pattern.append(1);
		pattern.append(time);
		pattern.append(properties);

		patterns.append(pattern);
	}
}

void Bullets::add_aim_at_point(Variant id, int32_t trigger, int32_t time, Vector2 point) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
		Array pattern = Array();
		pattern.append(trigger);
		pattern.append(2);
		pattern.append(time);
		pattern.append(point);

		patterns.append(pattern);
	}
}

void Bullets::add_aim_at_object(Variant id, int32_t trigger, int32_t time, Node2D* object) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
		Array pattern = Array();
		pattern.append(trigger);
		pattern.append(3);
		pattern.append(time);
		pattern.append(object);
		pattern.append(object->get_instance_id());

		patterns.append(pattern);
	}
}

void Bullets::add_go_to_object(Variant id, int32_t trigger, int32_t time, Node2D* object) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0) {
		Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
		Array pattern = Array();
		pattern.append(trigger);
		pattern.append(4);
		pattern.append(time);
		pattern.append(object);
		pattern.append(object->get_instance_id());

		patterns.append(pattern);
	}
}

void Bullets::add_change_bullet(Variant id, int32_t trigger, int32_t time, PoolRealArray bullet_data, bool fade_in) {
	PoolIntArray bullet_id = id.operator PoolIntArray();

	int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
	if(pool_index >= 0 && pool_sets[bullet_id[2]].pools[pool_index].pool->is_bullet_valid(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]))) {
		Ref<BulletKit> kit = pool_sets[bullet_id[2]].pools[pool_index].bullet_kit;

		Color compressed_data = Color();
		compressed_data.r = bullet_data[1] + bullet_data[0] / kit->texture_width;
		compressed_data.g = bullet_data[3] + bullet_data[2] / kit->texture_width;
		compressed_data.b = floor(bullet_data[6]) + 0.99999f;
		compressed_data.a = floor(bullet_data[7]) + animation_random;

		Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
		Array pattern = Array();
		pattern.append(trigger);
		pattern.append(5);
		pattern.append(time);
		pattern.append(compressed_data);
		pattern.append(bullet_data[4]);
		pattern.append(bullet_data[5]);
		pattern.append(floor(bullet_data[6]));
		pattern.append(bullet_data[8]);
		pattern.append(bullet_data[9]);
		pattern.append(fade_in);
		patterns.append(pattern);
	}
}


void Bullets::add_pattern_bulk(Array bullets, int32_t trigger, int32_t time, Dictionary properties) {
	for (int i = 0; i < bullets.size(); i++) {
		PoolIntArray bullet_id = bullets[i].operator PoolIntArray();

		int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
		if(pool_index >= 0) {
			Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
			Array pattern = Array();
			pattern.append(trigger);
			pattern.append(0);
			pattern.append(time);
			pattern.append(properties);

			patterns.append(pattern);
		}
	}
}

void Bullets::add_translate_bulk(Array bullets, int32_t trigger, int32_t time, Dictionary properties) {
	for (int i = 0; i < bullets.size(); i++) {
		PoolIntArray bullet_id = bullets[i].operator PoolIntArray();

		int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
		if(pool_index >= 0) {
			Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
			Array pattern = Array();
			pattern.append(trigger);
			pattern.append(1);
			pattern.append(time);
			pattern.append(properties);

			patterns.append(pattern);
		}
	}
}

void Bullets::add_aim_at_point_bulk(Array bullets, int32_t trigger, int32_t time, Vector2 point) {
	for (int i = 0; i < bullets.size(); i++) {
		PoolIntArray bullet_id = bullets[i].operator PoolIntArray();

		int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
		if(pool_index >= 0) {
			Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
			Array pattern = Array();
			pattern.append(trigger);
			pattern.append(2);
			pattern.append(time);
			pattern.append(point);

			patterns.append(pattern);
		}
	}
}

void Bullets::add_aim_at_object_bulk(Array bullets, int32_t trigger, int32_t time, Node2D* object) {
	int64_t instance_id = object->get_instance_id();
	for (int i = 0; i < bullets.size(); i++) {
		PoolIntArray bullet_id = bullets[i].operator PoolIntArray();

		int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
		if(pool_index >= 0) {
			Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
			Array pattern = Array();
			pattern.append(trigger);
			pattern.append(3);
			pattern.append(time);
			pattern.append(object);
			pattern.append(instance_id);

			patterns.append(pattern);
		}
	}
}

void Bullets::add_go_to_object_bulk(Array bullets, int32_t trigger, int32_t time, Node2D* object) {
	for (int i = 0; i < bullets.size(); i++) {
		PoolIntArray bullet_id = bullets[i].operator PoolIntArray();

		int32_t pool_index = _get_pool_index(bullet_id[2], bullet_id[0]);
		if(pool_index >= 0) {
			Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
			Array pattern = Array();
			pattern.append(trigger);
			pattern.append(4);
			pattern.append(time);
			pattern.append(object);
			pattern.append(object->get_instance_id());

			patterns.append(pattern);
		}
	}
}

void Bullets::add_change_bullet_bulk(Array bullets, int32_t trigger, int32_t time, PoolRealArray bullet_data, bool fade_in) {
	PoolIntArray first_bullet_id = bullets[0].operator PoolIntArray();
	int32_t pool_index = _get_pool_index(first_bullet_id[2], first_bullet_id[0]);
	Ref<BulletKit> kit = pool_sets[first_bullet_id[2]].pools[pool_index].bullet_kit;
	Color compressed_data = Color();
	compressed_data.r = bullet_data[1] + bullet_data[0] / kit->texture_width;
	compressed_data.g = bullet_data[3] + bullet_data[2] / kit->texture_width;
	compressed_data.b = floor(bullet_data[6]) + 0.99999f;
	compressed_data.a = floor(bullet_data[7]) + animation_random;
	
	for (int i = 0; i < bullets.size(); i++) {
		PoolIntArray bullet_id = bullets[i].operator PoolIntArray();

		if(pool_index >= 0 && pool_sets[bullet_id[2]].pools[pool_index].pool->is_bullet_valid(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]))) {


			Array patterns = pool_sets[bullet_id[2]].pools[pool_index].pool->get_bullet_property(BulletID(bullet_id[0], bullet_id[1], bullet_id[2]), "patterns");
			Array pattern = Array();
			pattern.append(trigger);
			pattern.append(5);
			pattern.append(time);
			pattern.append(compressed_data);
			pattern.append(bullet_data[4]);
			pattern.append(bullet_data[5]);
			pattern.append(floor(bullet_data[6]));
			pattern.append(bullet_data[8]);
			pattern.append(bullet_data[9]);
			pattern.append(fade_in);
			patterns.append(pattern);
		}
	}
}


bool Bullets::is_deleted(Variant id) {
	return !is_bullet_valid(id);
}




