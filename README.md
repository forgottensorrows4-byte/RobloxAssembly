# RobloxAssembly

Custom VM with a Assembler (Based off custom consoles like rasberry pi)

Basic Computer with a CPU,GPU,RAM,Screen,Assembler
## Setup

1. Download **`Roblox Assembly.rbxl`** from the repository.
2. Open the file in **Roblox Studio**.
3. Press **Play** (or edit the Example script in `Runtime`) to run the VM.
## Custom Setup
1. If youre making a custom screen check the instructions in boot
2. Paste the scripts into correct folders and change the module acceses if needed
3. Change the ImageLabel ResamplerMode to Pixelated (`Enum.ResamplerMode.Pixelated`)

## Specs
- **CPU**: 64-bit, 32-bit, 16-bit, and 8-bit x86-style registers (`RAX`–`R15`, `RIP`, etc....) (Modifiable)
- **RAM**: 2 KB byte-addressable memory (`0–255 per ``address`) (Ram size is modifiable)
- **Speed**: ~250k instructions/sec using pre-parsed numeric opcodes (Based off Cpu Speed but Faster than `Python` Slower than `Luau`)
- **GPU**: Direct RGB pixel/line drawing (`PIX`) onto a 32x32 screen (Screen Size Modifiable)
## Modules
- `CPU.luau` — Manages registers, bit widths, and the instruction pointer (`RIP`).
- `RAM.luau` — Handles memory reads/writes (`LOAD`/`STORE`) and the byte stack (`PUSH`/`POP`).
- `ASM.luau` — Parses assembly text into numeric opcodes and runs the execution loop.
- `GPU.luau` — Handles drawing pixels, colors, and updating the screen.

## Basic Syntax
Instructions end with `;` and comments use `//`.

```asm
// Example: draw a diagonal line
PIX C, 0, 255, 100;
MOV RAX, 0;

LABEL LOOP;
PIX D, RAX, RAX;
ADD RAX, 1;
JL RAX, 32, LOOP;

PIX S;
```

## Instruction List
- **Math**:           `MOV`, `ADD`, `SUB`, `MUL`, `DIV`
- **Memory**:         `LOAD`, `STORE`, `PUSH`, `POP`, `POPA`
- **Logic / Jumps**:  `JMP`, `JL`, `JEQ`, `JG`, `LABEL`
- **Subroutines**:    `CALL`, `RET`
- **Bitwise**:        `AND`, `OR`, `XOR`, `NOT`, `SHL`, `SHR`
- **Graphics**:       `PIX C` (color), `PIX D` (draw), `PIX S` (display written pixels)
- **System**          `HLT` (Default 0.1, Minimum 0.015//In Seconds) 
