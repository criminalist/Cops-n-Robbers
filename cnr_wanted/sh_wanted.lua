
--[[
  Cops and Robbers: Wanted Script - Shared Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/20/2019
  
  This file's main purpose is the definition of criminal events.
  
  We don't want client modders to modify the fines or times they would receive.
  Thus, the variable is secure to this file and only accessible by accessors.
  
--]]


mw     = 101 -- The value a player becomes "Most Wanted"
felony = 40  -- The value a player becomes a Felon.
wanted = {} -- Table of wanted players (KEY: Server Id, VAL: Points)


-- List of emergency vehicles by MODELNAME
eVehicle = {
  "POLICE", "POLICE2", "POLICE3", "POLICE4",
  "SHERIFF", "SHERIFF2",
  "FBI", "FBI2", "FIB", "FIB2",
  "PRANGER", "FBIRANCHER",
  "HYDRA", "RHINO", "BARRACKS"
}


--[[
  VAR: crimes
  INFO: Holds the crimes information.
  KEY: crime designation/event
  VALUE: (Table)
    title:    The title of the crime for display purposes/referencing
    weight:   Used for organizing seriousness of a crime (1 being most serious)
    minTime:  The minimum time that can be given for this crime
    maxTime:  The maximum time that can be given for this crime
    isFelony: This crime can make the player exceed Wanted Level 5
    fine:     The amount of the fine (if applicable)
]]
local crimes = {
  ['gta-npc'] = {
    title = "Grand Theft Auto (NPC)",
    weight = 51, minTime = 0, maxTime = 0, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['gta'] = {
    title = "Grand Theft Auto",
    weight = 76, minTime = 0, maxTime = 0, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['carjack-npc'] = {
    title = "Carjacking (NPC)",
    weight = 31, minTime = 0, maxTime = 0, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['carjack'] = {
    title = "Carjacking",
    weight = 61, minTime = 10, maxTime = 25, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['murder'] = {
    title = "Murder",
    weight = 120, minTime = 90, maxTime = 120, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['murder-leo'] = {
    title = "Murder of a Law Enforcement Officer",
    weight = 200, minTime = 10, maxTime = 25, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['manslaughter'] = {
    title = "Manslaughter (Killing an NPC)",
    weight = 20, minTime = 5, maxTime = 10, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['adw'] = {
    title = "Assault with a Deadly Weapon",
    weight = 60, minTime = 5, maxTime = 20, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['assault'] = {
    title = "Simple Assault",
    weight = 10, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['discharge'] = {
    title = "Discharging a Firearm",
    weight = 21, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['vandalism'] = {
    title = "Vandalism",
    weight = 5, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['robbery'] = {
    title = "Armed Robbery",
    weight = 90, minTime = 20, maxTime = 30, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['robbery-sa'] = {
    title = "Strong-Arm Robbery",
    weight = 42, minTime = 5, maxTime = 20, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['atm'] =  {
    title = "ATM Robbery",
    weight = 65, minTime = 5, maxTime = 15, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['unpaid'] = {
    title = "Unpaid Ticket",
    weight = 50, minTime = 1, maxTime = 10, isFelony = true,
    fine = function() return (math.random(1000, 5000)) end
  },
  ['brandish'] = {
    title = "Brandishing a Firearm",
    weight = 5, minTime = 1, maxTime = 2, isFelony = false,
    fine = function() return (math.random(1000, 5000)) end
  },
  ['brandish-leo'] = {
    title = "Brandish Firearm upon a Law Enforcement Officer",
    weight = 50, minTime = 1, maxTime = 10, isFelony = true,
    fine = function() return (math.random(1000, 5000)) end
  },
  ['prisonbreak'] = {
    title = "Prison Break",
    weight = 128, minTime = 20, maxTime = 30, isFelony = true,
    fine = function() return (math.random(1000, 5000)) end
  },
  ['jailbreak'] = {
    title = "Jailbreak",
    weight = 60, minTime = 5, maxTime = 10, isFelony = true,
    fine = function() return (math.random(1000, 5000)) end
  },
  ['jailed'] = {
    title = "Jailed/Clear",
    weight = 0, minTime = 0, maxTime = 0, isFelony = true,
    fine = 0
  },
}

--- EXPORT: GetCrimeName()
-- Returns the proper name of the given crime.
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The name of the crime (always string, 'crime' if not found)
function GetCrimeName(crime)
  if not crime               then  return  "crime"  end
  if not crimes[crime]       then  return  "crime"  end
  if not crimes[crime].title then  return  "crime"  end
  print("DEBUG - GetCrimeTitle("..crime..") = "..(crimes[crime].title))
  return crimes[crime].title
end


--- EXPORT: GetCrimeTime()
-- Returns the generated time for the given crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 0 minutes
function GetCrimeTime(crime)
  if not crime         then return 0 end
  if not crimes[crime] then return 0 end
  local c = crimes[crime]
  if not c.minTime then c.minTime =  5 end
  if not c.maxTime then c.maxTime = 10 end
  local cTime = math.random(c.minTime, c.maxTime)
  print("DEBUG - GetCrimeTime("..crime..") = "..cTime)
  return cTime
end


--- EXPORT: GetCrimeFine()
-- Returns the generated fine for the crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 50 dollars
function GetCrimeFine(crime)
  if not crime              then  return 0 end
  if not crimes[crime]      then  return 0 end
  if not crimes[crime].fine then  return 0 end
  print("DEBUG - GetCrimeFine("..crime..") = "..(crimes[crime].fine()))
  return (crimes[crime].fine())
end


--- EXPORT: IsCrimeFelony()
-- Gets whether the given crime is a felony
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 50 dollars
function IsCrimeFelony(crime)
  if not crime                  then  return false  end
  if not crimes[crime]          then  return false  end
  if not crimes[crime].isFelony then  return false  end
  print("DEBUG - IsCrimeFelony("..crime..") = "..tostring(crimes[crime].isFelony))
  return (crimes[crime].isFelony)
end


--- EXPORT: GetCrimeWeight()
-- Gets the severity of a crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The severity weight, where 1 is least severe
function GetCrimeWeight(crime)
  if not crime                 then  return 1 end
  if not crimes[crime]         then  return 1 end
  if not crimes[crime].weight  then  return 1 end
  return (crimes[crime].weight)
end


--- EXPORT: DoesCrimeExist()
-- Checks if the given crime index exists in the table
-- @param crime The string to check for
-- @return True if the crime exists, false if it does not 
function DoesCrimeExist(crime)
  if crimes[crime] then 
    if crimes[crime].title then
      print("DEBUG - DoesCrimeExist("..crime..") ["..(crimes[crime].title).."]")
      return true
    else
      cprint("^1Crime '"..tostring(crime).."' did not exist in sh_wanted.lua")
      return false
    end
  else
    cprint("^1Crime '"..tostring(crime).."' did not exist in sh_wanted.lua")
    return false 
  end
end