-- Sets up the Screen
-- Server/Local Script
local GPU = require(script.Parent.Parent.Hardware.GPU)
local Screen = game.Workspace:WaitForChild("Display"):WaitForChild("DisplayGui"):WaitForChild("Screen")
Screen.ImageContent = Content.fromObject(GPU.ed)
