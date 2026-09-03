local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Tự động dọn dẹp các GUI cũ (Clear Gui OLD) để tránh bị lỗi chồng chéo
pcall(function()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name == "SimpleAutoFishGui" then
            gui:Destroy()
        end
    end
end)

-- Tạo GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleAutoFishGui"
ScreenGui.Parent = PlayerGui

-- Nút ẩn/hiện menu chính
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(0.015, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.BackgroundTransparency = 0.05
ToggleButton.Image = "rbxassetid://77399452392419"
ToggleButton.ScaleType = Enum.ScaleType.Crop
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.ClipsDescendants = true
ToggleButton.AutoButtonColor = false

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleButton.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleButton
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 1.5

-- Frame chứa ScrollingFrame (Canh ra giữa màn hình, cấu hình trạng thái ban đầu để Tween)
local ContainerFrame = Instance.new("Frame")
ContainerFrame.Name = "ContainerFrame"
ContainerFrame.Parent = ScreenGui
ContainerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContainerFrame.BackgroundTransparency = 1 -- Bắt đầu bằng trong suốt
ContainerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ContainerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
ContainerFrame.Size = UDim2.new(0, 0, 0, 0) -- Bắt đầu với kích thước 0 để hiệu ứng phóng to mượt hơn
ContainerFrame.Visible = false
ContainerFrame.ClipsDescendants = true

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 8)
ContainerCorner.Parent = ContainerFrame

-- Thêm viền màu xanh dương cho bảng menu
local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Parent = ContainerFrame
ContainerStroke.Color = Color3.fromRGB(0, 160, 255)
ContainerStroke.Thickness = 2

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

-- Biến cấu hình (Mồi mặc định là Basic Bait)
_G.SelectedRod = "Fishing Rod"
_G.SelectedBait = "Basic Bait"
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
local function CreateDropdownRow(name, options, defaultVal, callback)
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
    valueButton.Text = defaultVal
    valueButton.TextColor3 = Color3.fromRGB(180, 180, 255)
    valueButton.TextSize = 10

    local valCorner = Instance.new("UICorner")
    valCorner.CornerRadius = UDim.new(0, 4)
    valCorner.Parent = valueButton

    local index = 1
    for i, opt in ipairs(options) do
        if opt == defaultVal then
            index = i
            break
        end
    end

    valueButton.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then index = 1 end
        valueButton.Text = options[index]
        callback(options[index])
    end)
end

-- Hàm tạo nút bấm chức năng
local function CreateButtonRow(name, buttonText, callback)
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
    label.Size = UDim2.new(0, 90, 1, 0)
    label.Font = Enum.Font.SourceSansSemibold
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local actionButton = Instance.new("TextButton")
    actionButton.Parent = rowFrame
    actionButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    actionButton.Position = UDim2.new(0, 105, 0.5, -12)
    actionButton.Size = UDim2.new(0, 100, 0, 24)
    actionButton.Font = Enum.Font.SourceSansBold
    actionButton.Text = buttonText
    actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionButton.TextSize = 11

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = actionButton

    actionButton.MouseButton1Click:Connect(function()
        callback()
    end)
end

-- Thêm các mục vào menu
CreateDropdownRow("Rod:", {"Fishing Rod", "Gold Rod", "Shark Rod", "Shell Rod", "Treasure Rod"}, "Fishing Rod", function(val)
    _G.SelectedRod = val
end)

CreateDropdownRow("Bait:", {"Basic Bait", "Kelp Bait", "Good Bait", "Abyssal Bait", "Frozen Bait", "Epic Bait", "Carnivore Bait"}, "Basic Bait", function(val)
    _G.SelectedBait = val
end)

CreateToggleRow("Auto Craft Bait", function(val)
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

CreateButtonRow("Clear Gui:", "Delete OLD", function()
    pcall(function()
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui.Name == "SimpleAutoFishGui" and gui ~= ScreenGui then
                gui:Destroy()
            end
        end
        ScreenGui:Destroy()
    end)
end)

-- Xử lý ẩn hiện menu chính kết hợp TweenService 0.5 giây
local menuVisible = false
local isTweening = false

ToggleButton.MouseButton1Click:Connect(function()
    if isTweening then return end
    menuVisible = not menuVisible
    isTweening = true

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    if menuVisible then
        ContainerFrame.Visible = true
        ToggleStroke.Color = Color3.fromRGB(255, 100, 100)
        
        local openTween = TweenService:Create(ContainerFrame, tweenInfo, {
            Size = UDim2.new(0, 235, 0, 270),
            BackgroundTransparency = 0.1
        })
        openTween:Play()
        openTween.Completed:Wait()
    else
        ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
        
        local closeTween = TweenService:Create(ContainerFrame, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        closeTween:Play()
        closeTween.Completed:Wait()
        ContainerFrame.Visible = false
    end
    
    isTweening = false
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

-- Vòng lặp Auto Craft Bait
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
    while task.wait(1) do
        if _G.AutoSkillZ then
            pcall(function()
                RFJobToolAbilities4:InvokeServer("Z", true)
            end)
        end
    end
end)
