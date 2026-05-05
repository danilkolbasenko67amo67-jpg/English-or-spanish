local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Координаты
local teleLocs = {
    ["Troll"] = Vector3.new(-348.28, -301.37, -144.77),
    ["Win"] = Vector3.new(-295.78, 4.63, 4.23),
    ["Shop"] = Vector3.new(-294.78, -352.27, -38.77)
}
local farmPos = Vector3.new(-306.78, 9.63, 12.23)
local giveLocs = {
    ["Iron slap"] = Vector3.new(-282.2, 5.76, 12.28),
    ["Banana"] = Vector3.new(-285.38, -352.52, -268.36),
    ["Speed coin"] = Vector3.new(-504.3, -352.96, -114.25),
    ["Tp. Player"] = Vector3.new(-248.79, -321.52, -129.87),
    ["Invisible"] = Vector3.new(-239.28, -351.96, -75.77),
    ["Light slap"] = Vector3.new(-212.67, -351.92, -75.87),
    ["Cloud"] = Vector3.new(-185.28, -351.74, -75.77)
}

-- Удаление старого GUI если есть
if game.CoreGui:FindFirstChild("GeminiFinal") then game.CoreGui.GeminiFinal:Destroy() end

local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "GeminiFinal"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 400, 0, 220)
main.Position = UDim2.new(0.5, -200, 0.5, -110)
main.BackgroundColor3 = Color3.new(0,0,0)
main.BorderSizePixel = 3
main.BorderColor3 = Color3.new(1,1,1)
main.Active = true
main.Draggable = true

local sep = Instance.new("Frame", main)
sep.Size = UDim2.new(0, 3, 1, 0)
sep.Position = UDim2.new(0, 110, 0, 0)
sep.BackgroundColor3 = Color3.new(1,1,1)
sep.BorderSizePixel = 0

-- Контейнеры для вкладок
local frames = {}
local function createPage(name, isScroll)
    local f = isScroll and Instance.new("ScrollingFrame", main) or Instance.new("Frame", main)
    f.Name = name .. "Page"
    f.Size = UDim2.new(1, -125, 1, -20)
    f.Position = UDim2.new(0, 120, 0, 10)
    f.BackgroundTransparency = 1
    f.Visible = false
    if isScroll then 
        f.ScrollBarThickness = 3
        f.CanvasSize = UDim2.new(0,0,0,0)
        f.AutomaticCanvasSize = "Y"
        local l = Instance.new("UIListLayout", f)
        l.Padding = UDim.new(0, 5)
    end
    frames[name] = f
    return f
end

local fFarm = createPage("FARM", false)
local fTarg = createPage("TARG", false)
local fTele = createPage("TELE", true)
local fGive = createPage("GIVE", true)
local fInfo = createPage("INFO", false)

-- Вкладка TARG (Охота)
local tList = Instance.new("ScrollingFrame", fTarg)
tList.Size = UDim2.new(1, 0, 0.7, 0)
tList.Position = UDim2.new(0, 0, 0.3, 0)
tList.BackgroundTransparency = 1
tList.AutomaticCanvasSize = "Y"
tList.ScrollBarThickness = 2
local tl = Instance.new("UIListLayout", tList)

-- Кнопки вкладок
local function tab(name, y, realName)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0, 110, 0, 40)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundTransparency = 1
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = "SourceSansBold"
    b.TextSize = 22
    b.TextXAlignment = "Left"
    b.RichText = true
    b.Text = "  " .. name
    
    b.MouseButton1Click:Connect(function()
        for k, v in pairs(frames) do v.Visible = false end
        frames[realName].Visible = true
        bFarm.Text, bTarg.Text, bTele.Text, bGive.Text, bInfo.Text = "  FARM", "  TARG.", "  TELE.", "  GIVE", "  INFO"
        b.Text = "  " .. name .. '<font color="#FFFF00">+</font>'
    end)
    return b
end

bFarm = tab("FARM", 10, "FARM")
bTarg = tab("TARG.", 50, "TARG")
bTele = tab("TELE.", 90, "TELE")
bGive = tab("GIVE", 130, "GIVE")
bInfo = tab("INFO", 170, "INFO")

-- INFO Текст
local it = Instance.new("TextLabel", fInfo)
it.Size = UDim2.new(1,0,1,0)
it.BackgroundTransparency = 1
it.TextColor3 = Color3.new(1,1,1)
it.TextSize = 18
it.Font = "SourceSans"
it.TextWrapped = true
it.TextXAlignment = "Left"
it.TextYAlignment = "Top"
it.Text = "Hi, this is one of my scripts. It was created by Gemini AI. So, thanks to Google for this AI."

-- Логика
local hunt, farm, target, noclip = false, false, nil, false

-- Кнопки FARM и TARG OFF/ON
local function mainBtn(parent, txt)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.8, 0, 0.3, 0)
    b.Position = UDim2.new(0.1, 0, 0.1, 0)
    b.BackgroundColor3 = Color3.new(0,0,0)
    b.BorderColor3 = Color3.new(1,1,1)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 20
    b.Text = txt
    return b
end

local fb = mainBtn(fFarm, "FARM OFF")
fb.MouseButton1Click:Connect(function() farm = not farm fb.Text = farm and "FARM ON" or "FARM OFF" end)

local tb = mainBtn(fTarg, "OFF")
tb.MouseButton1Click:Connect(function() hunt = not hunt tb.Text = hunt and "ON" or "OFF" end)

-- Списки игроков и точек
local function addActionBtn(parent, name, fn)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -5, 0, 30)
    b.BackgroundColor3 = Color3.new(0,0,0)
    b.BorderColor3 = Color3.new(1,1,1)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = name
    b.MouseButton1Click:Connect(fn)
end

for n, p in pairs(teleLocs) do addActionBtn(fTele, n, function() player.Character.HumanoidRootPart.CFrame = CFrame.new(p) end) end
for n, p in pairs(giveLocs) do addActionBtn(fGive, n, function()
    local h = player.Character.HumanoidRootPart
    local o = h.CFrame noclip = true h.CFrame = CFrame.new(p) task.wait(1) h.CFrame = o task.wait(0.2) noclip = false
end) end

local function refresh()
    for _,v in pairs(tList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in pairs(Players:GetPlayers()) do if p ~= player then
        addActionBtn(tList, p.Name, function() target = p end)
    end end
end
Players.PlayerAdded:Connect(refresh) Players.PlayerRemoving:Connect(refresh) refresh()

-- Циклы
RunService.Stepped:Connect(function() if noclip and player.Character then for _,v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end)
RunService.Heartbeat:Connect(function() if hunt and target and target.Character then player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end end)
task.spawn(function() while true do if farm and player.Character then player.Character.HumanoidRootPart.CFrame = CFrame.new(farmPos) end task.wait(2) end end)

fInfo.Visible = true
bInfo.Text = '  INFO<font color="#FFFF00">+</font>'

