
--[[
  Cops and Robbers: Character Creation (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file handles all client-sided interaction to verifying character
  information, switching characters, and creating characters.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]


local sign = GetHashKey("prop_police_id_board")
local ovrl = GetHashKey("prop_police_id_text")
local cb   = nil
local ov   = nil


 -- DEBUG - 
Citizen.CreateThread(function()
  Wait(1000)
  SetNuiFocus(false)
end)
    
    
    
    
    
    
    
    
    
local cam = nil
local runOnce = false

function PlayerJoined()
  if not runOnce then 
    runOnce = true
    exports.spawnmanager:setAutoSpawn(false)
    Citizen.Wait(2000)
    
    print("DEBUG - Creating Vinewood Camera.")
    local c = cams.start
    if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    SetCamParams(cam,
      c.view.x, c.view.y, c.view.z,
      c.rotx, c.roty, c.h,
      50.0
    )
    
    exports.spawnmanager:spawnPlayer({
      x = cams.start.ped.x,
      y = cams.start.ped.y,
      z = cams.start.ped.z + 1.0,
      model = "mp_m_freemode_01"
    }, function()
    
      SetPedDefaultComponentVariation(PlayerPedId())
      print("DEBUG - Spawned Player!")
      
      Citizen.Wait(1000)
      print("DEBUG - Opening menu.")
      
      SendNUIMessage({showwelcome = true})
      SetNuiFocus(true, true)
      
      Citizen.Wait(1200)
      TriggerServerEvent('cnr:create_player')
      print("DEBUG - Finished.")
      
    end)
  end
end


AddEventHandler('onClientMapStart', function()
  PlayerJoined()
end)


--- EVENT: create_character
-- Creates a new player for newbies or if character was wiped/lost
RegisterNetEvent('cnr:create_character')
AddEventHandler('cnr:create_character', function()
  
  print("DEBUG - Fading screen.")
  DoScreenFadeOut(400)
  Wait(410)
  
  print("DEBUG - Setting default component variation.")
  SetPedDefaultComponentVariation(PlayerPedId())
  ModifyParents(1, 21, 0.5)
 
  local c   = cams.creator
  SetEntityCoords(PlayerPedId(), c.ped)
  SetEntityHeading(PlayerPedId(), c.h)
  
  print("DEBUG - Teleported player.")
  Wait(200)

  if not DoesCamExist(cam) then
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
  end
  
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 500, true, true)
  
  SetCamParams(cam,
    c.view.x, c.view.y, c.view.z,
    c.rotx, c.roty, c.rotz,
    50.0
  )
  
  RequestAnimDict(creation.dict)
  while not HasAnimDictLoaded(creation.dict) do Wait(10) end
  
  print("DEBUG - Created camera view.")
  TaskPlayAnim(PlayerPedId(), creation.dict, creation.anim,
    8.0, 0, (-1), 2, 0, 0, 0, 0
  )
  
  Wait(1200)
  DoScreenFadeIn(600)
  
  print("DEBUG - Screen returned.")
  
  Citizen.CreateThread(CreateBoardDisplay)
  print("DEBUG - Created mugshot board.")
  
  Wait(6400)
  
  TaskPlayAnim(PlayerPedId(), creation.dict, "loop",
    8.0, 0, (-1), 1, 0, 0, 0, 0
  )
  
  print("DEBUG - Started animation dictionary: "..tostring(creation.dict)..".")
  Citizen.CreateThread(function()
    Citizen.Wait(12000)
    if DoesEntityExist(cb) then DeleteObject(cb) end
    if DoesEntityExist(ov) then DeleteObject(ov) end
    print("DEBUG - Removing mugshot board.")
  end)
  
  print("DEBUG - Opening Designer.")
  SendNUIMessage({opendesigner = true})
  SetNuiFocus(true, true)
    
end)



-- DEBUG - 
RegisterCommand('cset', function(s,a,r)
  SetPedComponentVariation(PlayerPedId(),
    tonumber(a[1]), tonumber(a[2]), tonumber(a[3]), 0
  )
end)
RegisterCommand('nextitem', function(s,a,r)
  local slotNumber = tonumber(a[1])
  local i = GetPedDrawableVariation(PlayerPedId(), slotNumber)
  SetPedComponentVariation(PlayerPedId(), slotNumber, i+1, 0, 0)
  print("DEBUG - Slot ["..slotNumber.."] Current item #"..i+1)
end)
RegisterCommand('previtem', function(s,a,r)
  local slotNumber = tonumber(a[1])
  local i = GetPedDrawableVariation(PlayerPedId(), slotNumber)
  SetPedComponentVariation(PlayerPedId(), slotNumber, i-1, 0, 0)
  print("DEBUG - Slot ["..slotNumber.."] Current item #"..i-1)
end)
RegisterCommand('anim', function(s, a, r)
  if a[1] and a[2] then
  
    local dict  = tostring(a[1])
    local anim  = tostring(a[2])
    local flags 
    if not a[3] then flags = 0
    else flags = tonumber(a[3]) end
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
    TriggerEvent('chatMessage',
      "^2Playing: ^7"..dict.." ^2(^7"..anim.."^2)"
    )
    TaskPlayAnim(PlayerPedId(), dict, anim,
      8.0, 0, (-1), flags, 0, 0, 0, 0
    )
    
  else
    TriggerEvent('chatMessage',
      "^1Animation Debugger failed. Insufficient arguments."
    )
  end
end)
RegisterCommand('stopanim', function()
  ClearPedTasksImmediately(PlayerPedId())
end)
RegisterCommand('mimick', function()
  PlayerJoined()
end)

local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

local function LoadScaleform (scaleform)
	local handle = RequestScaleformMovie(scaleform)

	if handle ~= 0 then
		while not HasScaleformMovieLoaded(handle) do
			Citizen.Wait(0)
		end
	end

	return handle
end

local function CallScaleformMethod (scaleform, method, ...)
	local t
	local args = { ... }

	BeginScaleformMovieMethod(scaleform, method)

	for k, v in ipairs(args) do
		t = type(v)
		if t == 'string' then
			PushScaleformMovieMethodParameterString(v)
		elseif t == 'number' then
			if string.match(tostring(v), "%.") then
				PushScaleformMovieFunctionParameterFloat(v)
			else
				PushScaleformMovieFunctionParameterInt(v)
			end
		elseif t == 'boolean' then
			PushScaleformMovieMethodParameterBool(v)
		end
	end

	EndScaleformMovieMethod()
end

function CreateBoardDisplay()

  local ped  = PlayerPedId()
  
  RequestModel(sign)
  RequestModel(ovrl)
  while not HasModelLoaded(sign) or not HasModelLoaded(ovrl) do Wait(10) end
  cb = CreateObject(sign, GetEntityCoords(ped), false, false, false)
  ov = CreateObject(ovrl, GetEntityCoords(ped), false, false, false)
  
	AttachEntityToEntity(ov, cb, (-1), 4103,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0, 0, 0, 0, 2, 1
  )
  
  
	AttachEntityToEntity(cb, ped,
    GetPedBoneIndex(ped, 28422),
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0, 0, 0, 0, 2, 1
  )
  
  SetModelAsNoLongerNeeded(sign)
  SetModelAsNoLongerNeeded(ovrl)
  


  Citizen.CreateThread(function()
    board_scaleform = LoadScaleform("mugshot_board_01")
    handle = CreateNamedRenderTargetForModel("ID_Text", ovrl)
  
    CallScaleformMethod(board_scaleform, 'SET_BOARD',
      GetPlayerName(PlayerId()),
      "31337455",
      "LOS SANTOS POLICE DEPT",
      "TRANSFERRED",
      0, 0, 116
    )
  
    while handle do
      HideHudAndRadarThisFrame()
      SetTextRenderId(handle)
      Set_2dLayer(4)
      Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
      DrawScaleformMovie(board_scaleform, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
      Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
      SetTextRenderId(GetDefaultScriptRendertargetRenderId())
  
      Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
      Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
      Wait(0)
    end
  end)
end


function SwitchGender()
  print("DEBUG - Attempting to switch genders.")
  local currModel = GetEntityModel(PlayerPedId())
  local newHash   = femaleHash
  if (femaleHash == currModel) then 
    newHash = maleHash
  end
  RequestModel(newHash)
  while not HasModelLoaded(newHash) do Wait(10) end
  SetPlayerModel(PlayerId(), newHash)
  Wait(100)
  SetPedDefaultComponentVariation(PlayerPedId())
  print("DEBUG - Gender changed.")
  SendNUIMessage({getParents = true}) -- Update blend data
end


function ModifyParents(one, two, val)
  SetPedHeadBlendData(PlayerPedId(),
    one, two, 0,
    one, two, 0,
    (100 - val)/100,
    val/100,
    0.0, false
  )
end

function DesignerCamera(addX, addY, addZ, rotX, rotY, rotZ, fov)
  if not addX then addX =  0.0 end
  if not addY then addY =  0.0 end
  if not addX then addZ =  0.0 end
  if not rotX then rotX =  0.0 end
  if not rotY then rotY =  0.0 end
  if not rotZ then rotZ =  0.0 end
  if not fov  then fov  = 50.0 end
  local c = cams.creator
  SetCamParams(cam,
    c.view.x + addX, c.view.y + addY, c.view.z + addZ,
    c.rotx + rotX, c.roty + rotY, c.rotz + rotZ,
    fov
  )
end









--- EVENT: create_ready 
-- Called when the character (or lack thereof) is ready
-- and the player can join.
RegisterNetEvent('cnr:create_ready')
AddEventHandler('cnr:create_ready', function()
  SendNUIMessage({hideready = true})
end)


RegisterNUICallback("playGame", function(data, cb)
  SendNUIMessage({hidewelcome = true})
  Citizen.Wait(500)
  TriggerServerEvent('cnr:create_session')
end)


RegisterNUICallback("heritage", function(data, cb)
  if data.action == "gender" then 
    SwitchGender()
  
  elseif data.action == "changeParent" then
    ModifyParents(data.pOne, data.pTwo, data.similarity)
  
  end
end)

RegisterNUICallback("doOverlays", function(data, cb)
  if data.action == "setOverlay" then 
    local i = tonumber(data.ovr)
    local s, n, ct, c1, c2, c0 = GetPedHeadOverlayData(PlayerPedId(), i)
    
    if data.direction == 1 then n = n + 1
    else n = n - 1
    end
    
    if     n <    0             then n = 255
    elseif n == 254 or n == 256 then n =   0
    elseif n >  maxOverlays[i]  then n = 255
    end
    
    SetPedHeadOverlay(PlayerPedId(), i, n, 1.0)
    SetPedHeadOverlayColor(PlayerPedId(), i, 1, 1, 1)
    DesignerCamera(0.0, 0.8, 0.24, 0.0, 0.0, 0.0, 50.0)
    
    if i == 10 or i == 11 then 
      if GetEntityModel(PlayerPedId()) == maleHash then 
        SetPedComponentVariation(PlayerPedId(), 11, 91, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 3,  15, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 8,  15, 0, 0)
      else
        SetPedComponentVariation(PlayerPedId(), 11, 18, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 3,  15, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 8,  14, 0, 0)
      end
    else
      if GetEntityModel(PlayerPedId()) == maleHash then 
        SetPedComponentVariation(PlayerPedId(), 11, 0, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 3,  0, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 8,  15, 0, 0)
      else
        SetPedComponentVariation(PlayerPedId(), 11, 0, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 3,  0, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 8,  14, 0, 0)
      end
    end
    
  elseif data.action == "hairStyle" then
    local i    = GetPedDrawableVariation(PlayerPedId(), 2)
    local iMax = GetNumberOfPedDrawableVariations(PlayerPedId(), 2)
    
    if data.direction == 1 then i = i + 1
    else i = i - 1
    end
    
    if i < 0 then i = iMax
    elseif i > iMax then i = 0
    end
    
    if GetEntityModel(PlayerPedId()) == maleHash then 
      if i == 23 then -- Ignore night vision goggle hairpiece
        if data.direction == 1 then i = 24
        else i = 22
        end
      end
    else
      if i == 24 then -- Ignore night vision goggle hairpiece
        if data.direction == 1 then i = 25
        else i = 23
        end
      end
    end
    
    SetPedComponentVariation(PlayerPedId(), 2, i, 0, 0)
    DesignerCamera(0.0, 1.6, 0.32, 0.0, 0.0, 0.0, 50.0)
    
  elseif data.action == "hairColor" then
    local i = GetPedHairColor(PlayerPedId())
    
    if data.direction == 1 then i = i + 1
    else i = i - 1
    end
    
    if     i > 63 then i =  0
    elseif i <  0 then i = 63
    end
    
    SetPedHairColor(PlayerPedId(), i, GetPedHairHighlightColor(PlayerPedId()))
    DesignerCamera(0.0, 1.6, 0.32, 0.0, 0.0, 0.0, 50.0)
    
  elseif data.action == "hairHighlight" then
    local i = GetPedHairHighlightColor(PlayerPedId())
    
    if data.direction == 1 then i = i + 1
    else i = i - 1
    end
    
    if     i > 63 then i =  0
    elseif i <  0 then i = 63
    end
    
    SetPedHairColor(PlayerPedId(), GetPedHairColor(PlayerPedId()), i)
    DesignerCamera(0.0, 1.6, 0.32, 0.0, 0.0, 0.0, 50.0)
    
  
  elseif data.action == "eyeColor" then
    local i = GetPedEyeColor(PlayerPedId())
    
    if data.direction == 1 then i = i + 1
    else i = i - 1
    end
    
    if     i > 8 then i = 0
    elseif i < 0 then i = 8
    end
    
    SetPedEyeColor(PlayerPedId(), i)
    DesignerCamera(0.0, 1.6, 0.32, 0.0, 0.0, 0.0, 50.0)
  
  end
end)


RegisterNUICallback("facialFeatures", function(data, cb)
  if data.action == "setFeature" then
    SetPedFaceFeature(PlayerPedId(), (data.fNum), (data.sVal)/100)
  end
end)


RegisterNUICallback("clothingOptions", function(data, cb)
  if data.action == "setOutfit" then
    local pModel = GetEntityModel(PlayerPedId())
    print("DEBUG - Is Male choosing a Male Outfit? ["..
      tostring(data.sex == 0 and pModel == maleHash)..
    "]")
    print("DEBUG - Is Female choosing a Female Outfit? ["..
      tostring(data.sex == 1 and pModel == femaleHash)..
    "]")
    if (data.sex == 0 and pModel == maleHash)   or 
       (data.sex == 1 and pModel == femaleHash) then
      for k,v in pairs (defaultOutfits[pModel][data.cNum]) do
        print("DEBUG - Comp Var: "..tostring(v.slot)..", "..
          tostring(v.draw)..", "..
          tostring(v.text)..")"
        )
        SetPedComponentVariation(PlayerPedId(), v.slot, v.draw, v.text, 2)
      end
      if pModel == femaleHash then
        SetPedComponentVariation(PlayerPedId(), 8, 14, 0, 2)
      else
        SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 2)
      end
    end
  end
end)
