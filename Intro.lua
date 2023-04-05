--ReplicatedFirst/Intro.lua
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local IntroGUI = script:WaitForChild("IntroGUI")
local LaunchInStudio = script:WaitForChild("LaunchInStudio")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
 local PlayerModule = PlayerScripts:WaitForChild("PlayerModule")

local ArrivingTeleportGui = TeleportService:GetArrivingTeleportGui()
local PlayerControls = require(PlayerModule):GetControls()


function environmentCheck()
    return not RunService:IsStudio() or LaunchInStudio.Value
end

function mobileCheck()
	if UserInputService.TouchEnabled
	and not UserInputService.KeyboardEnabled
	and not UserInputService.MouseEnabled
	and not GuiService:IsTenFootInterface() then
		return true
	end
end

function touchGuiCheck()
	local TouchGui
	pcall(function()
		TouchGui = PlayerGui:FindFirstChild("TouchGui")
	end)
	return TouchGui
end

function setArrivingTeleportGui()
	ArrivingTeleportGui.Name = "ArrivingTeleportGui"
	ArrivingTeleportGui.Frame.Info.Text = "Loading..."
	ArrivingTeleportGui.DisplayOrder = 255
	ArrivingTeleportGui.Parent = PlayerGui
	ReplicatedFirst:RemoveDefaultLoadingScreen()
end

function coreCall(method, ...)
	local MAX_RETRIES = 100
	local result = {}

	for retries = 1, MAX_RETRIES do
		result = {pcall(StarterGui[method], StarterGui, ...)}
		if result[1] then
			break
		end
		RunService.Stepped:Wait()
	end
	return unpack(result)
end

function safeDestroy(...)
	for _, element in ipairs({...}) do
		if element then
			element:Destroy()
		end
	end
end

function main()
	local loadingDelay = 2
	local mainGuiDestroyDelay = 1

	local mainGui = IntroGUI:Clone()
	local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	local fadeBackgroundTween = TweenService:Create(mainGui.Frame, fadeInfo, {BackgroundTransparency = 1})
	local fadeTextTween = TweenService:Create(mainGui.Frame.Loading, fadeInfo, {TextTransparency = 1})


	coreCall('SetCore', 'TopbarEnabled', false)
	UserInputService.MouseIconEnabled = false

	mainGui.Parent = PlayerGui
	safeDestroy(ArrivingTeleportGui)


	local function preloaded()
		ReplicatedFirst:RemoveDefaultLoadingScreen()
		if mobileCheck() and touchGuiCheck() then
			PlayerControls:Disable()
			touchGuiCheck().Enabled = false
		end
	end

	local function confirmed()
		if mobileCheck() and touchGuiCheck() then
			for _, element in pairs(touchGuiCheck():GetDescendants()) do
				if element.Name == 'JumpButton' then
					element.Visible = false
				end
			end
		end
		
		task.wait(loadingDelay)
		fadeTextTween:Play()
		fadeBackgroundTween:Play()

		local mainSound = mainGui.Frame.Sound
		mainSound.Name = "MenuSound"
		mainSound.Parent = PlayerGui
		mainSound:Play()

		task.wait(mainGuiDestroyDelay)
		mainGui:Destroy()
	end

	ContentProvider:PreloadAsync({mainGui}, preloaded)
	mainGui.Event.Event:Once(confirmed)
end

function trueCheck(value, redirect)
	if value and redirect then
		redirect()
	end
	return value
end

trueCheck(environmentCheck(), main)
