#ifndef BULLET_H
#define BULLET_H

#include <limits>

#include <Godot.hpp>
#include <Transform2D.hpp>
#include <Array.hpp>

using namespace godot;

// struct BulletPattern {
// 	int32_t trigger;
// 	float time;
// 	Dictionary properties;
// 	BulletPattern(int32_t trigger, float time, Dictionary properties):
// 		trigger(trigger), time(time), properties(properties) {}
// };

struct BulletID {
	int32_t index;
	int32_t cycle;
	int32_t set;

	BulletID(int32_t index, int32_t cycle, int32_t set): 
		index(index), cycle(cycle), set(set) {}
};

class Bullet : public Object {
	GODOT_CLASS(Bullet, Object)

public:
	RID item_rid;
	int32_t cycle = 0;
	int32_t shape_index = -1;
	float hitbox_scale = 0.5f;
	float texture_offset = 0.0f;
	
	Transform2D transform;
	Vector2 position;
	Vector2 direction;
	float angle;
	float speed;
	float max_speed;
	float accel;
	float wvel;
	float rotation;
	float spin;

	float fade_timer;
	float fade_time;

	Array patterns;

	float lifetime;
	float lifespan;
	Color bullet_data;

	void _init() {}

	RID get_item_rid() { return item_rid; }
	void set_item_rid(RID value) { Godot::print_error("Can't edit the item rid of bullets!", "set_item_rid", "bullet.h", 31); }

	int32_t get_cycle() { return cycle; }
	void set_cycle(int32_t value) { Godot::print_error("Can't edit the cycle of bullets!", "set_cycle", "bullet.h", 34); }

	int32_t get_shape_index() { return shape_index; }
	void set_shape_index(int32_t value) { Godot::print_error("Can't edit the shape index of bullets!", "set_shape_index", "bullet.h", 37); }

	static void _register_methods() {
		register_property<Bullet, Vector2>("position", &Bullet::position, Vector2());
		register_property<Bullet, float>("angle", &Bullet::angle, 0.0f);
		register_property<Bullet, float>("speed", &Bullet::speed, 0.0f);
		register_property<Bullet, float>("accel", &Bullet::accel, 0.0f);
		register_property<Bullet, float>("max_speed", &Bullet::max_speed, 0.0f);
		register_property<Bullet, float>("wvel", &Bullet::wvel, 0.0f);
		register_property<Bullet, float>("rotation", &Bullet::rotation, 0.0f);
		register_property<Bullet, float>("spin", &Bullet::spin, 0.0f);
		register_property<Bullet, float>("lifespan", &Bullet::lifespan, 999999999.9f);
		register_property<Bullet, float>("lifetime", &Bullet::lifetime, 0.0f);
		register_property<Bullet, float>("hitbox_scale", &Bullet::hitbox_scale, 0.5f);
		register_property<Bullet, float>("texture_offset", &Bullet::texture_offset, 0.0f);
		register_property<Bullet, float>("fade_timer", &Bullet::fade_timer, 0.0f);
		register_property<Bullet, float>("fade_time", &Bullet::fade_time, 0.0f);

		register_property<Bullet, Transform2D>("transform", &Bullet::transform, Transform2D());
		register_property<Bullet, Vector2>("direction", &Bullet::direction, Vector2());
		
		register_property<Bullet, RID>("item_rid", &Bullet::set_item_rid, &Bullet::get_item_rid, RID());
		register_property<Bullet, int32_t>("shape_index", &Bullet::set_shape_index, &Bullet::get_shape_index, 0);
		register_property<Bullet, int32_t>("cycle", &Bullet::set_cycle, &Bullet::get_cycle, 0);

		register_property<Bullet, Color>("bullet_data", &Bullet::bullet_data, Color(1.0f, 1.0f, 0.99999f, 1.0f));
		register_property<Bullet, Array>("patterns", &Bullet::patterns, Array());
	}

};

#endif