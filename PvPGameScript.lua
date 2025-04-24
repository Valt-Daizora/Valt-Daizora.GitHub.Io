-- PvP Game Script
-- This script sets up basic combat mechanics for a PvP Roblox game.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a RemoteEvent for damage handling
local DamageEvent = Instance.new("RemoteEvent")
DamageEvent.Name = "DamageEvent"
DamageEvent.Parent = ReplicatedStorage

-- Leaderboard Setup
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local Kills = Instance.new("IntValue")
    Kills.Name = "Kills"
    Kills.Value = 0
    Kills.Parent = leaderstats

    local Deaths = Instance.new("IntValue")
    Deaths.Name = "Deaths"
    Deaths.Value = 0
    Deaths.Parent = leaderstats
end)

-- Health and Damage System
DamageEvent.OnServerEvent:Connect(function(player, targetPlayer, damage)
    if targetPlayer and targetPlayer.Character then
        local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(damage)

            -- Track Kills and Deaths
            if humanoid.Health <= 0 then
                local leaderstats = player:FindFirstChild("leaderstats")
                if leaderstats then
                    local Kills = leaderstats:FindFirstChild("Kills")
                    if Kills then
                        Kills.Value = Kills.Value + 1
                    end
                end

                local targetLeaderstats = targetPlayer:FindFirstChild("leaderstats")
                if targetLeaderstats then
                    local Deaths = targetLeaderstats:FindFirstChild("Deaths")
                    if Deaths then
                        Deaths.Value = Deaths.Value + 1
                    end
                end
            end
        end
    end
end)

-- Tool Setup for Combat
local function setupWeapon(player)
    local tool = Instance.new("Tool")
    tool.Name = "Sword"
    tool.RequiresHandle = false
    tool.CanBeDropped = false

    -- Create an Attack Mechanic
    tool.Activated:Connect(function()
        local character = player.Character
        if character then
            local target = findTarget(character) -- Replace with your targeting logic
            if target then
                DamageEvent:FireServer(player, target, 25) -- 25 damage per hit
            end
        end
    end)

    tool.Parent = player.Backpack
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        setupWeapon(player)
    end)
end)

-- Function to find a target (simplified for demonstration purposes)
function findTarget(character)
    local range = 10
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer.Character and otherPlayer.Character ~= character then
            local distance = (character.PrimaryPart.Position - otherPlayer.Character.PrimaryPart.Position).Magnitude
            if distance <= range then
                return otherPlayer
            end
        end
    end
    return nil
end