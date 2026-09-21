lerp = math.lerp

function angle_diff(a, b)
    local d = (a - b) & 0xFFFF
    if d >= 0x8000 then
        d = d - 0x10000
    end
    return d
end

function update_tilting(m, spd, max)
  if not max then max = 0x8000 end
	
	diff = math.clamp(angle_diff(m.faceAngle.y, m.intendedYaw), -max, max)

  m.faceAngle.z = approach_s16_asymptotic(m.faceAngle.z, diff, spd)
	
	m.marioObj.header.gfx.angle.z = m.faceAngle.z
end

function hoshiko_gravity(m)
  
  if (m.vel.y > HOSHIKO_TERMINAL_VEL) then
  m.vel.y = m.vel.y - HOSHIKO_GRAVITY
  end
  
end

function interact_w_door(m)
  
    local wdoor = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoorWarp)
    local door = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoor)
    local sdoor = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvStarDoor)

    if door ~= nil and dist_between_objects(m.marioObj, door) < 200 and m.numStars >= door.oBehParams >> 24 then
        interact_door(m, 0, door)
        --djui_chat_message_create("door.")
        if m.action ~= ACT_PULLING_DOOR and m.action ~= ACT_PUSHING_DOOR and m.action ~= ACT_UNLOCKING_STAR_DOOR then
          set_mario_action(m, ACT_DECELERATING, 0)
				end
    elseif sdoor ~= nil and dist_between_objects(m.marioObj, sdoor) < 200 then
      if m.numStars >= sdoor.oBehParams >> 24 then
        interact_door(m, 0, sdoor)
        --djui_chat_message_create("star door.")
        if m.action ~= ACT_PULLING_DOOR and m.action ~= ACT_PUSHING_DOOR and m.action ~= ACT_UNLOCKING_STAR_DOOR then
          set_mario_action(m, ACT_DECELERATING, 0)
				end
				
      end
    elseif wdoor ~= nil and dist_between_objects(m.marioObj, wdoor) < 200 then
        interact_warp_door(m, 0, wdoor)
				if m.action ~= ACT_PULLING_DOOR and m.action ~= ACT_PUSHING_DOOR and m.action ~= ACT_UNLOCKING_STAR_DOOR then
          set_mario_action(m, ACT_DECELERATING, 0)
				end
        --djui_chat_message_create("warp door.")
    end
		
end