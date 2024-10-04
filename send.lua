local BotWorld = "RHYFAA9555" -- World Pabrik 
local BotMaker = "6382rhy7828" -- World Pabrik Path Marker 
local SaveWorld = "breakunv" -- Save World 
local SaveMaker = "rhywsrhy" -- Save Path Marker 
local DropDelay = 100 -- Drop Delay
local DropBlock = 20 -- Detector Block Where To Drop 
local BlockID = 880 -- Block ID No Need To Set Seed ID 
local Length = 40 -- Length Of Platform, U Can Use Dirt Tho 
local BreakTile = 3 -- Sometimes Broken Idk 
local PlaceDelay = 150 -- Place Delay 
local BreakDelay = 200 -- Break Delay 
local CollectRadius = 5 -- Collect Radius 
local CollectDelay = 250 -- Collect Delay 
local DelayStatus = 1 -- set delay send webhook [minutes follow real time]
local WebhookUrl = "https://discord.com/api/webhooks/1291787418189434971/_yfbJpUPBEo-Y3Toka987KPvQNpVDakOgH1Qiy52I0zLZPHMVZW3hkea8slyQl9ubJV5" -- set webhook url

local px = math.floor(getLocal().pos.x/32)
local py = math.floor(getLocal().pos.y/32)
local otime = tonumber(os.date("%M") + DelayStatus)
local SavedT = 0
local DNotif = false

function CTime()
	local Match = false
    for counter = 0, 60, DelayStatus do
        if tonumber(os.date("%M")) == counter then
            if DNotif == false then
                Match = true
                SavedT = counter
            end
        elseif tonumber(os.date("%M")) == SavedT+1 then 
        DNotif = false
        end
    end
    return Match
end

function sendw(txt)
	Webhook = {}
	Webhook.username = "Rhy Universe"
	Webhook.avatar_url = "https://cdn.discordapp.com/attachments/1118696532464648257/1291786338105819190/IMG_20240515_211732_946.jpg?ex=67015d47&is=67000bc7&hm=c6dbe6d615bf9228c765e91f02874d123cb18b6f87e256d255816f9c3f8eb573&"
	Webhook.content = txt
	sendWebhook(WebhookUrl, Webhook)
end

function send(txt)
	var = {} var[0] = "OnTextOverlay"
	var[1] = "`4<MuraalDB#2176> : "..txt
	sendVariant(var)
end

function collect(obj)
	local pkt = {}
	pkt.type = 11
	pkt.value = obj.oid
	pkt.x = obj.pos.x
	pkt.y = obj.pos.y
	sendPacketRaw(false, pkt)
end

function Place(id,x , y)
	pkt = {}
	pkt.x = math.floor(getLocal().pos.x/32)*32
	pkt.y = math.floor(getLocal().pos.y/32)*32
	pkt.punchx = x
	pkt.punchy = y
	pkt.type = 3
	pkt.value = id
	sendPacketRaw (false, pkt)
	sleep(PlaceDelay)
	end
	
function Punch(x , y)
	pkt = {}
	pkt.x = math.floor(getLocal().pos.x/32)*32
	pkt.y = math.floor(getLocal().pos.y/32)*32
	pkt.punchx = x
	pkt.punchy = y
	pkt.type = 3
	pkt.value = 18
	sendPacketRaw(false, pkt)
	sleep(BreakDelay)
end

function Drop(id,amount)
	sendPacket(2,"action|drop\n|itemID|"..id)
	sleep(DropDelay*2)
	sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..amount)
	sleep(DropDelay*2)
end

function GoToW(w,p)
	while getWorld().name ~= w:upper() do
		sendPacket(3,"action|join_request\nname|"..w.."|"..p.."\ninvitedWorld|0")
		sleep(1000)
	end
	while checkTile(math.floor(getLocal().pos.x/32), math.floor(getLocal().pos.y/32)).fg == 6 do
		sendPacket(3,"action|join_request\nname|"..w.."|"..p.."\ninvitedWorld|0")
		sleep(1000)
	end
end

function CDropPos(x,y,id)
	local TotalAmount = 0
	for i, v in pairs(getWorldObject()) do
		if math.floor(v.pos.x/32) == x and math.floor(v.pos.y/32) == y then
			if v.id == id then
				TotalAmount = TotalAmount + v.amount
			end
		end
	end
	return TotalAmount
end

function CInv(id)
	for i, v in pairs(getInventory()) do
		if v.id == id then
			return v.amount
		end
	end
end

function CIPos(x,y)
	local CItem = {}
	for i, v in pairs(getWorldObject()) do
		if v.id ~= 0 then
			local xdist = math.abs(x.floor(v.pos.x/32))
			local ydist = math.abs(y.floor(v.pos.y/32))
			if xdist <= CollectRadius and ydist <= CollectRadius then
				table.insert(CItem,v)
			end
		end
	end
	return CItem
end

function CPos(x,y)
	local CItem = CIPos(x,y)
	if #CItem > 0 then
		for i,v in pairs(CItem) do
			collect(v)
		end
		sleep(CollectDelay*#CItem)
	end
end

function CADrop(ATDrop)
	for y = 0, 54 do
		for x = 99, 0, -1 do
			if checkTile(x,y).fg == DropBlock then
				local Float = CDropPos(x,y,BlockID+1)
				if Float <= 2800 then
					sleep(5000)
					findPath(x-1,y)
					sleep(500)
					Drop(BlockID+1,ATDrop)
					return
				end
			end
		end
		sleep(100)
	end
end

local Main = nil 
local Plant = nil 
local Harvest = nil 
local Script = { Main = function()
	local BInt = CInv(BlockID)
	local SInt = CInv(BlockID+1)
	if SInt > 180 then
		GoToW(SaveWorld,SaveMaker)
		sleep(250)
		local ATDrop = SInt - Length * 2
		CADrop(ATDrop)
		GoToW(BotWorld,BotMaker)
		sleep(5000)
		findPath(px,py)
	elseif
		SInt <= 180 then
		if BInt < 10 or CRP() == true or CURP() == true then
			if CRP() == true then
				coroutine.resume(Harvest)
			elseif CURP() == true then
				coroutine.resume(Plant)
				end
		elseif BInt >= 10 or CRP() == false then
			while CInv(BlockID) >= 10 do
				if CTime() == true then
					coroutine.yield()
				end
				if CInv(BlockID+1) > 180 then
					break 
				end findPath(px,py) 
					local Math = math.floor((BreakTile/2)+(BreakTile/(BreakTile*2)))
				for i = 1, BreakTile do 
					Place(BlockID,(px+i),py-1) 
				end 
				for i=1, BreakTile do 
					while checkTile((px+i),py-1).fg ~= 0 do 
						if CTime() == true then
							coroutine.yield()
						end 
						Punch((px+i),py-1) 
					end 
				end 
				for i=0, BreakTile do 
					CPos((px+i),py-1) 
				end 
			end 
		end 
	end 
end 

Plant = function()
	for i = 1, Length do 
		while checkTile(px+i, py).fg ~= BlockID+1 do 
			if CTime() == true then 
				coroutine.yield() 
			end 
			if CInv(BlockID+1) == 1 then 
				local cx = math.floor(getLocal().pos.x/32) 
				for i=cx,0,-1 do 
					findPath(px+i,py) 
					sleep(200) 
				end 
				break 
			end 
			findPath(px+i,py) 
			Place(BlockID+1,px+i, py)
		end 
	end 
	for i = Length, 0, -1 do 
		findPath(px+i,py)
		sleep(200) 
	end 
end 

Harvest = function() 
	local done = false 
	for i = 1, Length do 
		if done == false then 
			if checkTile(px+i,py).fg == 0 then 
				findPath(px+i,py) 
				sleep(200) 
			else
				done = true 
			end 
		end 
	end 
		for i = 1, Length do 
			if checkTile(px+i,py).fg == BlockID+1 and getExtraTile(px+i,py).ready == false then 
				while getExtraTile(px+i,py).ready == false do 
					if CTime() == true then 
						coroutine.yield() 
					end 
					sleep(1000) 
				end 
			end 
			while checkTile(px+i,py).fg == BlockID+1 and getExtraTile(px+i,py).ready == true do 
				if CTime() == true then
					coroutine.yield()
				end 
				if CInv(BlockID) > 180 then 
					local cx = math.floor(getLocal().pos.x/32) 
					for i=cx,0,-1 do 
						findPath(px+i,py) 
						sleep(200) 
					end 
					break 
				end 
				findPath(px+i,py)
				Punch(px+i,py)
				CPos(px+i,py) 
			end 
		end 
		for i = Length, 0, -1 do 
			findPath(px+i,py) 
			sleep(200) 
		end 
end } Main = coroutine.create(Script.Main) 
	Plant = coroutine.create(Script.Plant) 
	Harvest = coroutine.create(Script.Harvest)

function CURP() 
	if CInv(BlockID) > 180 then 
		return false 
	end 
	for i = 1, Length do 
		if checkTile(px+i,py).fg ~= BlockID+1 then 
			return true 
		end 
	end 
	return false 
end 

function CRP() 
	if CInv(BlockID) > 180 then 
		return false 
	end 
	for i=1, Length do 
		if getExtraTile(px+i,py).ready == true then 
			return true 
		end 
	end 
	return false 
end 

send("Script Made By @AKM?")
sleep(2000)
send("Do Not Resell Script!")
sleep(1000)

while true do 
	if CTime() == true then 
		sendw(getLocal().name.." : Seed <["..CInv(BlockID+1).." Seed!]>") 
		DNotif = true 
	end 
	if coroutine.status(Plant) == "dead" then 
		Plant = coroutine.create(Script.Plant)
	end 
	if coroutine.status(Harvest) == "dead" then 
		Harvest = coroutine.create(Script.Harvest) 
	end 
	if coroutine.status(Main) == "dead" then 
		Main = coroutine.create(Script.Main) 
	end 
	coroutine.resume(Main) 
end
