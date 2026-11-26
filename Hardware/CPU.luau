--!native
--!optimize 2
--!strict
local CPU = {}

local registers: { [string]: { val: number, bits: number, maxVal: number? } } = {
	-- 64-bit Registers
	RAX = { val = 0, bits = 64 }, RBX = { val = 0, bits = 64 },
	RCX = { val = 0, bits = 64 }, RDX = { val = 0, bits = 64 },
	RSI = { val = 0, bits = 64 }, RDI = { val = 0, bits = 64 },
	RSP = { val = 0, bits = 64 }, RBP = { val = 0, bits = 64 },
	R8  = { val = 0, bits = 64 }, R9  = { val = 0, bits = 64 },
	R10 = { val = 0, bits = 64 }, R11 = { val = 0, bits = 64 },
	R12 = { val = 0, bits = 64 }, R13 = { val = 0, bits = 64 },
	R14 = { val = 0, bits = 64 }, R15 = { val = 0, bits = 64 },

	-- 32-bit Registers
	EAX = { val = 0, bits = 32 }, EBX = { val = 0, bits = 32 },
	ECX = { val = 0, bits = 32 }, EDX = { val = 0, bits = 32 },
	ESI = { val = 0, bits = 32 }, EDI = { val = 0, bits = 32 },
	ESP = { val = 0, bits = 32 }, EBP = { val = 0, bits = 32 },

	-- 16-bit Registers
	AX  = { val = 0, bits = 16 }, BX  = { val = 0, bits = 16 },
	CX  = { val = 0, bits = 16 }, DX  = { val = 0, bits = 16 },
	SI  = { val = 0, bits = 16 }, DI  = { val = 0, bits = 16 },
	SP  = { val = 0, bits = 16 }, BP  = { val = 0, bits = 16 },

	-- 8-bit Registers
	AL  = { val = 0, bits = 8 },  AH  = { val = 0, bits = 8 },
	BL  = { val = 0, bits = 8 },  BH  = { val = 0, bits = 8 },
	CL  = { val = 0, bits = 8 },  CH  = { val = 0, bits = 8 },
	DL  = { val = 0, bits = 8 },  DH  = { val = 0, bits = 8 },
	SIL = { val = 0, bits = 8 },  DIL = { val = 0, bits = 8 },
	SPL = { val = 0, bits = 8 },  BPL = { val = 0, bits = 8 },

	-- 64-bit IP (program counter)
	RIP = { val = 1, bits = 64 },
}

CPU.registers = registers
for _, reg in registers do
	if reg.bits < 64 then
		reg.maxVal = 2 ^ reg.bits
	end
end
function CPU.Exists(name: any): boolean
	return type(name) == "string" and registers[name] ~= nil
end
function CPU.Get(name: string): number
	local reg = registers[name]
	return if reg then reg.val else 0
end

function CPU.Set(name: string, val: number)
	local reg = registers[name]
	if not reg then return end
	if reg.maxVal then
		reg.val = val % reg.maxVal
	else
		reg.val = val
	end
end

function CPU.Reset()
	for _, reg in registers do
		reg.val = 0
	end
	registers.RIP.val = 1
end

return CPU

