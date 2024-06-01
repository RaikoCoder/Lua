---[[
Very Simple Script to Open Geode After Using Free Miner
- Make A preset with all the geode inside then Load the preset. 
-it Will open and load last preset @Burthope Bank
Change Do action to bank u want to use
]]--

local API = require("api")
startTime, afk = os.time(), os.time()
MAX_IDLE_TIME_MINUTES = 5
local ID =  {
Bank = 25688 ,}
local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
end


API.SetDrawTrackedSkills(true)
while (API.Read_LoopyLoop()) do
    idleCheck()
    if API.ReadPlayerMovin2() or API.CheckAnim(20) then
        goto continue
     end
     if API.InvFull_() then
        API.DoAction_Object1(0x33,API.OFF_ACT_GeneralObject_route3,{ ID.Bank },50)
        
    end

    if API.InvItemFound1(44816) and API.Invfreecount_()  > 26 then
        API.DoAction_Inventory1(44816,0,2,API.OFF_ACT_GeneralInterface_route)
    elseif not API.InvItemFound1(44816) then
        API.Write_LoopyLoop(false)
    end
print(API.Invfreecount_())
::continue::
API.RandomSleep2(800,200,400)
end
