--!native
--!optimize 2
--!strict
--Assembles and Runs Code
local ASM = {}

local GPU = require(script.Parent.Parent.Hardware.GPU)
local RAM = require(script.Parent.Parent.Hardware.RAM)
local CPU = require(script.Parent.Parent.Hardware.CPU)

local r, g, b = 255, 255, 255
local callStack: { number } = {}
--commands
local OPCODES: { [string]: number } = {
	MOV = 1,  ADD = 2,  SUB = 3,  MUL = 4,  DIV = 5,
	PUSH = 6, POP = 7,  POPA = 8, LOAD = 9, STORE = 10,
	JMP = 11, JL = 12,  JEQ = 13, JG = 14,
	AND = 15, OR = 16,  XOR = 17, NOT = 18,
	SHR = 19, SHL = 20, HLT = 21, PIX = 22,
	CALL = 23, RET = 24,
}

-- h func
local function resolve(val: any): number
	if CPU.Exists(val) then
		return CPU.Get(val :: string)
	end
	return tonumber(val) or 0
end

local function resetSystem()
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

	return instructions, labels
end

function ASM.Run(code: string)
	resetSystem()
	local instructions, labels = ASM.Parse(code)
	local cycles = 0

	while CPU.Get("RIP") <= #instructions do
		cycles += 1
		if cycles % 200000 == 0 then
			task.wait()
		end

		local inst = instructions[CPU.Get("RIP")]
		local op = inst[1]
		local arg1: any = inst[2]
		local arg2: any = inst[3]
		local arg3: any = inst[4]
		local arg4: any = inst[5]
		local arg5: any = inst[6]

		local jumped = false

		--//////// MATH
		if op == 1 then
			if CPU.Exists(arg1) then
				CPU.Set(arg1, resolve(arg2))
			end

		elseif op == 2 then
			if CPU.Exists(arg1) then
				for _, arg in { arg2, arg3, arg4, arg5 } do
					if arg == nil then break end
					CPU.Set(arg1, CPU.Get(arg1) + resolve(arg))
				end
			end

		elseif op == 3 then
			if CPU.Exists(arg1) then
				for _, arg in { arg2, arg3, arg4, arg5 } do
					if arg == nil then break end
					CPU.Set(arg1, CPU.Get(arg1) - resolve(arg))
				end
			end

		elseif op == 4 then
			if CPU.Exists(arg1) then
				for _, arg in { arg2, arg3, arg4, arg5 } do
					if arg == nil then break end
					CPU.Set(arg1, CPU.Get(arg1) * resolve(arg))
				end
			end

		elseif op == 5 then
			if CPU.Exists(arg1) then
				for _, arg in { arg2, arg3, arg4, arg5 } do
					if arg == nil then break end
					local divisor = resolve(arg)
					if divisor ~= 0 then
						CPU.Set(arg1, math.floor(CPU.Get(arg1) / divisor))
					end
				end
			end

			--//////// MEMORY
		elseif op == 6 then
			RAM.Push(math.clamp(math.floor(resolve(arg1)), 0, 255))

		elseif op == 7 then
			local popped = RAM.Pop()
			if CPU.Exists(arg1) then
				CPU.Set(arg1, popped)
			end

		elseif op == 8 then
			RAM.Clear()

		elseif op == 9 then
			if CPU.Exists(arg1) then
				CPU.Set(arg1, RAM.Read(resolve(arg2)))
			end

		elseif op == 10 then
			RAM.Write(resolve(arg1), math.clamp(math.floor(resolve(arg2)), 0, 255))

			--//////// LOGIC
		elseif op == 11 then
			local target = labels[arg1] or tonumber(arg1)
			if target then
				CPU.Set("RIP", target)
				jumped = true
			end

		elseif op == 12 then
			if resolve(arg1) < resolve(arg2) then
				local target = labels[arg3] or tonumber(arg3)
				if target then
					CPU.Set("RIP", target)
					jumped = true
				end
			end

		elseif op == 13 then
			if resolve(arg1) == resolve(arg2) then
				local target = labels[arg3] or tonumber(arg3)
				if target then
					CPU.Set("RIP", target)
					jumped = true
				end
			end

		elseif op == 14 then
			if resolve(arg1) > resolve(arg2) then
				local target = labels[arg3] or tonumber(arg3)
				if target then
					CPU.Set("RIP", target)
					jumped = true
				end
			end
		--/////////// bitwise arithmetic
		elseif op == 15 then
			if CPU.Exists(arg1) then
				local result = bit32.band(resolve(arg1), resolve(arg2))
				CPU.Set(arg1, result)
			end
		elseif op == 16 then
			if CPU.Exists(arg1) then
				local result = bit32.bor(resolve(arg1), resolve(arg2))
				CPU.Set(arg1, result)
			end
		elseif op == 17 then
			if CPU.Exists(arg1) then
				local result = bit32.bxor(resolve(arg1), resolve(arg2))
				CPU.Set(arg1, result)
			end
		elseif op == 18 then
			if CPU.Exists(arg1) then
				local result = bit32.bnot(resolve(arg1))
				CPU.Set(arg1, result)
			end
		--////////// SHIFTS
		--Right Shift
		elseif op == 19 then -- UNSIGNED
			if CPU.Exists(arg1) then
				local result = bit32.rshift(resolve(arg1), resolve(arg2))
				CPU.Set(arg1, result)
			end	
		--Left Shift
		elseif op == 20 then 
			if CPU.Exists(arg1) then
				local result = bit32.lshift(resolve(arg1), resolve(arg2))
				CPU.Set(arg1, result)
			end	
			--//////// WAIT
		elseif op == 21 then
			local duration = if arg1 ~= nil then resolve(arg1) else 0.1
			if duration >= 0.015 then
				task.wait(duration)
			else
				local targetTime = os.clock() + duration
				while os.clock() < targetTime do
					-- Miniscule wait
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
				r = math.clamp(math.floor(resolve(arg2)), 0, 255)
				g = math.clamp(math.floor(resolve(arg3)), 0, 255)
				b = math.clamp(math.floor(resolve(arg4)), 0, 255)
			end
			--/////// CALL AND RET
		elseif op == 23 then
			local target = labels[arg1] or tonumber(arg1)
			if target then
				table.insert(callStack, CPU.Get("RIP") + 1)
				CPU.Set("RIP", target)
				jumped = true
			end

		elseif op == 24 then
			local returnAddr = table.remove(callStack)
			if returnAddr then
				CPU.Set("RIP", returnAddr)-- JUMP TO ADRESS
				jumped = true
			else
				CPU.Set("RIP", #instructions + 1) 
				jumped = true
			end
		end

		if not jumped then
			CPU.Set("RIP", CPU.Get("RIP") + 1)
		end
	end
end

return ASM
