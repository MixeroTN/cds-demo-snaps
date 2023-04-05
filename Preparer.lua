--ReplicatedFirst/Preparer.lua
local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Intro = script.Parent:WaitForChild("Intro")
 local LaunchInStudio = Intro:WaitForChild("LaunchInStudio")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
 local IntroGUI = PlayerGui:WaitForChild("IntroGUI")
local L_White = Lighting:WaitForChild("White")

local toPreload = {
    Lighting,
    PlayerGui,
    ReplicatedStorage
}


function environmentCheck()
    return RunService:IsStudio() and not LaunchInStudio.Value
end

function preloadAsync(...)
    for _, table in ipairs({...}) do
        pcall(function()
            ContentProvider:PreloadAsync(table)
        end)
    end
end

function prepareObjects()
    L_White.Enabled = true
end

function skipIntro()
    if environmentCheck() then
        IntroGUI.Event:Fire()
        return true
    end
end


skipIntro()
preloadAsync(toPreload)
prepareObjects()
