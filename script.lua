-- DQ v10 no character reset
print("[DQ] file started", game.PlaceId)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
repeat task.wait() until Players.LocalPlayer
local LP = Players.LocalPlayer
local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 20) or game:GetService("CoreGui")
print("[DQ] player ready", LP.Name)

local URL = "https://raw.githubusercontent.com/Pawan-Tamang/DQ-AutoProgress/main/script.lua"
pcall(function()
 local code = "repeat task.wait() until game:IsLoaded() loadstring(game:HttpGet(\"" .. URL .. "\"))()"
 if queue_on_teleport then queue_on_teleport(code)
 elseif syn and syn.queue_on_teleport then syn.queue_on_teleport(code) end
end)

local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local HUB_PLACES = { [77649408247578] = true, [115445507767090] = true }
local DUNGEON_PLACE = 85776757589518
local function isDungeon() return game.PlaceId == DUNGEON_PLACE end
local function isHub() return HUB_PLACES[game.PlaceId] == true end

local S = {
 HostName = "kurokazahood", Members = {"royaldancersss"},
 AutoBest = true, Hardcore = true, Private = false,
 WaitMembers = true, AutoAccept = true,
 AutoCreate = true, AutoJoin = true, AutoStart = true,
 AutoMelee = true, Timeout = 25,
}
pcall(function()
 if readfile and isfile and isfile("DQAutoProgress.json") then
  local d = HttpService:JSONDecode(readfile("DQAutoProgress.json"))
  if type(d) == "table" then for k,v in pairs(d) do S[k] = v end end
 end
end)
local function save() pcall(function() if writefile then writefile("DQAutoProgress.json", HttpService:JSONEncode(S)) end end) end

local PROG = {
 {"Desert Temple",1,"Easy"},{"Desert Temple",6,"Medium"},{"Desert Temple",12,"Hard"},
 {"Desert Temple",20,"Insane"},{"Desert Temple",27,"Nightmare"},
 {"Winter Outpost",33,"Easy"},{"Winter Outpost",40,"Medium"},{"Winter Outpost",45,"Hard"},
 {"Winter Outpost",50,"Insane"},{"Winter Outpost",55,"Nightmare"},
 {"Pirate Island",60,"Insane"},{"Pirate Island",65,"Nightmare"},
 {"King's Castle",70,"Insane"},{"King's Castle",75,"Nightmare"},
 {"The Underworld",80,"Insane"},{"The Underworld",85,"Nightmare"},
 {"Samurai Palace",90,"Insane"},{"Samurai Palace",95,"Nightmare"},
 {"The Canals",100,"Insane"},{"The Canals",105,"Nightmare"},
 {"Ghastly Harbor",110,"Insane"},{"Ghastly Harbor",115,"Nightmare"},
 {"Steampunk Sewers",120,"Insane"},{"Steampunk Sewers",125,"Nightmare"},
 {"Orbital Outpost",140,"Insane"},{"Orbital Outpost",145,"Nightmare"},
 {"Volcanic Chambers",150,"Insane"},{"Volcanic Chambers",155,"Nightmare"},
 {"Aquatic Temple",160,"Insane"},{"Aquatic Temple",165,"Nightmare"},
 {"Enchanted Forest",170,"Insane"},{"Enchanted Forest",175,"Nightmare"},
 {"Northern Lands",180,"Insane"},{"Northern Lands",185,"Nightmare"},
}
local st = { name = isDungeon() and "Dungeon" or "Hub", created = false, joined = false, started = false, seen = {}, lastStart = 0, lastMobPrint = 0 }

local function rem() return RS:FindFirstChild("remotes") or RS:FindFirstChild("Remotes") end
local function level()
 local ls = LP:FindFirstChild("leaderstats")
 if ls and ls:FindFirstChild("Level") then return tonumber(ls.Level.Value) or 1 end
 return 1
end
local function pick()
 local lv, cur = level(), PROG[1]
 if S.AutoBest then for _,d in ipairs(PROG) do if lv >= d[2] then cur = d else break end end end
 return cur[1], cur[3]
end
local function lobbyFolder()
 local g = workspace:FindFirstChild("games")
 return g and g:FindFirstChild("inLobby")
end
local function hostLobby()
 local f = lobbyFolder() if not f then return nil end
 for _,l in ipairs(f:GetChildren()) do if l.Name:lower() == S.HostName:lower() then return l end end
 return nil
end
local function callRemote(name, invoke, ...)
 local r = rem() if not r then return false end
 local x = r:FindFirstChild(name) if not x then return false end
 local args = {...}
 local ok, err = pcall(function()
  if invoke or x:IsA("RemoteFunction") then x:InvokeServer(unpack(args)) else x:FireServer(unpack(args)) end
 end)
 print("[DQ] remote", name, ok, tostring(err))
 return ok
end
local function parse(t)
 local a = {} for n in string.gmatch(t or "", "[^,%s]+") do table.insert(a,n) end return a
end
local function memberHere(name)
 if st.seen[name:lower()] then return true end
 for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower() == name:lower() then return true end end
 local lobby = hostLobby()
 if lobby then
  for _,d in ipairs(lobby:GetDescendants()) do
   if d.Name:lower() == name:lower() then return true end
  end
 end
 return false
end
local function partyReady()
 if not S.WaitMembers or #S.Members == 0 then return true end
 for _,n in ipairs(S.Members) do if not memberHere(n) then return false end end
 return true
end
pcall(function()
 PlayerGui.DescendantAdded:Connect(function(o)
  if o:IsA("TextLabel") or o:IsA("TextButton") then
   local a = string.match(string.lower(o.Text or ""), "player added to lobby:%s*(%S+)")
   if a then st.seen[a] = true end
  end
 end)
end)
local function isHost() return LP.Name:lower() == S.HostName:lower() end
local function whitelist()
 for _,n in ipairs(S.Members) do callRemote("addPlayerToWhitelist", false, n) end
end
local function doCreate()
 if st.created or st.started then return end
 local map, diff = pick()
 st.name = "Creating"
 if callRemote("createLobby", true, map, diff, 0, S.Hardcore, S.Private, false) then
  st.created = true st.name = "Created"
 end
end
local function doStart()
 if tick() - st.lastStart < 5 then return end
 st.lastStart = tick() st.started = true st.name = "Starting"
 whitelist()
 callRemote("startDungeon", false)
end
local function doJoin()
 if st.joined then return end
 local lobby = hostLobby() if not lobby then return end
 if callRemote("joinDungeon", true, lobby.Name) then st.joined = true st.name = "InParty" end
end

local function isPlayerChar(model)
 for _,p in ipairs(Players:GetPlayers()) do
  if p.Character == model or p.Name == model.Name then return true end
 end
 return false
end
local function getMob()
 local char = LP.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 if not root then return nil end
 local best, bestD = nil, 400
 for _,m in ipairs(workspace:GetDescendants()) do
  if m:IsA("Model") and not isPlayerChar(m) then
   local hum = m:FindFirstChildOfClass("Humanoid")
   local part = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
   if hum and part and hum.Health > 0 and hum.Health < 1e8 then
    local d = (part.Position - root.Position).Magnitude
    if d < bestD then best, bestD = m, d end
   end
  end
 end
 return best, bestD
end
local function melee()
 if not S.AutoMelee then return end
 local char = LP.Character if not char then return end
 local hum = char:FindFirstChildOfClass("Humanoid")
 local root = char:FindFirstChild("HumanoidRootPart")
 if not hum or not root then return end
 local mob, dist = getMob()
 if mob then
  if tick() - st.lastMobPrint > 3 then
   st.lastMobPrint = tick()
   print("[DQ] target", mob.Name, math.floor(dist))
  end
  st.name = "Fight " .. mob.Name
  local part = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
  if part then
   pcall(function()
    hum:MoveTo(part.Position)
    root.CFrame = CFrame.new(root.Position, Vector3.new(part.Position.X, root.Position.Y, part.Position.Z))
   end)
  end
 else
  st.name = "NoMob"
 end
 local tool = char:FindFirstChildOfClass("Tool")
 if not tool then
  tool = LP.Backpack:FindFirstChildOfClass("Tool")
  if tool then pcall(function() hum:EquipTool(tool) end) end
 end
 tool = char:FindFirstChildOfClass("Tool")
 if tool then pcall(function() tool:Activate() end) end
end

local old = PlayerGui:FindFirstChild("DQAutoProgress") if old then old:Destroy() end
local gui = Instance.new("ScreenGui") gui.Name = "DQAutoProgress" gui.ResetOnSpawn = false
pcall(function() gui.Parent = PlayerGui end)
if not gui.Parent then pcall(function() gui.Parent = game:GetService("CoreGui") end) end
local win = Instance.new("Frame")
win.Size = UDim2.new(0,340,0,220) win.Position = UDim2.new(0,18,0.5,-110)
win.BackgroundColor3 = Color3.fromRGB(16,16,18) win.BorderSizePixel = 0
win.Active = true win.Draggable = true win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0,8)
local title = Instance.new("TextLabel") title.Size = UDim2.new(1,-40,0,28) title.BackgroundTransparency = 1
title.Text = "  kuya" title.TextXAlignment = Enum.TextXAlignment.Left title.TextColor3 = Color3.fromRGB(230,230,235)
title.Font = Enum.Font.Gotham title.TextSize = 16 title.Parent = win
local minB = Instance.new("TextButton") minB.Size = UDim2.new(0,28,0,24) minB.Position = UDim2.new(1,-34,0,4)
minB.BackgroundColor3 = Color3.fromRGB(40,40,48) minB.Text = "_" minB.TextColor3 = Color3.new(1,1,1) minB.Parent = win
local open = Instance.new("TextButton") open.Size = UDim2.new(0,70,0,28) open.Position = UDim2.new(0,18,0,18)
open.BackgroundColor3 = Color3.fromRGB(140,90,255) open.Text = "kuya" open.TextColor3 = Color3.new(1,1,1)
open.Visible = false open.Parent = gui
minB.MouseButton1Click:Connect(function() win.Visible = false open.Visible = true end)
open.MouseButton1Click:Connect(function() win.Visible = true open.Visible = false end)
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-16,1,-40) status.Position = UDim2.new(0,8,0,32) status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left status.TextYAlignment = Enum.TextYAlignment.Top
status.TextColor3 = Color3.fromRGB(190,190,200) status.Font = Enum.Font.Gotham status.TextSize = 13 status.TextWrapped = true status.Parent = win

local waitT = 0
task.spawn(function()
 while gui.Parent do
  local map, diff = pick()
  status.Text = string.format("%s\n%s\n%s %s lv%s\nplace=%s dungeon=%s",
   LP.Name, st.name, map, diff, tostring(level()), tostring(game.PlaceId), tostring(isDungeon()))
  task.wait(0.4)
 end
end)

task.spawn(function()
 task.wait(1)
 while gui.Parent do
  if isDungeon() then
   melee()
  elseif isHub() then
   if isHost() then
    if S.AutoCreate and not hostLobby() and not st.created then
     doCreate()
    elseif hostLobby() then
     st.created = true
     whitelist()
     if S.WaitMembers and not partyReady() and not st.started then
      st.name = "Waiting"
      waitT += 1
      if waitT >= S.Timeout then doStart() end
     elseif S.AutoStart then
      doStart()
     end
    end
   else
    if S.AutoJoin and hostLobby() and not st.joined then doJoin()
    elseif st.joined then st.name = "InParty" else st.name = "Looking" end
   end
  end
  task.wait(0.25)
 end
end)
print("[DQ] v10 ready", game.PlaceId)
