# Touhou-native

Fork of godot-native-bullets-plugin to better suit touhou style bullet hells. 

Sometimes the project will fail to load from the project selection menu; opening from your file browser still works.

Currently only Windows support, multi-platform support should come soon.

## Getting started

TODO

## Functions

### Create Shot

```gdscript
Bullets.create_shot_a1(bullet_kit, position, speed, angle, bullet_data)


```

## Compiling and extending the plugin

The plugin can be extended with new BulletKits that are more suitable to your specific use cases.<br>
To do so, you have to download the entire repository together with submodules, write some C++ code and recompile the plugin.

```
git clone --recursive https://github.com/samdze/godot-native-bullets-plugin
```

New BulletKits can be added creating a new header file inside the src/kits directory.
Here's an example.

```c++
// src/kits/custom_following_bullet_kit.h

#ifndef CUSTOM_FOLLOWING_BULLET_KIT_H
#define CUSTOM_FOLLOWING_BULLET_KIT_H

#include <Texture.hpp>
#include <PackedScene.hpp>
#include <Node2D.hpp>
#include <SceneTree.hpp>
#include <cmath>

#include "../bullet_kit.h"

using namespace godot;


// Bullet definition.
// This is necessary only if your BulletKit needs custom efficiently accessible bullet properties.
class CustomFollowingBullet : public Bullet {
	// Godot requires you to add this macro to make this class work properly.
	GODOT_CLASS(CustomFollowingBullet, Bullet)
public:
	Node2D* target_node = nullptr;

	// the _init method must be defined.
	void _init() {}

	// Custom setter and getter, not needed.
	void set_target_node(Node2D* node) {
		target_node = node;
	}

	Node2D* get_target_node() {
		return target_node;
	}

	static void _register_methods() {
		// Registering an Object reference property with GODOT_PROPERTY_HINT_RESOURCE_TYPE and hint_string is just
		// a way to tell the editor plugin the type of the property, so that it can be viewed in the BulletKit inspector.
		register_property<CustomFollowingBullet, Node2D*>("target_node",
			&CustomFollowingBullet::set_target_node,
			&CustomFollowingBullet::get_target_node, nullptr,
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_NO_INSTANCE_STATE, GODOT_PROPERTY_HINT_RESOURCE_TYPE, "Node2D");
	}
};

// Bullet kit definition.
// Add your own properties, methods and exports.
class CustomFollowingBulletKit : public BulletKit {
	// Godot requires you to add this macro to make this class work properly.
	GODOT_CLASS(CustomFollowingBulletKit, BulletKit)
public:
	// Use this macro to configure this bullet kit.
	// Pass the BulletsPool type that will be used as the argument.
	BULLET_KIT(CustomFollowingBulletsPool)

	Ref<Texture> texture;
	float bullets_turning_speed = 1.0f;

	static void _register_methods() {
		register_property<CustomFollowingBulletKit, Ref<Texture>>("texture", &CustomFollowingBulletKit::texture, Ref<Texture>(),
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_RESOURCE_TYPE, "Texture");
		register_property<CustomFollowingBulletKit, float>("bullets_turning_speed", &CustomFollowingBulletKit::bullets_turning_speed, 1.0f,
			GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT, GODOT_PROPERTY_HINT_RANGE, "0.0,128.0");

		// Add this macro at the end of the _register_methods() method.
		// Pass this BulletKit type and the used Bullet type as arguments.
		BULLET_KIT_REGISTRATION(CustomFollowingBulletKit, CustomFollowingBullet)
	}
};

// Bullets pool definition.
// This is the class that will handle the logic linked to your custom BulletKit.
// It must extend AbstractBulletsPool.
class CustomFollowingBulletsPool : public AbstractBulletsPool<CustomFollowingBulletKit, CustomFollowingBullet> {

	void _init_bullet(CustomFollowingBullet* bullet) {
		// Initialize your bullet however you like.
	}

	void _enable_bullet(CustomFollowingBullet* bullet) {
		// Runs when a bullet is obtained from the pool and is being enabled.

		// Reset the bullet lifetime.
		bullet->lifetime = 0.0f;
		Rect2 texture_rect = Rect2(-kit->texture->get_size() / 2.0f, kit->texture->get_size());
		RID texture_rid = kit->texture->get_rid();

		// Configure the bullet to draw the kit texture each frame.
		VisualServer::get_singleton()->canvas_item_add_texture_rect(bullet->item_rid,
			texture_rect,
			texture_rid);
	}

	void _disable_bullet(CustomFollowingBullet* bullet) {
		// Runs when a bullet is being removed from the scene.
	}

	bool _process_bullet(CustomFollowingBullet* bullet, float delta) {
		// Runs each frame for each bullet, here goes your update logic.
		if(bullet->target_node != nullptr) {
			// Find the rotation to the target node.
			Vector2 to_target = bullet->target_node->get_global_position() - bullet->transform.get_origin();
			float rotation_to_target = bullet->velocity.angle_to(to_target);
			float rotation_value = Math::min(kit->bullets_turning_speed * delta, std::abs(rotation_to_target));

			// Apply the rotation, capped to the max turning speed.
			bullet->velocity = bullet->velocity.rotated(Math::sign(rotation_to_target) * rotation_value);
		}
		// Apply velocity.
		bullet->transform.set_origin(bullet->transform.get_origin() + bullet->velocity * delta);

		if(!active_rect.has_point(bullet->transform.get_origin())) {
			// Return true if the bullet should be deleted.
			return true;
		}
		// Rotate the bullet based on its velocity if "rotate" is enabled.
		if(kit->rotate) {
			bullet->transform.set_rotation(bullet->velocity.angle());
		}
		// Bullet is still alive, increase its lifetime.
		bullet->lifetime += delta;
		// Return false if the bullet should not be deleted yet.
		return false;
	}
};

// Add this macro at the end of the file to automatically implement a few needed utilities.
// Pass the BulletKit type and the BulletsPool type as arguments.
BULLET_KIT_IMPLEMENTATION(CustomFollowingBulletKit, CustomFollowingBulletsPool)

#endif
```

Next, register you Godot classes inside the `gdlibrary.cpp` file.

```c++
// src/gdlibrary.cpp

#include "bullets.h"
...
...

#include "kits/custom_following_bullet_kit.h"

...
...

extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
	...
	...

	// Custom Bullet Kits.
	godot::register_class<CustomFollowingBullet>();
	godot::register_class<CustomFollowingBulletKit>();
}
```

Compile the bindings and the plugin for your selected platform.

```
cd addons/native_bullets/godot-cpp
scons platform=windows target=release generate_bindings=yes -j4

cd ..
scons platform=windows target=release
```

Finally, create a NativeScript resource setting `bullets.gdnlib` as its library and `CustomFollowingBulletKit` as its class name.<br>
Now you can attach this script to your BulletKit resources and use it.
