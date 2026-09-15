-- DQ AutoProgress v3: no rejoin loop + start + minimize
if getgenv then getgenv().DQAutoProgressQueued = true end
local LOADER = [[if not game:IsLoaded() then game.Loaded:Wait() end loadstring(game:HttpGet("https://raw.githubusercontent.com/Pawan-Tamang/DQ-AutoProgress/main/script.lua"))()]]
pcall(function()
 if queue_on_teleport then queue_on_teleport(LOADER)
 elseif syn and syn.queue_on_teleport then syn.queue_on_teleport(LOADER) end
end)

task.spawn(function()
 if not game:IsLoaded() then repeat task.wait() until game:IsLoaded() end
 task.wait(2)
 local Players = game:GetService("Players")
 local RS = game:GetService("ReplicatedStorage")
 local UIS = game:GetService("UserInputService")
 local HttpService = game:GetService("HttpService")
 local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()
 local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 15)
 if not PlayerGui then return end

 local SAVE_FILE = "DQAutoProgress.json"
 local Settings = {
  HostName = "kurokazahood",
  RequiredPlayers = {"royaldancersss"},
  AutoBest = true, Hardcore = true, Private = false,
  WaitForMembers = true, AutoAccept = true,
  WaitTimeout = 45, AutoStart = true, AutoStartDungeon = true,
  AutoReplay = false, AutoMelee = true,
 }
 pcall(function()
  if writefile and readfile and isfile and isfile(SAVE_FILE) then
   local data = HttpService:JSONDecode(readfile(SAVE_FILE))
   if type(data) == "table" then for k,v in pairs(data) do Settings[k] = v end end
  end
 end)
 local function saveSettings()
  pcall(function() if writefile then writefile(SAVE_FILE, HttpService:JSONEncode(Settings)) end end)
 end

 local PROG = {
  {"Desert Temple",1,"Easy"},{"Desert Temple",6,"Medium"},{"Desert Temple",12,"Hard"},
  {"Desert Temple",20,"Insane"},{"Desert Temple",27,"Nightmare"},
  {"Winter Outpost",30,"Insane"},{"Winter Outpost",55,"Nightmare"},
  {"Pirate Island",60,"Insane"},{"Pirate Island",65,"Nightmare"},
  {"King's Castle",70,"Insane"},{"King's Castle",75,"Nightmare"},
  {"The Underworld",80,"Insane"},{"The Underworld",85,"Nightmare"},
  {"Samurai Palace",90,"Insane"},{"Samurai Palace",110,"Nightmare"},
  {"Ghastly Harbor",120,"Insane"},
  {"Enchanted Forest",170,"Insane"},{"Enchanted Forest",175,"Nightmare"},
  {"Northern Lands",180,"Insane"},{"Northern Lands",185,"Nightmare"},
 }
 local State, joinedOnce, lobbySeen, lastCreate, lastStart, lastJoin = "Idle", false, {}, 0, 0, 0

 local function remotes() return RS:FindFirstChild("remotes") end
 local function lvl()
  local ls = LP:FindFirstChild("leaderstats")
  if ls and ls:FindFirstChild("Level") then return tonumber(ls.Level.Value) or 1 end
  return 1
 end
 local function best()
  local level, cur = lvl(), PROG[1]
  if Settings.AutoBest then
   for _,d in ipairs(PROG) do if level >= d[2] then cur = d else break end end
  end
  return cur[1], cur[3]
 end
 local function fire(names, invoke)
  local r = remotes() if not r then return false end
  for _,n in ipairs(names) do
   local rem = r:FindFirstChild(n)
   if rem then
    local ok = pcall(function()
     if invoke and rem:IsA("RemoteFunction") then rem:InvokeServer() else rem:FireServer() end
    end)
    if ok then return true, n end
   end
  end
  return false
 end
 local function inLobbyFolder()
  local g = workspace:FindFirstChild("games")
  return g and g:FindFirstChild("inLobby")
 end
 local function hostLobby()
  local f = inLobbyFolder() if not f then return nil end
  for _,l in ipairs(f:GetChildren()) do
   if l.Name:lower() == Settings.HostName:lower() then return l end
  end
  return nil
 end
 local LOBBY = {[77649408247578]=true,[115445507767090]=true}
 local function inHub()
  if LOBBY[game.PlaceId] then return true end
  return inLobbyFolder() ~= nil
 end
 local function parse(text)
  local t = {}
  for n in string.gmatch(text or "", "[^,%s]+") do table.insert(t,n) end
  return t
 end
 local function memberIn(name)
  if lobbySeen[name:lower()] then return true end
  local lobby = hostLobby()
  if lobby then
   if lobby.Name:lower() == name:lower() then return true end
   for _,d in ipairs(lobby:GetDescendants()) do
    if d.Name:lower() == name:lower() then return true end
    if (d:IsA("StringValue") or d:IsA("ObjectValue")) and tostring(d.Value):lower() == name:lower() then return true end
   end
  end
  for _,p in ipairs(Players:GetPlayers()) do
   if p.Name:lower() == name:lower() then return true end
  end
  return false
 end
 local function allIn()
  if not Settings.WaitForMembers or #Settings.RequiredPlayers == 0 then return true end
  for _,n in ipairs(Settings.RequiredPlayers) do if not memberIn(n) then return false end end
  return true
 end
 pcall(function()
  PlayerGui.DescendantAdded:Connect(function(obj)
   if obj:IsA("TextLabel") or obj:IsA("TextButton") then
    local a = string.match(string.lower(obj.Text or ""), "player added to lobby:%s*(%S+)")
    if a then lobbySeen[a] = true end
   end
  end)
 end)

 local function clickNamed(words)
  for _,obj in ipairs(PlayerGui:GetDescendants()) do
   if obj:IsA("TextButton") then
    local t = string.lower(obj.Text or obj.Name or "")
    for _,w in ipairs(words) do
     if t == w or string.find(t, w, 1, true) then
      pcall(function()
       if typeof(firesignal) == "function" then firesignal(obj.MouseButton1Click) end
      end)
      return true
     end
    end
   end
  end
  return false
 end

 local function createLobby()
  if tick() - lastCreate < 8 then return false end
  lastCreate = tick()
  local r = remotes() if not r then return false end
  local c = r:FindFirstChild("createLobby") if not c then return false end
  local map, diff = best()
  print("[Host] create", map, diff, "lvl", lvl())
  State = "Creating"
  return pcall(function() c:InvokeServer(map, diff, 0, Settings.Hardcore, Settings.Private, false) end)
 end

 local function startDungeon()
  if tick() - lastStart < 8 then return false end
  lastStart = tick()
  State = "Starting"
  print("[Host] starting dungeon")
  local ok = fire({"startDungeon","startGame","startLobby","beginDungeon"}, false)
    or fire({"startDungeon","startGame","startLobby","beginDungeon"}, true)
    or clickNamed({"start","start dungeon","start game"})
  return ok
 end

 local function joinHost()
  if tick() - lastJoin < 6 then return false end
  lastJoin = tick()
  local r = remotes() if not r then return false end
  local j = r:FindFirstChild("joinDungeon") if not j then return false end
  local lobby = hostLobby() if not lobby then return false end
  State = "Joining"
  local ok = pcall(function() j:InvokeServer(lobby.Name) end)
  if ok then print("[Joiner] joined", Settings.HostName) joinedOnce = true State = "InLobby" end
  return ok
 end

 local function accept()
  if not Settings.AutoAccept then return end
  fire({"acceptRequest","acceptJoin","acceptJoinRequest","acceptPlayer"}, false)
 end

 -- GUI
 local old = PlayerGui:FindFirstChild("DQAutoProgress") if old then old:Destroy() end
 local gui = Instance.new("ScreenGui") gui.Name = "DQAutoProgress" gui.ResetOnSpawn = false gui.Parent = PlayerGui
 local Window = Instance.new("Frame")
 Window.Size = UDim2.new(0, 360, 0, 520)
 Window.Position = UDim2.new(0, 20, 0.5, -260)
 Window.BackgroundColor3 = Color3.fromRGB(16,16,18)
 Window.BorderSizePixel = 0
 Window.Active = true
 Window.Draggable = true
 Window.Parent = gui
 Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 8)

 local Top = Instance.new("Frame")
 Top.Size = UDim2.new(1, 0, 0, 32)
 Top.BackgroundColor3 = Color3.fromRGB(22,22,26)
 Top.BorderSizePixel = 0
 Top.Parent = Window
 local Title = Instance.new("TextLabel")
 Title.Size = UDim2.new(1, -70, 1, 0)
 Title.BackgroundTransparency = 1
 Title.Text = "  kuya"
 Title.TextXAlignment = Enum.TextXAlignment.Left
 Title.TextColor3 = Color3.fromRGB(230,230,235)
 Title.Font = Enum.Font.Gotham
 Title.TextSize = 16
 Title.Parent = Top
 local MinBtn = Instance.new("TextButton")
 MinBtn.Size = UDim2.new(0, 28, 0, 24)
 MinBtn.Position = UDim2.new(1, -62, 0, 4)
 MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,48)
 MinBtn.Text = "_"
 MinBtn.TextColor3 = Color3.fromRGB(230,230,235)
 MinBtn.Font = Enum.Font.GothamBold
 MinBtn.TextSize = 16
 MinBtn.Parent = Top
 Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
 local CloseBtn = Instance.new("TextButton")
 CloseBtn.Size = UDim2.new(0, 28, 0, 24)
 CloseBtn.Position = UDim2.new(1, -30, 0, 4)
 CloseBtn.BackgroundColor3 = Color3.fromRGB(80,40,40)
 CloseBtn.Text = "x"
 CloseBtn.TextColor3 = Color3.fromRGB(230,230,235)
 CloseBtn.Font = Enum.Font.GothamBold
 CloseBtn.TextSize = 14
 CloseBtn.Parent = Top
 Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

 local OpenBtn = Instance.new("TextButton")
 OpenBtn.Size = UDim2.new(0, 70, 0, 28)
 OpenBtn.Position = UDim2.new(0, 20, 0, 20)
 OpenBtn.BackgroundColor3 = Color3.fromRGB(140,90,255)
 OpenBtn.Text = "kuya"
 OpenBtn.TextColor3 = Color3.fromRGB(255,255,255)
 OpenBtn.Font = Enum.Font.GothamBold
 OpenBtn.TextSize = 14
 OpenBtn.Visible = false
 OpenBtn.Parent = gui
 Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)

 local function setOpen(on)
  Window.Visible = on
  OpenBtn.Visible = not on
 end
 MinBtn.MouseButton1Click:Connect(function() setOpen(false) end)
 CloseBtn.MouseButton1Click:Connect(function() setOpen(false) end)
 OpenBtn.MouseButton1Click:Connect(function() setOpen(true) end)
 UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Enum.KeyCode.RightShift then setOpen(not Window.Visible) end end)

 local Status = Instance.new("TextLabel")
 Status.Size = UDim2.new(1, -16, 0, 90)
 Status.Position = UDim2.new(0, 8, 0, 40)
 Status.BackgroundTransparency = 1
 Status.TextXAlignment = Enum.TextXAlignment.Left
 Status.TextYAlignment = Enum.TextYAlignment.Top
 Status.TextColor3 = Color3.fromRGB(190,190,200)
 Status.Font = Enum.Font.Gotham
 Status.TextSize = 13
 Status.TextWrapped = true
 Status.Parent = Window

 local y = 140
 local function addToggle(name, default)
  local b = Instance.new("TextButton")
  b.Size = UDim2.new(1, -24, 0, 24)
  b.Position = UDim2.new(0, 12, 0, y)
  b.BackgroundColor3 = default and Color3.fromRGB(140,90,255) or Color3.fromRGB(50,50,56)
  b.Text = name
  b.TextColor3 = Color3.fromRGB(230,230,235)
  b.Font = Enum.Font.Gotham
  b.TextSize = 12
  b.Parent = Window
  Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
  local on = default
  b.MouseButton1Click:Connect(function()
   on = not on
   b.BackgroundColor3 = on and Color3.fromRGB(140,90,255) or Color3.fromRGB(50,50,56)
   saveSettings()
  end)
  y += 28
  return function() return on end
 end
 local getBest = addToggle("Auto Best Dungeon", Settings.AutoBest)
 local getHC = addToggle("Hardcore", Settings.Hardcore)
 local getPriv = addToggle("Private", Settings.Private)
 local getWait = addToggle("Wait For Members", Settings.WaitForMembers)
 local getAcc = addToggle("Auto Accept", Settings.AutoAccept)
 local getStartD = addToggle("Auto Start Dungeon", Settings.AutoStartDungeon)
 local getReplay = addToggle("Auto Replay (off unless needed)", Settings.AutoReplay)
 local getMelee = addToggle("Auto Melee", Settings.AutoMelee)
 local getLoop = addToggle("Auto Loop", Settings.AutoStart)

 local HostBox = Instance.new("TextBox")
 HostBox.Size = UDim2.new(1, -24, 0, 24)
 HostBox.Position = UDim2.new(0, 12, 0, y)
 HostBox.BackgroundColor3 = Color3.fromRGB(32,32,36)
 HostBox.Text = Settings.HostName
 HostBox.TextColor3 = Color3.fromRGB(230,230,235)
 HostBox.Font = Enum.Font.Gotham
 HostBox.TextSize = 12
 HostBox.Parent = Window
 y += 30
 local MemBox = Instance.new("TextBox")
 MemBox.Size = UDim2.new(1, -24, 0, 24)
 MemBox.Position = UDim2.new(0, 12, 0, y)
 MemBox.BackgroundColor3 = Color3.fromRGB(32,32,36)
 MemBox.Text = table.concat(Settings.RequiredPlayers, ", ")
 MemBox.TextColor3 = Color3.fromRGB(230,230,235)
 MemBox.Font = Enum.Font.Gotham
 MemBox.TextSize = 12
 MemBox.Parent = Window
 y += 34
 local StartNow = Instance.new("TextButton")
 StartNow.Size = UDim2.new(1, -24, 0, 28)
 StartNow.Position = UDim2.new(0, 12, 0, y)
 StartNow.BackgroundColor3 = Color3.fromRGB(60,140,80)
 StartNow.Text = "Start Dungeon Now"
 StartNow.TextColor3 = Color3.fromRGB(255,255,255)
 StartNow.Font = Enum.Font.GothamBold
 StartNow.TextSize = 13
 StartNow.Parent = Window
 Instance.new("UICorner", StartNow).CornerRadius = UDim.new(0, 4)
 StartNow.MouseButton1Click:Connect(function() lastStart = 0 startDungeon() end)

 local function sync()
  Settings.HostName = HostBox.Text:gsub("%s+", "")
  Settings.RequiredPlayers = parse(MemBox.Text)
  Settings.AutoBest = getBest() Settings.Hardcore = getHC() Settings.Private = getPriv()
  Settings.WaitForMembers = getWait() Settings.AutoAccept = getAcc()
  Settings.AutoStartDungeon = getStartD() Settings.AutoReplay = getReplay()
  Settings.AutoMelee = getMelee() Settings.AutoStart = getLoop()
 end

 task.spawn(function()
  while gui.Parent do
   sync()
   local map, diff = best()
   Status.Text = string.format("Account: %s\nState: %s\nBest: %s %s\nLvl: %s  Hub: %s",
    LP.Name, State, map, diff, tostring(lvl()), tostring(inHub()))
   task.wait(0.5)
  end
 end)

 task.spawn(function()
  while gui.Parent do
   if Settings.AutoAccept and inHub() then accept() end
   task.wait(2)
  end
 end)

 task.spawn(function()
  task.wait(3)
  while gui.Parent do
   sync()
   if Settings.AutoStart then
    local isHost = LP.Name:lower() == Settings.HostName:lower()
    if inHub() then
     local lobby = hostLobby()
     if isHost then
      if not lobby then
       createLobby()
      else
       if Settings.WaitForMembers and #Settings.RequiredPlayers > 0 and not allIn() then
        State = "Waiting"
        accept()
       elseif Settings.AutoStartDungeon then
        startDungeon()
       else
        State = "Ready"
       end
      end
     else
      if lobby and not joinedOnce then
       joinHost()
      elseif lobby then
       State = "InLobby"
      else
       joinedOnce = false
       State = "Looking"
      end
     end
    else
     State = "InDungeon"
    end
   end
   task.wait(1.5)
  end
 end)

 print("[DQ] v3 loaded — create is rate-limited, replay off, minimize added")
end)
