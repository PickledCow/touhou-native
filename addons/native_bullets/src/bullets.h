#ifndef BULLETS_H
#define BULLETS_H

#include <Godot.hpp>
#include <Node2D.hpp>
#include <AtlasTexture.hpp>
#include <Material.hpp>
#include <Color.hpp>
// #include <PoolRealArray.hpp>
#include <Rect2.hpp>
#include <Array.hpp>
#include <RegEx.hpp>

#include <vector>
#include <memory>

#include "bullet_kit.h"
#include "bullets_pool.h"

using namespace godot;


class Bullets : public Node2D {
	GODOT_CLASS(Bullets, Node2D)
	
private:
	// A pool internal representation with related properties.
	struct PoolKit {
		std::unique_ptr<BulletsPool> pool;
		Ref<BulletKit> bullet_kit;
		int32_t size;
		int32_t z_index;
	};
	struct PoolKitSet {
		std::vector<PoolKit> pools;
		int32_t bullets_amount;
	};
	// PoolKitSets represent PoolKits organized by their shared area.
	std::vector<PoolKitSet> pool_sets;
	// Maps each area RID to the corresponding PoolKitSet index.
	Dictionary areas_to_pool_set_indices;
	// Maps each BulletKit to the corresponding PoolKit index.
	Dictionary kits_to_set_pool_indices;

	Node* bullets_environment = nullptr;

	int32_t available_bullets = 0;
	int32_t active_bullets = 0;
	int32_t total_bullets = 0;

	Node2D* parent;
	Vector2 last_origin;

	Array shared_areas;
	PoolIntArray invalid_id;

	// Float that makes it so bullets fired on different frames aren't syncronised
	float animation_random = 0.0;

	void _clear_rids();
	int32_t _get_pool_index(int32_t set_index, int32_t bullet_index);

public:
	static void _register_methods();

	Bullets();
	~Bullets();

	void _init();

	void _physics_process(float delta);

	void mount(Node* bullets_environment);
	void unmount(Node* bullets_environment);
	Node* get_bullets_environment();

	bool spawn_bullet(Ref<BulletKit> kit, Dictionary properties);
	Variant obtain_bullet(Ref<BulletKit> kit);
	bool release_bullet(Variant id);

	bool is_bullet_valid(Variant id);
	bool is_kit_valid(Ref<BulletKit> kit);

	int32_t get_available_bullets(Ref<BulletKit> kit);
	int32_t get_active_bullets(Ref<BulletKit> kit);
	int32_t get_pool_size(Ref<BulletKit> kit);
	int32_t get_z_index(Ref<BulletKit> kit);

	int32_t get_total_available_bullets();
	int32_t get_total_active_bullets();

	bool is_bullet_existing(RID area_rid, int32_t shape_index);
	Variant get_bullet_from_shape(RID area_rid, int32_t shape_index);
	Ref<BulletKit> get_kit_from_bullet(Variant id);

	void set_bullet_property(Variant id, String property, Variant value);
	Variant get_bullet_property(Variant id, String property);

	// New stuff
	Variant create_shot_a1(Ref<BulletKit> kit, Vector2 pos, float speed, float angle, PoolRealArray bullet_data, bool fade_in);
	Variant create_shot_a2(Ref<BulletKit> kit, Vector2 pos, float speed, float angle, float accel, float max_speed, PoolRealArray bullet_data, bool fade_in);

	Variant create_item(Ref<BulletKit> kit, PoolRealArray item_data, Vector2 pos, float speed, float angle, float spin);

	Variant create_pattern_a1(Ref<BulletKit> kit, int mode, Vector2 pos, float r1, float speed1, float angle, int density, float spread, PoolRealArray bullet_data, bool fade_in);
	Variant create_pattern_a2(Ref<BulletKit> kit, int mode, Vector2 pos, float r1, float r2, float speed1, float speed2, float angle, int density, int stack, float spread, PoolRealArray bullet_data, bool fade_in);


	void set_bullet_properties(Variant id, Dictionary properties);
	void set_bullet_properties_bulk(Array bullets, Dictionary properties);

	void set_magnet_target(Variant id, Node2D *target);

	void add_pattern(Variant id, int32_t trigger, int32_t time, Dictionary properties);
	void add_translate(Variant id, int32_t trigger, int32_t time, Dictionary properties);
	void add_multiply(Variant id, int32_t trigger, int32_t time, Dictionary properties);
	void add_aim_at_point(Variant id, int32_t trigger, int32_t time, Vector2 point);
	void add_aim_at_object(Variant id, int32_t trigger, int32_t time, Node2D* object);
	void add_go_to_object(Variant id, int32_t trigger, int32_t time, Node2D* object);
	void add_change_bullet(Variant id, int32_t trigger, int32_t time, PoolRealArray bullet_data, bool fade_in);

	void add_pattern_bulk(Array bullets, int32_t trigger, int32_t time, Dictionary properties);
	void add_translate_bulk(Array bullets, int32_t trigger, int32_t time, Dictionary properties);
	void add_multiply_bulk(Array bullets, int32_t trigger, int32_t time, Dictionary properties);
	void add_aim_at_point_bulk(Array bullets, int32_t trigger, int32_t time, Vector2 point);
	void add_aim_at_object_bulk(Array bullets, int32_t trigger, int32_t time, Node2D* object);
	void add_go_to_object_bulk(Array bullets, int32_t trigger, int32_t time, Node2D* object);
	void add_change_bullet_bulk(Array bullets, int32_t trigger, int32_t time, PoolRealArray bullet_data, bool fade_in);

	bool is_deleted(Variant id);

	void create_particle(Ref<BulletKit> kit, Vector2 pos, float size, Color color, Vector2 drift, bool upright);

};

#endif