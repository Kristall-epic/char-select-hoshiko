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