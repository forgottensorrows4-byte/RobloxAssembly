--!native
--!optimize 2
--!strict
local RAM = {}

local kibibytes = 2 * 1024 -- a kikibyte is 1024 bytes and a kilobyte is 1000 bytes theres a diffrence lol

RAM.Size = kibibytes
RAM.Stack = buffer.create(RAM.Size)
RAM.SP = 0

--h func
local function CoB(val)-- checks out of bounds
	if val >= RAM.Size or val < 0 then
		return true
	end
	return false
end
--func

function RAM.Write(adress,value)
	if CoB(adress) then return end
	buffer.writeu8(RAM.Stack,adress,value)
end

function RAM.Read(adress,value)
	if CoB(adress) then return 0 end
	local val = buffer.readu8(RAM.Stack,adress)
	return val
end

function RAM.Clear()
	buffer.fill(RAM.Stack,0,0,RAM.Size)
	RAM.SP = 0
end

function RAM.Push(value)
	if CoB(RAM.SP) then warn("Stack Overflow") return end
	buffer.writeu8(RAM.Stack,RAM.SP,value)
	RAM.SP += 1
end

function RAM.Pop()
	if RAM.SP <= 0 then warn("Stack Underflow") return 0 end
	RAM.SP -= 1
	local val = buffer.readu8(RAM.Stack,RAM.SP)
	buffer.writeu8(RAM.Stack, RAM.SP, 0)
	return val
end


return RAM



return RAM
