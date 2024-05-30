
--[[
Version 0.01 - Fixed Addy Bugs
v0.05 - added orikalchite , Fixed the Orebox not filling whenever banked.  Added another safe
v0.10 - cleaned up codes and fix how some movement
]]
local API =require("api")
local LODESTONE = require("lodestones")
startTime, afk = os.time(), os.time()
MAX_IDLE_TIME_MINUTES = 5

-----
local plr = API.GetLocalPlayerName()
local oreBox = false
local isDeposit = false
local countore = 0
local isBurthMine, isCoalmine , isMithmine , isAdaMine, isRuneMine,isLumiMine  = false,false,false,false,false,false
local isOrikalchite = false
----

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



local ores = {
    Copper = {113028, 113027, 113026},
    Tin = {113031, 113030},
    Iron = {113040, 113038, 113039},
    Coal = {113043, 113042, 113041},
    Mithril = {113050, 113051, 113052},
    Adamantite = {113055, 113053, 113054},
    Runite = {113067, 113066, 113065},
    Luminite = { 113056, 113057, 113058 },
    Orikalchite = {113070,113069},
    --Drakolith = {113071, 113072, 113073},
   -- Banite = {113140, 113141, 113142},
    --Necrite = {113143, 113144, 113145}
   
}

local function getDictKeys(dict)
    local oreNames = {}
    for i, v in pairs(dict) do
        table.insert(oreNames, i)
    end
    return oreNames
end

local selectedOre = API.ScriptDialogWindow2(
    "Mining", getDictKeys(ores), "Start", "Close"
).Name

local oreBoxes = { 44779,44781,44783,44785,44787,44789, 44791,44793,44795,44797}
local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
end
local function OresboxCheck()
    if API.Invfreecount_() <= 3 then
        if oreBox ==  true and countore < 6 then
            print("Filling ore Box")
            API.DoAction_Inventory2(oreBoxes,0, 1, API.OFF_ACT_GeneralInterface_route)
            countore = countore + 1
            print(countore)
        elseif countore >= 6 then
            print("Box is Already Filled,Waiting to bank")
        end
        if oreBox == false then
            return
        end
    end
end
local function RetrieveRandomOreId()
    local tbl = ores[selectedOre]
    return tbl[math.random(1, #tbl)]
end

local function MineOre()

    if API.Invfreecount_()  <= 25 then
        OresboxCheck()
        end
    if not API.InvFull_() then
    if not API.IsPlayerAnimating_(plr, 3) then
        API.RandomSleep2(600, 600, 600)    
        if not API.IsPlayerAnimating_(plr, 2) then
            --Starts Mining
            API.DoAction_Object_r(0x3a, 0, {RetrieveRandomOreId()}, 50, FFPOINT.new(0, 0, 0), 50)
        end
    else
        math.randomseed(os.time())
        if API.LocalPlayer_HoverProgress() < 85 + math.random(-30,60) then
        -- Try to find and mine a sparkling rock
        local foundSparkling = API.FindHl(0x3a, 0, ores[selectedOre], 50, { 7165, 7164 })
        if foundSparkling then
            print("Sparkle vein found, clicking..")
            API.FindHl(0x3a, 0, ores[selectedOre], 50, { 7165, 7164 })
            API.RandomSleep2(1200,300,600)  
        else
            -- If no sparkling rock was found, mine the first ore in the shuffled list
            API.DoAction_Object_r(0x3a,0,ores[selectedOre],50,FFPOINT.new(0, 0, 0),50)
            API.RandomSleep2(1200,300,600)
        end
    end
    end

end end

--Burthope for Iron Below-
local function GotoBurth()
    if API.CheckAnim(5) then
        API.RandomSleep2(300,200,100)
        goto hello
    end
    if not API.PInArea(2899,2,3544,2,0) and isBurthMine == false then
        LODESTONE.Burthope()
        isBurthMine = true
        
        print("Reach Burthope Walking to mining ")
    end
    if API.PInArea(2899,2,3544,2,0) and isBurthMine == true then
        API.RandomSleep2(1200,300,300)
        goToTile(2889,3503,0)
    end
    if API.PInArea(2889,4,3503,4,0) then
            API.DoAction_Object1(0x39,API.OFF_ACT_GeneralObject_route0,{ 66876 },50)
            if API.PInArea(2292,3,4516,3,0) then
              isBurthMine = true
            end
    end
    ::hello::
    API.RandomSleep2(1200,500,900)
end
local function DepositOres()
    API.DoAction_Object1(0x29, 80, {67467}, API.OFF_ACT_GeneralObject_route1)
    API.RandomSleep2(1200, 600, 600)
     countore = 0
end

local function MiningAtBurthope()
    if selectedOre == "Tin" or selectedOre == "Iron" or selectedOre == "Copper" then
    if API.InvItemFound2({44779,44781,44783,44785,44787,44789, 44791,44793,44795,44797}) then
        oreBox = true end
        GotoBurth()
    if isBurthMine == true then
    if not API.InvFull_()then 
        MineOre() 
    end
    if API.InvFull_() then 
        API.DoAction_Object1(0x39, 0, {67002}, 50)
        API.RandomSleep2(600, 0, 0)
        DepositOres()
        end 
    if not API.InvFull_() then 
        API.DoAction_Object1(0x39,API.OFF_ACT_GeneralObject_route0,{ 66876 },50)
            API.RandomSleep2(600, 0, 0)  
        end 
    end
end    
end
--End of iron 


--Start of Coal
local function DepositBarb()
    if not API.ReadPlayerMovin2() then
        API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, {113270}, 50)
        countore = 0
    end
end



local function GotoEdge()
    if API.CheckAnim(10) then

 API.RandomSleep2(300,200,100)
        goto hello
    end
       if not API.PInArea(3067,4,3505,4,0) and isCoalmine == false then
        LODESTONE.Edgeville()
        API.RandomSleep2(1200,300,600)
        isCoalmine = true
        isDeposit = false
       elseif API.PInArea(3067,4,3505,4,0) and isCoalmine == true   then
        API.DoAction_WalkerW(WPOINT.new(3080 + math.random(-2, 2), 3422 + math.random(-2, 2), 0))
        print("Going to barb Village")
        
       elseif API.PInArea(3080,6,3422,6,0) and isCoalmine == true then
            isCoalmine = true
       end
       ::hello::
       API.RandomSleep2(1200,500,900)
end


local function MiningCoalsBarb()
    if selectedOre == "Coal" then
        if API.InvItemFound2({44781,44783,44785,44787,44789, 44791,44793,44795,44797}) then
            oreBox = true
        end
        GotoEdge()
    if isCoalmine == true then
        if not API.InvFull_() then
            MineOre()
        end
        if API.InvFull_() then
            DepositBarb()
            API.RandomSleep2(600, 600, 600)
        end
    end
    end
end
--End of Coal

--Start of Mithril
local function GotoMith()
    if API.CheckAnim(10) then
        API.RandomSleep2(600, 600, 600)
        goto hello
    end
    if not API.PInArea(3214,4,3376,4,0) and isMithmine  == false then
        LODESTONE.Varrock()
        API.RandomSleep2(1200,300,600)
        isMithmine = true
        isDeposit = false
    elseif API.PInArea(3214,4,3376,4,0) and isMithmine == true then
        print("Reach Varrock, Going to Mithril Area")
        goToTile(3187,3375,0) -- get close to mine
    elseif API.PInArea(3187,4,3375,4,0) and isMithmine == true then
        print("Reached Mith Mining")
    end
    ::hello::
    API.RandomSleep2(1200,500,600)
end

local function BankingforMith()
   
    if not API.PInArea(3183,4,3423,4,0) and isMithmine == true then
        goToTile(3183,3423,0)
    end
    if API.PInArea(3183,4,3423,4,0) then
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{ 113259 },50) -- varrock forge
            API.RandomSleep2(1200,300,200)
            isDeposit =true
            isMithmine = false
            countore = 0
    end
    if API.PInArea(3183,4,3423,4,0) and isDeposit == true then
        GotoMith()
    end
end
local function MiningMithVarrock()

    if selectedOre == "Mithril" then
        if API.InvItemFound2({44783,44785,44787,44789, 44791,44793,44795,44797}) then
            oreBox = true
        end
        GotoMith()
    if isMithmine == true then
        if not API.InvFull_() then
            MineOre()
        end
    end
    if API.InvFull_() then
            isMithmine = true
            isDeposit = false
            BankingforMith()
            API.RandomSleep2(600,600,600)
    end
end
end
--End of Mithril


---Start of Adamant
local function GotoAddy()
    if API.CheckAnim(10) then
        API.RandomSleep2(600, 600, 600)
        goto hello
    end
    if not API.PInArea(3011,4,3215,4,0) and isAdaMine == false then
       LODESTONE.PortSarim()
       API.RandomSleep2(1200,300,600)
        isAdaMine = true
        isDeposit =false
       
    elseif API.PInArea(3011,4,3215,4,0) and isAdaMine == true then
        print("Reach Port Sarim, Going to Adamantite Area")
        goToTile(2968,3229,0) -- adamant Area
    elseif API.PInArea(2968,4,3229,4,0) and isAdaMine == true then
        print("Adamantite Area")
    end
    ::hello::
    API.RandomSleep2(1200,500,400)
end
local function BankingForAddy()
    if not API.PInArea(3233,4,3221,4,0) and isAdaMine == true then
        LODESTONE.Lumbridge()
        API.RandomSleep2(1200,300,600)
    end
    if API.PInArea(3233,4,3221,4,0) and isAdaMine == true and isDeposit == false then
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{ 113261 },50) --lumby forge 
        API.RandomSleep2(1200,300,600)
        isDeposit = true
        isAdaMine = false
        countore = 0
    end      
    if API.PInArea(3227,2,3255,2,0) and (not API.InvFull_()) and isDeposit== true then
        GotoAddy()
        isDeposit = false 
    end
end
local function MiningAddyRimmy()

    if selectedOre == "Adamantite" then
        if API.InvItemFound2({44785,44787,44789, 44791,44793,44795,44797}) then
            oreBox = true
        end
        GotoAddy()
        if isAdaMine == true then
            if not API.InvFull_() then
                MineOre()
            end
        end
        if API.InvFull_()  then
        isAdaMine = true
            isDeposit = false
            BankingForAddy()
            API.RandomSleep2(600,600,600)
        end
    end

end

--end of Adamant 


--Start of Runite to orikalkum
local function GotoMiningGuild()
    if API.CheckAnim(10) then
        API.RandomSleep2(600, 600, 600)
        goto hello
    end
    if selectedOre == "Runite" or selectedOre == "Orikalchite" then
        
    if not API.PInArea(3011,4,3215,4,0) and isRuneMine == false or isOrikalchite == false then
        LODESTONE.PortSarim()
        API.RandomSleep2(1200,300,400)
        isRuneMine = true
        isLumiMine = false
        isOrikalchite = true
    end

    if API.PInArea(3011,4,3215,4,0) and isRuneMine == true or isOrikalchite == true and isLumiMine == false  then
        API.DoAction_WalkerW(WPOINT.new(3027 + math.random(-2, 2), 3336 + math.random(-2, 2), 0))
        API.RandomSleep2(1200,300,400)
    elseif API.PInArea(3027,4,3336,4,0) then
        API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder
    elseif API.PInArea(3021,8,9739,8,0) then
        print("Rune Area")
    end
end

if selectedOre == "Luminite"  then
    if not API.PInArea(3011,4,3215,4,0) and isLumiMine == false then
        LODESTONE.PortSarim()
        API.RandomSleep2(1200,300,400)
        isLumiMine = true
        isRuneMine =false 
    end

    if API.PInArea(3011,4,3215,4,0) and isLumiMine == true and isRuneMine == false then
        API.DoAction_WalkerW(WPOINT.new(3027 + math.random(-2, 2), 3336 + math.random(-2, 2), 0))
        API.RandomSleep2(1200,300,400)
    elseif API.PInArea(3027,4,3336,4,0) then
        API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder 
        API.RandomSleep2(1200,300,400)
    elseif API.PInArea(3021,8,9739,8,0) then
        API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ 2112 },50) --Door
    elseif API.PInArea(3046,3,9757,3,0) then
        print("Luminite Area")
    end
end
    ::hello::
    API.RandomSleep2(1200,500,400)
    
end


local function BankingForRune()
    if isRuneMine == true and  isDeposit == false or isOrikalchite == true then
        if API.PInArea(3033,6,9736,6,0) then
            API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 6226 },50) --Ladder  going up
            API.RandomSleep2(1200,300,400)
            end
            if API.PInArea(3021,4,3339,4,0) then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{ 113265 },50) --Furnce
                isDeposit = true
                countore = 0
            end 
    end
    if API.PInArea(3043,4,3338,4,0) and isDeposit == true then
        API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder 
          API.RandomSleep2(1200,300,400)
      end
end
local function BankingForLuminite()
    if isLumiMine == true and isDeposit == false then
        if API.PInArea(3039,4,9763,4,0) then
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ 2112 },50) --Door 
            API.RandomSleep2(1200,300,400)
        elseif API.PInArea(3046,3,9757,3,0) then
            API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 6226 },50) --Ladder going up
            API.RandomSleep2(1200,300,400)
        end
        if API.PInArea(3021,4,3339,4,0) and isDeposit == false   then
            API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{ 113265 },50) --Furnce
            countore = 0
            isDeposit =true
        end
        
    if API.PInArea(3043,4,3338,4,0) and isDeposit == true then
    API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{ 2113 },50) --Ladder 
    API.RandomSleep2(1200,300,400)
    API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ 2112 },50) --Door 
    end
    end
end

local function MiningAtMiningGuild()
    if selectedOre == "Runite" or selectedOre == "Orikalchite"  then
        if API.InvItemFound2({44785,44787,44789, 44791,44793,44795,44797}) then
            oreBox = true
        end
        GotoMiningGuild()
        if isRuneMine == true or isOrikalchite == true  then
            if not API.InvFull_() then
                MineOre()
            end
        end
        if API.InvFull_() then
            isOrikalchite = true
            isRuneMine = true
            isDeposit = false 
            BankingForRune()
        end
          
            API.RandomSleep2(600,600,600)
    end

    if selectedOre == "Luminite" then
        if API.InvItemFound2({44785,44787,44789, 44791,44793,44795,44797}) then
            oreBox = true
        end
        GotoMiningGuild()
        if isLumiMine == true then
            if not API.InvFull_() then
                MineOre()
            end
        end
        if API.InvFull_() then
            isLumiMine = true
            isDeposit = false 
            BankingForLuminite()
        end
           
            API.RandomSleep2(600,600,600)
    end
end

--end of orikalkum 


API.SetDrawTrackedSkills(true)
while (API.Read_LoopyLoop()) do
 if API.ReadPlayerMovin2() then
    API.RandomSleep2(500,500,400)
    goto continue
 end
 
MiningAtBurthope()
MiningCoalsBarb()
MiningMithVarrock()
MiningAddyRimmy()
MiningAtMiningGuild()


::continue::
idleCheck()
API.RandomSleep2(1200,300,600)
end
