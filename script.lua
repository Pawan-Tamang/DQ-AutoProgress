-- DQ v17 swing + fps + pixel
if getgenv and getgenv().DQRunning then return end
if getgenv then getgenv().DQRunning = true end
print("[DQ] v17", game.PlaceId)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
repeat task.wait() until Players.LocalPlayer
local LP = Players.LocalPlayer
local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 20) or game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VU = game:GetService("VirtualUser")

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
 WaitMembers = true, AutoAccept = true, AutoCreate = true, AutoJoin = true,
 AutoStart = true, AutoClick = true, AutoReplay = true, ClickPlay = true,
 FPSBoost = true, PixelMode = true, HideEffects = true,
 Timeout = 45, SwingMs = 50,
}
pcall(function()
 if readfile and isfile and isfile("DQAutoProgress.json") then
  local d = HttpService:JSONDecode(readfile("DQAutoProgress.json"))
  if type(d) == "table" then for k,v in pairs(d) do S[k] = v end end
 end
end)
local function save()
 pcall(function() if writefile then writefile("DQAutoProgress.json", HttpService:JSONEncode(S)) end end)
end

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
local function level()
 local best = 1
 local ls = LP:FindFirstChild("leaderstats")
 if ls and ls:FindFirstChild("Level") then best = math.max(best, tonumber(ls.Level.Value) or 1) end
 local ps = PlayerGui:FindFirstChild("playerStatus") or PlayerGui:FindFirstChild("PlayerStatus")
 if ps then
  for _,d in ipairs(ps:GetDescendants()) do
   if string.lower(d.Name):find("level") then
    local n = tonumber(tostring(d.Text or d.Value or ""):match("%d+"))
    if n then best = math.max(best, n) end
   end
  end
 end
 local run = loadRun()
 if run and tonumber(run.lv) then best = math.max(best, tonumber(run.lv)) end
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
 return pcall(function()
  if invoke or ev:IsA("RemoteFunction") then ev:InvokeServer(unpack(args)) else ev:FireServer(unpack(args)) end
 end)
end
local function clickText(words)
 for _,o in ipairs(PlayerGui:GetDescendants()) do
  if o:IsA("TextButton") and o.Visible ~= false then
   local t = string.lower((o.Text or "").." "..(o.Name or ""))
   for _,w in ipairs(words) do
    if string.find(t, w, 1, true) then
     pcall(function()
      if typeof(firesignal)=="function" then firesignal(o.MouseButton1Click) end
      if typeof(getconnections)=="function" then
       for _,c in ipairs(getconnections(o.MouseButton1Click)) do pcall(function() c:Fire() end) end
      end
     end)
     return true
    end
   end
  end
 end
end
local function clickPlay()
 if not S.ClickPlay or tick()-st.lastPlay < 4 then return end
 st.lastPlay = tick()
 clickText({"play","play game","start","start dungeon"})
end
local function fireStart() fireNamed("startDungeon", false) clickPlay() end
local function createLobby()
 local map,diff,lv = pick()
 print("[DQ] create", map, diff, lv)
 saveRun(map,diff,lv)
 return fireNamed("createLobby", true, map, diff, 0, S.Hardcore, S.Private, false)
end
local function joinHost()
 local lobby = hostLobby() if not lobby then return false end
 return fireNamed("joinDungeon", true, lobby.Name)
end
local function replay()
 return fireNamed("replay", false) or fireNamed("replayDungeon", false) or clickText({"replay","play again"})
end
local function memberHere(name)
 if st.seen[name:lower()] then return true end
 for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower()==name:lower() then return true end end
end
local function partyReady()
 if not S.WaitMembers or #S.Members==0 then return true end
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
local function isHost() return LP.Name:lower()==S.HostName:lower() end
local WIN = {"victory","dungeon complete","you win","boss defeated","mission complete"}
local function guiSaysWin()
 for _,o in ipairs(PlayerGui:GetDescendants()) do
  if (o:IsA("TextLabel") or o:IsA("TextButton")) and o.Visible ~= false then
   local t = string.lower(o.Text or "")
   if not string.find(t,"return to lobby",1,true) then
    for _,w in ipairs(WIN) do if string.find(t,w,1,true) then return true end end
   end
  end
 end
end

local function swing()
 if not S.AutoClick or not isDungeon() then return end
 local char = LP.Character if not char then return end
 local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
 local tool = char:FindFirstChildOfClass("Tool")
 if not tool then
  for _,t in ipairs(LP.Backpack:GetChildren()) do
   if t:IsA("Tool") then tool = t break end
  end
  if tool then pcall(function() hum:EquipTool(tool) end) end
 end
 tool = char:FindFirstChildOfClass("Tool")
 if tool then
  pcall(function() tool:Activate() end)
  local h = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
  if h then pcall(function() tool:Activate() end) end
 end
 pcall(function()
  VU:CaptureController()
  VU:ClickButton1(Vector2.new())
 end)
 pcall(function() if mouse1click then mouse1click() end end)
 pcall(function()
  if mouse1press then mouse1press() task.wait() if mouse1release then mouse1release() end end
 end)
end

local boosted = false
local function applyFPS()
 if not S.FPSBoost then return end
 pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
 pcall(function()
  local g = UserSettings():GetService("UserGameSettings")
  g.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
 end)
 Lighting.GlobalShadows = false
 Lighting.FogEnd = 1e6
 Lighting.Brightness = 1
 pcall(function() Lighting.Technology = Enum.Technology.Compatibility end)
 for _,v in ipairs(Lighting:GetChildren()) do
  if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
   v.Enabled = false
  end
 end
 if S.HideEffects then
  for _,v in ipairs(workspace:GetDescendants()) do
   if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
    v.Enabled = false
   end
  end
 end
 boosted = true
 print("[DQ] fps on")
end
local function applyPixel()
 if not S.PixelMode then return end
 pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
 for _,v in ipairs(workspace:GetDescendants()) do
  if v:IsA("BasePart") then
   v.Material = Enum.Material.SmoothPlastic
   v.Reflectance = 0
   if v.Transparency < 1 then v.CastShadow = false end
  elseif v:IsA("Decal") or v:IsA("Texture") then
   v.Transparency = 1
  elseif v:IsA("MeshPart") then
   v.TextureID = ""
   v.Material = Enum.Material.SmoothPlastic
  end
 end
 Lighting.ClockTime = 14
 Lighting.Brightness = 2
 Lighting.Ambient = Color3.fromRGB(180,180,180)
 Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
 print("[DQ] pixel on")
end

local function onFinished()
 if st.finished then return end
 st.finished = true st.name = "Replay"
 if isHost() and S.AutoReplay then replay() end
 task.delay(15, function() st.finished = false end)
end

local old = PlayerGui:FindFirstChild("DQManager") if old then old:Destroy() end
local gui = Instance.new("ScreenGui") gui.Name = "DQManager" gui.ResetOnSpawn = false
pcall(function() gui.Parent = PlayerGui end)
if not gui.Parent then pcall(function() gui.Parent = game:GetService("CoreGui") end) end
local BG, PANEL, SIDE, TEXT, MUTED, ACC =
 Color3.fromRGB(18,18,20), Color3.fromRGB(28,28,32), Color3.fromRGB(22,22,24),
 Color3.fromRGB(230,230,235), Color3.fromRGB(150,150,160), Color3.fromRGB(140,90,255)
local root = Instance.new("Frame")
root.Size = UDim2.new(0,720,0,430) root.Position = UDim2.new(0.5,-360,0.5,-215)
root.BackgroundColor3 = BG root.BorderSizePixel = 0 root.Active = true root.Draggable = true root.Parent = gui
Instance.new("UICorner", root).CornerRadius = UDim.new(0,8)
local top = Instance.new("Frame") top.Size = UDim2.new(1,0,0,36) top.BackgroundColor3 = Color3.fromRGB(16,16,18) top.BorderSizePixel = 0 top.Parent = root
local brand = Instance.new("TextLabel") brand.Size = UDim2.new(0,130,1,0) brand.BackgroundTransparency = 1
brand.Text = "  Manager" brand.TextXAlignment = Enum.TextXAlignment.Left brand.TextColor3 = TEXT brand.Font = Enum.Font.Gotham brand.TextSize = 16 brand.Parent = top
local closeB = Instance.new("TextButton") closeB.Size = UDim2.new(0,28,0,24) closeB.Position = UDim2.new(1,-34,0,6)
closeB.BackgroundColor3 = Color3.fromRGB(40,40,46) closeB.Text = "_" closeB.TextColor3 = TEXT closeB.Parent = top
local reopen = Instance.new("TextButton") reopen.Size = UDim2.new(0,90,0,28) reopen.Position = UDim2.new(0,16,0,16)
reopen.BackgroundColor3 = ACC reopen.Text = "Manager" reopen.TextColor3 = Color3.new(1,1,1) reopen.Visible = false reopen.Parent = gui
closeB.MouseButton1Click:Connect(function() root.Visible=false reopen.Visible=true end)
reopen.MouseButton1Click:Connect(function() root.Visible=true reopen.Visible=false end)
UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode==Enum.KeyCode.RightShift then root.Visible=not root.Visible reopen.Visible=not root.Visible end end)
local side = Instance.new("Frame") side.Size = UDim2.new(0,140,1,-36) side.Position = UDim2.new(0,0,0,36)
side.BackgroundColor3 = SIDE side.BorderSizePixel = 0 side.Parent = root
local function sideBtn(txt,y)
 local b=Instance.new("TextButton") b.Size=UDim2.new(1,-16,0,28) b.Position=UDim2.new(0,8,0,y)
 b.BackgroundColor3=Color3.fromRGB(32,32,36) b.Text="  "..txt b.TextXAlignment=Enum.TextXAlignment.Left
 b.TextColor3=TEXT b.Font=Enum.Font.Gotham b.TextSize=13 b.Parent=side
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) return b
end
local bMain,bSet = sideBtn("Main",12), sideBtn("UI Settings",46)
local mainPage = Instance.new("Frame") mainPage.Size=UDim2.new(1,-160,1,-70) mainPage.Position=UDim2.new(0,150,0,44) mainPage.BackgroundTransparency=1 mainPage.Parent=root
local setPage = Instance.new("Frame") setPage.Size=mainPage.Size setPage.Position=mainPage.Position setPage.BackgroundTransparency=1 setPage.Visible=false setPage.Parent=root
local function showTab(m) mainPage.Visible=m setPage.Visible=not m bMain.BackgroundColor3=m and ACC or Color3.fromRGB(32,32,36) bSet.BackgroundColor3=(not m) and ACC or Color3.fromRGB(32,32,36) end
bMain.MouseButton1Click:Connect(function() showTab(true) end)
bSet.MouseButton1Click:Connect(function() showTab(false) end) showTab(true)
local function section(parent,title,x,y,w,h)
 local f=Instance.new("Frame") f.Size=UDim2.new(0,w,0,h) f.Position=UDim2.new(0,x,0,y) f.BackgroundColor3=PANEL f.BorderSizePixel=0 f.Parent=parent
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
 local t=Instance.new("TextLabel") t.Size=UDim2.new(1,-16,0,22) t.Position=UDim2.new(0,10,0,6) t.BackgroundTransparency=1 t.Text=title t.TextXAlignment=Enum.TextXAlignment.Left t.TextColor3=TEXT t.Font=Enum.Font.GothamMedium t.TextSize=14 t.Parent=f
 return f
end
local mgr = section(mainPage,"Manager",0,0,360,330)
local stat = section(mainPage,"Status",372,0,188,180)
local y=34
local function toggle(parent,label,key,cb)
 local row=Instance.new("Frame") row.Size=UDim2.new(1,-20,0,26) row.Position=UDim2.new(0,10,0,y) row.BackgroundTransparency=1 row.Parent=parent
 local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-54,1,0) l.BackgroundTransparency=1 l.Text=label l.TextXAlignment=Enum.TextXAlignment.Left l.TextColor3=TEXT l.Font=Enum.Font.Gotham l.TextSize=13 l.Parent=row
 local pill=Instance.new("TextButton") pill.Size=UDim2.new(0,40,0,20) pill.Position=UDim2.new(1,-44,0.5,-10) pill.Text="" pill.Parent=row
 Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
 local kn=Instance.new("Frame") kn.Size=UDim2.new(0,16,0,16) kn.BackgroundColor3=Color3.new(1,1,1) kn.Parent=pill
 Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
 local function paint()
  pill.BackgroundColor3=S[key] and ACC or Color3.fromRGB(70,70,78)
  kn.Position=UDim2.new(S[key] and 1 or 0, S[key] and -18 or 2, 0.5, -8)
 end
 paint()
 pill.MouseButton1Click:Connect(function() S[key]=not S[key] paint() save() if cb then cb(S[key]) end end)
 y+=28
end
toggle(mgr,"Auto Best Dungeon","AutoBest")
toggle(mgr,"Hardcore Lobby","Hardcore")
toggle(mgr,"Private Lobby","Private")
toggle(mgr,"Wait For Members After restart","WaitMembers")
local tl=Instance.new("TextLabel") tl.Size=UDim2.new(1,-20,0,16) tl.Position=UDim2.new(0,10,0,y) tl.BackgroundTransparency=1 tl.Text="Member Rejoin Timeout (s)" tl.TextXAlignment=Enum.TextXAlignment.Left tl.TextColor3=MUTED tl.Font=Enum.Font.Gotham tl.TextSize=12 tl.Parent=mgr y+=18
local bar=Instance.new("Frame") bar.Size=UDim2.new(1,-20,0,8) bar.Position=UDim2.new(0,10,0,y) bar.BackgroundColor3=Color3.fromRGB(50,50,58) bar.Parent=mgr
Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
local fill=Instance.new("Frame") fill.Size=UDim2.new((S.Timeout or 45)/120,0,1,0) fill.BackgroundColor3=ACC fill.Parent=bar
local tv=Instance.new("TextLabel") tv.Size=UDim2.new(1,-20,0,14) tv.Position=UDim2.new(0,10,0,y+10) tv.BackgroundTransparency=1 tv.Text=tostring(S.Timeout).."/120" tv.TextColor3=MUTED tv.Font=Enum.Font.Gotham tv.TextSize=11 tv.Parent=mgr
bar.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then
  local a=math.clamp((input.Position.X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
  S.Timeout=math.clamp(math.floor(a*120),5,120) fill.Size=UDim2.new(S.Timeout/120,0,1,0) tv.Text=S.Timeout.."/120" save()
 end
end)
y+=28
local ml=Instance.new("TextLabel") ml.Size=UDim2.new(1,-20,0,14) ml.Position=UDim2.new(0,10,0,y) ml.BackgroundTransparency=1 ml.Text="Member Usernames" ml.TextXAlignment=Enum.TextXAlignment.Left ml.TextColor3=MUTED ml.Font=Enum.Font.Gotham ml.TextSize=12 ml.Parent=mgr y+=16
local mem=Instance.new("TextBox") mem.Size=UDim2.new(1,-20,0,24) mem.Position=UDim2.new(0,10,0,y) mem.BackgroundColor3=Color3.fromRGB(22,22,26) mem.Text=table.concat(S.Members,", ") mem.PlaceholderText="alt1, alt2" mem.TextColor3=TEXT mem.Font=Enum.Font.Gotham mem.TextSize=12 mem.Parent=mgr
mem.FocusLost:Connect(function() local a={} for n in string.gmatch(mem.Text or "","[^,%s]+") do table.insert(a,n) end S.Members=a save() end)
y+=32
toggle(mgr,"Auto Accept Join Requests","AutoAccept")
local sl=Instance.new("TextLabel") sl.Size=UDim2.new(1,-12,1,-30) sl.Position=UDim2.new(0,8,0,28) sl.BackgroundTransparency=1 sl.TextXAlignment=Enum.TextXAlignment.Left sl.TextYAlignment=Enum.TextYAlignment.Top sl.TextColor3=TEXT sl.Font=Enum.Font.Gotham sl.TextSize=12 sl.TextWrapped=true sl.Parent=stat

local setBox=section(setPage,"UI Settings",0,0,560,340)
y=34
toggle(setBox,"Auto Create (host)","AutoCreate")
toggle(setBox,"Auto Join (alts)","AutoJoin")
toggle(setBox,"Auto Start","AutoStart")
toggle(setBox,"Auto Replay","AutoReplay")
toggle(setBox,"Auto Swing","AutoClick")
toggle(setBox,"Click Play Button","ClickPlay")
toggle(setBox,"FPS Boost", "FPSBoost", function(on) if on then applyFPS() end end)
toggle(setBox,"Pixel Mode", "PixelMode", function(on) if on then applyPixel() end end)
toggle(setBox,"Hide Effects", "HideEffects", function(on) if on then applyFPS() end end)
local hl=Instance.new("TextLabel") hl.Size=UDim2.new(1,-20,0,14) hl.Position=UDim2.new(0,10,0,y) hl.BackgroundTransparency=1 hl.Text="Host Username" hl.TextXAlignment=Enum.TextXAlignment.Left hl.TextColor3=MUTED hl.Font=Enum.Font.Gotham hl.TextSize=12 hl.Parent=setBox y+=16
local host=Instance.new("TextBox") host.Size=UDim2.new(1,-20,0,24) host.Position=UDim2.new(0,10,0,y) host.BackgroundColor3=Color3.fromRGB(22,22,26) host.Text=S.HostName host.TextColor3=TEXT host.Font=Enum.Font.Gotham host.TextSize=12 host.Parent=setBox
host.FocusLost:Connect(function() S.HostName=host.Text:gsub("%s+","") save() end)

task.spawn(function()
 while gui.Parent do
  local map,diff,lv=pick()
  sl.Text=string.format("Account: %s\nState: %s\nBest: %s %s\nLevel: %s\nSwing: %s",
   LP.Name, st.name, map, diff, tostring(lv), S.AutoClick and "ON" or "OFF")
  task.wait(0.4)
 end
end)

if S.FPSBoost then applyFPS() end
if S.PixelMode then task.defer(applyPixel) end

if isDungeon() then
 task.spawn(function() st.name="Wait5s" task.wait(5) st.started=true st.name="Swinging" fireStart() end)
 task.spawn(function()
  while gui.Parent do
   if isDungeon() and S.AutoClick then swing() end
   task.wait((S.SwingMs or 50)/1000)
  end
 end)
 task.spawn(function()
  task.wait(25)
  while gui.Parent and isDungeon() do if guiSaysWin() then onFinished() end task.wait(2) end
 end)
else
 local waitT=0
 task.spawn(function()
  st.name="WaitLevel"
  for _=1,15 do if level()>1 then break end task.wait(0.4) end
  clickPlay()
  while gui.Parent and isHub() do
   if S.AutoAccept and isHost() then fireNamed("acceptRequest", false) end
   clickPlay()
   if isHost() then
    if S.AutoCreate and not hostLobby() and not st.created then
     if level()<=1 then st.name="WaitLevel" else st.created=createLobby() or st.created st.name=st.created and "Created" or "CreateFail" end
    elseif hostLobby() then
     st.created=true
     if S.WaitMembers and not partyReady() and not st.started then
      st.name="Waiting" waitT+=1.2
      if waitT>=(S.Timeout or 45) then st.started=true fireStart() st.name="Started" end
     elseif S.AutoStart and not st.started then st.started=true fireStart() st.name="Started" end
    end
   else
    if S.AutoJoin and hostLobby() and not st.joined then st.joined=joinHost() or st.joined st.name=st.joined and "Joined" or "JoinFail"
    elseif st.joined then st.name="WaitingStart" else st.name="Looking" end
   end
   task.wait(1.2)
  end
 end)
end
