-- name: [CS] Hoshiko
-- description: critter who likes skate and does many trick

function on_char_select_load()
  
CT_HOSHI = charSelect.character_add(
        "Hoshiko",
        {'OW THE SUN'},
        "Kristall",
        "aa0000", 
        E_MODEL_HOSHIKO,
        CT_MARIO, 
        nil,
        1.5
    )
    
  local PALETTE_HOSHIKO = {
  	[PANTS] = "33394d", 
  	[SHIRT] = "9975d4", 
  	[GLOVES] = "9975d4", 
  	[SHOES] = "271c45", 
  	[HAIR] = "090c09", 
  	[SKIN] = "ffdca8", 
  	[CAP] = "390e52", 
  	[EMBLEM] = "916cca"
  }
    charSelect.character_add_palette_preset(E_MODEL_HOSHIKO, PALETTE_HOSHIKO, "Purpl")
		
  moveset_hoshiko()
    
end

hook_event(HOOK_ON_MODS_LOADED, on_char_select_load)