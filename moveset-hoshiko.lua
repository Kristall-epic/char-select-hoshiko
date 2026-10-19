--the actions are defined globally so my f3 debug thing picks up the action names and shows them correctly so i can debug better


_G.ACT_HOSHIKO_SKATE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)

function act_hoshiko_skate(m)
  step = perform_ground_step(m)
	
	if step == GROUND_STEP_LEFT_GROUND then
		set_mario_action(m, ACT_HOSHIKO_OLLIE, 0)
	elseif step == GROUND_STEP_HIT_WALL and MOVEMENT_HORIZONTAL > 25 then
	  m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
    play_sound(SOUND_GENERAL_BOING3, m.marioObj.header.gfx.cameraToObject)
    set_mario_action(m, ACT_HOSHIKO_BONK, 0)
		m.vel.y = 35
	end
	
	if MOVEMENT_HORIZONTAL > 35 then
	  m.particleFlags = m.particleFlags | PARTICLE_DUST
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
	
	if CONTROL_MAG > 0 and m.forwardVel < HOSHI_TOP_VEL then
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
		  mario_set_forward_vel(m, m.forwardVel/1.5)
		  set_mario_action(m, ACT_HOSHIKO_DRIFT, 0)
		end
	
	  m.forwardVel = approach_f32(m.forwardVel, 0, HOSHI_BRAKE_DECEL, HOSHI_BRAKE_DECEL)
	  
		if m.forwardVel > 11 then
			play_sound(SOUND_MOVING_SLIDE_DOWN_TREE, m.marioObj.header.gfx.cameraToObject)
      m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
		end
	end
	
	local floorace = atan2s(m.floor.normal.z, m.floor.normal.x)
	
	local add = coss(angle_diff(m.floorAngle, m.faceAngle.y)) * (1.05 - (m.floor.normal.y < .998 and m.floor.normal.y or 1.05)) * 10
	
	if m.playerIndex == 0 then
	  hoshikoSlopeAccel = lerp(hoshikoSlopeAccel, (m.floor.type ~= SURFACE_NOT_SLIPPERY) and add or 0, .05)
	end
	
	m.forwardVel = m.forwardVel + hoshikoSlopeAccel
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
	
	if m.wall and math.abs(m.floorHeight - m.pos.y) > 150 then
	  local wallace = atan2s(m.wall.normal.z, m.wall.normal.x)
	  
		m.vel.y = m.vel.y/2 + math.abs(coss(angle_diff(wallace, m.faceAngle.y)))*m.forwardVel
	  m.forwardVel = math.abs(coss(angle_diff(wallace, m.faceAngle.y)))*m.forwardVel
	
	  set_mario_action(m, ACT_HOSHIKO_WALL, 0)
	end
	
	if CONTROL_MAG > 0 then
	  m.vel.x = lerp(m.vel.x, sins(m.intendedYaw)*m.forwardVel, .05)
		m.vel.z = lerp(m.vel.z, coss(m.intendedYaw)*m.forwardVel, .05)
	end
	
	local leftInfo
	local rightInfo
	
	local wallaceR
	local wallaceL
	
	
	local railL = collision_find_surface_on_ray(m.pos.x - sins(m.faceAngle.y + 0x4000)*60, m.pos.y - 60, m.pos.z - coss(m.faceAngle.y + 0x4000)*60, sins(m.faceAngle.y + 0x4000)*120, 0, coss(m.faceAngle.y + 0x4000)*120)
	
	if railL.surface then
	  leftInfo = railL
		wallaceL = atan2s(railL.surface.normal.z, railL.surface.normal.x)
	end
	
	local railR = collision_find_surface_on_ray(m.pos.x - sins(m.faceAngle.y - 0x4000)*60, m.pos.y - 60, m.pos.z - coss(m.faceAngle.y - 0x4000)*60, sins(m.faceAngle.y - 0x4000)*120, 0, coss(m.faceAngle.y - 0x4000)*120)
	
	if railR.surface then
	  rightInfo = railR
		wallaceR = atan2s(railR.surface.normal.z, railR.surface.normal.x)
	end
	
	--[[
	LATER
	if railL.surface and railR.surface and math.abs(angle_diff(wallaceR, wallaceL)) > 0x3000 then
	  m.pos.x = (railR.hitPos.x + railL.hitPos.x)/2
		m.pos.z = (railR.hitPos.z + railL.hitPos.z)/2
	  set_mario_action(m, ACT_HOSHIKO_RAIL, 0)
	  djui_chat_message_create("railgrind")
	end
	]]
	
end

hook_mario_action(ACT_HOSHIKO_OLLIE, {every_frame = act_hoshiko_ollie, gravity = hoshiko_gravity})


_G.ACT_HOSHIKO_DRIFT = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_MOVING)

function act_hoshiko_drift(m)
  step = perform_ground_step(m)
  m.vel.y = 0
  
  if m.controller.buttonDown & Z_TRIG ~= 0 and step ~= GROUND_STEP_LEFT_GROUND then
  set_mario_animation(m, CHAR_ANIM_START_WALLKICK)
  m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, 8)
  play_sound(SOUND_MOVING_SLIDE_DOWN_TREE, m.marioObj.header.gfx.cameraToObject)
  m.particleFlags = m.particleFlags | PARTICLE_FIRE
  else
      mario_set_forward_vel(m, m.forwardVel*1.5)
      set_mario_action(m, ACT_HOSHIKO_SKATE, 0)
    end
		
		m.forwardVel = m.forwardVel * .98
		m.vel.x = m.vel.x * .98
		m.vel.z = m.vel.z * .98
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
	
	-- yaw set to wall
	m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, wallace + 0x8000, 4)
	
	-- roll set to 90deg to make her skateboard face the wall when changing pitch
  m.faceAngle.z = approach_s16_asymptotic(m.faceAngle.z, 0x4000, 4)
	
	-- pitch set to the actual angle based on horizontal vel and vertical vel
	m.faceAngle.x = approach_s16_asymptotic(m.faceAngle.x, -atan2s(m.vel.y, m.forwardVel * math.clamp(angle_diff(velAngle, wallace + 0x8000), -1, 1) ), 4)
	
	m.marioObj.header.gfx.angle.y = m.faceAngle.y - 0x4000
	m.marioObj.header.gfx.angle.z = m.faceAngle.z
	m.marioObj.header.gfx.angle.x = m.faceAngle.x - m.faceAngle.y + (wallace + 0x4000)
	
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


_G.ACT_HOSHIKO_BONK = allocate_mario_action(ACT_GROUP_CUTSCENE)

function act_hoshiko_bonk(m)
  if m.actionTimer < 15 then
	  m.faceAngle.y = atan2s(m.wall.normal.z, m.wall.normal.x) + 0x8000
		
	  if m.actionTimer < 10 then
		  m.actionState = lerp(m.actionState, 40, .4)
			obj_set_gfx_scale(m.marioObj, m.actionState/100, 1, 1)
			m.forwardVel = 0
		  m.vel.x = 0
		  m.vel.z = 0
		  set_mario_animation(m, CHAR_ANIM_A_POSE)
		else
		  m.actionState = lerp(m.actionState, 40, .2)
			obj_set_gfx_scale(m.marioObj, m.actionState/100, 1, 1)
		  m.vel.x = lerp(m.vel.x, sins(m.faceAngle.y)*-15, .2)
		  m.vel.z = lerp(m.vel.z, coss(m.faceAngle.y)*-15, .2)
		end
		
		
	else
	  set_mario_action(m, ACT_HOSHIKO_SKATE, 0)
	end
	
	m.actionTimer = m.actionTimer + 1

end

hook_mario_action(ACT_HOSHIKO_BONK, act_hoshiko_bonk)


_G.ACT_HOSHIKO_RAIL = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_MOVING)

function act_hoshiko_rail(m)
  local rail = collision_find_surface_on_ray(m.pos.x - sins(m.faceAngle.y - 0x4000)*60, m.pos.y - 60, m.pos.z - coss(m.faceAngle.y - 0x4000)*60, sins(m.faceAngle.y - 0x4000)*180, 0, coss(m.faceAngle.y - 0x4000)*180)
	
	
	if rail.surface then
	  wallace = atan2s(rail.surface.normal.z, rail.surface.normal.x)
		
		m.faceAngle.y = wallace - 0x4000
		
		m.pos.x = rail.hitPos.x + sins(m.faceAngle.y)*m.forwardVel
		m.pos.z = rail.hitPos.z + coss(m.faceAngle.y)*m.forwardVel
		floor = collision_find_surface_on_ray(m.pos.x + sins(m.faceAngle.y - 0x4000)*5, m.pos.y, m.pos.z + coss(m.faceAngle.y - 0x4000)*5, 0, -200, 0)
		m.pos.y = floor.hitPos.y + 20
		
	end
	
	if m.controller.buttonPressed & A_BUTTON ~= 0 or not rail.surface then
	  m.vel.y = 50
		set_mario_action(m, ACT_HOSHIKO_OLLIE, 0)
	end
	
end

hook_mario_action(ACT_HOSHIKO_RAIL, act_hoshiko_rail)

function update_variables()
  m = gMarioStates[0]
	
	interact_w_door(m)
	
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
	
		
	if m.flags & MARIO_WING_CAP ~= 0 then
	  if m.controller.buttonDown & B_BUTTON ~= 0 then
		  local wallRideAngleOffset = (m.action == ACT_HOSHIKO_WALL) and -0x4000 or 0
		  
			if MOVEMENT_3D < 100 then
				m.vel.x = m.vel.x + (sins(m.faceAngle.y)*coss(m.faceAngle.x))*2
			  m.vel.y = m.vel.y + sins(m.faceAngle.x + wallRideAngleOffset)*-5
			  m.vel.z = m.vel.z + (coss(m.faceAngle.y)*coss(m.faceAngle.x))*2
				hoshikoSlopeAccel = 1
			end
			play_sound(SOUND_AIR_BOWSER_SPIT_FIRE, m.marioObj.header.gfx.cameraToObject)
		end
	end
	
end


function hoshiko_before_act(m, nextAct)
  if nextAct == ACT_WALKING and m.action ~= ACT_PULLING_DOOR and m.action ~= ACT_PUSHING_DOOR then
	  return ACT_HOSHIKO_SKATE
	end
end

function hoshiko_hud()
  djui_hud_set_resolution(RESOLUTION_N64)
  djuiwidth = djui_hud_get_screen_width()
	djuiheight = djui_hud_get_screen_height()
	
	--1 sm64 unit is about 1cm
	cmpersecond = MOVEMENT_3D*30
	
	kmperhour = cmpersecond * 0.036
	
	xOffset = djuiwidth - 100

  local intendedAngle = degrees_to_sm64((270*(math.clamp(MOVEMENT_3D/250, 0, .9))) - 55)
  
  velAngle = lerp(velAngle, intendedAngle, 0.1)

  djui_hud_render_texture_tile(hoshikoUI, xOffset + 8, djuiheight-92, 0.65, 0.65, 256, 0, 128, 128)
  djui_hud_set_rotation(velAngle, 0, 0.5)
	
	djui_hud_set_color(0, 0, 0, 255)
  djui_hud_render_rect(xOffset + 40, djuiheight - 50, 33, 3)
	
  djui_hud_set_color(150, 118, 200, 255)
  djui_hud_render_rect(xOffset + 40, djuiheight - 50, 32, 2)
	
  djui_hud_set_color(255, 255, 255, 255)
  djui_hud_set_font(FONT_ALIASED)
	djui_hud_set_rotation(0, 0, 0)
 djui_hud_print_text(tostring(math.round(kmperhour)), xOffset + 32, djuiheight - 70, 0.3)
  
	local intendedAccelAngle = degrees_to_sm64(90) + degrees_to_sm64(-90)*math.clamp(hoshikoSlopeAccel/2, -1, 1)
	
	accelAngle = lerp(accelAngle, intendedAccelAngle, 0.2)
	
	djui_hud_set_rotation(accelAngle, 0, 0.5)
	djui_hud_set_color(0, 0, 0, 255)
  djui_hud_render_rect(xOffset + 81, djuiheight - 12, 11.5, 2)
  djui_hud_set_color(150, 118, 200, 255)
  djui_hud_render_rect(xOffset + 81, djuiheight - 12, 10, 1.25)
  djui_hud_set_rotation(0, 0, 0)
	
end

function moveset_hoshiko()
  charSelect.character_hook_moveset(CT_HOSHI, HOOK_UPDATE, update_variables)
  charSelect.character_hook_moveset(CT_HOSHI, HOOK_BEFORE_SET_MARIO_ACTION, hoshiko_before_act)
	charSelect.character_hook_moveset(CT_HOSHI, HOOK_MARIO_OVERRIDE_PHYS_STEP_DEFACTO_SPEED, function() return 1 end)
	charSelect.character_hook_moveset(CT_HOSHI, HOOK_ON_HUD_RENDER_BEHIND, hoshiko_hud)
	
end