-- Sets up the Screen
-- Server/Local Script
local GPU = require(script.Parent.Parent.Hardware.GPU)
-- insert where your imagelabel is, ex: having a part with a surfacegui and a imagelabel
local Screen = game.Workspace:WaitForChild("Display"):WaitForChild("DisplayGui"):WaitForChild("Screen")
Screen.ImageContent = Content.fromObject(GPU.ed)
