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
ContainerFrame.Size = UDim2.new(0, 235, 0, 300)
ContainerFrame.Visible = false

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 8)
ContainerCorner.Parent = ContainerFrame

-- Thanh cuộn ScrollingFrame bên trong
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = ContainerFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.Size = UDim2.new(0, 225, 0, 290)
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
_G.DangerSc = "Lv 1"
_G.SailBoats = false
_G.SelectedBoat = "Guardian"
_G.BoatSpeed = 250

local ListSeaBoat = {"Guardian", "PirateGrandBrigade", "MarineGrandBrigade", "PirateBrigade", "MarineBrigade", "PirateSloop", "MarineSloop", "Beast Hunter"}

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

-- Thêm các mục vào menu
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

CreateDropdownRow("Sea Zone", {"Lv 1", "Lv 2", "Lv 3", "Lv 4", "Lv 5", "Lv 6", "Lv Infinite"}, function(val)
    _G.DangerSc = val
end)

CreateDropdownRow("Boat Type", ListSeaBoat, function(val)
    _G.SelectedBoat = val
end)

CreateToggleRow("Sail Boats", function(val)
    _G.SailBoats = val
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

-- Vòng lặp Auto Buy Bait
task.spawn(function()
    while task.wait(5) do
        if _G.AutoBuyBait then
            pcall(function()
                local ReplicatedStorageTemp = game:GetService("ReplicatedStorage")
                local RemotesTemp = ReplicatedStorageTemp:FindFirstChild("Modules") and ReplicatedStorageTemp.Modules:FindFirstChild("Net")
                if RemotesTemp and RemotesTemp:FindFirstChild("RF/JobsRemoteFunction") then
                    RemotesTemp["RF/JobsRemoteFunction"]:InvokeServer("FishingNPC", "BuyBait", _G.SelectedBait)
                end
            end)
        end
    end
end)

-- Vòng lặp Auto Fishing Quest
local Players3 = game:GetService("Players")
local LocalPlayer3 = Players3.LocalPlayer
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local RFJobsRemoteFunction3 = ReplicatedStorage3.Modules.Net:WaitForChild("RF/JobsRemoteFunction")

local function HasQuest3()
    local questGui = LocalPlayer3.PlayerGui:FindFirstChild("Quest") or LocalPlayer3.PlayerGui:FindFirstChild("QuestGui")
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
                local ReplicatedStorageTemp = game:GetService("ReplicatedStorage")
                local RemotesTemp = ReplicatedStorageTemp:FindFirstChild("Modules") and ReplicatedStorageTemp.Modules:FindFirstChild("Net")
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
                local ReplicatedStorageTemp = game:GetService("ReplicatedStorage")
                local RemotesTemp = ReplicatedStorageTemp:FindFirstChild("Modules") and ReplicatedStorageTemp.Modules:FindFirstChild("Net")
                if RemotesTemp and RemotesTemp:FindFirstChild("RF/JobsRemoteFunction") then
                    RemotesTemp["RF/JobsRemoteFunction"]:InvokeServer("FishingNPC", "SellFish")
                end
            end)
        end
    end
end)

-- Vòng lặp Auto Skill Z
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local RFJobToolAbilities4 = ReplicatedStorage4.Modules.Net:WaitForChild("RF/JobToolAbilities")

task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoSkillZ then
            pcall(function()
                RFJobToolAbilities4:InvokeServer("Z", true)
            end)
        end
    end
end)
-- Vòng lặp Sail Boats & Danger Zone (Đã sửa lỗi tele lung tung và lỗi check mất thuyền cũ)
local replicated = game:GetService("ReplicatedStorage")
local plr = LocalPlayer

local function CheckBoat() 
    -- Kiểm tra thư mục Boats chính hãng của Blox Fruits xem có thuyền của mình không
    local boatsFolder = workspace:FindFirstChild("Boats")
    if boatsFolder then
        for _, boat in pairs(boatsFolder:GetChildren()) do
            local ownerVal = boat:FindFirstChild("Owner")
            if ownerVal and ownerVal.Value == plr.Name then
                return boat
            end
        end
    end
    
    -- Dự phòng kiểm tra thư mục MyBoat
    local myBoat = workspace:FindFirstChild("MyBoat")
    if myBoat then return myBoat end
    
    return nil
end

local function CheckShark() return false end
local function CheckTerrorShark() return false end
local function CheckFishCrew() return false end
local function CheckPiranha() return false end
local function CheckEnemiesBoat() return false end
local function CheckSeaBeast() return false end
local function CheckPirateGrandBrigade() return false end
local function CheckHauntedCrew() return false end
local function CheckLeviathan() return false end

local function LerpToTarget(targetCFrame)
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = _G.BoatSpeed or 250
    local timeToReach = distance / speed
    
    local startTime = tick()
    local startCFrame = hrp.CFrame
    
    while tick() - startTime < timeToReach do
        if not _G.SailBoats then break end
        local alpha = (tick() - startTime) / timeToReach
        hrp.CFrame = startCFrame:Lerp(targetCFrame, alpha)
        RunService.Heartbeat:Wait()
    end
    if _G.SailBoats then
        hrp.CFrame = targetCFrame
    end
end

local function TeleportToTarget(cf) LerpToTarget(cf) end
local function _tp(cf) LerpToTarget(cf) end

spawn(function()
  while task.wait(0.5) do
    if _G.SailBoats then 
      pcall(function()        
        local myBoat = CheckBoat()
        if not myBoat then
          -- Nếu hoàn toàn không có thuyền trên map mới tiến hành đi mua
          local buyBoatCFrame = CFrame.new(-16927.451, 9.086, 433.864)
          TeleportToTarget(buyBoatCFrame)
          if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and (buyBoatCFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 15 then 
              replicated.Remotes.CommF_:InvokeServer("BuyBoat", _G.SelectedBoat) 
              task.wait(2) -- Chờ thuyền khởi tạo xong
          end
        else
          -- Nếu đã có thuyền nhưng nhân vật chưa ngồi lên ghế lái (lỡ bấm nhảy ra ngoài)
          if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Sit == false then
            local vehicleSeat = myBoat:FindFirstChild("VehicleSeat") or myBoat:FindFirstChildWhichIsA("VehicleSeat", true)
            if vehicleSeat then
                local boatSeatCFrame = vehicleSeat.CFrame * CFrame.new(0, 3, 0)
                _tp(boatSeatCFrame)
                task.wait(0.5)
                if plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = boatSeatCFrame
                end
            end
          else                         
            -- Đã ngồi trên thuyền, tiến hành di chuyển đến Danger Zone đã chọn
            local CFrameSelectedZone
            if _G.DangerSc == "Lv 1" then CFrameSelectedZone = CFrame.new(-21998.375, 30.0006084, -682.309143)
            elseif _G.DangerSc == "Lv 2" then CFrameSelectedZone = CFrame.new(-26779.5215, 30.0005474, -822.858032)
            elseif _G.DangerSc == "Lv 3" then CFrameSelectedZone = CFrame.new(-31171.957, 30.0001011, -2256.93774)
            elseif _G.DangerSc == "Lv 4" then CFrameSelectedZone = CFrame.new(-34054.6875, 30.2187767, -2560.12012)
            elseif _G.DangerSc == "Lv 5" then CFrameSelectedZone = CFrame.new(-38887.5547, 30.0004578, -2162.99023)
            elseif _G.DangerSc == "Lv 6" then CFrameSelectedZone = CFrame.new(-44541.7617, 30.0003204, -1244.8584)
            elseif _G.DangerSc == "Lv Infinite" then CFrameSelectedZone = CFrame.new(-10000000, 31, 37016.25)
            end           
            
            repeat 
              task.wait() 
              if _G.SailBoats then
                  _tp(CFrameSelectedZone)
              end
            until _G.SailBoats == false or (plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Sit == false) 
            
            if not _G.SailBoats and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.Sit = false
            end
          end
        end
      end)
    end
  end
end)

spawn(function()
    while task.wait(1) do 
        pcall(function()
            if workspace:FindFirstChild("Boats") then
                for _, b in pairs(workspace.Boats:GetChildren()) do 
                    for _, d in pairs(b:GetDescendants()) do 
                        if d:IsA("BasePart") then 
                            d.CanCollide = not _G.SailBoats
                        end 
                    end 
                end
            end
        end) 
    end 
end)
