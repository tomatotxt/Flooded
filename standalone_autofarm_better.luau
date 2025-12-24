local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Alert = Workspace.svcl_com.Alert
local Modes = {"Hard", "Medium", "Easy"}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    warn("Anti-AFK triggered!")
    VirtualUser:CaptureController();VirtualUser:ClickButton2(Vector2.new())
end)

local function GetChar()
    return LocalPlayer.Character or (LocalPlayer.CharacterAdded:wait() and LocalPlayer.Character)
end

local function Touch(Part)
    local RootPart = GetChar():WaitForChild("HumanoidRootPart")
    firetouchinterest(RootPart, Part, 0)
    firetouchinterest(RootPart, Part, 1)
end

local function Crack_Code()
    for i,v in pairs(Workspace:GetDescendants()) do
        if v.Name == "ClickDetector" then
            if math.random(0,1) == 1 then
                fireclickdetector(v,2)
            end
            task.wait()
        end
    end
end

local function Press_Buttons()
    for i,v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Button" then
            local Character = GetChar()
            firetouchinterest(v,Character.HumanoidRootPart,0)
            task.wait()
            firetouchinterest(v,Character.HumanoidRootPart,1)
            v.Name = "Clicked"
        end
    end
end

local function FindReady()
    while task.wait() do
        for _, Mode in Modes do
            local ModeModel = Workspace[Mode]
            local Info = ModeModel.Info
            if Info.Value:match("Game is Ready!") then
                return ModeModel
            end
        end
    end
end

local function JoinLift(ModeModel)
    Touch(ModeModel.Entry.LiftEntryInfo)
end

local function GotoSafespot(ModeModel)
    GetChar():MoveTo(ModeModel:WaitForChild("Main"):WaitForChild("CodeDoor"):WaitForChild("MainOutput").Position)
end

local function Escape(ModeModel)
    Touch(ModeModel.Main.Exit)
end

local Wins = 0
local StartTime = tick()
while task.wait() do
    print("Looking for next round..")
    local CurrentMode = FindReady()
    JoinLift(CurrentMode)
    repeat task.wait() until LocalPlayer.Ingame.Value >= 1
    print("Going to Safespot..")
    GotoSafespot(CurrentMode)
    local FinalRoomActive = false
    local Connection
    Connection = Alert.OnClientEvent:Connect(function(message)
        if message:match("Final Room") then
            print("Final Room Active. Escaping..")
            FinalRoomActive = true
        end
    end)
    repeat task.wait() 
        -- Crack Code and Press Buttons to help players (faster they win faster you win)
        Crack_Code()
        Press_Buttons()
        if CurrentMode.Info.Value:match("1/") or CurrentMode.Info.Value:match("1 P") then
            FinalRoomActive = true
            print("Detected Solo, Skipping..")
        end
    until FinalRoomActive == true
    Connection:Disconnect()
    -- Repeat Escape to ensure server lag doesn't cause touch to be ignored.
    repeat task.wait()
        Escape(CurrentMode)
    until LocalPlayer.Ingame.Value <= 0
    -- Teleport to Lobby Area for coolness.
    GetChar():WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-392, 261, 161)
    Wins += 1
    local Runtime = tick() - StartTime
    warn("----------------WIN STATISTICS----------------")
    warn("Runtime:", math.round(Runtime/60), "minutes")
    warn("Current Session Wins:", Wins)
    warn(math.round(((Wins/Runtime) * 60) * 60), "wins per hour.")
end
