
_G.ACT_HOSHIKO_SKATE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)

function act_hoshiko_skate(m)
  step = perform_ground_step(m)
	
	if step == GROUND_STEP_LEFT_GROUND then
		set_mario_action(m, ACT_HOSHIKO_OLLIE, 0)
	elseif step == GROUND_STEP_HIT_WALL and MOVEMENT_HORIZONTAL > 25 then
	  m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
    play_sound(SOUND_GENERAL_BOING3, m.marioObj.header.gfx.cameraToObject)
    set_mario_action(m, ACT_HARD_BACKWARD_AIR_KB, 0)
		m.vel.y = 35
	end
	
	if math.abs(PREV_STEEPNESS - m.floor.normal.y) > .15 and m.vel.y > 15 then
	  m.pos.y = m.pos.y + 25
		m.forwardVel = m.forwardVel - m.vel.y*.25
		set_mario_action(m, ACT_HOSHIKO_OLLIE, 1)
	end
	
	m.marioObj.header.gfx.pos.y = m.pos.y + 25
	
	m.faceAngle.x = approach_s16_asymptotic(m.faceAngle.x, 0x300 + MOVEMENT.y*-0x90, 3)
	
	m.marioObj.header.gfx.angle.x = m.faceAngle.x
	
	m.vel.y = MOVEMENT.y
	
	set_mario_animation(m, CHAR_ANIM_RIDING_SHELL)
	
	update_tilting(m, 4, 0x2500)
	
	if CONTROL_MAG > 0 then
	  m.forwardVel = math.lerp(m.forwardVel, CONTROL_MAG*HOSHI_TOP_VEL, HOSHI_ACCEL)
	else
	  m.forwardVel = approach_f32(m.forwardVel, 0, HOSHI_GROUND_DECEL, HOSHI_GROUND_DECEL)
	end	
	
	m.vel.x = sins(m.faceAngle.y)*m.forwardVel
	m.vel.z = coss(m.faceAngle.y)*m.forwardVel
	
	m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, 8)
	
	if m.controller.buttonPressed & A_BUTTON ~= 0 then
	  m.forwardVel = m.forwardVel - m.vel.y*.85
	  m.vel.y = m.vel.y*.9 + HOSHI_JUMP_VEL
	  set_mario_action(m, ACT_HOSHIKO_OLLIE, 0)
	end
	
	if m.controller.buttonDown & Z_TRIG ~= 0 then
	  if math.abs(angle_diff(m.intendedYaw, m.faceAngle.y)) > 0x4000 and m.forwardVel > 20 then
		  mario_set_forward_vel(m, m.forwardVel/2)
		  set_mario_action(m, ACT_HOSHIKO_DRIFT, 0)
		end
	
	  m.forwardVel = approach_f32(m.forwardVel, 0, HOSHI_BRAKE_DECEL, HOSHI_BRAKE_DECEL)
	  
		if m.forwardVel > 11 then
			play_sound(SOUND_MOVING_SLIDE_DOWN_TREE, m.marioObj.header.gfx.cameraToObject)
      m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
		end
	end
	
end

hook_mario_action(ACT_HOSHIKO_SKATE, act_hoshiko_skate)

_G.ACT_HOSHIKO_OLLIE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

function act_hoshiko_ollie(m)
  step = perform_air_step(m, 0)
	
	local sideMag = math.clamp(angle_diff(m.faceAngle.y, m.intendedYaw), -0x4000, 0x4000)/3
	
	m.faceAngle.z = approach_s16_asymptotic(m.faceAngle.z, sideMag, 8)
	
	m.marioObj.header.gfx.angle.z = m.faceAngle.z
	
	m.faceAngle.x = approach_s16_asymptotic(m.faceAngle.x, math.clamp((0x100*-m.vel.y), -0x3000, 0x3000), 8)
	
	m.marioObj.header.gfx.angle.x = m.faceAngle.x
	
	--if the action arg is one then the anim id becomes 0x47 (regular shell ride) cuz 0x26 is subtracted from 0x6D
	set_mario_animation(m, CHAR_ANIM_START_RIDING_SHELL - 0x26*m.actionArg)
	
	if step == AIR_STEP_LANDED then
	  set_mario_action(m, ACT_HOSHIKO_SKATE, 0)
		m.vel.y = 0
		m.forwardVel = math.sqrt(MOVEMENT.z^2 + MOVEMENT.x^2)
	end
	
	if m.wall then
	  local wallace = atan2s(m.wall.normal.z, m.wall.normal.x)
	  
		m.vel.y = m.vel.y/2 + math.abs(coss(angle_diff(wallace, m.faceAngle.y)))*m.forwardVel
	  m.forwardVel = math.abs(coss(angle_diff(wallace, m.faceAngle.y)))*m.forwardVel
	
	  set_mario_action(m, ACT_HOSHIKO_WALL, 0)
	end
	
	if CONTROL_MAG > 0 then
	  m.vel.x = lerp(m.vel.x, sins(m.intendedYaw)*m.forwardVel, .05)
		m.vel.z = lerp(m.vel.z, coss(m.intendedYaw)*m.forwardVel, .05)
	end
	
end

hook_mario_action(ACT_HOSHIKO_OLLIE, {every_frame = act_hoshiko_ollie, gravity = hoshiko_gravity})


_G.ACT_HOSHIKO_DRIFT = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_MOVING)

function act_hoshiko_drift(m)
  step = perform_ground_step(m)
  m.vel.y = 0
  
  if m.actionTimer < 4 then
  set_mario_animation(m, CHAR_ANIM_START_WALLKICK)
  m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, 8)
  play_sound(SOUND_MOVING_SLIDE_DOWN_TREE, m.marioObj.header.gfx.cameraToObject)
  m.particleFlags = m.particleFlags | PARTICLE_FIRE
  else
      mario_set_forward_vel(m, m.forwardVel*2)
      set_mario_action(m, ACT_HOSHIKO_SKATE, 0)
    end
  
  m.actionTimer = m.actionTimer + 1
  end

hook_mario_action(ACT_HOSHIKO_DRIFT, act_hoshiko_drift)


_G.ACT_HOSHIKO_WALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

function act_hoshiko_wall(m)
  local step = perform_air_step(m, 0)
	local wallace = m.faceAngle.y + 0x8000
	
	if step == AIR_STEP_LANDED then
	  m.faceAngle.y = m.faceAngle.y + 0x8000
	  set_mario_action(m, ACT_HOSHIKO_SKATE, 0)
	end
	
	if m.wall then
	  wallace = atan2s(m.wall.normal.z, m.wall.normal.x)
		m.particleFlags = m.particleFlags | PARTICLE_DUST
	end
	local velAngle = atan2s(m.vel.z, m.vel.x)
	
	set_mario_animation(m, CHAR_ANIM_JUMP_RIDING_SHELL)
	
	-- idk at one point i started just changing values around until i made a bit of progress
	m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, wallace + 0x8000, 4)
  m.faceAngle.x = approach_s16_asymptotic(m.faceAngle.x, 0x4000, 4)
	m.faceAngle.z = approach_s16_asymptotic(m.faceAngle.z, -atan2s(m.vel.y, m.forwardVel * math.clamp(angle_diff(velAngle, wallace + 0x8000), -1, 1) ), 4)
	
	m.marioObj.header.gfx.angle.y = m.faceAngle.y - 0x4000
	m.marioObj.header.gfx.angle.z = m.faceAngle.x
	m.marioObj.header.gfx.angle.x = m.faceAngle.z - m.faceAngle.y + (wallace + 0x4000)
	
	m.vel.x = MOVEMENT.x + sins(m.faceAngle.y)*1
	m.vel.z = MOVEMENT.z + coss(m.faceAngle.y)*1
	
	m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2)
	
	if m.controller.buttonPressed & A_BUTTON ~= 0 then
	  m.faceAngle.y = wallace
		m.faceAngle.x = 0x8000
		set_mario_action(m, ACT_HOSHIKO_OLLIE, 0)
		m.pos.x = m.pos.x + sins(m.faceAngle.y)*50
		m.pos.z = m.pos.z + coss(m.faceAngle.y)*50
		m.faceAngle.y = wallace
		mario_set_forward_vel(m, math.max(math.sqrt(m.vel.y^2 + m.forwardVel^2), HOSHI_JUMP_VEL))
		m.vel.y = 15
	end
	
end

hook_mario_action(ACT_HOSHIKO_WALL, {every_frame = act_hoshiko_wall, gravity = hoshiko_gravity})


function update_variables()
  m = gMarioStates[0]
	
	MOVEMENT = {
    x = m.pos.x - PREV_POS.x,
    y = m.pos.y - PREV_POS.y,
    z = m.pos.z - PREV_POS.z
  }
  
  PREV_POS = {
    x = m.pos.x,
    y = m.pos.y,
    z = m.pos.z
  }
	
	CONTROL_MAG = (m.controller.stickMag/64)
	MOVEMENT_HORIZONTAL = math.sqrt(MOVEMENT.x^2 + MOVEMENT.z^2)
	MOVEMENT_3D = math.sqrt(MOVEMENT.x^2 + MOVEMENT.y^2 + MOVEMENT.z^2)
	
	if m.floor then
	  PREV_STEEPNESS = m.floor.normal.y
  end
	
end


function hoshiko_before_act(m, nextAct)
  if nextAct == ACT_WALKING then
	  return ACT_HOSHIKO_SKATE
	end
end

function moveset_hoshiko()
  charSelect.character_hook_moveset(CT_HOSHI, HOOK_UPDATE, update_variables)
  charSelect.character_hook_moveset(CT_HOSHI, HOOK_BEFORE_SET_MARIO_ACTION, hoshiko_before_act)
end