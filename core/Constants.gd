extends Object

# These should not be changed unless you *really* know what you're doing
const NC = -999999 # No Change constant for set position
enum TRIGGER { TIME, BOUNCE }
enum PATTERN { RING, ARC, POLYGON }
enum PATTERN_ADV { RINGS, FAN, POLYGON, ELLIPSE, CHEVRON, ROSE, STAR }

enum BULLET_DATA_STRUCTURE { SRC_X, SRC_Y, SRC_W, SRC_H, SIZE, HITBOX_RATIO, SPRITE_OFFSET, ANIM_FRAMES, SPIN, LAYER, CLEAR_R, CLEAR_G, CLEAR_B, DAMAGE_TYPE, DAMAGE_AMOUNT }

enum WALLS { NONE, TOP, BOTTOM, VERTICALS, LEFT, RIGHT = 8, SIDES = 12, DOME, CUP, ALL }
