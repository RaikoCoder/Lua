local API = require("api")
local GUI = require("gui")
startTime, afk = os.time(), os.time()
MAX_IDLE_TIME_MINUTES = 5
local skillxps = API.GetSkillXP("CONSTRUCTION")
local skillxpsold = 0
local fail_count = 0
--HIGGINS CODES----
local Buffs = {
-- BUFF/STATUS EFFECT IDS
Pfizz = 35051, -- Pink fizz (beach cocktail)
Purple =35052, -- Purple Lumbridge (beach cocktail)
Pineapple = 35053, -- Pineappletini (beach cocktail)
Lemon= 35054, -- Lemon sour (beach cocktail)
Hole = 51729, -- A Hole in One (beach cocktail)
Duck = 51730, -- The Ugly Duckling (beach cocktail)
Farm = 51731, -- The Palmer Farmer (beach cocktail)
Fisher = 51732, -- Fisherman's Friend (beach cocktail)
George = 51733, -- George's Peach Delight  (beach cocktail)
}
local function isHoleActive()
    return API.Buffbar_GetIDstatus(Buffs.Hole,false).found
end
local function isDuck()
    return API.Buffbar_GetIDstatus(Buffs.Duck,false).found
end
local function isFarm()
    return API.Buffbar_GetIDstatus(Buffs.Farm,false).found
end
local function isFisher()
    return API.Buffbar_GetIDstatus(Buffs.Fisher,false).found
end
local function isGeorge()
    return API.Buffbar_GetIDstatus(Buffs.George,false).found
end

local Sand_npc = {
    Sedridor = 21164,
    Duke = 21167,
    Ozan = 21166,
    Sally = 21165,
}
local Anim = {
   Bodybulding = 26551,
    
    Curl2 = 26552,
    Lunge = 26553,
    Fly = 26554,
    Raise = 26549,

}

local function isclawHP()
    local dia = API.ReadAllObjectsArray({1}, {21156}, {})
    for _, npc in pairs(dia) do
        if npc.Id == 21156 then
             clawHp = npc.Life
        end
    end
end
local function StrengthTraining()
    return API.VB_FindPSettinOrder(779, 1).state == 2473
  end

local sand_castle = {
    Duke = {97424,97425,97426,97427},
    Ozan = {109550,109551,109552},
    Sally = {97420,97421,97422,97423},
    Sedridor = {97416,97417,97418,97419},
}
GUI.AddBackground("Background", 1, 1, ImColor.new(15, 13, 18, 255))
GUI.AddLabel("Title", "Beach Event AIO", ImColor.new(255, 255, 255))
GUI.AddComboBox("Events","Events",{"","Dungeoneering","Strength","Cooking","Fishing","Farming","Construction","Hunter"})
local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
end
--[ 
-- 294 == 100% Temp
--  37 == 0%
--]
local function getBeachTemperature()
    local i = API.ScanForInterfaceTest2Get(false, { { 1642,0,-1,-1,0 }, { 1642,1,-1,0,0 }, { 1642,8,-1,1,0 } })
    if #i > 0 then
        return API.Mem_Read_int(i[1].memloc + 0x7c)
    end
end
--HIGGINS CODES----


local function Bodybulding()
    if not API.ReadPlayerMovin2() and StrengthTraining() then
        if API.FindNPCbyName("Ivan", 50).Anim == Anim.Curl2 then
            if not (API.ReadPlayerAnim() == Anim.Curl2) then
              API.DoAction_Interface(0x24,0xffffffff,1,796,6,-1,API.OFF_ACT_GeneralInterface_route)
            end
        elseif API.FindNPCbyName("Ivan", 50).Anim == Anim.Lunge then
            if not (API.ReadPlayerAnim() == Anim.Lunge) then
                    API.DoAction_Interface(0x24,0xffffffff,1,796,16,-1,API.OFF_ACT_GeneralInterface_route)
            end
        elseif API.FindNPCbyName("Ivan", 50).Anim == Anim.Fly then
            if (API.ReadPlayerAnim() == Anim.Fly) then
                    API.DoAction_Interface(0x24,0xffffffff,1,796,26,-1,API.OFF_ACT_GeneralInterface_route)
            end
        elseif API.FindNPCbyName("Ivan", 50).Anim == Anim.Raise then
            if not (API.ReadPlayerAnim() == Anim.Raise) then
                    API.DoAction_Interface(0x24,0xffffffff,1,796,36,-1,API.OFF_ACT_GeneralInterface_route)
            end
        end
    else
        API.RandomSleep2(1200, 1000, 1500)
        if API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 97379 }, 50) then
            API.RandomSleep2(1500, 1000, 2000)
        end
    end
end


local function goToTile(x, y, z) --random coord selection
    if x and y and z then
        math.randomseed(os.time())
        local offsetRange = 2

        -- Generate random offsets for x and y
        local offsetX = math.random(-offsetRange, offsetRange)
        local offsetY = math.random(-offsetRange, offsetRange)

        -- Apply the offsets to the original coordinates
        local newX = x + offsetX
        local newY = y + offsetY

        -- Assuming API.DoAction_Tile() takes coordinates as arguments
        API.DoAction_Tile(WPOINT.new(newX, newY, z))
    end
end
local function findNPC(npcid, distance)
    local distance = distance or 10
    return #API.GetAllObjArrayInteract({npcid}, distance, {1}) > 0
end
local function AttackClawdia()

    if #API.ReadAllObjectsArray({ 1 }, { 21156 }, {}) == 0 then return end
    if API.ReadLpInteracting().Id ~= 21156 then
        if API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { 21156 }, 50) then
            API.RandomSleep2(1200, 0, 200)
            API.WaitUntilMovingEnds(10,20)
        end
    end
end
local function getSpotlight()
    local i = API.ScanForInterfaceTest2Get(false, { { 1642,0,-1,-1,0 }, { 1642,3,-1,0,0 }, { 1642,5,-1,3,0 } })
    if #i > 0 then
        return string.match(i[1].textids,"<br>(.*)")
    end
end

local function isHappyHour()
    local spot = getSpotlight()
    if spot == nil or spot == '' then 
        return false 
    end
    return string.find(spot, 'Happy Hour')
end


local ncount = 0 
local fail = 0 
local function RenewbeachTemp()
 
 if getBeachTemperature() == 294 and ncount == 0 then
    if API.InvItemFound1(35049) then
        API.DoAction_Inventory1(35049, 0, 1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1200, 200, 200)
        ncount = ncount + 1
    end
end
    if ncount == 1 and getBeachTemperature() ~= 294 then
        API.RandomSleep2(1200,200,200)
        print("Yay Ice Cream")
        ncount = 0 
    end
    if ncount >= 1 and getBeachTemperature() == 294 then
        API.RandomSleep2(1800,200,200)
        print("Sleeping for 30 seconds")
        fail = fail + 1 
        ncount = ncount + 1
    end
    if fail >= 3 and ncount >= 3 then
        API.Write_LoopyLoop(false)
    end
       
    
 end
local function DoEvents()

    local EventTypes = GUI.GetComponentValue("Events")
    if EventTypes == "Strength" then
        GUI.UpdateLabelText("Title","Lets Get BUFFED!")
        Bodybulding()
        if (not isHappyHour()) then
            RenewbeachTemp()
        end
    end
       
    if EventTypes == "Dungeoneering" then
        if (API.InvItemcount_1(51729) >=1) and isHoleActive() ==false  and (not isHappyHour()) then
            if getBeachTemperature() == 294 then
                API.DoAction_Inventory1(51729,0,1,API.OFF_ACT_GeneralInterface_route)
            end
        end
        --Dungeoneering
        GUI.UpdateLabelText("Title","Going in the Hole!")
        if not API.PInArea21(3165,3173, 3241,3250) then
            goToTile(3169,3247,0)
            API.RandomSleep2(2600,100,100)
        else
            if isHoleActive() == false  and (not isHappyHour())  then
                RenewbeachTemp()
            end
            ---Start Dungeoneering--
            if API.ReadPlayerAnim() <= 2 and (isHappyHour() or isHoleActive() or getBeachTemperature() <= 293 )  then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 114121 },50)
                API.RandomSleep2(1800,100,100)
                
            end
            
        end
    end
    if EventTypes == "Fishing" then
        if API.InvItemFound1(51732) and (not isHappyHour()) and isFisher() == false then
            if getBeachTemperature() == 294 then
            API.DoAction_Inventory1(51732,0,1,API.OFF_ACT_GeneralInterface_route)
            end
        end
        GUI.UpdateLabelText("Title","Going Fishing")
            if API.ReadPlayerAnim() <= 2  then
                API.DoAction_NPC_str(0x29,API.OFF_ACT_InteractNPC_route,{"Fishing spot"},50)
                API.RandomSleep2(1800,100,100)
                if API.InvFull_() then
                    API.DoAction_NPC_str(0x29,API.OFF_ACT_InteractNPC_route,{ "Wellington" },50)
                    API.RandomSleep2(600,200,200)
                end
            end
            if (not isHappyHour()) and isFisher() == false  then
                RenewbeachTemp()
            end
        end
        --Fishing
    if EventTypes == "Farming" then
        if API.InvItemFound1(51731) and (not isHappyHour()) and isFarm() == false   then
            if getBeachTemperature() == 294 then
            API.DoAction_Inventory1(51731,0,1,API.OFF_ACT_GeneralInterface_route)
            end
        end
        skillxps = API.GetSkillXP("FARMING")
        if (skillxps ~= skillxpsold) then
        skillxpsold = skillxps
        fail_count = 0
        else
            API.RandomSleep2(800,200,200)
            fail_count = fail_count +1
        end 
        GUI.UpdateLabelText("Title","Going to Get Some Coconuts! ")
        if not API.PInArea21(3170,3186,3209,3218) then
            goToTile(3180,3213,0)
            API.RandomSleep2(2600,100,200)
        else
            if API.ReadPlayerAnim() <= 2 and API.PInArea21(3170,3186,3209,3218) then
        if (isHappyHour() or isFarm() or getBeachTemperature() <= 293 ) then
                if fail_count>= 3 then
            API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{117506,117500,117510},50,true)
            fail_count = 0
            API.RandomSleep2(1800,100,100)
                end
            if API.InvFull_() then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 97332 },50)
                fail_count = 0
                API.RandomSleep2(1800,100,100)
            end
        end
        if (not isHappyHour()) and isFarm() == false  then
            RenewbeachTemp()
        end
        --Farming
            end
        end
    end

    if EventTypes == "Construction" then
        if API.InvItemFound1(51733) and (not isHappyHour()) and isGeorge() == false then
            if getBeachTemperature() == 294 then
            API.DoAction_Inventory1(51733,0,1,API.OFF_ACT_GeneralInterface_route)
            end
        end
        GUI.UpdateLabelText("Title","Going to Build Sand Castles")
        skillxps = API.GetSkillXP("CONSTRUCTION")
        if (skillxps ~= skillxpsold) then
        skillxpsold = skillxps
        fail_count = 0
        else
            API.RandomSleep2(800,200,200)
            fail_count = fail_count +1
        end 
     if not API.PInArea21(3141,3166,3231,3258) then
        goToTile(3153,3241,0)
        API.RandomSleep2(2600,100,200)
        end
    if API.PInArea21(3141,3166,3231,3258) then
        if  not API.ReadPlayerMovin2() and (not API.CheckAnim(50)) then
            if isHappyHour() or isGeorge() or getBeachTemperature() <= 293 then
            if findNPC(Sand_npc.Duke,25) then
                API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{97424,97425,97426,97427},50,true)
            elseif findNPC(Sand_npc.Ozan,25) then
                API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{ 109550,109551,109552},50,true)
            elseif findNPC(Sand_npc.Sally,25) then
                API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{97420,97421,97422,97423},50,true)
            elseif findNPC(Sand_npc.Sedridor,25) then
                API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{97416,97417,97418,97419},50,true)
               end
            end
        end
        if (not isHappyHour()) and isGeorge() == false  then
            RenewbeachTemp()
        end
    end
        
    end
        --Construction
    if EventTypes == "Hunter" then
        skillxps = API.GetSkillXP("HUNTER")
        if (skillxps ~= skillxpsold) then
        skillxpsold = skillxps
        fail_count = 0
        else
            API.RandomSleep2(800,200,200)
        fail_count = fail_count +1
        end 
        if API.InvItemFound1(51730) and (not isHappyHour()) and isDuck() == false then
            if getBeachTemperature() == 294 then
            API.DoAction_Inventory1(51730,0,1,API.OFF_ACT_GeneralInterface_route)
            end
        end
        GUI.UpdateLabelText("Title","Going to Hunt Ducks!")
        if not API.PInArea21(3168,3174,3209,3216) then
            goToTile(3170,3212,0)
            API.RandomSleep2(2600,100,200)
        else
            if isHappyHour() or isDuck() or getBeachTemperature() <= 293 then
                if API.ReadPlayerAnim() <= 2 and fail_count>=6 then
                    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 104332 },50)
                    fail_count = 0
                    API.RandomSleep2(1200,100,100)
                end
            end
            if (not isHappyHour()) or isDuck() == false  then
                RenewbeachTemp()
        end
    end
        --Hunter
    end
    if EventTypes == "Cooking" then
        GUI.UpdateLabelText("Title","Going to Cook Fishes!")
        if not API.PInArea21(3173,3181,3249,3254) then
            API.DoAction_WalkerW(WPOINT.new( 3175+ math.random(-2, 2), 3251 + math.random(-2, 2), 0))
        else
            if API.ReadPlayerAnim() <= 2  then
                API.DoAction_Object1(0x40,API.OFF_ACT_GeneralObject_route0,{ 97276 },50)
                API.RandomSleep2(1200,100,100)
            end
        end
        if (not isHappyHour()) then
            RenewbeachTemp()
        end
        --Cooking
    end

    if isHappyHour() then
       EventTypes = "Dungeoneering"
    end
end




API.SetDrawTrackedSkills(true)
GUI.Draw()
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do  
    print(isHoleActive() ," Hole")
    print(isHappyHour() ," Happy")
    print(fail)
    print(ncount)
    idleCheck()
API.DoRandomEvents()
    if API.ReadPlayerMovin2() then
        API.RandomSleep2(600,100,100)
        goto Hello
    end
    if findNPC(21156, 25)and not API.LocalPlayer_IsInCombat_()  then
        AttackClawdia()
    else 
        if not API.LocalPlayer_IsInCombat_() then
            DoEvents()
            API.RandomSleep2(600,200,300)
        end
    end
    ::Hello::
    API.RandomSleep2(600,200,300)

    
end
