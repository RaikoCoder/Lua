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
35051, -- Pink fizz (beach cocktail)
35052, -- Purple Lumbridge (beach cocktail)
35053, -- Pineappletini (beach cocktail)
35054, -- Lemon sour (beach cocktail)
51729, -- A Hole in One (beach cocktail)
51730, -- The Ugly Duckling (beach cocktail)
51731, -- The Palmer Farmer (beach cocktail)
51732, -- Fisherman's Friend (beach cocktail)
51733, -- George's Peach Delight  (beach cocktail)
}

local Sand_npc = {
    Sedridor = 21164,
    Duke = 21167,
    Ozan = 21166,
    Sally = 21165,
}
local Anim = {
    Bodybulding = 26551,
    Crul = 26552,
    Lunge = 26553,
    Fly = 26554,
    Raise = 26549,
}
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
local step = 0
local function RenewbeachTemp()
  
    if getBeachTemperature() == 294 then
        API.DoAction_Inventory1(35049,0,1,API.OFF_ACT_GeneralInterface_route) -- Eat Ice cream (35049)
        API.RandomSleep2(200, 100, 200)
        step = step + 1
        
    end
    if step >= 3 then
        API.Write_LoopyLoop(false)
    end
end


local function findObj(objectId, distance)
    distance = distance or 25
    local allObj = API.GetAllObjArrayInteract(objectId, distance, {0,12})
    for _, v in pairs(allObj) do
        if v.Bool1 == 0 then
            return v.Id
        end
    end
    return false
end



local function findNPC(npcid, distance)
    local distance = distance or 10
    return #API.GetAllObjArrayInteract({npcid}, distance, {1}) > 0
end

local function DoEvents()
    local EventTypes = GUI.GetComponentValue("Events")
    if EventTypes == "Strength" then
        if not API.ReadPlayerMovin2() and StrengthTraining() then
           if API.FindNPCbyName("Ivan", 50).Anim == Anim.Curl then
                if not (API.ReadPlayerAnim() == Anim.Curl) then
                    API.DoAction_Interface(0x24,0xffffffff,1,796,1,-1,API.OFF_ACT_GeneralInterface_route)
                        --API.KeyboardPress2(0x30, 60, 100)
                end
            elseif API.FindNPCbyName("Ivan", 50).Anim == Anim.Lunge then
                if not (API.ReadPlayerAnim() == Anim.Lunge) then
                    API.DoAction_Interface(0x24,0xffffffff,1,796,16,-1,API.OFF_ACT_GeneralInterface_route)
                        --API.KeyboardPress2(0x32, 60, 100)
                end
            elseif API.FindNPCbyName("Ivan", 50).Anim == Anim.Fly then
                if (API.ReadPlayerAnim() == Anim.Fly) then
                    API.DoAction_Interface(0x24,0xffffffff,1,796,26,-1,API.OFF_ACT_GeneralInterface_route)
                      --  API.KeyboardPress2(0x33, 60, 100)
                end
            elseif API.FindNPCbyName("Ivan", 50).Anim == Anim.Raise then
                if not (API.ReadPlayerAnim() == Anim.Raise) then
                    API.DoAction_Interface(0x24,0xffffffff,1,796,36,-1,API.OFF_ACT_GeneralInterface_route)
                        --API.KeyboardPress2(0x34, 60, 100)
                end
            end
        else
            API.RandomSleep2(1200, 1000, 1500)
            print("Not on the platform!")
            if API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 97379 }, 50) then
                API.RandomSleep2(1500, 1000, 2000)
            end
        end
    end
    if EventTypes == "Dungeoneering" then
        if API.InvItemFound1(51729) then
            API.DoAction_Inventory1(51729,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        --Dungeoneering
        GUI.UpdateLabelText("Title","Going in the Hole!")
        if not API.PInArea21(3165,3173, 3241,3250) then
            API.DoAction_WalkerW(WPOINT.new(3169 + math.random(-2, 2), 3247 + math.random(-2, 2), 0))
        else
            ---Start Dungeoneering--
            if API.ReadPlayerAnim() <= 2  then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 114121 },50)
                API.RandomSleep2(600,200,200)
            end
           
        end
        
       
    end
    if EventTypes == "Fishing" then
        if API.InvItemFound1(51732) then
            API.DoAction_Inventory1(51732,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        GUI.UpdateLabelText("Title","Going Fishing")
            if API.ReadPlayerAnim() <= 2  then
                API.DoAction_NPC_str(0x29,API.OFF_ACT_InteractNPC_route,{"Fishing spot"},50)
                API.RandomSleep2(1200,100,100)
                if API.InvFull_() then
                    API.DoAction_NPC_str(0x29,API.OFF_ACT_InteractNPC_route,{ "Wellington" },50)
                    API.RandomSleep2(600,200,200)
                end
            end
        end
        --Fishing
    if EventTypes == "Farming" then
        if API.InvItemFound1(51731) then
            API.DoAction_Inventory1(51731,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        GUI.UpdateLabelText("Title","Going Farming")
        if not API.PInArea(3179,3,3213,3,0) then
            API.DoAction_WalkerW(WPOINT.new( 3179 + math.random(-2, 2), 3213 + math.random(-2, 2), 0))
        else
            if API.ReadPlayerAnim() <= 2  then
            API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{117506,117500,117510},50,true)
            if API.InvFull_() then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 97332 },50)
            end
        end
        --Farming
    end
end


    if EventTypes == "Construction" then
        if API.InvItemFound1(51733) then
            API.DoAction_Inventory1(51733,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        GUI.UpdateLabelText("Title","Going to Build Sand Castles")
        skillxps = API.GetSkillXP("CONSTRUCTION")
        if (skillxps ~= skillxpsold) then
        skillxpsold = skillxps
        fail_count = 0
        else
        fail_count = fail_count +1
        end 
     if not API.PInArea21(3141,3166,3231,3258) then
            API.DoAction_WalkerW(WPOINT.new( 3153 + math.random(-2, 2), 3241 + math.random(-2, 2), 0))
        end
        if API.PInArea21(3141,3166,3231,3258) then
       
           
            if findNPC(Sand_npc.Duke,25) then
                if  fail_count >= 2 then
                    API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{97424,97425,97426,97427},50,true)
                end
            elseif findNPC(Sand_npc.Ozan,25) then
                if fail_count >= 2 then
                API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{ 109550,109551,109552},50,true)
                end
            elseif findNPC(Sand_npc.Sally,25) then
                if  fail_count >= 2 then
                API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{97420,97421,97422,97423},50,true)
                end
            elseif findNPC(Sand_npc.Sedridor,25) then
                if fail_count >= 2 then
                API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{97416,97417,97418,97419},50,true)
                end
            end
        
        
    end
end
           
        --Construction
    if EventTypes == "Hunter" then
        if API.InvItemFound1(51730) then
            API.DoAction_Inventory1(51730,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        GUI.UpdateLabelText("Title","Going to Hunt Ducks!")
        if not API.PInArea(3170,2,3212,2,0) then
            API.DoAction_WalkerW(WPOINT.new( 3170 + math.random(-2, 2), 3212 + math.random(-2, 2), 0))
        else
            if API.PInArea(3170,3,3212,3,0) then
                if API.ReadPlayerAnim() <= 2  then
                    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 104332 },50)
                    API.RandomSleep2(1200,100,100)
                end
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
        --Cooking
  
    end
end


local function hasTarget()
    local interacting = API.ReadLpInteracting()
    if interacting.Id ~= 0 then return true else return false end
end

API.SetDrawTrackedSkills(true)
GUI.Draw()
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do
    idleCheck()
API.DoRandomEvents()
    if API.CheckAnim(20) or API.ReadPlayerMovin2() then
        API.RandomSleep2(600,100,100)
        goto Hello
    end
    if findNPC(21156,30) then
        if not hasTarget() then
            API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route,{ 21156 },50)
        end
    else
        RenewbeachTemp()
        DoEvents()
    end

    ::Hello::
    API.RandomSleep2(600,200,300)
end
