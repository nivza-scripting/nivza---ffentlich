local FlyKey = Enum.KeyCode.V
local ActivationKey = "nivza5" -- Aktivierungsschlüssel
local SpeedKey = Enum.KeyCode.LeftControl

local SpeedKeyMultiplier = 3
local FlightSpeed = 190
local FlightAcceleration = 4
local TurnSpeed = 16

local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local User = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserCharacter = nil
local UserRootPart = nil
local Connection = nil

workspace.Changed:Connect(function()
    Camera = workspace.CurrentCamera
end)

local setCharacter = function(c)
    UserCharacter = c
    UserRootPart = c:WaitForChild("HumanoidRootPart")
end

User.CharacterAdded:Connect(setCharacter)
if User.Character then
    setCharacter(User.Character)
end

local CurrentVelocity = Vector3.new(0, 0, 0)
local Flight = function(delta)
    local BaseVelocity = Vector3.new(0, 0, 0)
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            BaseVelocity = BaseVelocity + (Camera.CFrame.LookVector * FlightSpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            BaseVelocity = BaseVelocity - (Camera.CFrame.RightVector * FlightSpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            BaseVelocity = BaseVelocity - (Camera.CFrame.LookVector * FlightSpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            BaseVelocity = BaseVelocity + (Camera.CFrame.RightVector * FlightSpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            BaseVelocity = BaseVelocity + (Camera.CFrame.UpVector * FlightSpeed)
        end
        if UserInputService:IsKeyDown(SpeedKey) then
            BaseVelocity = BaseVelocity * SpeedKeyMultiplier
        end
    end
    if UserRootPart then
        local car = UserRootPart:GetRootPart()
        if car.Anchored then return end
        if not isnetworkowner(car) then return end
        CurrentVelocity = CurrentVelocity:Lerp(
            BaseVelocity,
            math.clamp(delta * FlightAcceleration, 0, 1)
        )
        car.Velocity = CurrentVelocity + Vector3.new(0, 2, 0)
        if car ~= UserRootPart then
            car.RotVelocity = Vector3.new(0, 0, 0)
            car.CFrame = car.CFrame:Lerp(CFrame.lookAt(
                car.Position,
                car.Position + CurrentVelocity + Camera.CFrame.LookVector
            ), math.clamp(delta * TurnSpeed, 0, 1))
        end
    end
end

local function toggleFlight()
    if Connection then
        StarterGui:SetCore("SendNotification", {
            Title = "nivza car fly",
            Text = "Flight disabled"
        })
        Connection:Disconnect()
        Connection = nil
    else
        StarterGui:SetCore("SendNotification", {
            Title = "nivza car fly",
            Text = "Flight enabled"
        })
        CurrentVelocity = UserRootPart.Velocity
        Connection = RunService.Heartbeat:Connect(Flight)
    end
end

UserInputService.InputBegan:Connect(function(userInput, gameProcessed)
    if gameProcessed then return end
    if userInput.KeyCode == FlyKey then
        toggleFlight()
    end
end)

-- GUI Overlay
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
local KeyInput = Instance.new("TextBox")
local ActivateButton = Instance.new("TextButton")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Name = "FlightOverlay"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 200)

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

TextLabel.Name = "TextLabel"
TextLabel.Parent = MainFrame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 0, 0, 10)
TextLabel.Size = UDim2.new(1, 0, 0, 30)
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.Text = "Enter Activation Key"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 18

KeyInput.Name = "KeyInput"
KeyInput.Parent = MainFrame
KeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyInput.Size = UDim2.new(0.8, 0, 0.15, 0)
KeyInput.Font = Enum.Font.SourceSans
KeyInput.PlaceholderText = "Enter Key"
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 16

ActivateButton.Name = "ActivateButton"
ActivateButton.Parent = MainFrame
ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ActivateButton.Position = UDim2.new(0.1, 0, 0.5, 0)
ActivateButton.Size = UDim2.new(0.8, 0, 0.15, 0)
ActivateButton.Font = Enum.Font.SourceSansBold
ActivateButton.Text = "Activate"
ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActivateButton.TextSize = 18

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ToggleButton.Position = UDim2.new(0.1, 0, 0.7, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0.15, 0)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Toggle Flight"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Visible = false -- Wird erst sichtbar nach Aktivierung

ActivateButton.MouseButton1Click:Connect(function()
    if KeyInput.Text == ActivationKey then
        StarterGui:SetCore("SendNotification", {
            Title = "Activation",
            Text = "Key Accepted! Flight Ready."
        })
        ToggleButton.Visible = true
        KeyInput.Visible = false
        ActivateButton.Visible = false
        TextLabel.Text = "Use Button or Press V to Toggle"
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Activation",
            Text = "Invalid Key! Try Again."
        })
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    toggleFlight()
end)

StarterGui:SetCore("SendNotification", {
    Title = "nivza car fly",
    Text = "Loaded successfully, Press V or use the overlay to toggle"
})

-- Funktion, um das GUI verschiebbar zu machen
local dragging = false
local dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
