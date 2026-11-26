--!native
--!optimize 2
--!strict
local GPU = {}

GPU.h = 32 -- screen height in pixels
GPU.w = 32 -- screen width in pixels

local AS = game:GetService("AssetService")
GPU.ed = AS:CreateEditableImage({ Size = Vector2.new(GPU.w, GPU.h) })
local pbf = buffer.create(GPU.w * GPU.h * 4)-- R, G, B, Alpha
-- h func
local function packRGBA(r: number, g: number, b: number, a: number?): number -- Writes the color directly instead of 4 arguments > 1 argument
	local alpha = a or 255 -- opacity
	return bit32.bor(
		r,
		bit32.lshift(g, 8),
		bit32.lshift(b, 16),
		bit32.lshift(alpha, 24)
	)
end

local function Writepbf(x : number,y : number,c) -- Writes pixels to the adress given / c = color
	if x < 0 or y < 0 then return end if x >= GPU.w or y >= GPU.h then return end
	local offset = (y * GPU.w + x) * 4
	buffer.writeu32(pbf, offset, c)
end
-- func
function GPU.Draw(r,g,b,a,x0,y0,x1,y1)
	local color = packRGBA(r,g,b,a)
	if x0 and y0 then
		if x0 and y0 and x1 and not y1 then return end
		if x0 and y0 and not x1 and y1 then return end
		if x0 and y0 and x1 and y1  then -- if all line draw
			x0 = math.floor(x0)
			y0 = math.floor(y0)
			x1 = math.floor(x1)
			y1 = math.floor(y1)
			local dx = math.abs(x1 - x0)
			local dy = math.abs(y1 - y0)
			local sx = if x0 < x1 then 1 else -1
			local sy = if y0 < y1 then 1 else -1
			local err = dx - dy

			while true do
				Writepbf(x0,y0,color)
				if x0 == x1 and y0 == y1 then
					break
				end

				local e2 = 2 * err
				if e2 > -dy then
					err -= dy
					x0 += sx
				end
				if e2 < dx then
					err += dx
					y0 += sy
				end
			end
		else
			Writepbf(x0,y0,color) -- else just draw a pixel
		end
	end
end

function GPU.Show()
	GPU.ed:WritePixelsBuffer(Vector2.zero, GPU.ed.Size, pbf)
	buffer.fill(pbf, 0, 0, GPU.w * GPU.h * 4) -- Wipes the next frame clean
end

return GPU

