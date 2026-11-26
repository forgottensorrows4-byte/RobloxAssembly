--!native
--!optimize 2
--!strict

--Assembles and Runs the Code
local ASM = {}

local GPU = require(script.Parent.Parent.Hardware.GPU)
local RAM = require(script.Parent.Parent.Hardware.RAM)
local CPU = require(script.Parent.Parent.Hardware.CPU)

local regs = CPU.registers
local floor = math.floor
local clamp = math.clamp
local band, bor, bxor, bnot = bit32.band, bit32.bor, bit32.bxor, bit32.bnot
local rshift, lshift = bit32.rshift, bit32.lshift
local random = math.random
local round = math.round
local sin = math.sin
local cos = math.cos-- im pretty sure putting commands as variables makes it faster

local r, g, b = 255, 255, 255
local callStack: { number } = {}
--commands
local OPCODES: { [string]: number } = {-- numbers are faster for computers than strings
	MOV = 1,  ADD = 2,  SUB = 3,  MUL = 4,  DIV = 5,
	PUSH = 6, POP = 7,  POPA = 8, LOAD = 9, STORE = 10,
	JMP = 11, JL = 12,  JEQ = 13, JG = 14,
	AND = 15, OR = 16,  XOR = 17, NOT = 18,
	SHR = 19, SHL = 20, HLT = 21, PIX = 22,
	CALL = 23, RET = 24, RNG = 25, RND = 26,
	SIN = 27, COS = 28
}

-- h func
local function resolve(val: any): number
	return if type(val) == "table" then val.val else (val or 0)-- check if it exists
end
local function setReg(reg: any, val: number)-- set register
	if reg.maxVal then
		reg.val = val % reg.maxVal
	else
		reg.val = val
	end
end
-- func
local function resetSystem()-- resetting everything
	RAM.Clear()
	CPU.Reset()
	table.clear(callStack)
	r, g, b = 255, 255, 255
end

-- func
function ASM.Parse(code: string): ({ { any } }, { [string]: number })
	local instructions: { { any } } = {}
	local labels: { [string]: number } = {}
	local cleanCode = string.gsub(code, "//[^\n]*", "")
	local statements = string.split(cleanCode, ";")

	for _, v in statements do
		local tokens: { any } = {}
		local cleanStmt = string.gsub(v, ",", " ")
		for token in string.gmatch(cleanStmt, "%S+") do
			table.insert(tokens, tonumber(token) or token)
		end
		if #tokens == 0 then continue end
		if tokens[1] == "LABEL" then
			labels[tokens[2] :: string] = #instructions + 1
		else
			tokens[1] = OPCODES[tokens[1]]
			table.insert(instructions, tokens)
		end
	end
	for _, inst in instructions do
		for i = 2, #inst do
			local tok = inst[i]
			if regs[tok] then
				inst[i] = regs[tok]
			elseif labels[tok] then
				inst[i] = labels[tok]
			end
		end
	end
	return instructions, labels
end

function ASM.Run(code: string)
	resetSystem()
	local instructions, labels = ASM.Parse(code)
	local cycles = 0
	local ripReg = regs.RIP
	local totalInst = #instructions

	while ripReg.val <= totalInst do
		cycles += 1
		if cycles % 200000 == 0 then
			task.wait()
		end

		local inst = instructions[ripReg.val]
		local op = inst[1]
		local arg1: any = inst[2]
		local arg2: any = inst[3]
		local arg3: any = inst[4]
		local arg4: any = inst[5]
		local arg5: any = inst[6]
		
		local jumped = false
		--//////// MATH
		if op == 1 then -- MOV
			if type(arg1) == "table" then
				setReg(arg1, resolve(arg2))
			end
		elseif op == 2 then -- ADD
			if type(arg1) == "table" then
				local sum = arg1.val
				for i = 3, #inst do
					sum += resolve(inst[i])
				end
				setReg(arg1, sum)
			end
		elseif op == 3 then -- SUB
			if type(arg1) == "table" then
				local diff = arg1.val
				for i = 3, #inst do
					diff -= resolve(inst[i])
				end
				setReg(arg1, diff)
			end
		elseif op == 4 then -- MUL
			if type(arg1) == "table" then
				local prod = arg1.val
				for i = 3, #inst do
					prod *= resolve(inst[i])
				end
				setReg(arg1, prod)
			end
		elseif op == 5 then -- DIV
			if type(arg1) == "table" then
				local quot = arg1.val
				for i = 3, #inst do
					local divisor = resolve(inst[i])
					if divisor ~= 0 then
						quot = floor(quot / divisor)
					end
				end
				setReg(arg1, quot)
			end
			--//////// MEMORY
		elseif op == 6 then
			RAM.Push(clamp(floor(resolve(arg1)), 0, 255))
		elseif op == 7 then
			local popped = RAM.Pop()
			if type(arg1) == "table" then
				setReg(arg1, popped)
			end
		elseif op == 8 then
			RAM.Clear()
		elseif op == 9 then
			if type(arg1) == "table" then
				setReg(arg1, RAM.Read(resolve(arg2)))
			end
		elseif op == 10 then
			RAM.Write(resolve(arg1), clamp(floor(resolve(arg2)), 0, 255))
			--//////// LOGIC
		elseif op == 11 then
			if type(arg1) == "number" then
				ripReg.val = arg1
				jumped = true
			end
		elseif op == 12 then
			if resolve(arg1) < resolve(arg2) and type(arg3) == "number" then
				ripReg.val = arg3
				jumped = true
			end
		elseif op == 13 then
			if resolve(arg1) == resolve(arg2) and type(arg3) == "number" then
				ripReg.val = arg3
				jumped = true
			end
		elseif op == 14 then
			if resolve(arg1) > resolve(arg2) and type(arg3) == "number" then
				ripReg.val = arg3
				jumped = true
			end
			--/////////// bitwise arithmetic
		elseif op == 15 then
			if type(arg1) == "table" then
				setReg(arg1, band(resolve(arg1), resolve(arg2)))
			end
		elseif op == 16 then
			if type(arg1) == "table" then
				setReg(arg1, bor(resolve(arg1), resolve(arg2)))
			end
		elseif op == 17 then
			if type(arg1) == "table" then
				setReg(arg1, bxor(resolve(arg1), resolve(arg2)))
			end
		elseif op == 18 then
			if type(arg1) == "table" then
				setReg(arg1, bnot(resolve(arg1)))
			end
			--////////// SHIFTS
		elseif op == 19 then -- UNSIGNED
			if type(arg1) == "table" then
				setReg(arg1, rshift(resolve(arg1), resolve(arg2)))
			end
		elseif op == 20 then
			if type(arg1) == "table" then
				setReg(arg1, lshift(resolve(arg1), resolve(arg2)))
			end
			--//////// WAIT
		elseif op == 21 then
			local duration = if arg1 ~= nil then resolve(arg1) else 0.1
			if duration >= 0.015 then
				task.wait(duration)
			else
				local targetTime = os.clock() + duration
				while os.clock() < targetTime do
				end
			end
			--//////// GRAPHICS
		elseif op == 22 then
			if arg1 == "D" then
				local x0 = resolve(arg2)
				local y0 = resolve(arg3)
				local x1 = if arg4 ~= nil then resolve(arg4) else nil
				local y1 = if arg5 ~= nil then resolve(arg5) else nil
				GPU.Draw(r, g, b, 255, x0, y0, x1, y1)
			elseif arg1 == "S" then
				GPU.Show()
			elseif arg1 == "C" then
				r = clamp(floor(resolve(arg2)), 0, 255)
				g = clamp(floor(resolve(arg3)), 0, 255)
				b = clamp(floor(resolve(arg4)), 0, 255)
			end
			--/////// CALL AND RET
		elseif op == 23 then
			if type(arg1) == "number" then
				table.insert(callStack, ripReg.val + 1)
				ripReg.val = arg1
				jumped = true
			end
		elseif op == 24 then
			local returnAddr = table.remove(callStack)
			if returnAddr then
				ripReg.val = returnAddr
				jumped = true
			else
				ripReg.val = totalInst + 1
				jumped = true
			end
			--//////// ADVANCED MATH
		elseif op == 25 then -- RANDOM
			if type(arg1) == "table" and arg2 ~= nil and arg3 ~= nil then
				local minVal = floor(resolve(arg2))
				local maxVal = floor(resolve(arg3))
				if minVal <= maxVal then
					setReg(arg1, random(minVal, maxVal))
				else
					setReg(arg1, 0)
				end
			end
		elseif op == 26 then -- ROUND
			if type(arg1) == "table" then
				local src = if arg2 ~= nil then arg2 else arg1
				setReg(arg1, round(resolve(src)))
			end
		elseif op == 27 then -- SIN
			if type(arg1) == "table" then
				local src = if arg2 ~= nil then arg2 else arg1
				setReg(arg1, sin(resolve(src)))
			end
		elseif op == 28 then -- COSINE
			if type(arg1) == "table" then
				local src = if arg2 ~= nil then arg2 else arg1
				setReg(arg1, cos(resolve(src)))
			end
		end
		if not jumped then
			ripReg.val += 1
		end
	end
end

return ASM

