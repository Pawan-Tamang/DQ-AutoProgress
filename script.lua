-- DQ v15 level+play+swing
if getgenv and getgenv().DQRunning then return end
if getgenv then getgenv().DQRunning = true end
print("[DQ] v15", game.PlaceId)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
repeat task.wait() until Players.LocalPlayer
local LP = Players.LocalPlayer
local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 20) or game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local URL = "https://raw.githubusercontent.com/Pawan-Tamang/DQ-AutoProgress/main/script.lua"
pcall(function()
 if getgenv and getgenv().DQQueued then return end
 if getgenv then getgenv().DQQueued = true end
 local code = "getgenv().DQRunning=nil getgenv().DQQueued=nil repeat task.wait() until game:IsLoaded() loadstring(game:HttpGet(\"" .. URL .. "\"))()"
 if queue_on_teleport then queue_on_teleport(code)
 elseif syn and syn.queue_on_teleport then syn.queue_on_teleport(code) end
end)

local HUB = { [77649408247578] = true, [115445507767090] = true }
local DUNGEON = 85776757589518
local function isHub() return HUB[game.PlaceId] == true end
local function isDungeon() return game.PlaceId == DUNGEON end

local S = {
 HostName = "kurokazahood", Members = {"royaldancersss"},
 AutoBest = true, Hardcore = true, Private = false,
 WaitMembers = true, AutoCreate = true, AutoJoin = true, AutoStart = true,
 AutoClick = true, AutoReplay = true, Timeout = 25,
}
pcall(function()
 if readfile and isfile and isfile("DQAutoProgress.json") then
  local d = HttpService:JSONDecode(readfile("DQAutoProgress.json"))
  if type(d) == "table" then for k,v in pairs(d) do S[k] = v end end
 end
end)

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
local RUN = "DQRun.json"
local function saveRun(map, diff, lv)
 pcall(function() if writefile then writefile(RUN, HttpService:JSONEncode({map=map,diff=diff,lv=lv,t=os.time()})) end end)
end
local function loadRun()
 local out
 pcall(function() if readfile and isfile and isfile(RUN) then out = HttpService:JSONDecode(readfile(RUN)) end end)
 return type(out) == "table" and out or nil
end

local st = { name = isDungeon() and "InDungeon" or "Hub", created = false, joined = false, started = false, finished = false, seen = {}, lastPlay = 0 }
local function rem() return RS:FindFirstChild("remotes") end

local function levelFromGui()
 local best = 0
 local ps = PlayerGui:FindFirstChild("playerStatus") or PlayerGui:FindFirstChild("PlayerStatus")
 if ps then
  for _,d in ipairs(ps:GetDescendants()) do
   if d.Name:lower() == "level" or d.Name:lower() == "lvl" then
    local n = tonumber(tostring(d.Text or d.Value or ""):match("%d+"))
    if n and n > best then best = n end
   end
  end
 end
 for _,d in ipairs(PlayerGui:GetDescendants()) do
  if d:IsA("TextLabel") or d:IsA("TextButton") then
   local n = string.match(string.lower(d.Text or ""), "level%s*:?%s*(%d+)")
    or string.match(d.Text or "", "^%s*(%d+)%s*$")
   n = tonumber(n)
   if n and n >= 1 and n <= 300 and n > best then
    if d.Name:lower():find("level") or d.Name:lower():find("lvl") then best = n end
   end
  end
 end
 return best
end
local function level()
 local best = 1
 local ls = LP:FindFirstChild("leaderstats")
 if ls then
  local l = ls:FindFirstChild("Level") or ls:FindFirstChild("level") or ls:FindFirstChild("Lvl")
  if l then best = math.max(best, tonumber(l.Value) or 1) end
 end
 best = math.max(best, levelFromGui())
 local run = loadRun()
 if run and tonumber(run.lv) and (tonumber(run.lv) or 0) > best then best = tonumber(run.lv) end
 return best
end
local function pick()
 local lv, cur = level(), PROG[1]
 if S.AutoBest then for _,d in ipairs(PROG) do if lv >= d[2] then cur = d else break end end end
 return cur[1], cur[3], lv
end
local function folder()
 local g = workspace:FindFirstChild("games")
 return g and g:FindFirstChild("inLobby")
end
local function hostLobby()
 local f = folder() if not f then return nil end
 for _,l in ipairs(f:GetChildren()) do if l.Name:lower() == S.HostName:lower() then return l end end
end
local function fireNamed(name, invoke, ...)
 local r = rem() if not r then return false end
 local ev = r:FindFirstChild(name) if not ev then return false end
 local args = {...}
 local ok = pcall(function()
  if invoke or ev:IsA("RemoteFunction") then ev:InvokeServer(unpack(args)) else ev:FireServer(unpack(args)) end
 end)
 if ok then print("[DQ]", name) end
 return ok
end
local function clickText(words)
 for _,o in ipairs(PlayerGui:GetDescendants()) do
  if o:IsA("TextButton") and o.Visible ~= false then
   local t = string.lower((o.Text or "") .. " " .. (o.Name or ""))
   for _,w in ipairs(words) do
    if t == w or string.find(t, w, 1, true) then
     pcall(function()
      if typeof(firesignal) == "function" then firesignal(o.MouseButton1Click) end
      if typeof(getconnections) == "function" then
       for _,c in ipairs(getconnections(o.MouseButton1Click)) do pcall(function() c:Fire() end) end
      end
     end)
     print("[DQ] click", o.Text or o.Name)
     return true
    end
   end
  end
 end
 return false
end
local function clickPlay()
 if tick() - st.lastPlay < 4 then return end
 st.lastPlay = tick()
 return clickText({"play", "play game", "start", "start dungeon"})
end
local function fireStart()
 fireNamed("startDungeon", false)
 clickPlay()
end
local function createLobby()
 local map, diff, lv = pick()
 print("[DQ] create", map, diff, "lv", lv)
 saveRun(map, diff, lv)
 return fireNamed("createLobby", true, map, diff, 0, S.Hardcore, S.Private, false)
end
local function joinHost()
 local lobby = hostLobby() if not lobby then return false end
 print("[DQ] join", lobby.Name)
 return fireNamed("joinDungeon", true, lobby.Name)
end
local function replay()
 print("[DQ] replay")
 return fireNamed("replay", false) or fireNamed("replayDungeon", false) or fireNamed("playAgain", false)
  or clickText({"replay", "play again"})
end
local function memberHere(name)
 if st.seen[name:lower()] then return true end
 for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower() == name:lower() then return true end end
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
local WIN = {"victory","dungeon complete","you win","boss defeated","mission complete"}
local function guiSaysWin()
 for _,o in ipairs(PlayerGui:GetDescendants()) do
  if (o:IsA("TextLabel") or o:IsA("TextButton")) and o.Visible ~= false then
   local t = string.lower(o.Text or "")
   if not string.find(t, "return to lobby", 1, true) then
    for _,w in ipairs(WIN) do if string.find(t, w, 1, true) then return true end end
   end
  end
 end
 return false
end
local function swing()
 if not S.AutoClick or not isDungeon() then return end
 local char = LP.Character if not char then return end
 local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
 local tool = char:FindFirstChildOfClass("Tool")
 if not tool then
  tool = LP.Backpack:FindFirstChildOfClass("Tool")
  if tool then pcall(function() hum:EquipTool(tool) end) task.wait() end
 end
 tool = char:FindFirstChildOfClass("Tool")
 if tool then
  pcall(function() tool:Activate() end)
  pcall(function() tool:Activate() end)
 end
end
local function onFinished()
 if st.finished then return end
 st.finished = true
 print("[DQ] victory")
 st.name = "Replay"
 if isHost() and S.AutoReplay then replay() end
 task.delay(15, function() st.finished = false end)
end

local old = PlayerGui:FindFirstChild("DQAutoProgress") if old then old:Destroy() end
local gui = Instance.new("ScreenGui") gui.Name = "DQAutoProgress" gui.ResetOnSpawn = false
pcall(function() gui.Parent = PlayerGui end)
if not gui.Parent then pcall(function() gui.Parent = game:GetService("CoreGui") end) end
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,330,0,190) frame.Position = UDim2.new(0,16,0.5,-95)
frame.BackgroundColor3 = Color3.fromRGB(16,16,18) frame.BorderSizePixel = 0
frame.Active = true frame.Draggable = true frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
local title = Instance.new("TextLabel") title.Size = UDim2.new(1,-36,0,28) title.BackgroundTransparency = 1
title.Text = "  kuya" title.TextXAlignment = Enum.TextXAlignment.Left title.TextColor3 = Color3.fromRGB(230,230,235)
title.Font = Enum.Font.Gotham title.TextSize = 16 title.Parent = frame
local minB = Instance.new("TextButton") minB.Size = UDim2.new(0,24,0,22) minB.Position = UDim2.new(1,-30,0,4)
minB.BackgroundColor3 = Color3.fromRGB(40,40,48) minB.Text = "_" minB.TextColor3 = Color3.new(1,1,1) minB.Parent = frame
local open = Instance.new("TextButton") open.Size = UDim2.new(0,64,0,26) open.Position = UDim2.new(0,16,0,16)
open.BackgroundColor3 = Color3.fromRGB(140,90,255) open.Text = "kuya" open.TextColor3 = Color3.new(1,1,1)
open.Visible = false open.Parent = gui
minB.MouseButton1Click:Connect(function() frame.Visible = false open.Visible = true end)
open.MouseButton1Click:Connect(function() frame.Visible = true open.Visible = false end)
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-16,0,90) status.Position = UDim2.new(0,8,0,32) status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left status.TextYAlignment = Enum.TextYAlignment.Top
status.TextColor3 = Color3.fromRGB(200,200,210) status.Font = Enum.Font.Gotham status.TextSize = 13 status.TextWrapped = true status.Parent = frame

task.spawn(function()
 while gui.Parent do
  local map, diff, lv = pick()
  status.Text = string.format("%s\n%s\nNEXT %s %s\nlv %s  place %s",
   LP.Name, st.name, map, diff, tostring(lv), tostring(game.PlaceId))
  task.wait(0.4)
 end
end)

if isDungeon() then
 task.spawn(function()
  st.name = "Wait5s"
  task.wait(5)
  st.started = true
  st.name = "StartRemote"
  fireStart()
 end)
 task.spawn(function()
  while gui.Parent and isDungeon() do
   swing()
   task.wait(0.08)
  end
 end)
 task.spawn(function()
  task.wait(25)
  while gui.Parent and isDungeon() do
   if guiSaysWin() then onFinished() end
   task.wait(2)
  end
 end)
else
 local waitT = 0
 task.spawn(function()
  st.name = "WaitLevel"
  for _ = 1, 15 do
   if level() > 1 then break end
   task.wait(0.4)
  end
  print("[DQ] level", level(), pick())
  clickPlay()
  while gui.Parent and isHub() do
   clickPlay()
   if isHost() then
    if S.AutoCreate and not hostLobby() and not st.created then
     if level() <= 1 then st.name = "WaitLevel" else
      st.created = createLobby() or st.created
      st.name = st.created and "Created" or "CreateFail"
     end
    elseif hostLobby() then
     st.created = true
     if S.WaitMembers and not partyReady() and not st.started then
      st.name = "Waiting"
      waitT += 1.2
      if waitT >= S.Timeout then st.started = true fireStart() st.name = "Started" end
     elseif S.AutoStart and not st.started then
      st.started = true fireStart() st.name = "Started"
     end
    end
   else
    if S.AutoJoin and hostLobby() and not st.joined then
     st.joined = joinHost() or st.joined
     st.name = st.joined and "Joined" or "JoinFail"
    elseif st.joined then st.name = "WaitingStart" else st.name = "Looking" end
   end
   task.wait(1.2)
  end
 end)
end
