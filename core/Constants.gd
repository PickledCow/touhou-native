extends Object

# These should not be changed unless you *really* know what you're doing
const NC = -999999 # No Change constant for set position
enum TRIGGER { TIME }
enum PATTERN { RING, ARC, POLYGON }
enum PATTERN_ADV { RING, FAN, POLYGON, ARROW, ROSE, ELLIPSE }


# These are suggestions on how to access and create shot data, if another way works for you then go ahead

enum BULLET_TYPE {	STRAIGHT_LASER, ARROWHEAD, BALL_OUTLINE, BALL, RICE, KUNAI, ICE, AMULET, BULLET, BACTERIA, STAR, DROPLET, # 0 - 11
					POPCORN, RICE_SMALL, COIN, SNOWBALL, # 12 - 15
					STAR_LARGE, MENTOS, BUTTERFLY, KNIFE, JELLYBEAN, DONTUSE, #16 - 21 
					BUBBLE, #22
					HEART, ARROW, REST, ICE_LARGE, FIREBALL, # 23 - 27
					DIVINE_SPIRIT, # 28
					LASER, # 29
					LIGHTNING, # 30
					GEAR, # 31
					SAW, # 32
					GEAR_SMALL, # 33
					SAW_SMALL, # 34
					MONEY, # 35
					NOTE, # 36
}

enum COLORS {GREY, RED_D, RED, PURPLE_D, PURPLE, BLUE_D, BLUE, CYAN_D, CYAN, TEAL_D, TEAL, GREEN, YELLOW_D, YELLOW, ORANGE, WHITE}
enum COLORS_LARGE {GREY, RED, PURPLE, BLUE, CYAN, GREEN, YELLOW, ORANGE}
enum COLORS_NOTE { RED, PURPLE, BLUE, YELLOW}
enum COLORS_DIVINE_SPIRIT {GREY, RED, PURPLE, BLUE, CYAN, GREEN, YELLOW, WHITE, ORANGE, RED_D, PURPLE_D, BLUE_D, CYAN_D, GREEN_D, YELLOW_D, GREY_D}
enum COLORS_SAW {NORMAL, BLOOD, BLOOD2}
enum COLORS_COIN {RED, PURPLE, BLUE, CYAN, GREEN, GOLD, SILVER, BRONZE}


func get_bullet_data(type: int, color: int):
	var data = PoolRealArray()
	data.resize(5)

