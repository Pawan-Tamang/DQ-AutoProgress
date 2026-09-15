-- DQ v8 start inside dungeon
print("[DQ] file started")
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
local VirtualInput = game:GetService("VirtualInputManager")
local HUB = { [77649408247578] = true, [115445507767090] = true }
local function lobbyFolder()
 local g = workspace:FindFirstChild("games")
 return g and g:FindFirstChild("inLobby")
end
-- Hub only if we can still see the town lobby list
local function isHub()
 return lobbyFolder() ~= nil
end
local MARK = "DQWasDungeon.txt"
local function markDungeon()
 pcall(function() if writefile then writefile(MARK, tostring(os.time())) end end)
end
local function cameFromDungeon()
 local yes = false
 pcall(function() if isfile and isfile(MARK) then yes = true if delfile then delfile(MARK) end end end)
 return yes
end

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
local st = { name = isHub() and "Hub" or "Dungeon", created = false, joined = false, started = false, seen = {}, lastStart = 0 }
if isHub() and cameFromDungeon() then st.name = "NextBest" print("[DQ] back from dungeon") end
if not isHub() then markDungeon() end

local function rem() return RS:FindFirstChild("remotes") end
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
local function hostLobby()
 local f = lobbyFolder() if not f then return nil end
 for _,l in ipairs(f:GetChildren()) do if l.Name:lower() == S.HostName:lower() then return l end end
 return nil
end
local function fire(list, inv)
 local r = rem() if not r then return false end
 for _,n in ipairs(list) do
  local x = r:FindFirstChild(n)
  if x then
   local ok = pcall(function()
    if inv and x:IsA("RemoteFunction") then x:InvokeServer() else x:FireServer() end
   end)
   if ok then print("[DQ] fired", n, inv and "invoke" or "fire") return true end
  end
 end
 return false
end
local function clickStartButtons()
 local words = {"start","start dungeon","start game","begin","play","ready"}
 for _,obj in ipairs(PlayerGui:GetDescendants()) do
  if obj:IsA("TextButton") or obj:IsA("ImageButton") then
   local t = string.lower((obj.Text or "") .. " " .. (obj.Name or ""))
   for _,w in ipairs(words) do
    if string.find(t, w, 1, true) then
     pcall(function()
      if typeof(firesignal) == "function" then firesignal(obj.MouseButton1Click) end
      if typeof(getconnections) == "function" then
       for _,c in ipairs(getconnections(obj.MouseButton1Click)) do pcall(function() c:Fire() end) end
      end
      local p = obj.AbsolutePosition
      local s = obj.AbsoluteSize
      VirtualInput:SendMouseButtonEvent(p.X + s.X/2, p.Y + s.Y/2, 0, true, game, 1)
      VirtualInput:SendMouseButtonEvent(p.X + s.X/2, p.Y + s.Y/2, 0, false, game, 1)
     end)
     print("[DQ] clicked", obj.Name, obj.Text)
     return true
    end
   end
  end
 end
 return false
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
local STARTS = {"startDungeon","startGame","beginDungeon","start","playDungeon"}
local function doCreate()
 if st.created or st.started then return end
 local r = rem() if not r then return end
 local c = r:FindFirstChild("createLobby") if not c then return end
 local map, diff = pick()
 st.name = "Creating"
 print("[DQ] create", map, diff, "lv", level())
 local ok = pcall(function() c:InvokeServer(map, diff, 0, S.Hardcore, S.Private, false) end)
 if ok then st.created = true st.name = "Created" end
end
local function doStart()
 if tick() - st.lastStart < 4 then return end
 st.lastStart = tick()
 st.started = true
 st.name = "Starting"
 print("[DQ] start")
 fire(STARTS, false)
 fire(STARTS, true)
 clickStartButtons()
end
local function doJoin()
 if st.joined then return end
 local r = rem() if not r then return end
 local j = r:FindFirstChild("joinDungeon") if not j then return end
 local lobby = hostLobby() if not lobby then return end
 st.name = "Joining"
 print("[DQ] join", lobby.Name)
 local ok = pcall(function() j:InvokeServer(lobby.Name) end)
 if ok then st.joined = true st.name = "InParty" end
end
local function melee()
 if not S.AutoMelee then return end
 local char = LP.Character if not char then return end
 local hum = char:FindFirstChildOfClass("Humanoid")
 local root = char:FindFirstChild("HumanoidRootPart")
 if not hum or not root then return end
 local bestM, bestD = nil, 220
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
 else
  pcall(function() hum:Move(Vector3.new(0,0,-1), true) end)
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
win.Size = UDim2.new(0,340,0,420) win.Position = UDim2.new(0,18,0.5,-210)
win.BackgroundColor3 = Color3.fromRGB(16,16,18) win.BorderSizePixel = 0
win.Active = true win.Draggable = true win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0,8)
local top = Instance.new("Frame") top.Size = UDim2.new(1,0,0,32) top.BackgroundColor3 = Color3.fromRGB(22,22,26) top.BorderSizePixel = 0 top.Parent = win
local title = Instance.new("TextLabel") title.Size = UDim2.new(1,-70,1,0) title.BackgroundTransparency = 1
title.Text = "  kuya" title.TextXAlignment = Enum.TextXAlignment.Left title.TextColor3 = Color3.fromRGB(230,230,235)
title.Font = Enum.Font.Gotham title.TextSize = 16 title.Parent = top
local function icon(txt,x,col)
 local b = Instance.new("TextButton") b.Size = UDim2.new(0,28,0,24) b.Position = UDim2.new(1,x,0,4)
 b.BackgroundColor3 = col b.Text = txt b.TextColor3 = Color3.new(1,1,1) b.Font = Enum.Font.GothamBold b.TextSize = 14 b.Parent = top
 Instance.new("UICorner", b).CornerRadius = UDim.new(0,4) return b
end
local minB = icon("_",-62,Color3.fromRGB(40,40,48))
local xB = icon("x",-30,Color3.fromRGB(80,40,40))
local open = Instance.new("TextButton") open.Size = UDim2.new(0,70,0,28) open.Position = UDim2.new(0,18,0,18)
open.BackgroundColor3 = Color3.fromRGB(140,90,255) open.Text = "kuya" open.TextColor3 = Color3.new(1,1,1)
open.Font = Enum.Font.GothamBold open.TextSize = 14 open.Visible = false open.Parent = gui
Instance.new("UICorner", open).CornerRadius = UDim.new(0,6)
local function show(v) win.Visible = v open.Visible = not v end
minB.MouseButton1Click:Connect(function() show(false) end)
xB.MouseButton1Click:Connect(function() show(false) end)
open.MouseButton1Click:Connect(function() show(true) end)
UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Enum.KeyCode.RightShift then show(not win.Visible) end end)
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-16,0,88) status.Position = UDim2.new(0,8,0,40) status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left status.TextYAlignment = Enum.TextYAlignment.Top
status.TextColor3 = Color3.fromRGB(190,190,200) status.Font = Enum.Font.Gotham status.TextSize = 13 status.TextWrapped = true status.Parent = win
local y = 132
local function tog(label,key)
 local b = Instance.new("TextButton") b.Size = UDim2.new(1,-24,0,24) b.Position = UDim2.new(0,12,0,y)
 b.BackgroundColor3 = S[key] and Color3.fromRGB(140,90,255) or Color3.fromRGB(50,50,56)
 b.Text = label b.TextColor3 = Color3.fromRGB(230,230,235) b.Font = Enum.Font.Gotham b.TextSize = 12 b.Parent = win
 Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
 b.MouseButton1Click:Connect(function() S[key] = not S[key] b.BackgroundColor3 = S[key] and Color3.fromRGB(140,90,255) or Color3.fromRGB(50,50,56) save() end)
 y += 28
end
tog("Auto Best", "AutoBest") tog("Hardcore", "Hardcore") tog("Wait For Members", "WaitMembers")
tog("Auto Create (host)", "AutoCreate") tog("Auto Join (alts)", "AutoJoin") tog("Auto Start (host)", "AutoStart")
local hostBox = Instance.new("TextBox") hostBox.Size = UDim2.new(1,-24,0,24) hostBox.Position = UDim2.new(0,12,0,y)
hostBox.BackgroundColor3 = Color3.fromRGB(32,32,36) hostBox.Text = S.HostName hostBox.TextColor3 = Color3.fromRGB(230,230,235)
hostBox.Font = Enum.Font.Gotham hostBox.TextSize = 12 hostBox.Parent = win y += 30
local memBox = Instance.new("TextBox") memBox.Size = UDim2.new(1,-24,0,24) memBox.Position = UDim2.new(0,12,0,y)
memBox.BackgroundColor3 = Color3.fromRGB(32,32,36) memBox.Text = table.concat(S.Members, ", ") memBox.TextColor3 = Color3.fromRGB(230,230,235)
memBox.Font = Enum.Font.Gotham memBox.TextSize = 12 memBox.Parent = win y += 34
local startBtn = Instance.new("TextButton") startBtn.Size = UDim2.new(1,-24,0,28) startBtn.Position = UDim2.new(0,12,0,y)
startBtn.BackgroundColor3 = Color3.fromRGB(60,140,80) startBtn.Text = "Start Once" startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold startBtn.TextSize = 13 startBtn.Parent = win
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,4)
startBtn.MouseButton1Click:Connect(function() st.lastStart = 0 doStart() end)

local waitT = 0
task.spawn(function()
 while gui.Parent do
  S.HostName = hostBox.Text:gsub("%s+","")
  S.Members = parse(memBox.Text)
  local map, diff = pick()
  status.Text = string.format("%s\n%s\nNEXT %s %s  lv %s\nhub=%s place=%s",
   LP.Name, st.name, map, diff, tostring(level()), tostring(isHub()), tostring(game.PlaceId))
  task.wait(0.4)
 end
end)

task.spawn(function()
 task.wait(2)
 while gui.Parent do
  if not isHub() then
   st.name = "InDungeon"
   markDungeon()
   if S.AutoStart then doStart() end
   melee()
  else
   if S.AutoAccept and isHost() and not st.started then
    fire({"acceptRequest","acceptJoin","acceptJoinRequest"}, false)
   end
   if isHost() then
    if S.AutoCreate and not hostLobby() and not st.created and not st.started then
     doCreate()
    elseif hostLobby() then
     st.created = true
     if S.WaitMembers and not partyReady() and not st.started then
      st.name = "Waiting"
      waitT += 1
      if waitT >= S.Timeout and S.AutoStart then doStart() end
     elseif S.AutoStart then
      doStart()
     end
    end
   else
    if S.AutoJoin and hostLobby() and not st.joined then
     doJoin()
    elseif st.joined then st.name = "InParty" else st.name = "Looking" end
   end
  end
  task.wait(0.4)
 end
end)
print("[DQ] v8 ready")
