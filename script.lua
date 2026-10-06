-- MM2 Custom Executor Menu Framework
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()
local Window = OrionLib:MakeWindow({Name = "Custom MM2 Menu", HidePremium = false, SaveConfig = true, ConfigFolder = "MM2AI"})

-- Game Core Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- State Controls
local Toggles = {
    Aimbot = false,
    AntiFling = false,
    CoinFarm = false
}

-- 1. Tab Setup
local MainTab = Window:MakeTab({Name = "Combat & Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local PlayerTab = Window:MakeTab({Name = "Player Protections", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- 2. Anti-Fling Feature (Disables collisions with fast moving players)
PlayerTab:AddToggle({
    Name = "Anti-Fling",
    Default = false,
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
    end    
})

-- 3. Coin Farm Feature (Tweens character safely to floating map coins)
MainTab:AddToggle({
    Name = "Auto Farm Coins",
    Default = false,
    Callback = function(Value)
        Toggles.CoinFarm = Value
        task.spawn(function()
            while Toggles.CoinFarm and task.wait(0.5) do
                local mainMap = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("Map")
                if mainMap and mainMap:FindFirstChild("CoinContainer") then
                    for _, coin in pairs(mainMap.CoinContainer:GetChildren()) do
                        if coin:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            if not Toggles.CoinFarm then break end
                            -- Smooth movement interpolation to prevent anti-cheat triggers
                            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                            local speed = 25 -- Adjust speed dynamically
                            local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
                            local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = coin.CFrame})
                            tween:Play()
                            tween.Completed:Wait()
                        end
                    end
                end
            end
        end)
    end    
})

-- 4. Sheriff Aimbot Feature (Automatically tracks the Murderer's position)
MainTab:AddToggle({
    Name = "Sheriff Aimbot (Lock Murderer)",
    Default = false,
    Callback = function(Value)
        Toggles.Aimbot = Value
        RunService.RenderStepped:Connect(function()
            if not Toggles.Aimbot then return end
            -- Scan for player holding the knife
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and (player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")) then
                    local murdererRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if murdererRoot and Workspace.CurrentCamera then
                        -- Forces user's camera framework directly toward the target
                        Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, murdererRoot.Position)
                    end
                end
            end
        end)
    end    
})

-- 5. Murderer Kill All Button (Teleports players to player/hitbox trigger)
MainTab:AddButton({
    Name = "Murderer: Kill All",
    Callback = function()
        local weapon = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
        if not weapon then 
            OrionLib:MakeNotification({Name = "Error", Content = "You must hold your Knife first!", Time = 3})
            return 
        end
        
        -- Equips knife explicitly
        weapon.Parent = LocalPlayer.Character
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Fires target validation check block via executor layer
                local targetRoot = player.Character.HumanoidRootPart
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1)
                task.wait(0.1)
                -- Simulates trigger mechanism
                if weapon:FindFirstChild("Stab") then 
                    weapon.Stab:FireServer() 
                end
            end
        end
    end
})

OrionLib:Init()
