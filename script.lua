local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 Custom Menu",
   LoadingTitle = "Loading Elements...",
   LoadingSubtitle = "by ytdanred8",
   ConfigurationSaving = {
      Enabled = false
   }
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Toggles = {
    Aimbot = false,
    AntiFling = false,
    CoinFarm = false
}

-- Creating Tabs
local MainTab = Window:CreateTab("Combat & Farm", 4483345998)
local PlayerTab = Window:CreateTab("Protections", 4483345998)

-- Anti-Fling Toggle
PlayerTab:CreateToggle({
   Name = "Anti-Fling",
   CurrentValue = false,
   Callback = function(Value)
        Toggles.AntiFling = Value
        RunService.Stepped:Connect(function()
            if not Toggles.AntiFling then return end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.Velocity = Vector3.new(0,0,0)
                            part.RotVelocity = Vector3.new(0,0,0)
                        end
                    end
                end
            end
        end)
   end,
})

-- Auto Farm Toggle
MainTab:CreateToggle({
   Name = "Auto Farm Coins",
   CurrentValue = false,
   Callback = function(Value)
        Toggles.CoinFarm = Value
        task.spawn(function()
            while Toggles.CoinFarm and task.wait(0.5) do
                local mainMap = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("Map")
                if mainMap and mainMap:FindFirstChild("CoinContainer") then
                    for _, coin in pairs(mainMap.CoinContainer:GetChildren()) do
                        if coin:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            if not Toggles.CoinFarm then break end
                            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                            local speed = 25
                            local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
                            local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = coin.CFrame})
                            tween:Play()
                            tween.Completed:Wait()
                        end
                    end
                end
            end
        end)
   end,
})

-- Aimbot Toggle
MainTab:CreateToggle({
   Name = "Sheriff Aimbot (Lock Murderer)",
   CurrentValue = false,
   Callback = function(Value)
        Toggles.Aimbot = Value
        RunService.RenderStepped:Connect(function()
            if not Toggles.Aimbot then return end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and (player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")) then
                    local murdererRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if murdererRoot and Workspace.CurrentCamera then
                        Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, murdererRoot.Position)
                    end
                end
            end
        end)
   end,
})

-- Kill All Button
MainTab:CreateButton({
   Name = "Murderer: Kill All",
   Callback = function()
        local weapon = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
        if not weapon then return end
        weapon.Parent = LocalPlayer.Character
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1)
                task.wait(0.1)
                if weapon:FindFirstChild("Stab") then 
                    weapon.Stab:FireServer() 
                end
            end
        end
   end,
})
