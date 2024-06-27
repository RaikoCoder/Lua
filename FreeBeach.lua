local API = require("api")
local GUI = require("gui")
startTime, afk = os.time(), os.time()
MAX_IDLE_TIME_MINUTES = 5
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
local function isHoleActive() return API.Buffbar_GetIDstatus(Buffs.Hole,false).found end
local function isDuck() return API.Buffbar_GetIDstatus(Buffs.Duck,false).found end
local function isFarm() return API.Buffbar_GetIDstatus(Buffs.Farm,false).found end
local function isFisher() return API.Buffbar_GetIDstatus(Buffs.Fisher,false).found end
local function isGeorge() return API.Buffbar_GetIDstatus(Buffs.George,false).found end
local function isDungPot() return API.Buffbar_GetIDstatus(Buffs.Lemon,false).found end
local function isFishFarmHunt() return API.Buffbar_GetIDstatus(Buffs.Pineapple,false).found end
local function isCookSand()  return API.Buffbar_GetIDstatus(Buffs.Purple,false).found end
local function isCombat() return API.Buffbar_GetIDstatus(Buffs.Pfizz,false).found end

local Sand_npc = { Sedridor = 21164,Duke = 21167,Ozan = 21166,Sally = 21165, }
local Anim = {Bodybulding = 26551,Curl2 = 26552,Lunge = 26553,Fly = 26554,Raise = 26549,}
local function StrengthTraining() return API.VB_FindPSettinOrder(779, 1).state == 2473 end
local sand_castle = {Duke = {97424,97425,97426,97427},Ozan = {109550,109551,109552},Sally = {97420,97421,97422,97423},Sedridor = {97416,97417,97418,97419},
}
GUI.AddBackground("Background", 1, 1, ImColor.new(15, 13, 18, 255))
GUI.AddLabel("Title", "Beach Events", ImColor.new(255, 255, 255))
GUI.AddComboBox("Events","Events",{"Clawdia","Dungeoneering","Strength","Cooking","Fishing","Farming","Construction","Hunter"})
local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
end
--294 == 100 & 37 == 0  Temp
local function getBeachTemperature()
    local i = API.ScanForInterfaceTest2Get(false, { { 1642,0,-1,-1,0 }, { 1642,1,-1,0,0 }, { 1642,8,-1,1,0 } })
    if #i > 0 then
        return API.Mem_Read_int(i[1].memloc + 0x7c)
    end
end

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


local function goToTile(x, y, z) 
    if x and y and z then
        math.randomseed(os.time())
        local offsetRange = 2
        local offsetX = math.random(-offsetRange, offsetRange)
        local offsetY = math.random(-offsetRange, offsetRange)
        local newX = x + offsetX
        local newY = y + offsetY
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
local Step = 0
local function RenewbeachTemp()
    if getBeachTemperature() == 294 and ncount == 0 then
        if API.InvItemFound1(35049) then
            API.DoAction_Inventory1(35049, 0, 1, API.OFF_ACT_GeneralInterface_route) -- Eat Ice cream
            API.RandomSleep2(1200, 200, 200)
            ncount = ncount + 1
        end
    end

    if ncount == 1 and getBeachTemperature() ~= 294 then
        API.RandomSleep2(1200, 200, 200)
        print("Yay Ice Cream")
        ncount = 0
    end

    if ncount >= 1 and getBeachTemperature() == 294 then
        API.RandomSleep2(1800, 200, 200)
        print("Sleeping for 30 seconds")
        Step = Step + 1
        ncount = ncount + 1
    end

    if Step >= 3 and ncount >= 3 then
        if API.InvItemFound1(35049) then
            API.DoAction_Inventory1(35049, 0, 1, API.OFF_ACT_GeneralInterface_route) -- Try eating ice cream one more time
            API.RandomSleep2(1200, 200, 200)
            if getBeachTemperature() ~= 294 then
                print("Yay Ice Cream")
                ncount = 0
                Step = 0
                return
            end
        end
        API.Write_LoopyLoop(false)
    end
end

local function DoEvents()

    local EventTypes = GUI.GetComponentValue("Events")
    if EventTypes == "Strength" then
        GUI.UpdateLabelText("Title","Lets Get BUFFED!")
        if isCombat() == false and (API.InvItemcount_1(Buffs.Pfizz) >= 1) then
            API.DoAction_Inventory1(Buffs.Pfizz,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        Bodybulding()
        if (not isHappyHour()) then
            RenewbeachTemp()
        end
    end
  ---Start Dungeoneering--
    if EventTypes == "Dungeoneering" then
        if (API.InvItemcount_1(51729) >=1) and isHoleActive() ==false  and (not isHappyHour()) then
            if getBeachTemperature() == 294 then
                API.DoAction_Inventory1(51729,0,1,API.OFF_ACT_GeneralInterface_route)
                ncount = 1
                Step = 0
            end
        end
        if isDungPot() ==false and (API.InvItemcount_1(Buffs.Lemon) >= 1) then
            API.DoAction_Inventory1(Buffs.Lemon,0,1,API.OFF_ACT_GeneralInterface_route)
        end
  
        GUI.UpdateLabelText("Title","Going in the Hole!")
        
            if isHoleActive() == false  and (not isHappyHour())  then
                RenewbeachTemp()
            end
           
            if API.ReadPlayerAnim() <= 2 and not API.CheckAnim(25) and (isHappyHour() or isHoleActive() or getBeachTemperature() <= 293 )  then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 114121 },50)
                API.RandomSleep2(1800,100,100)
                
            end
    end --End Dungeoneering
    if EventTypes == "Fishing" then --Start Fish
        if API.InvItemFound1(51732) and (not isHappyHour()) and isFisher() == false then
            if getBeachTemperature() == 294 then
            API.DoAction_Inventory1(51732,0,1,API.OFF_ACT_GeneralInterface_route)
            ncount = 1
                Step = 0
            end
        end
        if isFishFarmHunt() == false and (API.InvItemcount_1(Buffs.Pineapple) >= 1) then
            API.DoAction_Inventory1(Buffs.Pineapple,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        GUI.UpdateLabelText("Title","Going Fishing")
        if  not API.ReadPlayerMovin2() and (not API.CheckAnim(75)) then
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
        end --End Fishing
    if EventTypes == "Farming" then -- Start Farm
        if API.InvItemFound1(51731) and (not isHappyHour()) and isFarm() == false   then
            if getBeachTemperature() == 294 then
            API.DoAction_Inventory1(51731,0,1,API.OFF_ACT_GeneralInterface_route)
            ncount = 1 Step = 0
            end
        end
        if isFishFarmHunt() == false and (API.InvItemcount_1(Buffs.Pineapple) >= 1) then
            API.DoAction_Inventory1(Buffs.Pineapple,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        GUI.UpdateLabelText("Title","Going to Get Some Coconuts! ")
        if  not API.ReadPlayerMovin2() and (not API.CheckAnim(75)) then
        if isHappyHour() or isFarm() or getBeachTemperature() <= 293 then
            API.DoAction_Object_valid1(0x29,API.OFF_ACT_GeneralObject_route0,{117506,117500,117510},25,true)
            API.RandomSleep2(1800,100,100)
            if API.InvFull_() then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 97332 },50)
                API.RandomSleep2(1800,100,100) end end
        if (not isHappyHour()) and isFarm() == false  then RenewbeachTemp() end end end --Farming 

    if EventTypes == "Construction" then -- Start Construction
        if API.InvItemFound1(51733) and (not isHappyHour()) and isGeorge() == false then
            if getBeachTemperature() == 294 then
            API.DoAction_Inventory1(51733,0,1,API.OFF_ACT_GeneralInterface_route)
            ncount = 1 Step = 0 end end
        if isCookSand() == false and (API.InvItemcount_1(Buffs.Purple) >= 1) then
            API.DoAction_Inventory1(Buffs.Purple,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        GUI.UpdateLabelText("Title","Going to Build Sand Castles")
        if  not API.ReadPlayerMovin2() and (not API.CheckAnim(75)) then
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
    end --Construction
    if EventTypes == "Hunter" then -- Start Hunter
    
        if API.InvItemFound1(51730) and (not isHappyHour()) and isDuck() == false then
            if getBeachTemperature() == 294 then
            API.DoAction_Inventory1(51730,0,1,API.OFF_ACT_GeneralInterface_route)
            ncount = 1
                Step = 0
            end
        end
        if isFishFarmHunt() == false and (API.InvItemcount_1(Buffs.Pineapple) >= 1) then
            API.DoAction_Inventory1(Buffs.Pineapple,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        GUI.UpdateLabelText("Title","Going to Hunt Ducks!")
        if not API.PInArea21(3168,3174,3209,3216) then
            goToTile(3170,3212,0)
            API.RandomSleep2(2600,100,200)
        else
            if  not API.ReadPlayerMovin2() and (not API.CheckAnim(75)) then
            if isHappyHour() or isDuck() or getBeachTemperature() <= 293  then
                    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ 104332 },50)
                    API.RandomSleep2(1200,100,100)
            end
    end
    if isDuck() == false and not isHappyHour() then
        RenewbeachTemp()
  end  end end--Hunter
    if EventTypes == "Cooking" then -- Start Cooking
        GUI.UpdateLabelText("Title","Going to Cook Fishes!")
        if isCookSand() == false and (API.InvItemcount_1(Buffs.Purple) >= 1) then
            API.DoAction_Inventory1(Buffs.Purple,0,1,API.OFF_ACT_GeneralInterface_route)
        end
        if not API.PInArea21(3173,3181,3249,3254) then
            API.DoAction_WalkerW(WPOINT.new( 3175+ math.random(-2, 2), 3251 + math.random(-2, 2), 0))
        else
            if  not API.ReadPlayerMovin2() and (not API.CheckAnim(75)) then
                if isHappyHour() or isDuck() or getBeachTemperature() <= 293 then
                API.DoAction_Object1(0x40,API.OFF_ACT_GeneralObject_route0,{ 97276 },50)
                API.RandomSleep2(1200,100,100)
                end
            end
        end
        if (not isHappyHour()) then
            RenewbeachTemp()
        end
        
    end--Cooking
end

API.SetDrawTrackedSkills(true)
GUI.Draw()
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do  
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
