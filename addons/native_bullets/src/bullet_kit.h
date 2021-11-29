#ifndef BULLET_KIT_H
#define BULLET_KIT_H

#include <Godot.hpp>
#include <Resource.hpp>
#include <Shape2D.hpp>
#include <Material.hpp>
#include <Texture.hpp>
#include <PackedScene.hpp>
#include <Script.hpp>
#include <Vector2.hpp>

#include <memory>

#include "bullet.h"

#define BULLET_KIT(BulletsPoolType)							\
std::unique_ptr<BulletsPool> _create_pool() override;

#define BULLET_KIT_REGISTRATION(BulletKitType, BulletType)											\
register_property<BulletKitType, String>("bullet_class_name",										\
	&BulletKitType::_property_setter, &BulletKitType::_property_getter, #BulletType,			\
	GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_NOEDITOR);

#define BULLET_KIT_IMPLEMENTATION(BulletKitType, BulletsPoolType)					\
std::unique_ptr<BulletsPool> BulletKitType::_create_pool() {						\
	return std::unique_ptr<BulletsPool>(new BulletsPoolType());						\
}																										

using namespace godot;


class BulletsPool;

class BulletKit : public Resource {
	GODOT_CLASS(BulletKit, Resource)

public:
	// The material used to render each bullet.
	Ref<Material> material;
	float texture_width;
	// Time it takes for bullets to fully fade in
	float fade_time;
	// Controls whether collisions with other objects are enabled. Turning it off increases performance.
	bool collisions_enabled = true;
	// Collisions related properties.
	int32_t collision_layer = 0;
	int32_t collision_mask = 0;
	Ref<Shape2D> collision_shape;
	Vector2 origin;
	// Controls where the bullets can live, if a bullet exits this rect, it will be removed.
	Rect2 active_rect;
	// How "fast" bullets act
	float time_scale = 1.0f;
	// Additional data the user can set via the editor.
	Variant data;

	void _init() {}

	void _property_setter(String value) {}
	String _property_getter() { return ""; }

	static void _register_methods() {
		register_property<BulletKit, Ref<Material>>("material", &BulletKit::material,
			Ref<Material>(), GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT,
			GODOT_PROPERTY_HINT_RESOURCE_TYPE, "Material");
		register_property<BulletKit, float>("texture_width", &BulletKit::texture_width, 0.0f);
		register_property<BulletKit, float>("fade_time", &BulletKit::fade_time, 0.13f);
		register_property<BulletKit, bool>("collisions_enabled", &BulletKit::collisions_enabled, true,
			GODOT_METHOD_RPC_MODE_DISABLED, (godot_property_usage_flags)(GODOT_PROPERTY_USAGE_DEFAULT | GODOT_PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED),
			GODOT_PROPERTY_HINT_NONE);
		register_property<BulletKit, int32_t>("collision_layer", &BulletKit::collision_layer, 0, 
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_LAYERS_2D_PHYSICS);
		register_property<BulletKit, int32_t>("collision_mask", &BulletKit::collision_mask, 0, 
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_LAYERS_2D_PHYSICS);
		register_property<BulletKit, Ref<Shape2D>>("collision_shape", &BulletKit::collision_shape,
			Ref<Shape2D>(), GODOT_METHOD_RPC_MODE_DISABLED,GODOT_PROPERTY_USAGE_DEFAULT,
			GODOT_PROPERTY_HINT_RESOURCE_TYPE, "Shape2D");
		register_property<BulletKit, Vector2>("origin", &BulletKit::origin, Vector2(),
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_NONE);
		register_property<BulletKit, Rect2>("active_rect", &BulletKit::active_rect, Rect2(),
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_NONE);
		register_property<BulletKit, float>("time_scale", &BulletKit::time_scale, 1.0f);
		register_property<BulletKit, Variant>("data", &BulletKit::data, Dictionary(),
			GODOT_METHOD_RPC_MODE_DISABLED, (godot_property_usage_flags)(GODOT_PROPERTY_USAGE_DEFAULT | GODOT_PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED),
			GODOT_PROPERTY_HINT_NONE);
		
		register_property<BulletKit, String>("bullet_class_name",
			&BulletKit::_property_setter, &BulletKit::_property_getter, "",
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_NOEDITOR);
		register_property<BulletKit, String>("bullet_properties",
			&BulletKit::_property_setter, &BulletKit::_property_getter, "",
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_EDITOR);
	}

	virtual std::unique_ptr<BulletsPool> _create_pool() { return std::unique_ptr<BulletsPool>(); }
};

#include "bullets_pool.h"

#endif