local ASM = require(script.Parent.Parent.Kernel.ASM)

local code = [[
	PIX C, 0, 255, 100;
	MOV RAX, 0;

	LABEL LOOP;
	PIX D, RAX, RAX;
	ADD RAX, 1;
	JL RAX, 32, LOOP;

	PIX S;
]]

ASM.Run(code)
