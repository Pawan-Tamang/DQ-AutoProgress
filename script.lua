-- DQ v9 place-aware start
print("[DQ] file started", game.PlaceId)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
repeat task.wait() until Players.LocalPlayer
local LP = Players.LocalPlayer
local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 20) or game:GetService("CoreGui")
print("[DQ] player ready", LP.Name)

local URL = "https://raw.githubusercontent.com/Pawan-Tamang/DQ-AutoProgress/main/script.lua"
pcall(function()
 local code = "repeat task.wait() until game:IsLoaded() loadstring(game:HttpGet('"..URL.."'))()"
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
local st = { name = isDungeon() and "Dungeon" or "Hub", created = false, joined = false, started = false, seen = {}, lastStart = 0 }

local function rem()
 return RS:FindFirstChild("remotes") or RS:FindFirstChild("Remotes")
end
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
 local x = r:FindFirstChild(name)
 if not x then return false end
 local args = {...}
 local ok, err = pcall(function()
  if invoke or x:IsA("RemoteFunction") then x:InvokeServer(unpack(args)) else x:FireServer(unpack(args)) end
 end)
 print("[DQ] remote", name, ok, err)
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
   if (d:IsA("StringValue") or d:IsA("ObjectValue")) and tostring(d.Value):lower() == name:lower() then return true end
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
 for _,n in ipairs(S.Members) do
  callRemote("addPlayerToWhitelist", false, n)
 end
end
local function doCreate()
 if st.created or st.started then return end
 local map, diff = pick()
 st.name = "Creating"
 print("[DQ] create", map, diff)
 if callRemote("createLobby", true, map, diff, 0, S.Hardcore, S.Private, false) then
  st.created = true
  st.name = "Created"
 end
end
local function doStart()
 if tick() - st.lastStart < 5 then return end
 st.lastStart = tick()
 st.started = true
 st.name = "Starting"
 whitelist()
 print("[DQ] startDungeon FireServer")
 callRemote("startDungeon", false)
 task.wait(0.2)
 callRemote("startDungeon", true)
end
local function doJoin()
 if st.joined then return end
 local lobby = hostLobby() if not lobby then return end
 st.name = "Joining"
 if callRemote("joinDungeon", true, lobby.Name) then
  st.joined = true
  st.name = "InParty"
 end
end
local function melee()
 if not S.AutoMelee then return end
 local char = LP.Character if not char then return end
 local hum = char:FindFirstChildOfClass("Humanoid")
 local root = char:FindFirstChild("HumanoidRootPart")
 if not hum or not root then return end
 pcall(function() callRemote("loadPlayerCharacter", false) end)
 local bestM, bestD = nil, 250
 for _,m in ipairs(workspace:GetDescendants()) do
  if m:IsA("Model") and m ~= char then
   local mh = m:FindFirstChildOfClass("Humanoid")
   local mp = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")
   local skip = false
   for _,p in ipairs(Players:GetPlayers()) do if p.Character == m then skip = true end end
   if not skip and mh and mp and mh.Health > 0 then
    local d = (mp.Position - root.Position).Magnitude
    if d < bestD then bestM, bestD = m, d end
   end
  end
 end
 if bestM then
  local t = bestM:FindFirstChild("HumanoidRootPart") or bestM.PrimaryPart
  if t then pcall(function() hum:MoveTo(t.Position) end) end
 end
 local tool = char:FindFirstChildOfClass("Tool") or LP.Backpack:FindFirstChildOfClass("Tool")
 if tool and tool.Parent ~= char then pcall(function() hum:EquipTool(tool) end) end
 tool = char:FindFirstChildOfClass("Tool")
 if tool then pcall(function() tool:Activate() end) end
end

local old = PlayerGui:FindFirstChild("DQAutoProgress") if old then old:Destroy() end
local gui = Instance.new("ScreenGui") gui.Name = "DQAutoProgress" gui.ResetOnSpawn = false
pcall(function() gui.Parent = PlayerGui end)
if not gui.Parent then pcall(function() gui.Parent = game:GetService("CoreGui") end) end
local win = Instance.new("Frame")
win.Size = UDim2.new(0,340,0,360) win.Position = UDim2.new(0,18,0.5,-180)
win.BackgroundColor3 = Color3.fromRGB(16,16,18) win.BorderSizePixel = 0
win.Active = true win.Draggable = true win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0,8)
local top = Instance.new("Frame") top.Size = UDim2.new(1,0,0,32) top.BackgroundColor3 = Color3.fromRGB(22,22,26) top.BorderSizePixel = 0 top.Parent = win
local title = Instance.new("TextLabel") title.Size = UDim2.new(1,-70,1,0) title.BackgroundTransparency = 1
title.Text = "  kuya" title.TextXAlignment = Enum.TextXAlignment.Left title.TextColor3 = Color3.fromRGB(230,230,235)
title.Font = Enum.Font.Gotham title.TextSize = 16 title.Parent = top
local minB = Instance.new("TextButton") minB.Size = UDim2.new(0,28,0,24) minB.Position = UDim2.new(1,-62,0,4)
minB.BackgroundColor3 = Color3.fromRGB(40,40,48) minB.Text = "_" minB.TextColor3 = Color3.new(1,1,1) minB.Parent = top
local open = Instance.new("TextButton") open.Size = UDim2.new(0,70,0,28) open.Position = UDim2.new(0,18,0,18)
open.BackgroundColor3 = Color3.fromRGB(140,90,255) open.Text = "kuya" open.TextColor3 = Color3.new(1,1,1)
open.Visible = false open.Parent = gui
minB.MouseButton1Click:Connect(function() win.Visible = false open.Visible = true end)
open.MouseButton1Click:Connect(function() win.Visible = true open.Visible = false end)
UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Enum.KeyCode.RightShift then win.Visible = not win.Visible open.Visible = not win.Visible end end)
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-16,0,110) status.Position = UDim2.new(0,8,0,40) status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left status.TextYAlignment = Enum.TextYAlignment.Top
status.TextColor3 = Color3.fromRGB(190,190,200) status.Font = Enum.Font.Gotham status.TextSize = 13 status.TextWrapped = true status.Parent = win
local startBtn = Instance.new("TextButton") startBtn.Size = UDim2.new(1,-24,0,28) startBtn.Position = UDim2.new(0,12,1,-40)
startBtn.BackgroundColor3 = Color3.fromRGB(60,140,80) startBtn.Text = "Force Start" startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold startBtn.Parent = win
startBtn.MouseButton1Click:Connect(function() st.lastStart = 0 doStart() end)

local waitT = 0
task.spawn(function()
 while gui.Parent do
  S.HostName = S.HostName
  local map, diff = pick()
  local r = rem()
  local names = {}
  if r then for _,c in ipairs(r:GetChildren()) do table.insert(names, c.Name) end end
  status.Text = string.format("%s\n%s\n%s %s lv%s\nplace=%s dungeon=%s\nremotes=%s",
   LP.Name, st.name, map, diff, tostring(level()), tostring(game.PlaceId), tostring(isDungeon()), table.concat(names, ","))
  task.wait(0.5)
 end
end)

task.spawn(function()
 task.wait(2)
 while gui.Parent do
  if isDungeon() or (not isHub()) then
   st.name = "InDungeon"
   melee()
  elseif isHub() then
   if S.AutoAccept and isHost() and not st.started then
    callRemote("acceptRequest", false)
   end
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
  task.wait(0.4)
 end
end)
print("[DQ] v9 ready place", game.PlaceId)
