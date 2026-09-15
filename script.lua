-- DQ AutoProgress persist+melee
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
 local TeleportService = game:GetService("TeleportService")
 local HttpService = game:GetService("HttpService")
 local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()
 local PlayerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 15)
 if not PlayerGui then return end
 local SAVE_FILE = "DQAutoProgress.json"
 local Settings = {HostName="kurokazahood",RequiredPlayers={"royaldancersss"},AutoBest=true,Hardcore=true,Private=false,WaitForMembers=true,AutoAccept=true,WaitTimeout=45,CreateDelay=2,CheckInterval=2,AutoStart=true,AutoStartDungeon=true,AutoReplay=true,AutoMelee=true}
 pcall(function() if writefile and readfile and isfile and isfile(SAVE_FILE) then local data=HttpService:JSONDecode(readfile(SAVE_FILE)) if type(data)=="table" then for k,v in pairs(data) do Settings[k]=v end end end end)
 local function saveSettings() pcall(function() if writefile then writefile(SAVE_FILE, HttpService:JSONEncode(Settings)) end end) end
 local DUNGEON_PROGRESSION = {
  {name="Desert Temple",minLevel=1,difficulty="Easy"},
  {name="Desert Temple",minLevel=6,difficulty="Medium"},
  {name="Desert Temple",minLevel=12,difficulty="Hard"},
  {name="Desert Temple",minLevel=20,difficulty="Insane"},
  {name="Desert Temple",minLevel=27,difficulty="Nightmare"},
  {name="Winter Outpost",minLevel=30,difficulty="Insane"},
  {name="Winter Outpost",minLevel=55,difficulty="Nightmare"},
  {name="Pirate Island",minLevel=60,difficulty="Insane"},
  {name="Pirate Island",minLevel=65,difficulty="Nightmare"},
  {name="King's Castle",minLevel=70,difficulty="Insane"},
  {name="King's Castle",minLevel=75,difficulty="Nightmare"},
  {name="The Underworld",minLevel=80,difficulty="Insane"},
  {name="The Underworld",minLevel=85,difficulty="Nightmare"},
  {name="Samurai Palace",minLevel=90,difficulty="Insane"},
  {name="Samurai Palace",minLevel=110,difficulty="Nightmare"},
  {name="Ghastly Harbor",minLevel=120,difficulty="Insane"},
  {name="Enchanted Forest",minLevel=170,difficulty="Insane"},
  {name="Enchanted Forest",minLevel=175,difficulty="Nightmare"},
  {name="Northern Lands",minLevel=180,difficulty="Insane"},
  {name="Northern Lands",minLevel=185,difficulty="Nightmare"},
 }
 local State,running,joinedOnce,lobbySeenNames="Idle",true,false,{}
 local function getRemotes() return RS:FindFirstChild("remotes") end
 local function getPlayerLevel()
  local ls=LP:FindFirstChild("leaderstats") or LP:WaitForChild("leaderstats",3)
  if ls then local level=ls:FindFirstChild("Level") or ls:FindFirstChild("level") if level then return tonumber(level.Value) or 1 end end
  return 1
 end
 local function parseMembers(text) local list={} for name in string.gmatch(text or "","[^,%s]+") do table.insert(list,name) end return list end
 local function getCurrentDungeon()
  local level,current=getPlayerLevel(),DUNGEON_PROGRESSION[1]
  if Settings.AutoBest then for _,d in ipairs(DUNGEON_PROGRESSION) do if level>=d.minLevel then current=d else break end end end
  return current
 end
 local function fireRemote(names,method,...)
  local remotes=getRemotes() if not remotes then return false end
  for _,name in ipairs(names) do
   local remote=remotes:FindFirstChild(name)
   if remote then
    local ok=pcall(function(...)
     if method=="Invoke" and remote:IsA("RemoteFunction") then remote:InvokeServer(...) else remote:FireServer(...) end
    end,...)
    if ok then return true end
   end
  end
  return false
 end
 local function getInLobbyFolder() local g=workspace:FindFirstChild("games") return g and g:FindFirstChild("inLobby") end
 local function getHostLobby()
  local inLobby=getInLobbyFolder() if not inLobby then return nil end
  for _,lobby in ipairs(inLobby:GetChildren()) do if lobby.Name:lower()==Settings.HostName:lower() then return lobby end end
  return nil
 end
 local LOBBY_PLACES={[77649408247578]=true,[115445507767090]=true}
 local function inHub() if LOBBY_PLACES[game.PlaceId] then return true end return getInLobbyFolder()~=nil end
 local function nameInObject(obj,target)
  if not obj then return false end local t=target:lower()
  if obj.Name:lower()==t then return true end
  for _,d in ipairs(obj:GetDescendants()) do
   if d.Name:lower()==t then return true end
   if (d:IsA("StringValue") or d:IsA("ObjectValue")) and tostring(d.Value):lower()==t then return true end
  end
  return false
 end
 local function memberInLobby(name)
  local lobby=getHostLobby()
  if lobby and nameInObject(lobby,name) then return true end
  if lobbySeenNames[name:lower()] then return true end
  for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower()==name:lower() then return true end end
  return false
 end
 local function allRequiredPlayersJoined()
  if not Settings.WaitForMembers or #Settings.RequiredPlayers==0 then return true end
  for _,name in ipairs(Settings.RequiredPlayers) do if not memberInLobby(name) then return false end end
  return true
 end
 pcall(function()
  PlayerGui.DescendantAdded:Connect(function(obj)
   if obj:IsA("TextLabel") or obj:IsA("TextButton") then
    local added=string.match(string.lower(obj.Text or ""),"player added to lobby:%s*(%S+)")
    if added then lobbySeenNames[added]=true end
   end
  end)
 end)
 local function createLobby()
  local remotes=getRemotes() if not remotes then return false end
  local createRemote=remotes:FindFirstChild("createLobby") if not createRemote then return false end
  local dungeon=getCurrentDungeon()
  print("[Host] Creating",dungeon.name,dungeon.difficulty,"lvl",getPlayerLevel())
  return pcall(function() createRemote:InvokeServer(dungeon.name,dungeon.difficulty,0,Settings.Hardcore,Settings.Private,false) end)
 end
 local function startDungeon()
  if not Settings.AutoStartDungeon then return false end
  local ok=fireRemote({"startDungeon"},"Fire") or fireRemote({"startDungeon"},"Invoke")
  if ok then print("[Host] Started dungeon") end return ok
 end
 local function clickReplayButtons()
  local clicked=false
  for _,obj in ipairs(PlayerGui:GetDescendants()) do
   if obj:IsA("TextButton") or obj:IsA("ImageButton") then
    local t=string.lower(obj.Text or obj.Name or "")
    if string.find(t,"replay",1,true) or string.find(t,"play again",1,true) then
     pcall(function() if typeof(firesignal)=="function" then firesignal(obj.MouseButton1Click) end end)
     clicked=true
    end
   end
  end
  return clicked
 end
 local function replayDungeon()
  if not Settings.AutoReplay then return false end
  local ok=fireRemote({"replay","replayDungeon","playAgain","restartDungeon"},"Fire") or fireRemote({"replay","replayDungeon","playAgain","restartDungeon"},"Invoke") or clickReplayButtons()
  if ok then print("[Host] Auto replay") State="Replaying" end
  return ok
 end
 local function tryJoinHost()
  local remotes=getRemotes() if not remotes then return false end
  local joinRemote=remotes:FindFirstChild("joinDungeon") if not joinRemote then return false end
  local lobby=getHostLobby() if not lobby then return false end
  local ok=pcall(function() joinRemote:InvokeServer(lobby.Name) end)
  if ok then print("[Joiner] Joined",Settings.HostName) return true end
  return false
 end
 local function acceptJoinRequests()
  if not Settings.AutoAccept then return end
  fireRemote({"acceptRequest","acceptJoin","acceptJoinRequest","acceptPlayer"},"Fire")
  fireRemote({"acceptRequest","acceptJoin","acceptJoinRequest","acceptPlayer"},"Invoke")
 end
 local function returnToLobby()
  State="Returning"
  local sent=fireRemote({"leaveDungeon","returnToLobby","leaveLobby","exitDungeon"},"Fire") or fireRemote({"leaveDungeon","returnToLobby","leaveLobby","exitDungeon"},"Invoke")
  if not sent then pcall(function() TeleportService:Teleport(game.PlaceId,LP) end) end
 end
 local function isPlayerModel(model)
  for _,p in ipairs(Players:GetPlayers()) do if p.Character==model or p.Name==model.Name then return true end end
  return false
 end
 local function getNearestMob()
  local char=LP.Character local root=char and char:FindFirstChild("HumanoidRootPart") if not root then return nil end
  local best,bestDist=nil,250
  for _,model in ipairs(workspace:GetDescendants()) do
   if model:IsA("Model") and not isPlayerModel(model) then
    local hum=model:FindFirstChildOfClass("Humanoid")
    local hrp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    if hum and hrp and hum.Health>0 then
     local dist=(hrp.Position-root.Position).Magnitude
     if dist<bestDist then best,bestDist=model,dist end
    end
   end
  end
  return best
 end
 local function meleeAttack()
  if not Settings.AutoMelee or inHub() then return end
  State="InDungeon"
  local char=LP.Character if not char then return end
  local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
  local mob=getNearestMob() if not mob then return end
  local target=mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob.PrimaryPart if not target then return end
  pcall(function() hum:MoveTo(target.Position) end)
  local tool=char:FindFirstChildOfClass("Tool") or LP.Backpack:FindFirstChildOfClass("Tool")
  if tool and tool.Parent~=char then pcall(function() hum:EquipTool(tool) end) end
  tool=char:FindFirstChildOfClass("Tool")
  if tool then pcall(function() tool:Activate() end) end
 end
 local old=PlayerGui:FindFirstChild("DQAutoProgress") if old then old:Destroy() end
 local ScreenGui=Instance.new("ScreenGui") ScreenGui.Name="DQAutoProgress" ScreenGui.ResetOnSpawn=false ScreenGui.Parent=PlayerGui
 local Window=Instance.new("Frame") Window.Size=UDim2.new(0,740,0,520) Window.Position=UDim2.new(0.5,-370,0.5,-260) Window.BackgroundColor3=Color3.fromRGB(16,16,18) Window.BorderSizePixel=0 Window.Active=true Window.Draggable=true Window.Parent=ScreenGui
 Instance.new("UICorner",Window).CornerRadius=UDim.new(0,8)
 local Title=Instance.new("TextLabel") Title.Size=UDim2.new(1,0,0,28) Title.BackgroundTransparency=1 Title.Text="kuya  persist+melee" Title.TextColor3=Color3.fromRGB(230,230,235) Title.Font=Enum.Font.Gotham Title.TextSize=16 Title.Parent=Window
 local Status=Instance.new("TextLabel") Status.Size=UDim2.new(1,-16,0,80) Status.Position=UDim2.new(0,8,0,36) Status.BackgroundTransparency=1 Status.TextXAlignment=Enum.TextXAlignment.Left Status.TextYAlignment=Enum.TextYAlignment.Top Status.TextColor3=Color3.fromRGB(200,200,210) Status.Font=Enum.Font.Gotham Status.TextSize=13 Status.TextWrapped=true Status.Parent=Window
 local y=130
 local function addToggle(name,default)
  local row=Instance.new("TextButton") row.Size=UDim2.new(1,-24,0,24) row.Position=UDim2.new(0,12,0,y) row.BackgroundColor3=default and Color3.fromRGB(140,90,255) or Color3.fromRGB(50,50,56) row.Text=name row.TextColor3=Color3.fromRGB(230,230,235) row.Font=Enum.Font.Gotham row.TextSize=12 row.Parent=Window
  Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
  local state=default
  row.MouseButton1Click:Connect(function() state=not state row.BackgroundColor3=state and Color3.fromRGB(140,90,255) or Color3.fromRGB(50,50,56) saveSettings() end)
  y+=28
  return function() return state end
 end
 local getAutoBest=addToggle("Auto Best Dungeon",Settings.AutoBest)
 local getHardcore=addToggle("Hardcore Lobby",Settings.Hardcore)
 local getPrivate=addToggle("Private Lobby",Settings.Private)
 local getWait=addToggle("Wait For Members",Settings.WaitForMembers)
 local getAccept=addToggle("Auto Accept",Settings.AutoAccept)
 local getAutoStartDungeon=addToggle("Auto Start Dungeon",Settings.AutoStartDungeon)
 local getAutoReplay=addToggle("Auto Replay",Settings.AutoReplay)
 local getAutoMelee=addToggle("Auto Melee Attack",Settings.AutoMelee)
 local getAutoStart=addToggle("Auto Start Loop",Settings.AutoStart)
 local HostBox=Instance.new("TextBox") HostBox.Size=UDim2.new(1,-24,0,24) HostBox.Position=UDim2.new(0,12,0,y) HostBox.BackgroundColor3=Color3.fromRGB(32,32,36) HostBox.Text=Settings.HostName HostBox.TextColor3=Color3.fromRGB(230,230,235) HostBox.Font=Enum.Font.Gotham HostBox.TextSize=12 HostBox.Parent=Window y+=30
 local MembersBox=Instance.new("TextBox") MembersBox.Size=UDim2.new(1,-24,0,24) MembersBox.Position=UDim2.new(0,12,0,y) MembersBox.BackgroundColor3=Color3.fromRGB(32,32,36) MembersBox.Text=table.concat(Settings.RequiredPlayers,", ") MembersBox.TextColor3=Color3.fromRGB(230,230,235) MembersBox.Font=Enum.Font.Gotham MembersBox.TextSize=12 MembersBox.Parent=Window
 local function sync()
  Settings.HostName=HostBox.Text:gsub("%s+","")
  Settings.RequiredPlayers=parseMembers(MembersBox.Text)
  Settings.AutoBest=getAutoBest() Settings.Hardcore=getHardcore() Settings.Private=getPrivate()
  Settings.WaitForMembers=getWait() Settings.AutoAccept=getAccept()
  Settings.AutoStartDungeon=getAutoStartDungeon() Settings.AutoReplay=getAutoReplay()
  Settings.AutoMelee=getAutoMelee() Settings.AutoStart=getAutoStart()
 end
 task.spawn(function()
  while ScreenGui.Parent do
   sync()
   local d=getCurrentDungeon()
   Status.Text=string.format("Account: %s\nState: %s\nBest: %s %s\nLvl: %s\nPlace: %s",
    LP.Name,State,d.name,d.difficulty,tostring(getPlayerLevel()),tostring(game.PlaceId))
   task.wait(1)
  end
 end)
 task.spawn(function() while ScreenGui.Parent do if Settings.AutoAccept and inHub() then acceptJoinRequests() end if Settings.AutoReplay and not inHub() then replayDungeon() end task.wait(2) end end)
 task.spawn(function() while ScreenGui.Parent do if Settings.AutoMelee then meleeAttack() end task.wait(0.2) end end)
 task.spawn(function()
  task.wait(3)
  while ScreenGui.Parent and running do
   sync()
   if Settings.AutoStart then
    local isHost=LP.Name:lower()==Settings.HostName:lower()
    local hub=inHub()
    local hostLobby=getHostLobby()
    if not hub then State="InDungeon" joinedOnce=false task.wait(1)
    else
     if State=="InDungeon" then State="Hub" lobbySeenNames={} joinedOnce=false task.wait(3)
     elseif isHost then
      if hostLobby==nil then State="Creating" createLobby() task.wait(2)
      else
       if Settings.WaitForMembers and #Settings.RequiredPlayers>0 then
        State="Waiting" local waited=0
        while running and waited<Settings.WaitTimeout and not allRequiredPlayersJoined() do
         if Settings.AutoAccept then acceptJoinRequests() end task.wait(1) waited+=1 State="Waiting "..waited.."s"
        end
       end
       if (not Settings.WaitForMembers) or allRequiredPlayersJoined() or #Settings.RequiredPlayers==0 then
        if Settings.AutoStartDungeon then State="Starting" task.wait(Settings.CreateDelay) startDungeon() State="InDungeon" task.wait(6)
        else State="Ready" task.wait(2) end
       else State="Timeout" task.wait(3) end
      end
     else
      if hostLobby then
       if not joinedOnce then State="Joining" if tryJoinHost() then joinedOnce=true State="InLobby" end
       else State="InLobby" end
      else joinedOnce=false State="Looking" end
      task.wait(Settings.CheckInterval)
     end
    end
   end
   task.wait(1)
  end
 end)
 print("[DQ AutoProgress] persist+melee loaded")
end)
