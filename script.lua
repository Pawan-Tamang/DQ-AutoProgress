-- DQ v27 public lobby
if getgenv and getgenv().DQRunning then return end
if getgenv then getgenv().DQRunning = true end
print("[DQ] v27", game.PlaceId)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
repeat task.wait() until Players.LocalPlayer
local LP = Players.LocalPlayer
local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 20) or game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local URL = "https://raw.githubusercontent.com/Pawan-Tamang/DQ-AutoProgress/main/script.lua?v=27"
pcall(function()
 if getgenv and getgenv().DQQueued then return end
 if getgenv then getgenv().DQQueued = true end
 local code = "getgenv().DQRunning=nil getgenv().DQQueued=nil repeat task.wait() until game:IsLoaded() loadstring(game:HttpGet(\"" .. URL .. "\"))()"
 if queue_on_teleport then queue_on_teleport(code)
 elseif syn and syn.queue_on_teleport then syn.queue_on_teleport(code) end
end)

local DUNGEON = 85776757589518
local function dungeonName()
 local dn = workspace:FindFirstChild("dungeonName")
 return dn and tostring(dn.Value or "") or ""
end
local function isDungeon()
 if game.PlaceId == DUNGEON then return true end
 local v = dungeonName()
 return v ~= "" and v ~= "Lobby"
end

local S = {
 HostName = "kurokazahood",
 Members = {"royaldancersss", "splash_kyrie"},
 AutoBest = true, Hardcore = true, Private = false,
 WaitMembers = true, AutoAccept = true, AutoCreate = true, AutoJoin = true,
 AutoStart = true, AutoClick = true, AutoReplay = true,
 Timeout = 9999, SwingMs = 80,
}
pcall(function()
 if readfile and isfile and isfile("DQAutoProgress.json") then
  local d = HttpService:JSONDecode(readfile("DQAutoProgress.json"))
  if type(d) == "table" then for k,v in pairs(d) do S[k] = v end end
 end
end)
S.Private = false
S.WaitMembers = true
S.Members = {"royaldancersss", "splash_kyrie"}
local function save() pcall(function() if writefile then writefile("DQAutoProgress.json", HttpService:JSONEncode(S)) end end) end
save()

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
 {"Orbital Outpost",135,"Insane"},{"Orbital Outpost",140,"Nightmare"},
 {"Volcanic Chambers",150,"Insane"},{"Volcanic Chambers",155,"Nightmare"},
 {"Aquatic Temple",160,"Insane"},{"Aquatic Temple",165,"Nightmare"},
 {"Enchanted Forest",170,"Insane"},{"Enchanted Forest",175,"Nightmare"},
 {"Northern Lands",180,"Insane"},{"Northern Lands",185,"Nightmare"},
}
local RUN = "DQRun.json"
local function saveRun(map,diff,lv) pcall(function() if writefile then writefile(RUN, HttpService:JSONEncode({map=map,diff=diff,lv=lv,t=os.time()})) end end) end
local function loadRun()
 local out pcall(function() if readfile and isfile and isfile(RUN) then out = HttpService:JSONDecode(readfile(RUN)) end end)
 return type(out)=="table" and out or nil
end
local st = { name = isDungeon() and "InDungeon" or "Hub", created=false, joined=false, started=false, seen={}, missing="" }

local function rem() return RS:FindFirstChild("remotes") or RS:FindFirstChild("Remotes") end
local function findRemote(names)
 local r = rem() if not r then return nil end
 if type(names)=="string" then names={names} end
 for _,n in ipairs(names) do
  for _,v in ipairs(r:GetChildren()) do if v.Name:lower()==n:lower() then return v end end
 end
end
local function fireRemote(names, invoke, ...)
 local ev = findRemote(names) if not ev then return false end
 local args = {...}
 local ok = pcall(function()
  if invoke or ev:IsA("RemoteFunction") then ev:InvokeServer(unpack(args)) else ev:FireServer(unpack(args)) end
 end)
 if ok then print("[DQ]", ev.Name) end
 return ok
end
local function level()
 local best=1
 local ls=LP:FindFirstChild("leaderstats")
 if ls and ls:FindFirstChild("Level") then best=math.max(best,tonumber(ls.Level.Value) or 1) end
 local run=loadRun() if run and tonumber(run.lv) then best=math.max(best,tonumber(run.lv)) end
 return best
end
local function pick()
 local lv,cur=level(),PROG[1]
 if S.AutoBest then for _,d in ipairs(PROG) do if lv>=d[2] then cur=d else break end end end
 return cur[1],cur[3],lv
end
local function lobbyFolder()
 local g = workspace:FindFirstChild("games")
 return g and g:FindFirstChild("inLobby")
end
local function hostLobby()
 local f = lobbyFolder() if not f then return end
 for _,l in ipairs(f:GetChildren()) do if l.Name:lower()==S.HostName:lower() then return l end end
end
local function scanAddedGui()
 for _,o in ipairs(PlayerGui:GetDescendants()) do
  if o:IsA("TextLabel") or o:IsA("TextButton") then
   local ok,txt=pcall(function() return o.Text end)
   if ok and txt then
    local a=string.match(string.lower(txt), "player added to lobby:%s*(%S+)")
    if a then st.seen[a]=true end
   end
  end
 end
end
pcall(function()
 PlayerGui.DescendantAdded:Connect(function(o)
  task.defer(function()
   if o:IsA("TextLabel") or o:IsA("TextButton") then
    local ok,txt=pcall(function() return o.Text end)
    if ok and txt then
     local a=string.match(string.lower(txt), "player added to lobby:%s*(%S+)")
     if a then st.seen[a]=true print("[DQ] added", a) end
    end
   end
  end)
 end)
end)
local function inParty(name)
 local want = name:lower()
 if st.seen[want] then return true end
 scanAddedGui()
 if st.seen[want] then return true end
 local lobby = hostLobby()
 if not lobby then return false end
 for _,c in ipairs(lobby:GetDescendants()) do
  if c.Name:lower()==want then return true end
  local ok,val=pcall(function() return c.Value end)
  if ok and val ~= nil and tostring(val):lower()==want then return true end
 end
 return false
end
local function missingMembers()
 local miss={}
 for _,n in ipairs(S.Members) do if not inParty(n) then table.insert(miss,n) end end
 return miss
end
local function fireBtn(o)
 pcall(function()
  if typeof(getconnections)=="function" then
   for _,n in ipairs({"MouseButton1Click","Activated"}) do
    local ok,sig=pcall(function() return o[n] end)
    if ok and sig then for _,c in ipairs(getconnections(sig)) do pcall(function() if c.Fire then c:Fire() end end) end end
   end
  end
  if typeof(firesignal)=="function" then pcall(function() firesignal(o.MouseButton1Click) end) end
 end)
end
local function isOurs(o) return o:FindFirstAncestor("DQManager") ~= nil end
local function clickDungeonStart()
 for _,o in ipairs(PlayerGui:GetDescendants()) do
  if o:IsA("TextButton") and o.Visible~=false and not isOurs(o) then
   local t="" pcall(function() t=string.gsub(string.lower(o.Text or ""),"%s+","") end)
   if t=="start" or t=="startdungeon" then fireBtn(o) print("[DQ] click START") return true end
  end
 end
end
local function fireStart()
 print("[DQ] START now")
 fireRemote({"startDungeon"}, false)
 task.wait(0.3)
 fireRemote({"changeStartValue"}, false)
 clickDungeonStart()
end
local function createLobby()
 local map,diff,lv=pick()
 print("[DQ] create PUBLIC", map, diff, lv)
 saveRun(map,diff,lv)
 return fireRemote({"createLobby","createDungeon"}, true, map, diff, 0, S.Hardcore, false, false)
end
local function joinHost()
 local lobby=hostLobby() if not lobby then return false end
 return fireRemote({"joinDungeon"}, true, lobby.Name)
end
local function replay() return fireRemote({"replayDungeon","replay"}, false) end
local function isHost() return LP.Name:lower()==S.HostName:lower() end
local function dungeonFinished()
 local d=workspace:FindFirstChild("dungeon")
 local br=d and d:FindFirstChild("bossRoom")
 local f=br and br:FindFirstChild("dungeonFinished")
 return f and f.Value==true
end
local skillHeld=false
UIS.InputBegan:Connect(function(i)
 if i.KeyCode==Enum.KeyCode.Q or i.KeyCode==Enum.KeyCode.E or i.KeyCode==Enum.KeyCode.R or i.KeyCode==Enum.KeyCode.F then skillHeld=true end
end)
UIS.InputEnded:Connect(function(i)
 if i.KeyCode==Enum.KeyCode.Q or i.KeyCode==Enum.KeyCode.E or i.KeyCode==Enum.KeyCode.R or i.KeyCode==Enum.KeyCode.F then skillHeld=false end
end)
local function swing()
 if not S.AutoClick or not isDungeon() or skillHeld then return end
 local char=LP.Character if not char then return end
 local tool=char:FindFirstChildOfClass("Tool")
 if tool then pcall(function() tool:Activate() end) end
end

local old=PlayerGui:FindFirstChild("DQManager") if old then old:Destroy() end
local gui=Instance.new("ScreenGui") gui.Name="DQManager" gui.ResetOnSpawn=false gui.DisplayOrder=100
pcall(function() gui.Parent=PlayerGui end)
if not gui.Parent then pcall(function() gui.Parent=game:GetService("CoreGui") end) end
local BG,PANEL,SIDE,TEXT,MUTED,ACC=Color3.fromRGB(18,18,20),Color3.fromRGB(28,28,32),Color3.fromRGB(22,22,24),Color3.fromRGB(230,230,235),Color3.fromRGB(150,150,160),Color3.fromRGB(140,90,255)
local root=Instance.new("Frame") root.Size=UDim2.new(0,720,0,430) root.Position=UDim2.new(0,16,0,80)
root.BackgroundColor3=BG root.BorderSizePixel=0 root.Active=true root.Draggable=true root.Parent=gui
Instance.new("UICorner",root).CornerRadius=UDim.new(0,8)
local top=Instance.new("Frame") top.Size=UDim2.new(1,0,0,36) top.BackgroundColor3=Color3.fromRGB(16,16,18) top.BorderSizePixel=0 top.Parent=root
local brand=Instance.new("TextLabel") brand.Size=UDim2.new(0,180,1,0) brand.BackgroundTransparency=1 brand.Text="  Manager v27" brand.TextXAlignment=Enum.TextXAlignment.Left brand.TextColor3=TEXT brand.Font=Enum.Font.Gotham brand.TextSize=16 brand.Parent=top
local closeB=Instance.new("TextButton") closeB.Size=UDim2.new(0,28,0,24) closeB.Position=UDim2.new(1,-34,0,6) closeB.BackgroundColor3=Color3.fromRGB(40,40,46) closeB.Text="_" closeB.TextColor3=TEXT closeB.Parent=top
local reopen=Instance.new("TextButton") reopen.Size=UDim2.new(0,90,0,28) reopen.Position=UDim2.new(0,16,0,16) reopen.BackgroundColor3=ACC reopen.Text="Manager" reopen.TextColor3=Color3.new(1,1,1) reopen.Visible=false reopen.Parent=gui
closeB.MouseButton1Click:Connect(function() root.Visible=false reopen.Visible=true end)
reopen.MouseButton1Click:Connect(function() root.Visible=true reopen.Visible=false end)
UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode==Enum.KeyCode.RightShift then root.Visible=not root.Visible reopen.Visible=not root.Visible end end)
local side=Instance.new("Frame") side.Size=UDim2.new(0,140,1,-36) side.Position=UDim2.new(0,0,0,36) side.BackgroundColor3=SIDE side.BorderSizePixel=0 side.Parent=root
local function sideBtn(txt,yy)
 local b=Instance.new("TextButton") b.Size=UDim2.new(1,-16,0,28) b.Position=UDim2.new(0,8,0,yy) b.BackgroundColor3=Color3.fromRGB(32,32,36) b.Text="  "..txt b.TextXAlignment=Enum.TextXAlignment.Left b.TextColor3=TEXT b.Font=Enum.Font.Gotham b.TextSize=13 b.Parent=side Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) return b
end
local bMain,bSet=sideBtn("Main",12),sideBtn("UI Settings",46)
local mainPage=Instance.new("Frame") mainPage.Size=UDim2.new(1,-160,1,-70) mainPage.Position=UDim2.new(0,150,0,44) mainPage.BackgroundTransparency=1 mainPage.Parent=root
local setPage=Instance.new("Frame") setPage.Size=mainPage.Size setPage.Position=mainPage.Position setPage.BackgroundTransparency=1 setPage.Visible=false setPage.Parent=root
local function showTab(m) mainPage.Visible=m setPage.Visible=not m bMain.BackgroundColor3=m and ACC or Color3.fromRGB(32,32,36) bSet.BackgroundColor3=(not m) and ACC or Color3.fromRGB(32,32,36) end
bMain.MouseButton1Click:Connect(function() showTab(true) end) bSet.MouseButton1Click:Connect(function() showTab(false) end) showTab(true)
local function section(parent,title,x,yy,w,h)
 local f=Instance.new("Frame") f.Size=UDim2.new(0,w,0,h) f.Position=UDim2.new(0,x,0,yy) f.BackgroundColor3=PANEL f.BorderSizePixel=0 f.Parent=parent Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
 local t=Instance.new("TextLabel") t.Size=UDim2.new(1,-16,0,22) t.Position=UDim2.new(0,10,0,6) t.BackgroundTransparency=1 t.Text=title t.TextXAlignment=Enum.TextXAlignment.Left t.TextColor3=TEXT t.Font=Enum.Font.GothamMedium t.TextSize=14 t.Parent=f return f
end
local mgr=section(mainPage,"Manager",0,0,360,330)
local stat=section(mainPage,"Status",372,0,188,220)
local y=34
local function toggle(parent,label,key)
 local row=Instance.new("Frame") row.Size=UDim2.new(1,-20,0,26) row.Position=UDim2.new(0,10,0,y) row.BackgroundTransparency=1 row.Parent=parent
 local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-54,1,0) l.BackgroundTransparency=1 l.Text=label l.TextXAlignment=Enum.TextXAlignment.Left l.TextColor3=TEXT l.Font=Enum.Font.Gotham l.TextSize=13 l.Parent=row
 local pill=Instance.new("TextButton") pill.Size=UDim2.new(0,40,0,20) pill.Position=UDim2.new(1,-44,0.5,-10) pill.Text="" pill.Parent=row Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
 local kn=Instance.new("Frame") kn.Size=UDim2.new(0,16,0,16) kn.BackgroundColor3=Color3.new(1,1,1) kn.Parent=pill Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
 local function paint() pill.BackgroundColor3=S[key] and ACC or Color3.fromRGB(70,70,78) kn.Position=UDim2.new(S[key] and 1 or 0,S[key] and -18 or 2,0.5,-8) end
 paint() pill.MouseButton1Click:Connect(function() S[key]=not S[key] paint() save() end) y+=28
end
toggle(mgr,"Auto Best Dungeon","AutoBest") toggle(mgr,"Hardcore Lobby","Hardcore") toggle(mgr,"Private Lobby","Private") toggle(mgr,"Wait For Members After restart","WaitMembers")
local mem=Instance.new("TextBox") mem.Size=UDim2.new(1,-20,0,24) mem.Position=UDim2.new(0,10,0,y) mem.BackgroundColor3=Color3.fromRGB(22,22,26) mem.Text=table.concat(S.Members,", ") mem.TextColor3=TEXT mem.Font=Enum.Font.Gotham mem.TextSize=12 mem.Parent=mgr
mem.FocusLost:Connect(function() local a={} for n in string.gmatch(mem.Text or "","[^,%s]+") do table.insert(a,n) end S.Members=a save() end) y+=32
toggle(mgr,"Auto Accept Join Requests","AutoAccept")
local sl=Instance.new("TextLabel") sl.Size=UDim2.new(1,-12,1,-30) sl.Position=UDim2.new(0,8,0,28) sl.BackgroundTransparency=1 sl.TextXAlignment=Enum.TextXAlignment.Left sl.TextYAlignment=Enum.TextYAlignment.Top sl.TextColor3=TEXT sl.Font=Enum.Font.Gotham sl.TextSize=12 sl.TextWrapped=true sl.Parent=stat
local setBox=section(setPage,"UI Settings",0,0,560,340) y=34
toggle(setBox,"Auto Create (host)","AutoCreate") toggle(setBox,"Auto Join (alts)","AutoJoin") toggle(setBox,"Auto Start","AutoStart") toggle(setBox,"Auto Replay","AutoReplay") toggle(setBox,"Auto Swing","AutoClick")
local host=Instance.new("TextBox") host.Size=UDim2.new(1,-20,0,24) host.Position=UDim2.new(0,10,0,y) host.BackgroundColor3=Color3.fromRGB(22,22,26) host.Text=S.HostName host.TextColor3=TEXT host.Font=Enum.Font.Gotham host.TextSize=12 host.Parent=setBox
host.FocusLost:Connect(function() S.HostName=host.Text:gsub("%s+","") save() end)
task.spawn(function()
 while gui.Parent do
  local map,diff,lv=pick()
  sl.Text=string.format("v27 PUBLIC\n%s\nState: %s\nBest: %s %s\nMissing: %s",LP.Name,st.name,map,diff,st.missing~="" and st.missing or "none")
  task.wait(0.4)
 end
end)

if isDungeon() then
 task.spawn(function()
  st.name="Wait5s" task.wait(5)
  if not S.AutoStart then return end
  for i=1,8 do st.name="StartRemote "..i fireStart() task.wait(1.2) end
  st.name="Swinging"
 end)
 task.spawn(function() while gui.Parent do if isDungeon() and S.AutoClick then swing() end task.wait((S.SwingMs or 80)/1000) end end)
 task.spawn(function()
  task.wait(20)
  while gui.Parent and isDungeon() do
   if dungeonFinished() then st.name="Finished" if isHost() and S.AutoReplay then replay() end task.wait(12) end
   task.wait(2)
  end
 end)
else
 task.spawn(function()
  st.name="WaitLevel" for _=1,15 do if level()>1 then break end task.wait(0.4) end
  while gui.Parent and not isDungeon() do
   if isHost() then
    if S.AutoCreate and not hostLobby() and not st.created then
     if level()<=1 then st.name="WaitLevel" else st.created=createLobby() or st.created st.name=st.created and "CreatedPublic" or "CreateFail" end
    elseif hostLobby() then
     st.created=true
     local miss=missingMembers()
     st.missing=table.concat(miss, ", ")
     if #miss>0 then
      st.started=false
      st.name="WAIT "..st.missing
     elseif S.AutoStart and not st.started then
      print("[DQ] both alts in lobby")
      st.started=true fireStart() st.name="Started"
     end
    end
   else
    if S.AutoJoin and hostLobby() and not st.joined then st.joined=joinHost() or st.joined st.name=st.joined and "Joined" or "JoinFail"
    elseif st.joined then st.name="WaitingStart" else st.name="Looking" end
   end
   task.wait(1)
  end
 end)
end
