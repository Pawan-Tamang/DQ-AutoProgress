-- DQ v33 level detect + current dungeon status
if getgenv and getgenv().DQRunning then return end
if getgenv then getgenv().DQRunning = true end
print("[DQ] v33", game.PlaceId)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
repeat task.wait() until Players.LocalPlayer
local LP = Players.LocalPlayer
local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 20) or game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")
local Lighting = game:GetService("Lighting")

local URL = "https://raw.githubusercontent.com/Pawan-Tamang/DQ-AutoProgress/main/script.lua?v=33"
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
local function norm(s) return string.lower((s or ""):gsub("[^%w]","")) end
local function sameMap(a,b) return norm(a)==norm(b) and norm(a)~="" end

local ALLOW = { splash_kyrie=true, spikytamanggg=true, kurokazahood=true }
local S = {
 HostName="kurokazahood", Members={"splash_kyrie","spikytamanggg"},
 AutoBest=true, Hardcore=true, Private=false, WaitMembers=true,
 AutoAccept=true, AutoCreate=true, AutoJoin=true, AutoStart=true,
 AutoClick=true, AutoReplay=true, FPSBoost=true, AutoSell=true,
 SellBelow=120, NeedCount=2,
}
pcall(function()
 if readfile and isfile and isfile("DQAutoProgress.json") then
  local d=HttpService:JSONDecode(readfile("DQAutoProgress.json"))
  if type(d)=="table" then for k,v in pairs(d) do S[k]=v end end
 end
end)
S.AutoBest=true S.Private=false S.WaitMembers=true S.NeedCount=2
S.Members={"splash_kyrie","spikytamanggg"}
ALLOW={splash_kyrie=true,spikytamanggg=true,[S.HostName:lower()]=true,[LP.Name:lower()]=true}
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
 {"Orbital Outpost",135,"Insane"},{"Orbital Outpost",140,"Nightmare"},
 {"Volcanic Chambers",150,"Insane"},{"Volcanic Chambers",155,"Nightmare"},
 {"Aquatic Temple",160,"Insane"},{"Aquatic Temple",165,"Nightmare"},
 {"Enchanted Forest",170,"Insane"},{"Enchanted Forest",175,"Nightmare"},
 {"Northern Lands",180,"Insane"},{"Northern Lands",185,"Nightmare"},
}
local st = { name=isDungeon() and "InDungeon" or "Hub", created=false, joined=false, started=false, seen={}, lvl=1, lvlSrc="?" }

local function grabNum(obj)
 if not obj then return nil end
 local ok,val=pcall(function()
  if obj:IsA("ValueBase") then return obj.Value end
  if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then return obj.Text end
  return obj.Value or obj.Text
 end)
 if not ok or val==nil then return nil end
 if type(val)=="number" then return val end
 local s=tostring(val)
 local n=tonumber(string.match(s, "Lv%.?%s*(%d+)") or string.match(s, "[Ll]evel%s*:?%s*(%d+)") or string.match(s, "(%d+)"))
 return n
end
local function consider(best, n, src)
 if type(n)=="number" and n>=1 and n<10000 and n>best then return n, src end
 return best, src
end
local function level()
 local best,src=1,"default"
 local function scan(root, tag)
  if not root then return end
  for _,o in ipairs(root:GetDescendants()) do
   local nm=string.lower(o.Name or "")
   if nm=="level" or nm=="lvl" or nm=="lv" or nm:find("playerstatus") or nm=="leveltext" then
    best,src=consider(best, grabNum(o), tag.."."..o.Name)
   end
  end
 end
 local ls=LP:FindFirstChild("leaderstats")
 if ls then
  for _,o in ipairs(ls:GetChildren()) do
   best,src=consider(best, grabNum(o), "leaderstats."..o.Name)
  end
 end
 scan(LP, "player")
 scan(PlayerGui, "gui")
 -- nametag above character often "67" next to name
 local char=LP.Character
 if char then
  local hum=char:FindFirstChildOfClass("Humanoid")
  if hum then
   local dt=tostring(hum.DisplayName or "").." "..tostring(hum.Name or "")
   local n=tonumber(string.match(dt, "(%d+)"))
   best,src=consider(best, n, "humanoid")
  end
  scan(char, "char")
 end
 st.lvl, st.lvlSrc = best, src
 return best
end
local function pick()
 local lv,cur=level(),PROG[1]
 for _,d in ipairs(PROG) do if lv>=d[2] then cur=d else break end end
 return cur[1],cur[3],lv
end
local function rem() return RS:FindFirstChild("remotes") or RS:FindFirstChild("Remotes") end
local function findRemote(names)
 local r=rem() if not r then return nil end
 if type(names)=="string" then names={names} end
 for _,n in ipairs(names) do
  for _,v in ipairs(r:GetChildren()) do if v.Name:lower()==n:lower() then return v end end
 end
end
local function fireRemote(names, invoke, ...)
 local ev=findRemote(names) if not ev then return false end
 local args={...}
 local ok=pcall(function()
  if invoke or ev:IsA("RemoteFunction") then ev:InvokeServer(unpack(args)) else ev:FireServer(unpack(args)) end
 end)
 if ok then print("[DQ]", ev.Name) end
 return ok
end
local function lobbyFolder()
 local g=workspace:FindFirstChild("games")
 return g and g:FindFirstChild("inLobby")
end
local function hostLobby()
 local f=lobbyFolder() if not f then return end
 for _,l in ipairs(f:GetChildren()) do if l.Name:lower()==S.HostName:lower() then return l end end
end
local function lobbyMap(lobby)
 if not lobby then return "" end
 for _,n in ipairs({"mapName","MapName","map","Map","dungeon","Dungeon"}) do
  local v=lobby:FindFirstChild(n)
  if v then
   local ok,val=pcall(function() return v.Value end)
   if ok and val then return tostring(val) end
  end
 end
 return ""
end
local function currentDungeon()
 local dn=dungeonName()
 if dn~="" and dn~="Lobby" then return dn end
 local lm=lobbyMap(hostLobby())
 if lm~="" then return lm end
 return "Lobby"
end
local function leaveLobby()
 fireRemote({"returnToLobby","leaveDungeon","leaveLobby","exitDungeon","cancelLobby"}, false)
end
local function createLobby()
 local map,diff,lv=pick()
 print("[DQ] create", map, diff, "lv"..tostring(lv), st.lvlSrc)
 return fireRemote({"createLobby","createDungeon"}, true, map, diff, 0, S.Hardcore, false, false)
end
local function joinHost()
 local lobby=hostLobby() if not lobby then return false end
 return fireRemote({"joinDungeon"}, true, lobby.Name)
end
local function replay() return fireRemote({"replayDungeon","replay"}, false) end
local function allowed(name) return ALLOW[(name or ""):lower()]==true end
local function kickName(name)
 if not name or allowed(name) then return end
 fireRemote({"kickPlayer","kickFromLobby","removePlayer"}, false, name)
end
local function markAdded(name)
 if not name or name=="" then return end
 local n=name:lower():gsub("[^%w_]","")
 if n=="" or not allowed(n) then if n~="" then kickName(name) end return end
 if n==LP.Name:lower() or n==S.HostName:lower() then return end
 if not st.seen[n] then st.seen[n]=true print("[DQ] added", n) end
end
pcall(function()
 LogService.MessageOut:Connect(function(msg)
  local a=string.match(string.lower(tostring(msg)), "player added to lobby:%s*(%S+)")
  if a then markAdded(a) end
 end)
end)
local function seenCount() local n=0 for k in pairs(st.seen) do if allowed(k) then n+=1 end end return n end
local function partyReady() return seenCount()>=(S.NeedCount or 2) end
local function isHost() return LP.Name:lower()==S.HostName:lower() end
local function dungeonFinished()
 local d=workspace:FindFirstChild("dungeon")
 local br=d and d:FindFirstChild("bossRoom")
 local f=br and br:FindFirstChild("dungeonFinished")
 return f and f.Value==true
end
local function fireStart()
 print("[DQ] START now")
 fireRemote({"startDungeon"}, false)
 task.wait(0.3)
 fireRemote({"changeStartValue"}, false)
end
local function afterWin()
 local map,diff,lv=pick()
 local cur=currentDungeon()
 print("[DQ] win in", cur, "next", map, diff, "lv"..tostring(lv))
 if sameMap(cur,map) then
  if isHost() then replay() end
 else
  leaveLobby()
 end
end
local function lobbyIsWanted()
 local lobby=hostLobby()
 if not lobby then return false end
 local have=lobbyMap(lobby)
 local want=pick()
 if have=="" then return true end
 return sameMap(have,want)
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
local BG,PANEL,SIDE,TEXT,ACC=Color3.fromRGB(18,18,20),Color3.fromRGB(28,28,32),Color3.fromRGB(22,22,24),Color3.fromRGB(230,230,235),Color3.fromRGB(140,90,255)
local root=Instance.new("Frame") root.Size=UDim2.new(0,720,0,430) root.Position=UDim2.new(0,16,0,80)
root.BackgroundColor3=BG root.BorderSizePixel=0 root.Active=true root.Draggable=true root.Parent=gui
Instance.new("UICorner",root).CornerRadius=UDim.new(0,8)
local top=Instance.new("Frame") top.Size=UDim2.new(1,0,0,36) top.BackgroundColor3=Color3.fromRGB(16,16,18) top.BorderSizePixel=0 top.Parent=root
local brand=Instance.new("TextLabel") brand.Size=UDim2.new(0,200,1,0) brand.BackgroundTransparency=1 brand.Text="  Manager v33" brand.TextXAlignment=Enum.TextXAlignment.Left brand.TextColor3=TEXT brand.Font=Enum.Font.Gotham brand.TextSize=16 brand.Parent=top
local closeB=Instance.new("TextButton") closeB.Size=UDim2.new(0,28,0,24) closeB.Position=UDim2.new(1,-34,0,6) closeB.BackgroundColor3=Color3.fromRGB(40,40,46) closeB.Text="_" closeB.TextColor3=TEXT closeB.Parent=top
local reopen=Instance.new("TextButton") reopen.Size=UDim2.new(0,90,0,28) reopen.Position=UDim2.new(0,16,0,16) reopen.BackgroundColor3=ACC reopen.Text="Manager" reopen.TextColor3=Color3.new(1,1,1) reopen.Visible=false reopen.Parent=gui
closeB.MouseButton1Click:Connect(function() root.Visible=false reopen.Visible=true end)
reopen.MouseButton1Click:Connect(function() root.Visible=true reopen.Visible=false end)
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
local stat=section(mainPage,"Status",372,0,188,240)
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
y+=32 toggle(mgr,"Auto Accept Join Requests","AutoAccept")
local sl=Instance.new("TextLabel") sl.Size=UDim2.new(1,-12,1,-28) sl.Position=UDim2.new(0,8,0,28) sl.BackgroundTransparency=1 sl.TextXAlignment=Enum.TextXAlignment.Left sl.TextYAlignment=Enum.TextYAlignment.Top sl.TextColor3=TEXT sl.Font=Enum.Font.Gotham sl.TextSize=12 sl.TextWrapped=true sl.Parent=stat
local setBox=section(setPage,"UI Settings",0,0,560,340) y=34
toggle(setBox,"Auto Create (host)","AutoCreate") toggle(setBox,"Auto Join (alts)","AutoJoin") toggle(setBox,"Auto Start","AutoStart") toggle(setBox,"Auto Replay","AutoReplay") toggle(setBox,"Auto Swing","AutoClick") toggle(setBox,"FPS Boost","FPSBoost") toggle(setBox,"Auto Sell <120","AutoSell")
task.spawn(function()
 while gui.Parent do
  local map,diff,lv=pick()
  sl.Text=string.format("v33 %s\nLevel: %s\n(%s)\nNOW: %s\nNEXT: %s %s\nState: %s\nParty %d/2",LP.Name,tostring(lv),st.lvlSrc,currentDungeon(),map,diff,st.name,seenCount())
  task.wait(0.4)
 end
end)

task.spawn(function()
 task.wait(2)
 print("[DQ] level", level(), st.lvlSrc, "now", currentDungeon(), "next", pick())
end)

if isDungeon() then
 task.spawn(function()
  st.name="Wait5s" task.wait(5)
  if S.AutoStart then for i=1,6 do fireStart() task.wait(1.2) end end
  st.name="Swinging"
 end)
 task.spawn(function() while gui.Parent do if S.AutoClick then swing() end task.wait(0.08) end end)
 task.spawn(function()
  task.wait(15)
  while gui.Parent and isDungeon() do
   if dungeonFinished() then st.name="Finished" afterWin() task.wait(12) end
   task.wait(2)
  end
 end)
else
 task.spawn(function()
  while gui.Parent and not isDungeon() do
   if isHost() then
    if hostLobby() and not lobbyIsWanted() then
     st.created=false st.started=false st.seen={}
     leaveLobby()
     st.name="DropOldLobby"
    elseif S.AutoCreate and not hostLobby() and not st.created then
     local want=select(1,pick())
     st.created=createLobby() or st.created
     st.name=st.created and ("Created "..want) or "CreateFail"
    elseif hostLobby() then
     st.created=true
     if S.WaitMembers and not partyReady() then
      st.started=false st.name="WAIT "..tostring(seenCount()).."/2"
     elseif S.AutoStart and not st.started then
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
