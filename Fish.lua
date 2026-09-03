local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Tạo GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleAutoFishGui"
ScreenGui.Parent = PlayerGui

-- Nút ẩn/hiện menu chính (Hình tròn 30x30, có thể kéo thả di chuyển)
local MainToggleButton = Instance.new("TextButton")
MainToggleButton.Name = "MainToggleButton"
MainToggleButton.Parent = ScreenGui
MainToggleButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
MainToggleButton.Position = UDim2.new(0.5, -15, 0, 40)
MainToggleButton.Size = UDim2.new(0, 30, 0, 30)
MainToggleButton.Font = Enum.Font.SourceSansBold
MainToggleButton.Text = "OFF"
MainToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainToggleButton.TextSize = 9

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(1, 0)
MainCorner.Parent = MainToggleButton

-- Tính năng kéo thả di chuyển nút tròn
local dragging, dragInput, dragStart, startPos
MainToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainToggleButton.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Frame chứa ScrollingFrame (Canh ra giữa màn hình)
local ContainerFrame = Instance.new("Frame")
ContainerFrame.Name = "ContainerFrame"
ContainerFrame.Parent = ScreenGui
ContainerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContainerFrame.BackgroundTransparency = 0.1
ContainerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ContainerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
ContainerFrame.Size = UDim2.new(0, 235, 0, 270)
ContainerFrame.Visible = false

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 8)
ContainerCorner.Parent = ContainerFrame

-- Thanh cuộn ScrollingFrame bên trong
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = ContainerFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.Size = UDim2.new(0, 225, 0, 260)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)

-- Tự động sắp xếp các hàng dọc theo LayoutOrder
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Biến cấu hình
_G.SelectedRod = "Fishing Rod"
_G.SelectedBait = "Kelp Bait"
_G.AutoBuyBait = false
_G.AutoFishing = false
_G.AutoFishingQuest = false
_G.AutoQuestComplete = false
_G.AutoSellFish = false
_G.AutoSkillZ = false

-- Biến đếm LayoutOrder tự động tăng
local CurrentLayoutOrder = 0

-- Hàm tạo hàng công tắc gạt (Switch Toggle)
local function CreateToggleRow(name, callback)
    CurrentLayoutOrder = CurrentLayoutOrder + 1
    
    local rowFrame = Instance.new("Frame")
    rowFrame.Parent = ScrollingFrame
    rowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    rowFrame.Size = UDim2.new(0, 215, 0, 35)
    rowFrame.LayoutOrder = CurrentLayoutOrder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = rowFrame

    local label = Instance.new("TextLabel")
    label.Parent = rowFrame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Font = Enum.Font.SourceSansSemibold
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local switchBg = Instance.new("TextButton")
    switchBg.Parent = rowFrame
    switchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    switchBg.Position = UDim2.new(1, -45, 0.5, -10)
    switchBg.Size = UDim2.new(0, 40, 0, 20)
    switchBg.Text = ""
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg

    local switchCircle = Instance.new("Frame")
    switchCircle.Parent = switchBg
    switchCircle.BackgroundColor3 = Color3.fromRGB(140, 140, 160)
    switchCircle.Position = UDim2.new(0, 2, 0.5, -8)
    switchCircle.Size = UDim2.new(0, 16, 0, 16)
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = switchCircle

    local state = false
    switchBg.MouseButton1Click:Connect(function()
        state = not state
        
        local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = state and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(45, 45, 55)
        local circleColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 160)

        TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(switchCircle, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = circleColor}):Play()

        callback(state)
    end)
end

-- Hàm tạo hàng Dropdown
local function CreateDropdownRow(name, options, callback)
    CurrentLayoutOrder = CurrentLayoutOrder + 1
    
    local rowFrame = Instance.new("Frame")
    rowFrame.Parent = ScrollingFrame
    rowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    rowFrame.Size = UDim2.new(0, 215, 0, 35)
    rowFrame.LayoutOrder = CurrentLayoutOrder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = rowFrame

    local label = Instance.new("TextLabel")
    label.Parent = rowFrame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0, 80, 1, 0)
    label.Font = Enum.Font.SourceSansSemibold
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueButton = Instance.new("TextButton")
    valueButton.Parent = rowFrame
    valueButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    valueButton.Position = UDim2.new(0, 95, 0.5, -12)
    valueButton.Size = UDim2.new(0, 110, 0, 24)
    valueButton.Font = Enum.Font.SourceSansBold
    valueButton.Text = options[1]
    valueButton.TextColor3 = Color3.fromRGB(180, 180, 255)
    valueButton.TextSize = 10

    local valCorner = Instance.new("UICorner")
    valCorner.CornerRadius = UDim.new(0, 4)
    valCorner.Parent = valueButton

    local index = 1
    valueButton.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then index = 1 end
        valueButton.Text = options[index]
        callback(options[index])
    end)
end

-- Thêm các mục cần thiết vào menu
CreateDropdownRow("Rod:", {"Fishing Rod", "Gold Rod", "Shark Rod", "Shell Rod", "Treasure Rod"}, function(val)
    _G.SelectedRod = val
end)

CreateDropdownRow("Bait:", {"Basic Bait", "Kelp Bait", "Good Bait", "Abyssal Bait", "Frozen Bait", "Epic Bait", "Carnivore Bait"}, function(val)
    _G.SelectedBait = val
end)

CreateToggleRow("Auto Buy Bait", function(val)
    _G.AutoBuyBait = val
end)

CreateToggleRow("Auto Fish", function(val)
    _G.AutoFishing = val
end)

CreateToggleRow("Auto Quest", function(val)
    _G.AutoFishingQuest = val
end)

CreateToggleRow("Auto Complete", function(val)
    _G.AutoQuestComplete = val
end)

CreateToggleRow("Auto Sell Fish", function(val)
    _G.AutoSellFish = val
end)

CreateToggleRow("Auto Skill Z", function(val)
    _G.AutoSkillZ = val
end)

-- Xử lý ẩn hiện menu chính từ nút tròn
local menuVisible = false
MainToggleButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    ContainerFrame.Visible = menuVisible
    if menuVisible then
        MainToggleButton.Text = "ON"
        MainToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    else
        MainToggleButton.Text = "OFF"
        MainToggleButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
    end
end)

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FishReplicated = ReplicatedStorage:WaitForChild("FishReplicated")
local FishingRequest = FishReplicated:WaitForChild("FishingRequest")
local Config = require(FishReplicated.FishingClient.Config)
local GetWaterHeight = require(ReplicatedStorage.Util.GetWaterHeightAtLocation)
local MaxDistance = Config.Rod.MaxLaunchDistance

-- Vòng lặp Auto Fishing
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoFishing then
            pcall(function()
                local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local HRP = Char:FindFirstChild("HumanoidRootPart")
                if not HRP then return end

                local Tool = Char:FindFirstChildOfClass("Tool")  

                if _G.SelectedRod and (not Tool or Tool.Name ~= _G.SelectedRod) then  
                    local backpackTool = LocalPlayer.Backpack:FindFirstChild(_G.SelectedRod)  
                    if backpackTool then  
                        Char.Humanoid:EquipTool(backpackTool)  
                        Tool = backpackTool  
                    end  
                end  

                if Tool then  
                    local waterHeight = GetWaterHeight(HRP.Position)  
                    local _, hitPos = Workspace:FindPartOnRayWithIgnoreList(  
                        Ray.new(Char.Head.Position, HRP.CFrame.LookVector * MaxDistance),  
                        {Char, Workspace.Characters, Workspace.Enemies}  
                    )  
                    local TargetPos = hitPos and Vector3.new(hitPos.X, math.max(hitPos.Y, waterHeight), hitPos.Z)  
                    local State = Tool:GetAttribute("State")  
                    local ServerState = Tool:GetAttribute("ServerState")  

                    if TargetPos and (State == "ReeledIn" or ServerState == "ReeledIn") then  
                        FishingRequest:InvokeServer("StartCasting")  
                        task.wait()  
                        FishingRequest:InvokeServer("CastLineAtLocation", TargetPos, 100, true)  
                    elseif ServerState == "Biting" then  
                        FishingRequest:InvokeServer("Catching", true)  
                        task.wait(0.1)  
                        FishingRequest:InvokeServer("Catch", 1)  
                    end  
                end  
            end) 
        end  
    end
end)
-- Vòng lặp Auto Craft Bait (Chế tạo mồi tự động theo loại đã chọn)
task.spawn(function()
    while task.wait(3) do
        if _G.AutoBuyBait then
            pcall(function()
                local args = {
                    "Craft",
                    _G.SelectedBait,
                    1,
                    {}
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft"):InvokeServer(unpack(args))
            end)
        end
    end
end)

-- Vòng lặp Auto Fishing Quest
local RFJobsRemoteFunction3 = ReplicatedStorage.Modules.Net:WaitForChild("RF/JobsRemoteFunction")

local function HasQuest3()
    local questGui = LocalPlayer.PlayerGui:FindFirstChild("Quest") or LocalPlayer.PlayerGui:FindFirstChild("QuestGui")
    if questGui and questGui:FindFirstChild("Container") and questGui.Container:FindFirstChild("QuestTitle") then
        return true
    end
    return false
end

task.spawn(function()
    while task.wait(1) do
        if _G.AutoFishingQuest then
            pcall(function()
                if not HasQuest3() then
                    RFJobsRemoteFunction3:InvokeServer("FishingNPC", "Angler", "AskQuest")
                end
            end)
        end
    end
end)

-- Vòng lặp Auto Complete Quest
task.spawn(function()
    while task.wait(5) do 
        if _G.AutoQuestComplete then
            pcall(function()
                local RemotesTemp = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                if RemotesTemp and RemotesTemp:FindFirstChild("RF/JobsRemoteFunction") then
                    RemotesTemp["RF/JobsRemoteFunction"]:InvokeServer("FishingNPC", "FinishQuest")
                end
            end)
        end
    end
end)

-- Vòng lặp Auto Sell Fish
task.spawn(function()
    while task.wait(5) do 
        if _G.AutoSellFish then
            pcall(function()
                local RemotesTemp = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                if RemotesTemp and RemotesTemp:FindFirstChild("RF/JobsRemoteFunction") then
                    RemotesTemp["RF/JobsRemoteFunction"]:InvokeServer("FishingNPC", "SellFish")
                end
            end)
        end
    end
end)

-- Vòng lặp Auto Skill Z
local RFJobToolAbilities4 = ReplicatedStorage.Modules.Net:WaitForChild("RF/JobToolAbilities")

task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoSkillZ then
            pcall(function()
                RFJobToolAbilities4:InvokeServer("Z", true)
            end)
        end
    end
end)
