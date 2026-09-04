local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local OldGUI = PlayerGui:FindFirstChild("SimpleAutoFishGui")
if OldGUI then
    OldGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleAutoFishGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainToggleButton = Instance.new("TextButton")
MainToggleButton.Name = "MainToggleButton"
MainToggleButton.Parent = ScreenGui
MainToggleButton.Size = UDim2.fromOffset(42, 42)
MainToggleButton.Position = UDim2.new(0.5, -21, 0, 45)
MainToggleButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
MainToggleButton.BackgroundTransparency = 0.05
MainToggleButton.Text = "OFF"
MainToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainToggleButton.TextSize = 10
MainToggleButton.Font = Enum.Font.GothamBold
MainToggleButton.AutoButtonColor = false
MainToggleButton.Active = true
MainToggleButton.Selectable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(1, 0)
MainCorner.Parent = MainToggleButton

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.15
MainStroke.Parent = MainToggleButton

local ContainerFrame = Instance.new("Frame")
ContainerFrame.Name = "ContainerFrame"
ContainerFrame.Parent = ScreenGui
ContainerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ContainerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
ContainerFrame.Size = UDim2.fromOffset(235, 270)
ContainerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContainerFrame.BackgroundTransparency = 1
ContainerFrame.Visible = false
ContainerFrame.ClipsDescendants = true

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 12)
ContainerCorner.Parent = ContainerFrame

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Thickness = 1.5
ContainerStroke.Transparency = 1
ContainerStroke.Parent = ContainerFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Parent = ContainerFrame
ScrollingFrame.Position = UDim2.fromOffset(5, 5)
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local MenuScale = Instance.new("UIScale")
MenuScale.Scale = 0.85
MenuScale.Parent = ContainerFrame

local menuVisible = false
local menuAnimating = false

local OpenInfo = TweenInfo.new(
    0.28,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

local CloseInfo = TweenInfo.new(
    0.22,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.In
)

local function OpenMenu()
    if menuAnimating or menuVisible then
        return
    end

    menuAnimating = true
    menuVisible = true
    ContainerFrame.Visible = true
    MenuScale.Scale = 0.85
    ContainerFrame.BackgroundTransparency = 1
    ContainerStroke.Transparency = 1

    TweenService:Create(
        MenuScale,
        OpenInfo,
        {Scale = 1}
    ):Play()

    TweenService:Create(
        ContainerFrame,
        OpenInfo,
        {BackgroundTransparency = 0.1}
    ):Play()

    TweenService:Create(
        ContainerStroke,
        OpenInfo,
        {Transparency = 0.2}
    ):Play()

    task.delay(0.28, function()
        menuAnimating = false
    end)
end

local function CloseMenu()
    if menuAnimating or not menuVisible then
        return
    end

    menuAnimating = true
    menuVisible = false

    TweenService:Create(
        MenuScale,
        CloseInfo,
        {Scale = 0.85}
    ):Play()

    TweenService:Create(
        ContainerFrame,
        CloseInfo,
        {BackgroundTransparency = 1}
    ):Play()

    TweenService:Create(
        ContainerStroke,
        CloseInfo,
        {Transparency = 1}
    ):Play()

    task.delay(0.22, function()
        if not menuVisible then
            ContainerFrame.Visible = false
        end

        menuAnimating = false
    end)
end

local function UpdateButton()
    if menuVisible then
        MainToggleButton.Text = "ON"

        TweenService:Create(
            MainToggleButton,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad),
            {
                BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            }
        ):Play()
    else
        MainToggleButton.Text = "OFF"

        TweenService:Create(
            MainToggleButton,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad),
            {
                BackgroundColor3 = Color3.fromRGB(100, 30, 30)
            }
        ):Play()
    end
end

local dragging = false
local dragStart
local startPosition
local moved = false

local DRAG_THRESHOLD = 8

MainToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        moved = false
        dragStart = input.Position
        startPosition = MainToggleButton.Position
    end
end)

MainToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    if math.abs(delta.X) > DRAG_THRESHOLD
        or math.abs(delta.Y) > DRAG_THRESHOLD then

        moved = true
    end

    MainToggleButton.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        if dragging and not moved then
            if menuVisible then
                CloseMenu()
            else
                OpenMenu()
            end

            task.defer(UpdateButton)
        end

        dragging = false
    end
end)

UpdateButton()
