local API = require("api")
local GUI= require("gui")
local UTILS= require("utils")
local LODESTONE= require("lodestones")
startTime, afk= os.time(), os.time()
MAX_IDLE_TIME_MINUTES= 5
local nextstep = 0
local nextMine = 0
local lastMiningOresValue = nil
-----
local plr = API.GetLocalPlayerName()
local oreBox = false
local isDeposit = false
local countore = 0
local isBurthMine, isCoalmine, isMithmine, isAdaMine, isRuneMine, isLumiMine   = false, false, false, false, false, false
local isOrikalchite, isDrakolith, isBanite, isNecrite, isPhasmatite, isLight, isDark = false, false, false, false, false,
    false, false
----
local previousMiningOres = nil
local ores = {
    Copper = { 113028, 113027, 113026 },
    Tin = { 113031, 113030 },
    Iron = { 113040, 113038, 113039 },
    Coal = { 113043, 113042, 113041 },
    Mithril = { 113050, 113051, 113052 },
    Adamantite = { 113055, 113053, 113054 },
    Runite = { 113067, 113066, 113065 },
    Luminite = { 113056, 113057, 113058 },
    Orikalchite = { 113070, 113069 },
    Drakolith = { 113131, 113133, 113132, 113133 },
    Necrite = { 113206, 113207, 113208 },
    Phasmatite = { 113138, 113139, 113137 },
    Banite = { 113140, 113141, 113142 },
    LightAnimica = { 113018 }, --5340,2255,0 Coords
    DarkAnimica = { 113020, 113021, 113022 },
    Uncommon = {113047,113048,113049},
    Common = {113035,113036,113037},
}
GUI.AddBackground("Background", 1, 1, ImColor.new(15, 13, 18, 255))
GUI.AddLabel("Title", "Free Miner AIO", ImColor.new(255, 255, 255))
GUI.AddComboBox("Mining", "Ores",
    { "", "Copper", "Tin", "Iron", "Coal", "Mithril", "Adamantite", "Runite", "Luminite", "Orikalchite",
        "Drakolith", "Banite", "Necrite", "Phasmatite", "Light Animica", "Dark Animica" })
--GUI.AddCheckbox("Bank", "Deposit Ores")
--GUI.AddCheckbox("Drop", "Drop Ores")
GUI.AddCheckbox("Special", "Dung Spot")

local oresID = {
    COPPER = 436,
    TIN = 438,
    IRON = 440,
    SILVER = 442,
    GOLD = 444,
    MITHRIL = 447,
    ADAMANTITE = 449,
    RUNITE = 451,
    COAL = 453,
    BANITE = 21778,
    LUMINITE = 44820,
    ORICHALCITE = 44822,
    DRAKOLITH = 44824,
    NECRITE = 44826,
    PHASMATITE = 44828,
    LIGHT_ANIMICA = 44830,
    DARK_ANIMICA = 44832
}
local function MonitorMiningOres()
    local currentMiningOresValue = GUI.GetComponentValue("Mining")
    if currentMiningOresValue ~= lastMiningOresValue then
        nextstep = 0
        nextMine = 0
        lastMiningOresValue = currentMiningOresValue
    end
end

local function getSelectedOreValues()
    local selectedOre = GUI.GetComponentValue("Mining")
    if selectedOre and ores[selectedOre] then
        return ores[selectedOre]
    end
end

local function RetrieveRandomOreId()
    local selectedOre = GUI.GetComponentValue("Mining")
    if selectedOre and ores[selectedOre] then
        local tbl = ores[selectedOre]
        return tbl[math.random(1, #tbl)]
    end
end
--IMPORTANT
local oreBoxes = { 44779, 44781, 44783, 44785, 44787, 44789, 44791, 44793, 44795, 44797 }
local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
end
local function OresboxCheck()
    if oreBox == true and countore < 6 then
        print("Filling ore Box")
        API.DoAction_Inventory2(oreBoxes, 0, 1, API.OFF_ACT_GeneralInterface_route)
        countore = countore + 1
        print(countore)
    elseif countore >= 6 then
        print("Box is Already Filled,Waiting to bank")
    end
    if oreBox == false then
        return
    end
end
--For Necrite  -- Iterates data from the optimal location
local function findobjtile()
    Right = API.GetAllObjArray1({ 7164, 7165 }, 50, { 4 })
    for _k, v in pairs(Right) do
        -- Assuming v has fields TileX and TileY
        local x = math.floor(v.TileX / 512)
        local y = math.floor(v.TileY / 512)
        return x, y, 0
    end
    return false, false, false
end

local function NecriteMining()
    if not API.InvFull_() then
        if API.Invfreecount_() <= 3 then
            OresboxCheck()
        end
        if not API.IsPlayerAnimating_(plr, 3) then
            API.RandomSleep2(600, 600, 600)
            if not API.IsPlayerAnimating_(plr, 2) then
                --Starts Mining
                API.DoAction_Object_r(0x3a, API.OFF_ACT_GeneralObject_route0, { 113206, 113207, 113208 }, 50,
                    FFPOINT.new(0, 0, 0), 50)
                    API.RandomSleep2(1200, 300, 600)
            end
        else
            math.randomseed(os.time())
            if API.LocalPlayer_HoverProgress() < 185 + math.random(-25, 50) then
                local x, y, z = findobjtile()
                if x and y then
                    local tile = WPOINT.new(x, y, z)
                    API.DoAction_Object_valid2(0x3a, API.OFF_ACT_GeneralObject_route0, { 113206, 113207, 113208 }, 30,
                        tile, false)
                    API.RandomSleep2(600, 800, 1000)
                    API.WaitUntilMovingEnds(10, 2)
                    return true
                else
                    -- If no sparkling rock was found, mine the first ore in the shuffled list
                    API.DoAction_Object_r(0x3a, API.OFF_ACT_GeneralObject_route0, { 113206, 113207, 113208 }, 50,
                        FFPOINT.new(0, 0, 0), 50)
                    API.RandomSleep2(1200, 300, 600)
                end
            end
        end
    end
end
--NECRITE
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
local function MineOre()
    if not API.InvFull_() then
        if API.Invfreecount_() <= 3 then
            OresboxCheck()
        end
        if not API.IsPlayerAnimating_(plr, 3) then
            API.RandomSleep2(600, 600, 600)
            if not API.IsPlayerAnimating_(plr, 2) then
                --Starts Mining
                API.DoAction_Object_r(0x3a, API.OFF_ACT_GeneralObject_route0, { RetrieveRandomOreId() }, 50,
                    FFPOINT.new(0, 0, 0), 50)
                    API.RandomSleep2(1200, 300, 600)
            end
        else
            math.randomseed(os.time())
            if API.LocalPlayer_HoverProgress() < 165 + math.random(-35, 60) then
                local foundSparkling = API.DOFindHl(0x3a, API.OFF_ACT_GeneralObject_route0, getSelectedOreValues(), 50, { 7165, 7164 })
                if foundSparkling then
                    API.RandomSleep2(200, 100,100)
                else
                    -- If no sparkling rock was found, mine the first ore in the shuffled list
                    API.DoAction_Object_r(0x3a, API.OFF_ACT_GeneralObject_route0, getSelectedOreValues(), 50, FFPOINT.new(0, 0, 0), 50)
                    API.RandomSleep2(1200, 300, 600)
                end
                
            end
        end
    end
end

--START of IRON,Tin,Copper
local function GotoBurth()
    if API.CheckAnim(25) or API.ReadPlayerMovin2() then
        API.RandomSleep2(600, 200, 100)
        goto continue
    end
    --Check Player Location and Start Script there --
    if API.PInArea(2899, 10, 3544, 10, 0) then nextstep = 1 end     --Burthope
    if API.PInArea(2292, 25, 4516, 25, 0) then nextstep = 2 end     --inside Mining Area
    --Done Checks
    if not API.PInArea(2899, 2, 3544, 2, 0) and nextstep == 0 then
        LODESTONE.Burthope()
        nextstep = 1
    end
    if API.PInArea(2899, 10, 3544, 10, 0) and nextstep == 1 then
        API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 66876 }, 50)
        print("Reached Burthorpe, walking to mining area")
        nextstep = 2
    end
    if API.PInArea(2292, 25, 4516, 25, 0) and nextstep == 2 then
        isBurthMine = true
    end
    ::continue::
    API.RandomSleep2(2600, 200, 200)
end
local function DepositOres()
    if API.CheckAnim(10) and API.ReadPlayerMovin2() then
        API.RandomSleep2(400, 200, 100)
        goto continue
    end
    if isDeposit == false and API.InvFull_() then
        if nextMine == 0 then
            API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 67002 }, 50) --Mine Burthope
            nextMine = nextMine + 1
        elseif nextMine == 1 then
            API.DoAction_Object1(0x29, 80, { 67467 }, API.OFF_ACT_GeneralObject_route1) --furnace
            nextMine = 2
            countore = 0
            isDeposit = true
        end
    end
    if isDeposit == true and nextMine == 2 and API.InvFull_() == false then
        API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 66876 }, 50) --enter mine
        nextMine = 0
        isDeposit = false
    end
    ::continue::
    API.RandomSleep2(400, 200, 200)
end
--END OF IRON,Tin,Copper
-- Start of Coal
local function GotoEdge()
    if API.CheckAnim(25) then
        API.RandomSleep2(300, 200, 100)
        goto hello
    end
    -- Values for Edge Mining
    if API.PInArea(3067, 10, 3505, 10, 0) then nextstep = 1 end
    if API.PInArea(3080, 10, 3422, 10, 0) then nextstep = 2 end
    --End of values
    if not API.PInArea(3067, 4, 3505, 4, 0) and nextstep == 0 then
        LODESTONE.Edgeville()
        nextstep = 1
    end
    if API.PInArea(3067, 10, 3505, 10, 0) and nextstep == 1 then
        API.DoAction_WalkerW(WPOINT.new(3080 + math.random(-2, 2), 3422 + math.random(-2, 2), 0))
        print("Reached Edgeville, walking to mining area")
        nextstep = 2
    end
    if API.PInArea(3080, 10, 3422, 10, 0) and nextstep == 2 then
        isCoalmine = true
    end
    ::hello::
    API.RandomSleep2(400, 200, 100)
end
local function DepositBarb()
    if not API.ReadPlayerMovin2() and isDeposit == false and API.InvFull_() then
        API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, {113270}, 50)
        countore = 0
    end
end
--End of Coal
--Start of Mithril
local function GotoMith()
    if API.CheckAnim(25) then API.RandomSleep2(600, 100, 100) goto hello end
    ---Values for mith---
    if API.PInArea(3214, 15, 3376, 15, 0) then nextstep = 1 end
    --End of Values
    if not API.PInArea(3214,4,3376,4,0) and nextstep == 0 then
        LODESTONE.Varrock()
        nextstep = 1
    end
    if API.PInArea(3214, 15, 3376, 15, 0) and nextstep == 1  then nextstep = 2 isMithmine = true  print("Reach Mining Area ") end
    ::hello:: API.RandomSleep2(600, 100, 100)
end
local function BankingForMith()
    if API.CheckAnim(10) and API.ReadPlayerMovin2() then
        API.RandomSleep2(400, 200, 100)
        goto continue
    end
    if isDeposit == false and API.InvFull_() then
        if nextMine == 0 then
            API.DoAction_Tile(WPOINT.new(3172+math.random(-2,2),3419+math.random(-2,2),0))
            nextMine = 1
        elseif nextMine == 1 then
            API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{ 113259 },50) -- varrock forge
            nextMine = 0 
        end
    end
    ::continue:: API.RandomSleep2(400, 200, 200)
end
--End of Mithril
--start of Adamantite
local function GotoAdamant()
    if API.CheckAnim(25) then API.RandomSleep2(600, 100, 100) goto hello end
    if API.PInArea(3011,10,3215,10,0) then nextstep = 1 end
    if API.PInArea(2974,10,3233,10,0) then nextstep = 2 isAdaMine = true end
    if not API.PInArea(3011,10,3215,10,0) and nextstep == 0 then
        LODESTONE.PortSarim()
        nextstep = 1
    end
    if API.PInArea(3011,4,3215,4,0) and nextstep == 1 then nextstep= 2 isAdaMine = true print("Reach Adamant Area ") end
    ::hello:: API.RandomSleep2(600, 100, 100)
end
local function BankingForAdamant()
    if API.CheckAnim(25) then API.RandomSleep2(600, 100, 100) goto hello end
    if API.PInArea(3297,10,3184,10,0) then nextMine = 1 end
    if isDeposit == false and API.InvFull_() then
        if nextMine == 0 then
            LODESTONE.AlKharid()
            API.RandomSleep2(600, 100, 100)
            nextMine = 1
        elseif API.PInArea(3297,10,3184,10,0) and nextMine == 1 then
            API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{ 76293 },50) --alkharid forge
            nextMine = 0 countore = 0 isDeposit = true nextstep = 0
        end
    end
    if isDeposit == true and not API.InvFull_() then
        GotoAdamant()
    end
    ::hello:: API.RandomSleep2(600, 100, 100)
end
--End of Adamantite
local function GotoLumiDung()
    if API.PInArea(2967,8,3403,8,0) then nextstep = 1 end
    if API.PInArea(3027,4,3336,4,0) then nextstep = 2 end
    if API.PInArea(3021,3,9739,3,0) then nextstep = 3 end
    if API.PInArea(1054,10,4516,10,0) then nextstep = 4 isLumiMine = true end
    if API.CheckAnim(25) then API.RandomSleep2(600, 600, 600) goto hello end
    if not API.PInArea(2967,8,3403,8,0) and nextstep == 0 then
        LODESTONE.Falador() API.RandomSleep2(600,200,100) nextstep = nextstep + 1
    end
   
    if nextMine < 1 and isLumiMine == false then
    if API.PInArea(2967,8,3403,8,0) and nextstep == 1 then
        API.DoAction_WalkerW(WPOINT.new(3027 + math.random(-2, 2), 3336 + math.random(-2, 2), 0))
        API.RandomSleep2(1200,300,400) nextstep = nextstep + 1
    elseif  nextstep == 2  then
        print("Going down the hole GOTO")
            API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder
            API.RandomSleep2(600,200,100) nextstep = nextstep + 1
    elseif nextstep == 3 then
        API.DoAction_Object1(0x39,API.OFF_ACT_GeneralObject_route0,{ 52856 },50) --dungeon door
        API.RandomSleep2(600,200,100) nextstep = nextstep + 1
    end
end
    ::hello::
    API.RandomSleep2(1200,500,400)
end
local function BankLumiDung()
    --going out
    if API.PInArea(1054,15,4516,15,0) and API.InvFull_() then nextMine = 0 end --inside dungeon
    if API.PInArea21(3017,3025,9732,9745) and API.InvFull_() then nextMine = 1 end
    if API.PInArea(3021,4,3339,4,0) and API.InvFull_() then nextMine = 2 end --ladder up top
    --gong inside
    if API.PInArea(3043,3,3338,3,0) and not API.InvFull_() then nextMine = 3 end --furnace 
    if API.PInArea21(3017,3025,9732,9745) and not API.InvFull_() then nextMine = 4 end--ladder down stairs
    if API.CheckAnim(25) then API.RandomSleep2(600, 600, 600) goto hello end
    if isDeposit == false and API.InvFull_() then
        if nextMine == 0 then
            API.DoAction_Object1(0x39,API.OFF_ACT_GeneralObject_route0,{ 52866 },50) --dungeon door
            nextMine = nextMine + 1
        elseif nextMine == 1 then
            print("Going up Banking")
            API.DoAction_Object1(0x35, API.OFF_ACT_GeneralObject_route0, { 6226 }, 50) --LADDER
            nextMine = nextMine + 1
        elseif nextMine == 2 then
            API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { 113265 }, 50)  -- furnace
            countore = 0
            isDeposit = true
            nextMine = nextMine + 1
        end
    end
    if isDeposit ==true and not API.InvFull_() then
        if nextMine == 3 then
            print("Going down the hole Banking")
            API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder
            nextMine = nextMine + 1
        elseif nextMine == 4 then
            API.DoAction_Object1(0x39,API.OFF_ACT_GeneralObject_route0,{ 52856 },50) --dungeon door
            nextMine = 0
            isDeposit = false
        end
    end
    ::hello::
    API.RandomSleep2(1200,500,400)

end
local function GotoLumi()
    if API.CheckAnim(25) then API.RandomSleep2(600, 600, 600) goto hello end
    if not API.PInArea(2967,8,3403,8,0) and nextstep == 0 then
        LODESTONE.Falador() API.RandomSleep2(600,200,100) nextstep = nextstep + 1
    end
    if API.PInArea(2967,8,3403,8,0) then nextstep = 1 end
    if API.PInArea(3027,4,3336,4,0) then nextstep = 2 end
    if API.PInArea(3021,3,9739,3,0) then nextstep = 3 end
    if API.PInArea21(3043,3050,9752,9756) then nextstep = 4 end
    if API.PInArea21(3029,3060,9758,9774) then nextstep = 5 isLumiMine = true end
    if nextMine < 1 and isLumiMine == false then
    if API.PInArea(2967,8,3403,8,0) and nextstep == 1 then
        API.DoAction_WalkerW(WPOINT.new(3027 + math.random(-2, 2), 3336 + math.random(-2, 2), 0))
        API.RandomSleep2(1200,300,400) nextstep = nextstep + 1
    elseif  nextstep == 2  then
        print("Going down the hole GOTO")
            API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder
            API.RandomSleep2(600,200,100) nextstep = nextstep + 1
        elseif nextstep == 3 then
            goToTile(3046,9756,0) --Run to the door
            nextstep = nextstep + 1
            API.RandomSleep2(1200,200,200)
        elseif nextstep == 4 then
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ 2112 },50) --Door
            nextstep = nextstep + 1
            isLumiMine = true
        end
    end
    ::hello::
    API.RandomSleep2(1200,500,400)
end
local function BankingLumi()
       --Going UP 
       if API.PInArea21(3033,3050,9757,9768) and API.InvFull_() then nextMine = 0 end --Luminite area
       if API.PInArea21(3036,3052,9752,9756) and API.InvFull_() then nextMine = 1 end  --Door From Luminite area
       if API.PInArea(3021,4,3339,4,0) and API.InvFull_() then nextMine = 2 end --Ladder Spot 
       --Going Down
       if API.PInArea(3043,3,3338,3,0) and not API.InvFull_() then nextMine = 3 end --Furnace Spot 
       if API.PInArea21(3017,3025,9732,9745) and not API.InvFull_() then nextMine = 4 end --Ladder in Dungeon
       if API.PInArea21(3043,3050,9752,9756) and not API.InvFull_() then nextMine = 5 end --door to luminite
   
    if API.CheckAnim(25) then API.RandomSleep2(600, 600, 600) goto hello end
 
    if isDeposit == false and API.InvFull_() then
        if nextMine == 0 then
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ 2112 },50) --Door
            nextMine = nextMine + 1
        elseif nextMine == 1 then
            print("Going up Banking")
            API.DoAction_Object1(0x35, API.OFF_ACT_GeneralObject_route0, { 6226 }, 50) --LADDER
            nextMine = nextMine + 1
        elseif nextMine == 2 then
            API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { 113265 }, 50)  -- furnace
            countore = 0
            isDeposit = true
            nextMine = nextMine + 1
        end
    end
    if isDeposit == true and not API.InvFull_() then
        if nextMine == 3 then
            print("Going down the hole Banking")
            API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder
            API.RandomSleep2(600,200,100) nextMine = nextMine + 1
        elseif nextMine == 4 then
            goToTile(3046,9756,0)
            nextMine = nextMine + 1
            API.RandomSleep2(1200,200,200)
        elseif nextMine == 5 then
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ 2112 },50) --Door
            nextMine = 0
            isDeposit = false
        end
    end
    ::hello::
    API.RandomSleep2(1200,500,400)
end

--Start of Runite, Orikalchite, ---
local function GotoRuneOri()
    if API.CheckAnim(25) then API.RandomSleep2(600, 600, 600) goto hello end
    if API.PInArea(2967,8,3403,8,0) then nextstep = 1 end
    if API.PInArea(3027,10,3336,10,0) then nextstep = 2 end
    if API.PInArea(3021,25,9739,25,0) then nextstep = 3 isRuneMine = true isOrikalchite = true end
        
    if not API.PInArea(2967,8,3403,8,0) and nextstep == 0 then
        LODESTONE.Falador() API.RandomSleep2(600,200,100) nextstep = 1
    end
    if API.PInArea(2967,8,3403,8,0) and nextstep == 1 then
        API.DoAction_WalkerW(WPOINT.new(3027 + math.random(-2, 2), 3336 + math.random(-2, 2), 0))
        API.RandomSleep2(1200,300,400) nextstep = 2
    elseif nextstep == 2 and nextMine < 1  then
        API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder
        API.RandomSleep2(600,200,100) nextstep = 3
        isRuneMine = true isOrikalchite = true
    end
    ::hello::
    API.RandomSleep2(1200,500,400)
end
local function BankingForRuneOri()
    if API.CheckAnim(25) then
        API.RandomSleep2(600, 600, 600)
        goto hello
    end

    if isDeposit == false and API.InvFull_() then
        if nextMine == 0 then
            print("Going up the ladder")
            API.DoAction_Object1(0x35, API.OFF_ACT_GeneralObject_route0, { 6226 }, 50)  --going up ladder
            API.RandomSleep(1000, 100, 200)  -- Increased sleep time
            nextMine = nextMine + 1
        elseif nextMine == 1 and API.PInArea(3021, 3, 3339, 3, 0) then
            print("At the furnace")
            API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { 113265 }, 50)  -- furnace
            nextMine = nextMine + 1
            countore = 0
            isDeposit = true
        end
    end

    if isDeposit == true and not API.InvFull_() then
        if nextMine == 2 and API.PInArea(3043, 5, 3338, 5, 0) then
            print("Going down the ladder")
            API.DoAction_Object1(0x35, API.OFF_ACT_GeneralObject_route0, { 2113 }, 50)  --going down ladder
            nextMine = nextMine + 1
        end
        if nextMine == 3 then
            isDeposit = false
            isOrikalchite = true
            isRuneMine = true
            nextMine = 0
        end
    end

    ::hello::
    API.RandomSleep2(1200, 500, 400)
end
local function isDungSpot()
    local DungeonSpot = GUI.GetComponentValue("Special")
    if DungeonSpot ~= nil and DungeonSpot ~= false and DungeonSpot ~= 0 and DungeonSpot ~= "" then
        return true
    end
    return false
end
local function isDropOre()
    local DungeonSpot = GUI.GetComponentValue("Drop")
    if DungeonSpot ~= nil and DungeonSpot ~= false and DungeonSpot ~= 0 and DungeonSpot ~= "" then
        return true
    end
    return false
end


--end of Runite, Orikalchite, ---
local function DoOres()
    local MiningOres = GUI.GetComponentValue("Mining")
    if MiningOres == "Copper" or MiningOres == "Tin" then
        if API.InvItemFound2({ 44779, 44781, 44783, 44785, 44787, 44789, 44791, 44793, 44795, 44797 }) then oreBox = true end
        GotoBurth()
        if isBurthMine == true then
            if not API.InvFull_() then MineOre() end
            DepositOres()
        end
    end
    if MiningOres == "Iron" then
        if API.InvItemFound2({44781, 44783, 44785, 44787, 44789, 44791, 44793, 44795, 44797 }) then oreBox = true end
        GotoBurth()
        if isBurthMine == true then
            if not API.InvFull_() then MineOre() end
            DepositOres()
        end
    end
    if MiningOres == "Coal" then
        if API.InvItemFound2({44783,44785,44787,44789, 44791,44793,44795,44797}) then oreBox = true end
        GotoEdge()
        if isCoalmine == true then
            if not API.InvFull_() then MineOre()
            end
            DepositBarb()
        end
    end
    if MiningOres == "Mithril" then
        if API.InvItemFound2({44785,44787,44789, 44791,44793,44795,44797}) then oreBox = true end
        GotoMith()
        if isMithmine == true then
            if not API.InvFull_() then MineOre() end
            BankingForMith()
        end
    end
    if MiningOres == "Adamantite" then
        GotoAdamant()
        if API.InvItemFound2({44787,44789,44791,44793,44795,44797}) then oreBox = true end
        if isAdaMine == true then
            if not API.InvFull_() then 
                MineOre() 
                isDeposit = false 
            end
            BankingForAdamant()
        end
    end
    if MiningOres == "Runite" then
       if API.InvItemFound2({44789,44791,44793,44795,44797}) then oreBox = true end
        GotoRuneOri()
        if isRuneMine == true or isOrikalchite == true then
            if not API.InvFull_() then MineOre() end
            BankingForRuneOri()
        end
    end
    if MiningOres == "Orikalchite" then
       if API.InvItemFound2({44791,44793,44795,44797}) then oreBox = true end
        GotoRuneOri()
        if isRuneMine == true or isOrikalchite == true then
            if not API.InvFull_() then MineOre() end
            BankingForRuneOri()
        end
    end
    if MiningOres == "Luminite" then
        if not isDungSpot() then
        if API.InvItemFound2({44789,44791,44793,44795,44797}) then oreBox = true end
        GotoLumi()
        if isLumiMine == true then
            if not API.InvFull_() and isDeposit == false then MineOre() end
            BankingLumi()
        end end
        if isDungSpot() then
            if API.InvItemFound2({44789,44791,44793,44795,44797}) then oreBox = true end
            GotoLumiDung()
            if isLumiMine == true then
                if not API.InvFull_() and isDeposit == false then MineOre() end
                BankLumiDung()
            end
        end
    end
    if MiningOres == "Drakolith" then
        print("Mining Drakolith")
    end
    if MiningOres == "Banite" then
        print("Mining Banite")
    end
    if MiningOres == "Necrite" then
        print("Mining Necrite")
        NecriteMining()
    end
    if MiningOres == "Phasmatite" then
        print("Mining Phasmatite")
    end
    if MiningOres == "Light Animica" then
        print("Mining Light Animica")
    end
    if MiningOres == "Dark Animica" then
        print("Mining Dark Animica")
    end
end
local oreValues = getSelectedOreValues()
if oreValues then
    print("Selected ore values: ", table.concat(oreValues, ", "))
else
    print("No ore selected or ore not found.")
end
-- Loop through each pair of objects from NecriteOres and Highlight
GUI.Draw()
API.SetDrawTrackedSkills(true)
while (API.Read_LoopyLoop()) do
    isDungSpot() --isDropOre() -- checkBoxes 
    if API.ReadPlayerMovin2() then
        API.RandomSleep2(600, 200, 100)
        goto continue
    end

    idleCheck()
    MonitorMiningOres()
    DoOres()   
    ::continue::
    API.RandomSleep2(600, 200, 200)
end
