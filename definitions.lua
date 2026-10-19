E_MODEL_HOSHIKO = smlua_model_util_get_id("hoshiko_geo")
hoshikoUI = get_texture_info("hoshiko-atlas")
HOSHIKO_ICON = get_texture_info("life-icon")
HOSHIKO_GRAFFITI = get_texture_info("hoshiko-graffiti")

HOSHI_TOP_VEL = 55
HOSHI_ACCEL = .05
HOSHI_JUMP_VEL = 40
HOSHI_GROUND_DECEL = .35
HOSHI_BRAKE_DECEL = 2
HOSHIKO_TERMINAL_VEL = -500
HOSHIKO_GRAVITY = 2.5

--how many units hoshiko actually moves per frame
--if she rides a ramp, the y value of this will be positive
MOVEMENT = {
  x = 0,
	y = 0,
	z = 0
}

--how many units is she moving horizontally, doesn't go negative
MOVEMENT_HORIZONTAL = 0

--how many units she's moving in all 3 directions, doesn't go negative
MOVEMENT_3D = 0


PREV_POS = {
  x = 0,
	y = 0,
	z = 0
}

--m.controller.stickMag/64, quicker to type
CONTROL_MAG = 0

--how much speed to be added to hoshiko depending on slope
hoshikoSlopeAccel = 0

--rotation of her speed ui doohickey
velAngle = 0

--rotation of her slope acceleration ui doohickey
accelAngle = 0