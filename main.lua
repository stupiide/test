--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 81) then
			local FlatIdent_95CAC = 0;
			while true do
				if (FlatIdent_95CAC == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_76979 = 0;
				local b;
				while true do
					if (FlatIdent_76979 == 1) then
						return b;
					end
					if (FlatIdent_76979 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_76979 = 1;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_24A02 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_24A02 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_24A02 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_24A02 = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_1743D = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_1743D == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_1743D = 1;
				end
				if (FlatIdent_1743D == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_25011 = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_25011 == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_25011 = 3;
					end
					if (FlatIdent_25011 == 0) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_25011 = 1;
					end
					if (FlatIdent_25011 == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
					if (FlatIdent_25011 == 1) then
						Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							Inst[3] = gBits16();
							Inst[4] = gBits16();
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							local FlatIdent_51F42 = 0;
							while true do
								if (FlatIdent_51F42 == 0) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
									break;
								end
							end
						end
						FlatIdent_25011 = 2;
					end
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_1BCFB = 0;
				while true do
					if (FlatIdent_1BCFB == 1) then
						if (Enum <= 130) then
							if (Enum <= 64) then
								if (Enum <= 31) then
									if (Enum <= 15) then
										if (Enum <= 7) then
											if (Enum <= 3) then
												if (Enum <= 1) then
													if (Enum == 0) then
														local A;
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
													else
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													end
												elseif (Enum == 2) then
													if (Stk[Inst[2]] == Stk[Inst[4]]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
												else
													local FlatIdent_27957 = 0;
													local A;
													while true do
														if (FlatIdent_27957 == 1) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															FlatIdent_27957 = 2;
														end
														if (FlatIdent_27957 == 0) then
															A = nil;
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_27957 = 1;
														end
														if (FlatIdent_27957 == 3) then
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															FlatIdent_27957 = 4;
														end
														if (FlatIdent_27957 == 2) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3] ~= 0;
															VIP = VIP + 1;
															FlatIdent_27957 = 3;
														end
														if (FlatIdent_27957 == 4) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
													end
												end
											elseif (Enum <= 5) then
												if (Enum == 4) then
													local FlatIdent_7A75F = 0;
													local B;
													local T;
													local A;
													while true do
														if (FlatIdent_7A75F == 0) then
															B = nil;
															T = nil;
															A = nil;
															Stk[Inst[2]] = {};
															VIP = VIP + 1;
															FlatIdent_7A75F = 1;
														end
														if (FlatIdent_7A75F == 2) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_7A75F = 3;
														end
														if (10 == FlatIdent_7A75F) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_7A75F = 11;
														end
														if (FlatIdent_7A75F == 4) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_7A75F = 5;
														end
														if (FlatIdent_7A75F == 6) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															FlatIdent_7A75F = 7;
														end
														if (FlatIdent_7A75F == 11) then
															T = Stk[A];
															B = Inst[3];
															for Idx = 1, B do
																T[Idx] = Stk[A + Idx];
															end
															break;
														end
														if (8 == FlatIdent_7A75F) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_7A75F = 9;
														end
														if (FlatIdent_7A75F == 9) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_7A75F = 10;
														end
														if (FlatIdent_7A75F == 1) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															FlatIdent_7A75F = 2;
														end
														if (FlatIdent_7A75F == 7) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															FlatIdent_7A75F = 8;
														end
														if (FlatIdent_7A75F == 5) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_7A75F = 6;
														end
														if (FlatIdent_7A75F == 3) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_7A75F = 4;
														end
													end
												else
													local FlatIdent_D79D = 0;
													local A;
													local Results;
													local Edx;
													while true do
														if (0 == FlatIdent_D79D) then
															A = Inst[2];
															Results = {Stk[A](Stk[A + 1])};
															FlatIdent_D79D = 1;
														end
														if (FlatIdent_D79D == 1) then
															Edx = 0;
															for Idx = A, Inst[4] do
																local FlatIdent_28F1 = 0;
																while true do
																	if (0 == FlatIdent_28F1) then
																		Edx = Edx + 1;
																		Stk[Idx] = Results[Edx];
																		break;
																	end
																end
															end
															break;
														end
													end
												end
											elseif (Enum > 6) then
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											else
												local A;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if not Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											end
										elseif (Enum <= 11) then
											if (Enum <= 9) then
												if (Enum == 8) then
													local A;
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
												else
													Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
												end
											elseif (Enum > 10) then
												local A;
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											else
												local K;
												local B;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												B = Inst[3];
												K = Stk[B];
												for Idx = B + 1, Inst[4] do
													K = K .. Stk[Idx];
												end
												Stk[Inst[2]] = K;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
											end
										elseif (Enum <= 13) then
											if (Enum == 12) then
												local A;
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											else
												local B;
												local A;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
											end
										elseif (Enum > 14) then
											local FlatIdent_8A742 = 0;
											local A;
											while true do
												if (2 == FlatIdent_8A742) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_8A742 = 3;
												end
												if (FlatIdent_8A742 == 0) then
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8A742 = 1;
												end
												if (FlatIdent_8A742 == 18) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_8A742 = 19;
												end
												if (FlatIdent_8A742 == 23) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_8A742 = 24;
												end
												if (FlatIdent_8A742 == 24) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													break;
												end
												if (FlatIdent_8A742 == 14) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_8A742 = 15;
												end
												if (FlatIdent_8A742 == 10) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8A742 = 11;
												end
												if (FlatIdent_8A742 == 5) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8A742 = 6;
												end
												if (FlatIdent_8A742 == 20) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8A742 = 21;
												end
												if (12 == FlatIdent_8A742) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8A742 = 13;
												end
												if (FlatIdent_8A742 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_8A742 = 9;
												end
												if (FlatIdent_8A742 == 6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8A742 = 7;
												end
												if (11 == FlatIdent_8A742) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8A742 = 12;
												end
												if (FlatIdent_8A742 == 22) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_8A742 = 23;
												end
												if (FlatIdent_8A742 == 1) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8A742 = 2;
												end
												if (FlatIdent_8A742 == 21) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8A742 = 22;
												end
												if (FlatIdent_8A742 == 17) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_8A742 = 18;
												end
												if (FlatIdent_8A742 == 19) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8A742 = 20;
												end
												if (FlatIdent_8A742 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_8A742 = 8;
												end
												if (FlatIdent_8A742 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8A742 = 5;
												end
												if (FlatIdent_8A742 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_8A742 = 4;
												end
												if (FlatIdent_8A742 == 9) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_8A742 = 10;
												end
												if (FlatIdent_8A742 == 15) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8A742 = 16;
												end
												if (FlatIdent_8A742 == 13) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_8A742 = 14;
												end
												if (FlatIdent_8A742 == 16) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_8A742 = 17;
												end
											end
										else
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										end
									elseif (Enum <= 23) then
										if (Enum <= 19) then
											if (Enum <= 17) then
												if (Enum > 16) then
													local B;
													local A;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
												else
													local FlatIdent_32BB2 = 0;
													local A;
													while true do
														if (FlatIdent_32BB2 == 0) then
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
															break;
														end
													end
												end
											elseif (Enum == 18) then
												local A;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
											else
												local FlatIdent_21297 = 0;
												local A;
												while true do
													if (FlatIdent_21297 == 4) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_21297 = 5;
													end
													if (FlatIdent_21297 == 5) then
														if Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_21297 == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_21297 = 1;
													end
													if (FlatIdent_21297 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3] ~= 0;
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_21297 = 4;
													end
													if (FlatIdent_21297 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_21297 = 3;
													end
													if (FlatIdent_21297 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_21297 = 2;
													end
												end
											end
										elseif (Enum <= 21) then
											if (Enum == 20) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											else
												local FlatIdent_69C4C = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_69C4C == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69C4C = 11;
													end
													if (FlatIdent_69C4C == 11) then
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if not Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (1 == FlatIdent_69C4C) then
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_69C4C = 2;
													end
													if (FlatIdent_69C4C == 9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_69C4C = 10;
													end
													if (FlatIdent_69C4C == 2) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_69C4C = 3;
													end
													if (FlatIdent_69C4C == 4) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69C4C = 5;
													end
													if (FlatIdent_69C4C == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_69C4C = 1;
													end
													if (FlatIdent_69C4C == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_69C4C = 8;
													end
													if (6 == FlatIdent_69C4C) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_69C4C = 7;
													end
													if (FlatIdent_69C4C == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69C4C = 4;
													end
													if (FlatIdent_69C4C == 5) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_69C4C = 6;
													end
													if (FlatIdent_69C4C == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_69C4C = 9;
													end
												end
											end
										elseif (Enum == 22) then
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										else
											local FlatIdent_512FF = 0;
											while true do
												if (FlatIdent_512FF == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 5;
												end
												if (8 == FlatIdent_512FF) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 9;
												end
												if (FlatIdent_512FF == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 4;
												end
												if (FlatIdent_512FF == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 8;
												end
												if (FlatIdent_512FF == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 3;
												end
												if (FlatIdent_512FF == 9) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 10;
												end
												if (FlatIdent_512FF == 12) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 13;
												end
												if (FlatIdent_512FF == 22) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 23;
												end
												if (FlatIdent_512FF == 20) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 21;
												end
												if (FlatIdent_512FF == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 12;
												end
												if (FlatIdent_512FF == 26) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 27;
												end
												if (FlatIdent_512FF == 17) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 18;
												end
												if (FlatIdent_512FF == 6) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 7;
												end
												if (1 == FlatIdent_512FF) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 2;
												end
												if (FlatIdent_512FF == 14) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 15;
												end
												if (FlatIdent_512FF == 25) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 26;
												end
												if (FlatIdent_512FF == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 6;
												end
												if (FlatIdent_512FF == 29) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (21 == FlatIdent_512FF) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 22;
												end
												if (FlatIdent_512FF == 15) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 16;
												end
												if (FlatIdent_512FF == 24) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 25;
												end
												if (FlatIdent_512FF == 13) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 14;
												end
												if (FlatIdent_512FF == 10) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 11;
												end
												if (FlatIdent_512FF == 23) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_512FF = 24;
												end
												if (FlatIdent_512FF == 19) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 20;
												end
												if (FlatIdent_512FF == 18) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 19;
												end
												if (16 == FlatIdent_512FF) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 17;
												end
												if (FlatIdent_512FF == 28) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_512FF = 29;
												end
												if (FlatIdent_512FF == 27) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 28;
												end
												if (FlatIdent_512FF == 0) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_512FF = 1;
												end
											end
										end
									elseif (Enum <= 27) then
										if (Enum <= 25) then
											if (Enum > 24) then
												local FlatIdent_22A5C = 0;
												local A;
												while true do
													if (FlatIdent_22A5C == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_22A5C = 1;
													end
													if (3 == FlatIdent_22A5C) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_22A5C = 4;
													end
													if (FlatIdent_22A5C == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_22A5C = 3;
													end
													if (FlatIdent_22A5C == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = not Stk[Inst[3]];
														break;
													end
													if (FlatIdent_22A5C == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_22A5C = 2;
													end
												end
											else
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											end
										elseif (Enum == 26) then
											local A;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										else
											local Results;
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										end
									elseif (Enum <= 29) then
										if (Enum == 28) then
											do
												return;
											end
										else
											local FlatIdent_8239F = 0;
											local A;
											while true do
												if (FlatIdent_8239F == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8239F = 1;
												end
												if (FlatIdent_8239F == 1) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8239F = 2;
												end
												if (FlatIdent_8239F == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_8239F = 3;
												end
												if (FlatIdent_8239F == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_8239F == 5) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_8239F = 6;
												end
												if (FlatIdent_8239F == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_8239F = 7;
												end
												if (FlatIdent_8239F == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8239F = 5;
												end
												if (FlatIdent_8239F == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_8239F = 4;
												end
											end
										end
									elseif (Enum == 30) then
										local FlatIdent_1CFC3 = 0;
										local A;
										while true do
											if (FlatIdent_1CFC3 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = #Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1CFC3 = 2;
											end
											if (FlatIdent_1CFC3 == 12) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1CFC3 = 13;
											end
											if (FlatIdent_1CFC3 == 8) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CFC3 = 9;
											end
											if (FlatIdent_1CFC3 == 5) then
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CFC3 = 6;
											end
											if (7 == FlatIdent_1CFC3) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CFC3 = 8;
											end
											if (FlatIdent_1CFC3 == 10) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_1CFC3 = 11;
											end
											if (FlatIdent_1CFC3 == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1CFC3 = 1;
											end
											if (FlatIdent_1CFC3 == 6) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CFC3 = 7;
											end
											if (FlatIdent_1CFC3 == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_1CFC3 = 3;
											end
											if (FlatIdent_1CFC3 == 11) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1CFC3 = 12;
											end
											if (FlatIdent_1CFC3 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_1CFC3 = 5;
											end
											if (FlatIdent_1CFC3 == 9) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CFC3 = 10;
											end
											if (FlatIdent_1CFC3 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_1CFC3 = 4;
											end
											if (13 == FlatIdent_1CFC3) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
										end
									else
										local FlatIdent_5C0FA = 0;
										local Edx;
										local Results;
										local K;
										local B;
										local A;
										while true do
											if (FlatIdent_5C0FA == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C0FA = 6;
											end
											if (FlatIdent_5C0FA == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_5C0FA = 4;
											end
											if (FlatIdent_5C0FA == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5C0FA = 5;
											end
											if (FlatIdent_5C0FA == 7) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5C0FA = 8;
											end
											if (2 == FlatIdent_5C0FA) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5C0FA = 3;
											end
											if (FlatIdent_5C0FA == 11) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5C0FA = 12;
											end
											if (FlatIdent_5C0FA == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												B = Inst[3];
												K = Stk[B];
												FlatIdent_5C0FA = 10;
											end
											if (6 == FlatIdent_5C0FA) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C0FA = 7;
											end
											if (FlatIdent_5C0FA == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5C0FA = 9;
											end
											if (FlatIdent_5C0FA == 12) then
												Results = {Stk[A](Stk[A + 1])};
												Edx = 0;
												for Idx = A, Inst[4] do
													local FlatIdent_FC26 = 0;
													while true do
														if (FlatIdent_FC26 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_5C0FA == 10) then
												for Idx = B + 1, Inst[4] do
													K = K .. Stk[Idx];
												end
												Stk[Inst[2]] = K;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C0FA = 11;
											end
											if (FlatIdent_5C0FA == 0) then
												Edx = nil;
												Results = nil;
												K = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5C0FA = 1;
											end
											if (1 == FlatIdent_5C0FA) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C0FA = 2;
											end
										end
									end
								elseif (Enum <= 47) then
									if (Enum <= 39) then
										if (Enum <= 35) then
											if (Enum <= 33) then
												if (Enum == 32) then
													local A;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
												else
													local A;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
												end
											elseif (Enum > 34) then
												local A = Inst[2];
												local C = Inst[4];
												local CB = A + 2;
												local Result = {Stk[A](Stk[A + 1], Stk[CB])};
												for Idx = 1, C do
													Stk[CB + Idx] = Result[Idx];
												end
												local R = Result[1];
												if R then
													Stk[CB] = R;
													VIP = Inst[3];
												else
													VIP = VIP + 1;
												end
											else
												local FlatIdent_98E39 = 0;
												local A;
												while true do
													if (FlatIdent_98E39 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														VIP = Inst[3];
														break;
													end
													if (FlatIdent_98E39 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_98E39 = 2;
													end
													if (3 == FlatIdent_98E39) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_98E39 = 4;
													end
													if (2 == FlatIdent_98E39) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														FlatIdent_98E39 = 3;
													end
													if (FlatIdent_98E39 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]]();
														FlatIdent_98E39 = 5;
													end
													if (0 == FlatIdent_98E39) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_98E39 = 1;
													end
												end
											end
										elseif (Enum <= 37) then
											if (Enum > 36) then
												local FlatIdent_2458 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_2458 == 2) then
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_2458 = 3;
													end
													if (FlatIdent_2458 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Upvalues[Inst[3]];
														FlatIdent_2458 = 1;
													end
													if (FlatIdent_2458 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														FlatIdent_2458 = 4;
													end
													if (FlatIdent_2458 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_2458 = 5;
													end
													if (FlatIdent_2458 == 7) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2458 = 8;
													end
													if (6 == FlatIdent_2458) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_2458 = 7;
													end
													if (5 == FlatIdent_2458) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3] ~= 0;
														FlatIdent_2458 = 6;
													end
													if (FlatIdent_2458 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_2458 = 2;
													end
													if (FlatIdent_2458 == 8) then
														B = Stk[Inst[4]];
														if B then
															VIP = VIP + 1;
														else
															local FlatIdent_67408 = 0;
															while true do
																if (FlatIdent_67408 == 0) then
																	Stk[Inst[2]] = B;
																	VIP = Inst[3];
																	break;
																end
															end
														end
														break;
													end
												end
											else
												local B;
												local A;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											end
										elseif (Enum > 38) then
											local FlatIdent_79F35 = 0;
											while true do
												if (FlatIdent_79F35 == 3) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 4;
												end
												if (FlatIdent_79F35 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 9;
												end
												if (FlatIdent_79F35 == 10) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 11;
												end
												if (24 == FlatIdent_79F35) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 25;
												end
												if (FlatIdent_79F35 == 12) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 13;
												end
												if (FlatIdent_79F35 == 9) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 10;
												end
												if (FlatIdent_79F35 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 6;
												end
												if (FlatIdent_79F35 == 28) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 29;
												end
												if (FlatIdent_79F35 == 0) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 1;
												end
												if (FlatIdent_79F35 == 29) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													break;
												end
												if (FlatIdent_79F35 == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 12;
												end
												if (FlatIdent_79F35 == 15) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 16;
												end
												if (FlatIdent_79F35 == 20) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 21;
												end
												if (FlatIdent_79F35 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 2;
												end
												if (FlatIdent_79F35 == 21) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 22;
												end
												if (FlatIdent_79F35 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 5;
												end
												if (FlatIdent_79F35 == 19) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 20;
												end
												if (FlatIdent_79F35 == 25) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 26;
												end
												if (FlatIdent_79F35 == 18) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 19;
												end
												if (FlatIdent_79F35 == 23) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 24;
												end
												if (FlatIdent_79F35 == 22) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 23;
												end
												if (FlatIdent_79F35 == 6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 7;
												end
												if (FlatIdent_79F35 == 26) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 27;
												end
												if (FlatIdent_79F35 == 14) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 15;
												end
												if (FlatIdent_79F35 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 8;
												end
												if (FlatIdent_79F35 == 17) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 18;
												end
												if (FlatIdent_79F35 == 13) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 14;
												end
												if (FlatIdent_79F35 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_79F35 = 3;
												end
												if (FlatIdent_79F35 == 27) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_79F35 = 28;
												end
												if (FlatIdent_79F35 == 16) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_79F35 = 17;
												end
											end
										else
											local Results;
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_7695C = 0;
												while true do
													if (FlatIdent_7695C == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										end
									elseif (Enum <= 43) then
										if (Enum <= 41) then
											if (Enum > 40) then
												local B;
												local A;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												B = Stk[Inst[4]];
												if B then
													VIP = VIP + 1;
												else
													local FlatIdent_5A134 = 0;
													while true do
														if (FlatIdent_5A134 == 0) then
															Stk[Inst[2]] = B;
															VIP = Inst[3];
															break;
														end
													end
												end
											else
												local FlatIdent_4609C = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_4609C == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4609C = 6;
													end
													if (FlatIdent_4609C == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														FlatIdent_4609C = 1;
													end
													if (FlatIdent_4609C == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_4609C = 5;
													end
													if (FlatIdent_4609C == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4609C = 2;
													end
													if (FlatIdent_4609C == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														FlatIdent_4609C = 4;
													end
													if (FlatIdent_4609C == 2) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_4609C = 3;
													end
													if (FlatIdent_4609C == 6) then
														VIP = Inst[3];
														break;
													end
												end
											end
										elseif (Enum > 42) then
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
									elseif (Enum <= 45) then
										if (Enum == 44) then
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Stk[Inst[4]];
											if B then
												VIP = VIP + 1;
											else
												Stk[Inst[2]] = B;
												VIP = Inst[3];
											end
										else
											local A;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum > 46) then
										do
											return Stk[Inst[2]];
										end
									else
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									end
								elseif (Enum <= 55) then
									if (Enum <= 51) then
										if (Enum <= 49) then
											if (Enum == 48) then
												local A;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											else
												local FlatIdent_1FAE6 = 0;
												local A;
												local Cls;
												while true do
													if (FlatIdent_1FAE6 == 1) then
														for Idx = 1, #Lupvals do
															local List = Lupvals[Idx];
															for Idz = 0, #List do
																local Upv = List[Idz];
																local NStk = Upv[1];
																local DIP = Upv[2];
																if ((NStk == Stk) and (DIP >= A)) then
																	Cls[DIP] = NStk[DIP];
																	Upv[1] = Cls;
																end
															end
														end
														break;
													end
													if (FlatIdent_1FAE6 == 0) then
														A = Inst[2];
														Cls = {};
														FlatIdent_1FAE6 = 1;
													end
												end
											end
										elseif (Enum == 50) then
											local FlatIdent_2DD98 = 0;
											local A;
											while true do
												if (FlatIdent_2DD98 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_2DD98 = 2;
												end
												if (FlatIdent_2DD98 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_2DD98 = 3;
												end
												if (FlatIdent_2DD98 == 5) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_2DD98 == 4) then
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_2DD98 = 5;
												end
												if (FlatIdent_2DD98 == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2DD98 = 1;
												end
												if (FlatIdent_2DD98 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2DD98 = 4;
												end
											end
										else
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										end
									elseif (Enum <= 53) then
										if (Enum > 52) then
											Stk[Inst[2]] = Stk[Inst[3]];
										else
											local A;
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum > 54) then
										local FlatIdent_F1F2 = 0;
										local A;
										while true do
											if (FlatIdent_F1F2 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_F1F2 = 3;
											end
											if (4 == FlatIdent_F1F2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												break;
											end
											if (0 == FlatIdent_F1F2) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_F1F2 = 1;
											end
											if (FlatIdent_F1F2 == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_F1F2 = 4;
											end
											if (1 == FlatIdent_F1F2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_F1F2 = 2;
											end
										end
									else
										local A = Inst[2];
										local Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										local Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
									end
								elseif (Enum <= 59) then
									if (Enum <= 57) then
										if (Enum > 56) then
											local A = Inst[2];
											Stk[A] = Stk[A]();
										else
											local FlatIdent_101B7 = 0;
											local Results;
											local Edx;
											local Limit;
											local B;
											local A;
											while true do
												if (0 == FlatIdent_101B7) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													FlatIdent_101B7 = 1;
												end
												if (FlatIdent_101B7 == 5) then
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_101B7 = 6;
												end
												if (FlatIdent_101B7 == 1) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_101B7 = 2;
												end
												if (FlatIdent_101B7 == 7) then
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													Edx = 0;
													FlatIdent_101B7 = 8;
												end
												if (3 == FlatIdent_101B7) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_101B7 = 4;
												end
												if (FlatIdent_101B7 == 9) then
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_101B7 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_101B7 = 5;
												end
												if (FlatIdent_101B7 == 8) then
													for Idx = A, Inst[4] do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_101B7 = 9;
												end
												if (FlatIdent_101B7 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_101B7 = 3;
												end
												if (6 == FlatIdent_101B7) then
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_101B7 = 7;
												end
											end
										end
									elseif (Enum > 58) then
										local FlatIdent_5D2CC = 0;
										local A;
										while true do
											if (FlatIdent_5D2CC == 20) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 21;
											end
											if (FlatIdent_5D2CC == 31) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												break;
											end
											if (19 == FlatIdent_5D2CC) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 20;
											end
											if (FlatIdent_5D2CC == 11) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 12;
											end
											if (FlatIdent_5D2CC == 0) then
												A = nil;
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 1;
											end
											if (FlatIdent_5D2CC == 13) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 14;
											end
											if (26 == FlatIdent_5D2CC) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 27;
											end
											if (FlatIdent_5D2CC == 17) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 18;
											end
											if (FlatIdent_5D2CC == 16) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_5D2CC = 17;
											end
											if (FlatIdent_5D2CC == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_5D2CC = 10;
											end
											if (FlatIdent_5D2CC == 23) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5D2CC = 24;
											end
											if (FlatIdent_5D2CC == 27) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5D2CC = 28;
											end
											if (FlatIdent_5D2CC == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5D2CC = 5;
											end
											if (FlatIdent_5D2CC == 10) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_5D2CC = 11;
											end
											if (FlatIdent_5D2CC == 5) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 6;
											end
											if (FlatIdent_5D2CC == 14) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												FlatIdent_5D2CC = 15;
											end
											if (FlatIdent_5D2CC == 29) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_5D2CC = 30;
											end
											if (FlatIdent_5D2CC == 12) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5D2CC = 13;
											end
											if (FlatIdent_5D2CC == 25) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5D2CC = 26;
											end
											if (7 == FlatIdent_5D2CC) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 8;
											end
											if (FlatIdent_5D2CC == 24) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 25;
											end
											if (FlatIdent_5D2CC == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 2;
											end
											if (FlatIdent_5D2CC == 22) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 23;
											end
											if (FlatIdent_5D2CC == 28) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_5D2CC = 29;
											end
											if (FlatIdent_5D2CC == 3) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 4;
											end
											if (FlatIdent_5D2CC == 18) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5D2CC = 19;
											end
											if (FlatIdent_5D2CC == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 3;
											end
											if (FlatIdent_5D2CC == 15) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 16;
											end
											if (FlatIdent_5D2CC == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5D2CC = 7;
											end
											if (FlatIdent_5D2CC == 21) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 22;
											end
											if (8 == FlatIdent_5D2CC) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5D2CC = 9;
											end
											if (FlatIdent_5D2CC == 30) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5D2CC = 31;
											end
										end
									else
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 61) then
									if (Enum > 60) then
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = #Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local FlatIdent_43917 = 0;
										local B;
										local A;
										while true do
											if (8 == FlatIdent_43917) then
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_43917 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_43917 = 1;
											end
											if (FlatIdent_43917 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_43917 = 5;
											end
											if (FlatIdent_43917 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_43917 = 6;
											end
											if (FlatIdent_43917 == 6) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_43917 = 7;
											end
											if (FlatIdent_43917 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_43917 = 3;
											end
											if (FlatIdent_43917 == 1) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_43917 = 2;
											end
											if (FlatIdent_43917 == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_43917 = 8;
											end
											if (3 == FlatIdent_43917) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_43917 = 4;
											end
										end
									end
								elseif (Enum <= 62) then
									Stk[Inst[2]] = Inst[3] ~= 0;
								elseif (Enum == 63) then
									local B;
									local A;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								elseif (Inst[2] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 97) then
								if (Enum <= 80) then
									if (Enum <= 72) then
										if (Enum <= 68) then
											if (Enum <= 66) then
												if (Enum == 65) then
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
												else
													local FlatIdent_5C6FB = 0;
													local B;
													local A;
													while true do
														if (FlatIdent_5C6FB == 1) then
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_5C6FB = 2;
														end
														if (FlatIdent_5C6FB == 5) then
															Inst = Instr[VIP];
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
														if (FlatIdent_5C6FB == 4) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_5C6FB = 5;
														end
														if (FlatIdent_5C6FB == 2) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															FlatIdent_5C6FB = 3;
														end
														if (FlatIdent_5C6FB == 0) then
															B = nil;
															A = nil;
															A = Inst[2];
															B = Stk[Inst[3]];
															FlatIdent_5C6FB = 1;
														end
														if (FlatIdent_5C6FB == 3) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															FlatIdent_5C6FB = 4;
														end
													end
												end
											elseif (Enum > 67) then
												local FlatIdent_8C93D = 0;
												local A;
												while true do
													if (FlatIdent_8C93D == 10) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_8C93D = 11;
													end
													if (FlatIdent_8C93D == 13) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_8C93D = 14;
													end
													if (FlatIdent_8C93D == 3) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 4;
													end
													if (7 == FlatIdent_8C93D) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_8C93D = 8;
													end
													if (FlatIdent_8C93D == 18) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_8C93D = 19;
													end
													if (FlatIdent_8C93D == 15) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 16;
													end
													if (FlatIdent_8C93D == 4) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_8C93D = 5;
													end
													if (FlatIdent_8C93D == 16) then
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 17;
													end
													if (FlatIdent_8C93D == 21) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 22;
													end
													if (FlatIdent_8C93D == 14) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_8C93D = 15;
													end
													if (5 == FlatIdent_8C93D) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_8C93D = 6;
													end
													if (FlatIdent_8C93D == 23) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_8C93D = 24;
													end
													if (FlatIdent_8C93D == 11) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_8C93D = 12;
													end
													if (FlatIdent_8C93D == 27) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 28;
													end
													if (FlatIdent_8C93D == 26) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_8C93D = 27;
													end
													if (FlatIdent_8C93D == 19) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_8C93D = 20;
													end
													if (FlatIdent_8C93D == 6) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														FlatIdent_8C93D = 7;
													end
													if (FlatIdent_8C93D == 17) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_8C93D = 18;
													end
													if (FlatIdent_8C93D == 12) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_8C93D = 13;
													end
													if (FlatIdent_8C93D == 22) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 23;
													end
													if (FlatIdent_8C93D == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 3;
													end
													if (1 == FlatIdent_8C93D) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_8C93D = 2;
													end
													if (FlatIdent_8C93D == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 9;
													end
													if (FlatIdent_8C93D == 0) then
														A = nil;
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_8C93D = 1;
													end
													if (FlatIdent_8C93D == 9) then
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8C93D = 10;
													end
													if (FlatIdent_8C93D == 25) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														FlatIdent_8C93D = 26;
													end
													if (FlatIdent_8C93D == 20) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_8C93D = 21;
													end
													if (FlatIdent_8C93D == 28) then
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_8C93D == 24) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_8C93D = 25;
													end
												end
											else
												local A = Inst[2];
												do
													return Stk[A], Stk[A + 1];
												end
											end
										elseif (Enum <= 70) then
											if (Enum == 69) then
												local FlatIdent_900D9 = 0;
												local A;
												while true do
													if (FlatIdent_900D9 == 11) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_900D9 = 12;
													end
													if (FlatIdent_900D9 == 7) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														FlatIdent_900D9 = 8;
													end
													if (13 == FlatIdent_900D9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_900D9 = 14;
													end
													if (FlatIdent_900D9 == 5) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_900D9 = 6;
													end
													if (FlatIdent_900D9 == 22) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_900D9 = 23;
													end
													if (FlatIdent_900D9 == 17) then
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_900D9 = 18;
													end
													if (FlatIdent_900D9 == 26) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														FlatIdent_900D9 = 27;
													end
													if (FlatIdent_900D9 == 9) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_900D9 = 10;
													end
													if (FlatIdent_900D9 == 24) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_900D9 = 25;
													end
													if (FlatIdent_900D9 == 23) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_900D9 = 24;
													end
													if (FlatIdent_900D9 == 6) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_900D9 = 7;
													end
													if (FlatIdent_900D9 == 25) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_900D9 = 26;
													end
													if (FlatIdent_900D9 == 12) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_900D9 = 13;
													end
													if (FlatIdent_900D9 == 21) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_900D9 = 22;
													end
													if (FlatIdent_900D9 == 18) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_900D9 = 19;
													end
													if (FlatIdent_900D9 == 4) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_900D9 = 5;
													end
													if (19 == FlatIdent_900D9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_900D9 = 20;
													end
													if (FlatIdent_900D9 == 1) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_900D9 = 2;
													end
													if (FlatIdent_900D9 == 27) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														break;
													end
													if (FlatIdent_900D9 == 10) then
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_900D9 = 11;
													end
													if (FlatIdent_900D9 == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_900D9 = 1;
													end
													if (FlatIdent_900D9 == 14) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_900D9 = 15;
													end
													if (FlatIdent_900D9 == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_900D9 = 9;
													end
													if (FlatIdent_900D9 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_900D9 = 4;
													end
													if (FlatIdent_900D9 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_900D9 = 3;
													end
													if (FlatIdent_900D9 == 20) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_900D9 = 21;
													end
													if (FlatIdent_900D9 == 16) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_900D9 = 17;
													end
													if (FlatIdent_900D9 == 15) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_900D9 = 16;
													end
												end
											else
												local FlatIdent_4FB53 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_4FB53 == 2) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														FlatIdent_4FB53 = 3;
													end
													if (FlatIdent_4FB53 == 8) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_4FB53 = 9;
													end
													if (FlatIdent_4FB53 == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_4FB53 = 11;
													end
													if (FlatIdent_4FB53 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4FB53 = 7;
													end
													if (FlatIdent_4FB53 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4FB53 = 1;
													end
													if (FlatIdent_4FB53 == 7) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4FB53 = 8;
													end
													if (FlatIdent_4FB53 == 11) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_4FB53 = 12;
													end
													if (FlatIdent_4FB53 == 12) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if not Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_4FB53 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_4FB53 = 5;
													end
													if (FlatIdent_4FB53 == 1) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4FB53 = 2;
													end
													if (FlatIdent_4FB53 == 9) then
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_4FB53 = 10;
													end
													if (FlatIdent_4FB53 == 3) then
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_4FB53 = 4;
													end
													if (FlatIdent_4FB53 == 5) then
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														FlatIdent_4FB53 = 6;
													end
												end
											end
										elseif (Enum > 71) then
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										else
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										end
									elseif (Enum <= 76) then
										if (Enum <= 74) then
											if (Enum == 73) then
												local A;
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											else
												local B;
												local A;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											end
										elseif (Enum == 75) then
											local FlatIdent_E2D0 = 0;
											local A;
											while true do
												if (FlatIdent_E2D0 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_E2D0 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_E2D0 = 3;
												end
												if (FlatIdent_E2D0 == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_E2D0 = 4;
												end
												if (FlatIdent_E2D0 == 0) then
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_E2D0 = 1;
												end
												if (FlatIdent_E2D0 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_E2D0 = 2;
												end
											end
										else
											Stk[Inst[2]]();
										end
									elseif (Enum <= 78) then
										if (Enum == 77) then
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										else
											local FlatIdent_5E1D0 = 0;
											local A;
											while true do
												if (25 == FlatIdent_5E1D0) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5E1D0 = 26;
												end
												if (FlatIdent_5E1D0 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 8;
												end
												if (FlatIdent_5E1D0 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 6;
												end
												if (FlatIdent_5E1D0 == 26) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 27;
												end
												if (FlatIdent_5E1D0 == 24) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 25;
												end
												if (FlatIdent_5E1D0 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_5E1D0 = 5;
												end
												if (20 == FlatIdent_5E1D0) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_5E1D0 = 21;
												end
												if (FlatIdent_5E1D0 == 30) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 31;
												end
												if (FlatIdent_5E1D0 == 16) then
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_5E1D0 = 17;
												end
												if (FlatIdent_5E1D0 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 10;
												end
												if (FlatIdent_5E1D0 == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 12;
												end
												if (FlatIdent_5E1D0 == 13) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 14;
												end
												if (FlatIdent_5E1D0 == 23) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_5E1D0 = 24;
												end
												if (FlatIdent_5E1D0 == 27) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													FlatIdent_5E1D0 = 28;
												end
												if (29 == FlatIdent_5E1D0) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_5E1D0 = 30;
												end
												if (FlatIdent_5E1D0 == 19) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5E1D0 = 20;
												end
												if (FlatIdent_5E1D0 == 21) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5E1D0 = 22;
												end
												if (FlatIdent_5E1D0 == 22) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_5E1D0 = 23;
												end
												if (FlatIdent_5E1D0 == 6) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5E1D0 = 7;
												end
												if (FlatIdent_5E1D0 == 17) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_5E1D0 = 18;
												end
												if (3 == FlatIdent_5E1D0) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_5E1D0 = 4;
												end
												if (FlatIdent_5E1D0 == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5E1D0 = 1;
												end
												if (FlatIdent_5E1D0 == 14) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_5E1D0 = 15;
												end
												if (FlatIdent_5E1D0 == 31) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_5E1D0 == 18) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_5E1D0 = 19;
												end
												if (10 == FlatIdent_5E1D0) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_5E1D0 = 11;
												end
												if (FlatIdent_5E1D0 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_5E1D0 = 2;
												end
												if (FlatIdent_5E1D0 == 28) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 29;
												end
												if (FlatIdent_5E1D0 == 8) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													FlatIdent_5E1D0 = 9;
												end
												if (FlatIdent_5E1D0 == 12) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_5E1D0 = 13;
												end
												if (FlatIdent_5E1D0 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5E1D0 = 3;
												end
												if (FlatIdent_5E1D0 == 15) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5E1D0 = 16;
												end
											end
										end
									elseif (Enum == 79) then
										local FlatIdent_3F2AC = 0;
										local A;
										while true do
											if (0 == FlatIdent_3F2AC) then
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Top));
												break;
											end
										end
									else
										local A = Inst[2];
										local Step = Stk[A + 2];
										local Index = Stk[A] + Step;
										Stk[A] = Index;
										if (Step > 0) then
											if (Index <= Stk[A + 1]) then
												local FlatIdent_89142 = 0;
												while true do
													if (FlatIdent_89142 == 0) then
														VIP = Inst[3];
														Stk[A + 3] = Index;
														break;
													end
												end
											end
										elseif (Index >= Stk[A + 1]) then
											local FlatIdent_E47D = 0;
											while true do
												if (FlatIdent_E47D == 0) then
													VIP = Inst[3];
													Stk[A + 3] = Index;
													break;
												end
											end
										end
									end
								elseif (Enum <= 88) then
									if (Enum <= 84) then
										if (Enum <= 82) then
											if (Enum > 81) then
												local B;
												local A;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											else
												local FlatIdent_1AD87 = 0;
												local A;
												while true do
													if (FlatIdent_1AD87 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_1AD87 = 4;
													end
													if (6 == FlatIdent_1AD87) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1AD87 = 7;
													end
													if (FlatIdent_1AD87 == 7) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1AD87 = 8;
													end
													if (FlatIdent_1AD87 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_1AD87 = 5;
													end
													if (FlatIdent_1AD87 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_1AD87 = 2;
													end
													if (FlatIdent_1AD87 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_1AD87 = 3;
													end
													if (FlatIdent_1AD87 == 5) then
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1AD87 = 6;
													end
													if (8 == FlatIdent_1AD87) then
														if (Stk[Inst[2]] == Stk[Inst[4]]) then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_1AD87 == 0) then
														A = nil;
														A = Inst[2];
														Stk[A] = Stk[A]();
														FlatIdent_1AD87 = 1;
													end
												end
											end
										elseif (Enum == 83) then
											local A;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										else
											local FlatIdent_95545 = 0;
											local A;
											local Results;
											local Limit;
											local Edx;
											while true do
												if (FlatIdent_95545 == 1) then
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_95545 = 2;
												end
												if (FlatIdent_95545 == 0) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_95545 = 1;
												end
												if (FlatIdent_95545 == 2) then
													for Idx = A, Top do
														local FlatIdent_2B80F = 0;
														while true do
															if (FlatIdent_2B80F == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													break;
												end
											end
										end
									elseif (Enum <= 86) then
										if (Enum > 85) then
											local FlatIdent_8808B = 0;
											local Results;
											local Edx;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_8808B == 0) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													FlatIdent_8808B = 1;
												end
												if (FlatIdent_8808B == 1) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8808B = 2;
												end
												if (FlatIdent_8808B == 6) then
													for Idx = A, Inst[4] do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_8808B == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													FlatIdent_8808B = 4;
												end
												if (FlatIdent_8808B == 4) then
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													FlatIdent_8808B = 5;
												end
												if (FlatIdent_8808B == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													Edx = 0;
													FlatIdent_8808B = 6;
												end
												if (FlatIdent_8808B == 2) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_8808B = 3;
												end
											end
										else
											local FlatIdent_42297 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_42297 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_42297 = 1;
												end
												if (FlatIdent_42297 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]]();
													FlatIdent_42297 = 2;
												end
												if (FlatIdent_42297 == 6) then
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_42297 = 7;
												end
												if (2 == FlatIdent_42297) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_42297 = 3;
												end
												if (4 == FlatIdent_42297) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_42297 = 5;
												end
												if (FlatIdent_42297 == 7) then
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_42297 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_42297 = 4;
												end
												if (5 == FlatIdent_42297) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_42297 = 6;
												end
											end
										end
									elseif (Enum == 87) then
										local FlatIdent_1CF13 = 0;
										local A;
										while true do
											if (FlatIdent_1CF13 == 20) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1CF13 = 21;
											end
											if (FlatIdent_1CF13 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CF13 = 4;
											end
											if (FlatIdent_1CF13 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1CF13 = 3;
											end
											if (1 == FlatIdent_1CF13) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1CF13 = 2;
											end
											if (FlatIdent_1CF13 == 16) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CF13 = 17;
											end
											if (FlatIdent_1CF13 == 23) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CF13 = 24;
											end
											if (FlatIdent_1CF13 == 27) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_1CF13 == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_1CF13 = 14;
											end
											if (18 == FlatIdent_1CF13) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1CF13 = 19;
											end
											if (FlatIdent_1CF13 == 17) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CF13 = 18;
											end
											if (FlatIdent_1CF13 == 10) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CF13 = 11;
											end
											if (26 == FlatIdent_1CF13) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												FlatIdent_1CF13 = 27;
											end
											if (0 == FlatIdent_1CF13) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1CF13 = 1;
											end
											if (FlatIdent_1CF13 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1CF13 = 7;
											end
											if (FlatIdent_1CF13 == 22) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CF13 = 23;
											end
											if (FlatIdent_1CF13 == 14) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_1CF13 = 15;
											end
											if (FlatIdent_1CF13 == 25) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1CF13 = 26;
											end
											if (FlatIdent_1CF13 == 21) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1CF13 = 22;
											end
											if (FlatIdent_1CF13 == 11) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_1CF13 = 12;
											end
											if (4 == FlatIdent_1CF13) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CF13 = 5;
											end
											if (FlatIdent_1CF13 == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												FlatIdent_1CF13 = 8;
											end
											if (FlatIdent_1CF13 == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1CF13 = 10;
											end
											if (FlatIdent_1CF13 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1CF13 = 9;
											end
											if (FlatIdent_1CF13 == 5) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1CF13 = 6;
											end
											if (FlatIdent_1CF13 == 24) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1CF13 = 25;
											end
											if (FlatIdent_1CF13 == 19) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1CF13 = 20;
											end
											if (FlatIdent_1CF13 == 15) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_1CF13 = 16;
											end
											if (FlatIdent_1CF13 == 12) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1CF13 = 13;
											end
										end
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if not Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 92) then
									if (Enum <= 90) then
										if (Enum > 89) then
											local B;
											local A;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											for Idx = Inst[2], Inst[3] do
												Stk[Idx] = nil;
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum > 91) then
										local FlatIdent_89DA4 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_89DA4 == 7) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_89DA4 = 8;
											end
											if (FlatIdent_89DA4 == 4) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_89DA4 = 5;
											end
											if (FlatIdent_89DA4 == 6) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_89DA4 = 7;
											end
											if (FlatIdent_89DA4 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_89DA4 = 3;
											end
											if (FlatIdent_89DA4 == 9) then
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_89DA4 == 1) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_89DA4 = 2;
											end
											if (FlatIdent_89DA4 == 3) then
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_89DA4 = 4;
											end
											if (FlatIdent_89DA4 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												FlatIdent_89DA4 = 1;
											end
											if (FlatIdent_89DA4 == 5) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_89DA4 = 6;
											end
											if (FlatIdent_89DA4 == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_89DA4 = 9;
											end
										end
									else
										local FlatIdent_7B7BF = 0;
										while true do
											if (FlatIdent_7B7BF == 0) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 1;
											end
											if (FlatIdent_7B7BF == 3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 4;
											end
											if (FlatIdent_7B7BF == 9) then
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_7B7BF == 6) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 7;
											end
											if (7 == FlatIdent_7B7BF) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 8;
											end
											if (4 == FlatIdent_7B7BF) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 5;
											end
											if (FlatIdent_7B7BF == 5) then
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 6;
											end
											if (FlatIdent_7B7BF == 2) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 3;
											end
											if (FlatIdent_7B7BF == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 2;
											end
											if (FlatIdent_7B7BF == 8) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7B7BF = 9;
											end
										end
									end
								elseif (Enum <= 94) then
									if (Enum > 93) then
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
									end
								elseif (Enum <= 95) then
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 96) then
									local FlatIdent_5345 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_5345 == 2) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5345 = 3;
										end
										if (FlatIdent_5345 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_5345 = 1;
										end
										if (FlatIdent_5345 == 3) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5345 = 4;
										end
										if (1 == FlatIdent_5345) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5345 = 2;
										end
										if (5 == FlatIdent_5345) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_5345 == 4) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_5345 = 5;
										end
									end
								else
									local FlatIdent_618E5 = 0;
									local A;
									while true do
										if (FlatIdent_618E5 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_618E5 = 1;
										end
										if (FlatIdent_618E5 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_618E5 = 2;
										end
										if (3 == FlatIdent_618E5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_618E5 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_618E5 = 3;
										end
									end
								end
							elseif (Enum <= 113) then
								if (Enum <= 105) then
									if (Enum <= 101) then
										if (Enum <= 99) then
											if (Enum == 98) then
												local FlatIdent_99321 = 0;
												local A;
												while true do
													if (FlatIdent_99321 == 6) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_99321 = 7;
													end
													if (FlatIdent_99321 == 0) then
														A = nil;
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 1;
													end
													if (FlatIdent_99321 == 24) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_99321 = 25;
													end
													if (30 == FlatIdent_99321) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 31;
													end
													if (FlatIdent_99321 == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_99321 = 11;
													end
													if (FlatIdent_99321 == 19) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 20;
													end
													if (FlatIdent_99321 == 29) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_99321 = 30;
													end
													if (FlatIdent_99321 == 23) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_99321 = 24;
													end
													if (FlatIdent_99321 == 18) then
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_99321 = 19;
													end
													if (FlatIdent_99321 == 12) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_99321 = 13;
													end
													if (FlatIdent_99321 == 17) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 18;
													end
													if (FlatIdent_99321 == 31) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_99321 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 3;
													end
													if (FlatIdent_99321 == 21) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 22;
													end
													if (FlatIdent_99321 == 28) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_99321 = 29;
													end
													if (FlatIdent_99321 == 13) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 14;
													end
													if (FlatIdent_99321 == 14) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														FlatIdent_99321 = 15;
													end
													if (1 == FlatIdent_99321) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_99321 = 2;
													end
													if (FlatIdent_99321 == 20) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_99321 = 21;
													end
													if (FlatIdent_99321 == 27) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_99321 = 28;
													end
													if (FlatIdent_99321 == 22) then
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_99321 = 23;
													end
													if (9 == FlatIdent_99321) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_99321 = 10;
													end
													if (8 == FlatIdent_99321) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_99321 = 9;
													end
													if (25 == FlatIdent_99321) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_99321 = 26;
													end
													if (FlatIdent_99321 == 26) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_99321 = 27;
													end
													if (FlatIdent_99321 == 5) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_99321 = 6;
													end
													if (FlatIdent_99321 == 15) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 16;
													end
													if (FlatIdent_99321 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_99321 = 5;
													end
													if (FlatIdent_99321 == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_99321 = 8;
													end
													if (FlatIdent_99321 == 16) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_99321 = 17;
													end
													if (FlatIdent_99321 == 11) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_99321 = 12;
													end
													if (FlatIdent_99321 == 3) then
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_99321 = 4;
													end
												end
											else
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
											end
										elseif (Enum == 100) then
											local B;
											local T;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
										else
											local A;
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										end
									elseif (Enum <= 103) then
										if (Enum == 102) then
											local Results;
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										else
											local T;
											local A;
											local K;
											local B;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
										end
									elseif (Enum > 104) then
										local FlatIdent_21B40 = 0;
										while true do
											if (0 == FlatIdent_21B40) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 1;
											end
											if (FlatIdent_21B40 == 6) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 7;
											end
											if (FlatIdent_21B40 == 2) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 3;
											end
											if (FlatIdent_21B40 == 5) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 6;
											end
											if (FlatIdent_21B40 == 7) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 8;
											end
											if (3 == FlatIdent_21B40) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 4;
											end
											if (FlatIdent_21B40 == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 5;
											end
											if (FlatIdent_21B40 == 9) then
												VIP = Inst[3];
												break;
											end
											if (8 == FlatIdent_21B40) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 9;
											end
											if (FlatIdent_21B40 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21B40 = 2;
											end
										end
									else
										local A;
										Stk[Inst[2]] = Inst[3] / Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 109) then
									if (Enum <= 107) then
										if (Enum > 106) then
											local A;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										else
											local K;
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										end
									elseif (Enum > 108) then
										Stk[Inst[2]] = Inst[3] / Stk[Inst[4]];
									else
										Stk[Inst[2]] = Env[Inst[3]];
									end
								elseif (Enum <= 111) then
									if (Enum == 110) then
										local FlatIdent_3556F = 0;
										local A;
										while true do
											if (FlatIdent_3556F == 0) then
												A = nil;
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_3556F = 1;
											end
											if (6 == FlatIdent_3556F) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_3556F = 7;
											end
											if (FlatIdent_3556F == 19) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_3556F = 20;
											end
											if (FlatIdent_3556F == 23) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_3556F = 24;
											end
											if (FlatIdent_3556F == 20) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3556F = 21;
											end
											if (17 == FlatIdent_3556F) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_3556F = 18;
											end
											if (FlatIdent_3556F == 11) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												FlatIdent_3556F = 12;
											end
											if (10 == FlatIdent_3556F) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_3556F = 11;
											end
											if (FlatIdent_3556F == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3556F = 2;
											end
											if (5 == FlatIdent_3556F) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_3556F = 6;
											end
											if (FlatIdent_3556F == 18) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_3556F = 19;
											end
											if (FlatIdent_3556F == 22) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_3556F = 23;
											end
											if (FlatIdent_3556F == 2) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3556F = 3;
											end
											if (FlatIdent_3556F == 12) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_3556F = 13;
											end
											if (FlatIdent_3556F == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_3556F = 8;
											end
											if (FlatIdent_3556F == 24) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_3556F = 25;
											end
											if (FlatIdent_3556F == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3556F = 9;
											end
											if (FlatIdent_3556F == 16) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_3556F = 17;
											end
											if (FlatIdent_3556F == 14) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3556F = 15;
											end
											if (FlatIdent_3556F == 9) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3556F = 10;
											end
											if (FlatIdent_3556F == 15) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3556F = 16;
											end
											if (FlatIdent_3556F == 21) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3556F = 22;
											end
											if (FlatIdent_3556F == 3) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_3556F = 4;
											end
											if (13 == FlatIdent_3556F) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_3556F = 14;
											end
											if (FlatIdent_3556F == 25) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												break;
											end
											if (FlatIdent_3556F == 4) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_3556F = 5;
											end
										end
									else
										local A = Inst[2];
										local Index = Stk[A];
										local Step = Stk[A + 2];
										if (Step > 0) then
											if (Index > Stk[A + 1]) then
												VIP = Inst[3];
											else
												Stk[A + 3] = Index;
											end
										elseif (Index < Stk[A + 1]) then
											VIP = Inst[3];
										else
											Stk[A + 3] = Index;
										end
									end
								elseif (Enum > 112) then
									local B;
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								else
									local A;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 121) then
								if (Enum <= 117) then
									if (Enum <= 115) then
										if (Enum == 114) then
											local FlatIdent_8E500 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_8E500 == 1) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8E500 = 2;
												end
												if (FlatIdent_8E500 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_8E500 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_8E500 = 4;
												end
												if (FlatIdent_8E500 == 2) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_8E500 = 3;
												end
												if (0 == FlatIdent_8E500) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_8E500 = 1;
												end
											end
										else
											Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
										end
									elseif (Enum == 116) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										B = Stk[Inst[4]];
										if B then
											VIP = VIP + 1;
										else
											local FlatIdent_9777C = 0;
											while true do
												if (FlatIdent_9777C == 0) then
													Stk[Inst[2]] = B;
													VIP = Inst[3];
													break;
												end
											end
										end
									else
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 119) then
									if (Enum == 118) then
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									elseif (Stk[Inst[2]] <= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 120) then
									local FlatIdent_28673 = 0;
									local A;
									local B;
									while true do
										if (FlatIdent_28673 == 0) then
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_28673 = 1;
										end
										if (1 == FlatIdent_28673) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
									end
								elseif (Stk[Inst[2]] < Stk[Inst[4]]) then
									VIP = Inst[3];
								else
									VIP = VIP + 1;
								end
							elseif (Enum <= 125) then
								if (Enum <= 123) then
									if (Enum > 122) then
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
									end
								elseif (Enum > 124) then
									local FlatIdent_3D949 = 0;
									local A;
									while true do
										if (FlatIdent_3D949 == 23) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D949 = 24;
										end
										if (FlatIdent_3D949 == 24) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_3D949 = 25;
										end
										if (FlatIdent_3D949 == 20) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_3D949 = 21;
										end
										if (FlatIdent_3D949 == 12) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_3D949 = 13;
										end
										if (FlatIdent_3D949 == 13) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_3D949 = 14;
										end
										if (FlatIdent_3D949 == 14) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_3D949 = 15;
										end
										if (FlatIdent_3D949 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_3D949 = 2;
										end
										if (FlatIdent_3D949 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D949 = 4;
										end
										if (11 == FlatIdent_3D949) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_3D949 = 12;
										end
										if (FlatIdent_3D949 == 26) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											FlatIdent_3D949 = 27;
										end
										if (FlatIdent_3D949 == 18) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_3D949 = 19;
										end
										if (FlatIdent_3D949 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											FlatIdent_3D949 = 8;
										end
										if (FlatIdent_3D949 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_3D949 = 7;
										end
										if (FlatIdent_3D949 == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_3D949 = 6;
										end
										if (FlatIdent_3D949 == 25) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_3D949 = 26;
										end
										if (FlatIdent_3D949 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_3D949 = 9;
										end
										if (2 == FlatIdent_3D949) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_3D949 = 3;
										end
										if (17 == FlatIdent_3D949) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D949 = 18;
										end
										if (FlatIdent_3D949 == 19) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_3D949 = 20;
										end
										if (FlatIdent_3D949 == 15) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_3D949 = 16;
										end
										if (FlatIdent_3D949 == 21) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_3D949 = 22;
										end
										if (16 == FlatIdent_3D949) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D949 = 17;
										end
										if (FlatIdent_3D949 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D949 = 10;
										end
										if (FlatIdent_3D949 == 27) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_3D949 == 4) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D949 = 5;
										end
										if (FlatIdent_3D949 == 22) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D949 = 23;
										end
										if (FlatIdent_3D949 == 10) then
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D949 = 11;
										end
										if (0 == FlatIdent_3D949) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_3D949 = 1;
										end
									end
								else
									local Results;
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 127) then
								if (Enum == 126) then
									local B;
									local A;
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								else
									local FlatIdent_238AC = 0;
									local A;
									while true do
										if (4 == FlatIdent_238AC) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_238AC = 5;
										end
										if (FlatIdent_238AC == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_238AC = 2;
										end
										if (0 == FlatIdent_238AC) then
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_238AC = 1;
										end
										if (FlatIdent_238AC == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_238AC = 4;
										end
										if (FlatIdent_238AC == 2) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_238AC = 3;
										end
										if (FlatIdent_238AC == 5) then
											Stk[Inst[2]] = Inst[3];
											break;
										end
									end
								end
							elseif (Enum <= 128) then
								if (Inst[2] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum > 129) then
								local A = Inst[2];
								Stk[A](Stk[A + 1]);
							else
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 195) then
							if (Enum <= 162) then
								if (Enum <= 146) then
									if (Enum <= 138) then
										if (Enum <= 134) then
											if (Enum <= 132) then
												if (Enum == 131) then
													Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
												else
													local FlatIdent_370FF = 0;
													while true do
														if (FlatIdent_370FF == 0) then
															Stk[Inst[2]] = Inst[3] ~= 0;
															VIP = VIP + 1;
															break;
														end
													end
												end
											elseif (Enum == 133) then
												Stk[Inst[2]] = {};
											else
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
											end
										elseif (Enum <= 136) then
											if (Enum == 135) then
												local A;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
											else
												local A;
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
											end
										elseif (Enum == 137) then
											local B;
											local A;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
										else
											local A;
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum <= 142) then
										if (Enum <= 140) then
											if (Enum == 139) then
												local FlatIdent_3A029 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_3A029 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_3A029 = 5;
													end
													if (FlatIdent_3A029 == 3) then
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_3A029 = 4;
													end
													if (FlatIdent_3A029 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_3A029 = 3;
													end
													if (FlatIdent_3A029 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_3A029 = 7;
													end
													if (FlatIdent_3A029 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_3A029 = 2;
													end
													if (FlatIdent_3A029 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3] ~= 0;
														FlatIdent_3A029 = 6;
													end
													if (FlatIdent_3A029 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_3A029 = 1;
													end
													if (8 == FlatIdent_3A029) then
														Stk[Inst[2]] = Stk[Inst[3]];
														break;
													end
													if (FlatIdent_3A029 == 7) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3A029 = 8;
													end
												end
											else
												local B;
												local A;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
											end
										elseif (Enum > 141) then
											Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
										else
											local FlatIdent_23179 = 0;
											local B;
											local A;
											while true do
												if (8 == FlatIdent_23179) then
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (2 == FlatIdent_23179) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_23179 = 3;
												end
												if (FlatIdent_23179 == 1) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_23179 = 2;
												end
												if (FlatIdent_23179 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													FlatIdent_23179 = 1;
												end
												if (FlatIdent_23179 == 7) then
													for Idx = Inst[2], Inst[3] do
														Stk[Idx] = nil;
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_23179 = 8;
												end
												if (FlatIdent_23179 == 6) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_23179 = 7;
												end
												if (FlatIdent_23179 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_23179 = 4;
												end
												if (FlatIdent_23179 == 5) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_23179 = 6;
												end
												if (FlatIdent_23179 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_23179 = 5;
												end
											end
										end
									elseif (Enum <= 144) then
										if (Enum == 143) then
											local Step;
											local Index;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = #Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Index = Stk[A];
											Step = Stk[A + 2];
											if (Step > 0) then
												if (Index > Stk[A + 1]) then
													VIP = Inst[3];
												else
													Stk[A + 3] = Index;
												end
											elseif (Index < Stk[A + 1]) then
												VIP = Inst[3];
											else
												Stk[A + 3] = Index;
											end
										elseif (Stk[Inst[2]] ~= Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum > 145) then
										local B = Stk[Inst[4]];
										if not B then
											VIP = VIP + 1;
										else
											Stk[Inst[2]] = B;
											VIP = Inst[3];
										end
									else
										Upvalues[Inst[3]] = Stk[Inst[2]];
									end
								elseif (Enum <= 154) then
									if (Enum <= 150) then
										if (Enum <= 148) then
											if (Enum > 147) then
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											else
												local FlatIdent_46188 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_46188 == 3) then
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_46188 = 4;
													end
													if (FlatIdent_46188 == 2) then
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														FlatIdent_46188 = 3;
													end
													if (FlatIdent_46188 == 4) then
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														VIP = Inst[3];
														break;
													end
													if (FlatIdent_46188 == 1) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_46188 = 2;
													end
													if (FlatIdent_46188 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_46188 = 1;
													end
												end
											end
										elseif (Enum > 149) then
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
										else
											local FlatIdent_3603D = 0;
											local A;
											while true do
												if (FlatIdent_3603D == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_3603D = 5;
												end
												if (FlatIdent_3603D == 24) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_3603D = 25;
												end
												if (FlatIdent_3603D == 8) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3603D = 9;
												end
												if (FlatIdent_3603D == 22) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_3603D = 23;
												end
												if (FlatIdent_3603D == 1) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3603D = 2;
												end
												if (FlatIdent_3603D == 2) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_3603D = 3;
												end
												if (FlatIdent_3603D == 20) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3603D = 21;
												end
												if (FlatIdent_3603D == 13) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3603D = 14;
												end
												if (FlatIdent_3603D == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3603D = 1;
												end
												if (FlatIdent_3603D == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_3603D = 12;
												end
												if (FlatIdent_3603D == 18) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_3603D = 19;
												end
												if (FlatIdent_3603D == 19) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3603D = 20;
												end
												if (FlatIdent_3603D == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3603D = 8;
												end
												if (FlatIdent_3603D == 25) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_3603D == 14) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3603D = 15;
												end
												if (FlatIdent_3603D == 17) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_3603D = 18;
												end
												if (FlatIdent_3603D == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_3603D = 6;
												end
												if (FlatIdent_3603D == 16) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_3603D = 17;
												end
												if (FlatIdent_3603D == 9) then
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_3603D = 10;
												end
												if (FlatIdent_3603D == 23) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_3603D = 24;
												end
												if (FlatIdent_3603D == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_3603D = 7;
												end
												if (FlatIdent_3603D == 12) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_3603D = 13;
												end
												if (FlatIdent_3603D == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													FlatIdent_3603D = 11;
												end
												if (FlatIdent_3603D == 15) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_3603D = 16;
												end
												if (FlatIdent_3603D == 3) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_3603D = 4;
												end
												if (FlatIdent_3603D == 21) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_3603D = 22;
												end
											end
										end
									elseif (Enum <= 152) then
										if (Enum > 151) then
											local B;
											local A;
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local A;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										end
									elseif (Enum == 153) then
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										B = Stk[Inst[4]];
										if B then
											VIP = VIP + 1;
										else
											local FlatIdent_8F944 = 0;
											while true do
												if (FlatIdent_8F944 == 0) then
													Stk[Inst[2]] = B;
													VIP = Inst[3];
													break;
												end
											end
										end
									else
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									end
								elseif (Enum <= 158) then
									if (Enum <= 156) then
										if (Enum > 155) then
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										else
											local FlatIdent_6BBE5 = 0;
											local A;
											while true do
												if (FlatIdent_6BBE5 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_6BBE5 = 2;
												end
												if (FlatIdent_6BBE5 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6BBE5 = 4;
												end
												if (6 == FlatIdent_6BBE5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (0 == FlatIdent_6BBE5) then
													A = nil;
													Stk[Inst[2]] = Inst[3] / Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6BBE5 = 1;
												end
												if (FlatIdent_6BBE5 == 5) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_6BBE5 = 6;
												end
												if (FlatIdent_6BBE5 == 4) then
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6BBE5 = 5;
												end
												if (FlatIdent_6BBE5 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6BBE5 = 3;
												end
											end
										end
									elseif (Enum > 157) then
										local FlatIdent_CFAD = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_CFAD == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_CFAD = 1;
											end
											if (FlatIdent_CFAD == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if (Stk[Inst[2]] == Stk[Inst[4]]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_CFAD == 2) then
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_CFAD = 3;
											end
											if (FlatIdent_CFAD == 1) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_CFAD = 2;
											end
											if (FlatIdent_CFAD == 3) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_CFAD = 4;
											end
										end
									else
										local FlatIdent_1A3FF = 0;
										local A;
										while true do
											if (15 == FlatIdent_1A3FF) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_1A3FF = 16;
											end
											if (FlatIdent_1A3FF == 4) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1A3FF = 5;
											end
											if (FlatIdent_1A3FF == 19) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1A3FF = 20;
											end
											if (FlatIdent_1A3FF == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1A3FF = 3;
											end
											if (FlatIdent_1A3FF == 20) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1A3FF = 21;
											end
											if (FlatIdent_1A3FF == 17) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1A3FF = 18;
											end
											if (FlatIdent_1A3FF == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_1A3FF = 14;
											end
											if (FlatIdent_1A3FF == 11) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_1A3FF = 12;
											end
											if (FlatIdent_1A3FF == 23) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1A3FF = 24;
											end
											if (FlatIdent_1A3FF == 24) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1A3FF = 25;
											end
											if (FlatIdent_1A3FF == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1A3FF = 7;
											end
											if (FlatIdent_1A3FF == 27) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_1A3FF == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1A3FF = 1;
											end
											if (FlatIdent_1A3FF == 21) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1A3FF = 22;
											end
											if (FlatIdent_1A3FF == 5) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1A3FF = 6;
											end
											if (FlatIdent_1A3FF == 16) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1A3FF = 17;
											end
											if (FlatIdent_1A3FF == 14) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_1A3FF = 15;
											end
											if (FlatIdent_1A3FF == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1A3FF = 10;
											end
											if (FlatIdent_1A3FF == 22) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1A3FF = 23;
											end
											if (FlatIdent_1A3FF == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												FlatIdent_1A3FF = 8;
											end
											if (FlatIdent_1A3FF == 25) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1A3FF = 26;
											end
											if (18 == FlatIdent_1A3FF) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1A3FF = 19;
											end
											if (FlatIdent_1A3FF == 12) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1A3FF = 13;
											end
											if (FlatIdent_1A3FF == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1A3FF = 9;
											end
											if (FlatIdent_1A3FF == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1A3FF = 4;
											end
											if (26 == FlatIdent_1A3FF) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												FlatIdent_1A3FF = 27;
											end
											if (FlatIdent_1A3FF == 10) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1A3FF = 11;
											end
											if (FlatIdent_1A3FF == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1A3FF = 2;
											end
										end
									end
								elseif (Enum <= 160) then
									if (Enum > 159) then
										if (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
								elseif (Enum == 161) then
									local FlatIdent_70C86 = 0;
									local A;
									local T;
									while true do
										if (FlatIdent_70C86 == 0) then
											A = Inst[2];
											T = Stk[A];
											FlatIdent_70C86 = 1;
										end
										if (FlatIdent_70C86 == 1) then
											for Idx = A + 1, Inst[3] do
												Insert(T, Stk[Idx]);
											end
											break;
										end
									end
								else
									local B;
									local T;
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
								end
							elseif (Enum <= 178) then
								if (Enum <= 170) then
									if (Enum <= 166) then
										if (Enum <= 164) then
											if (Enum > 163) then
												local A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
											else
												local B;
												local A;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											end
										elseif (Enum > 165) then
											local FlatIdent_1B4EE = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_1B4EE == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1B4EE = 1;
												end
												if (FlatIdent_1B4EE == 3) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_1B4EE = 4;
												end
												if (5 == FlatIdent_1B4EE) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1B4EE = 6;
												end
												if (FlatIdent_1B4EE == 1) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1B4EE = 2;
												end
												if (FlatIdent_1B4EE == 4) then
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1B4EE = 5;
												end
												if (FlatIdent_1B4EE == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1B4EE = 3;
												end
												if (FlatIdent_1B4EE == 6) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													break;
												end
											end
										else
											local FlatIdent_52966 = 0;
											local B;
											local K;
											while true do
												if (FlatIdent_52966 == 1) then
													for Idx = B + 1, Inst[4] do
														K = K .. Stk[Idx];
													end
													Stk[Inst[2]] = K;
													break;
												end
												if (FlatIdent_52966 == 0) then
													B = Inst[3];
													K = Stk[B];
													FlatIdent_52966 = 1;
												end
											end
										end
									elseif (Enum <= 168) then
										if (Enum > 167) then
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local FlatIdent_405CA = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_405CA == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_405CA = 4;
												end
												if (6 == FlatIdent_405CA) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_405CA = 7;
												end
												if (0 == FlatIdent_405CA) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_405CA = 1;
												end
												if (FlatIdent_405CA == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_405CA = 6;
												end
												if (FlatIdent_405CA == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_405CA = 3;
												end
												if (FlatIdent_405CA == 1) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_405CA = 2;
												end
												if (FlatIdent_405CA == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_405CA = 8;
												end
												if (FlatIdent_405CA == 8) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_405CA == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_405CA = 5;
												end
											end
										end
									elseif (Enum == 169) then
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
									else
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 174) then
									if (Enum <= 172) then
										if (Enum == 171) then
											local FlatIdent_912A1 = 0;
											local B;
											local T;
											local A;
											while true do
												if (FlatIdent_912A1 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_912A1 = 2;
												end
												if (FlatIdent_912A1 == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_912A1 = 4;
												end
												if (FlatIdent_912A1 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													T = Stk[A];
													B = Inst[3];
													FlatIdent_912A1 = 5;
												end
												if (FlatIdent_912A1 == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_912A1 = 3;
												end
												if (FlatIdent_912A1 == 0) then
													B = nil;
													T = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_912A1 = 1;
												end
												if (FlatIdent_912A1 == 5) then
													for Idx = 1, B do
														T[Idx] = Stk[A + Idx];
													end
													break;
												end
											end
										else
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										end
									elseif (Enum > 173) then
										local A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
									else
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 176) then
									if (Enum == 175) then
										local FlatIdent_F8A8 = 0;
										local A;
										while true do
											if (FlatIdent_F8A8 == 0) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
										end
									else
										local FlatIdent_65580 = 0;
										local A;
										while true do
											if (FlatIdent_65580 == 10) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												FlatIdent_65580 = 11;
											end
											if (FlatIdent_65580 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_65580 = 6;
											end
											if (FlatIdent_65580 == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_65580 = 14;
											end
											if (22 == FlatIdent_65580) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_65580 = 23;
											end
											if (FlatIdent_65580 == 3) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_65580 = 4;
											end
											if (FlatIdent_65580 == 25) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_65580 == 12) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_65580 = 13;
											end
											if (FlatIdent_65580 == 1) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_65580 = 2;
											end
											if (FlatIdent_65580 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_65580 = 7;
											end
											if (FlatIdent_65580 == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_65580 = 8;
											end
											if (16 == FlatIdent_65580) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_65580 = 17;
											end
											if (FlatIdent_65580 == 8) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_65580 = 9;
											end
											if (FlatIdent_65580 == 9) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_65580 = 10;
											end
											if (FlatIdent_65580 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_65580 = 5;
											end
											if (FlatIdent_65580 == 20) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_65580 = 21;
											end
											if (FlatIdent_65580 == 2) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_65580 = 3;
											end
											if (FlatIdent_65580 == 19) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_65580 = 20;
											end
											if (FlatIdent_65580 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_65580 = 1;
											end
											if (FlatIdent_65580 == 23) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_65580 = 24;
											end
											if (18 == FlatIdent_65580) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_65580 = 19;
											end
											if (14 == FlatIdent_65580) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_65580 = 15;
											end
											if (FlatIdent_65580 == 21) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_65580 = 22;
											end
											if (FlatIdent_65580 == 15) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_65580 = 16;
											end
											if (FlatIdent_65580 == 17) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_65580 = 18;
											end
											if (FlatIdent_65580 == 11) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_65580 = 12;
											end
											if (FlatIdent_65580 == 24) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_65580 = 25;
											end
										end
									end
								elseif (Enum > 177) then
									local A;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								else
									local B;
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								end
							elseif (Enum <= 186) then
								if (Enum <= 182) then
									if (Enum <= 180) then
										if (Enum > 179) then
											local A;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										else
											VIP = Inst[3];
										end
									elseif (Enum == 181) then
										local FlatIdent_356A8 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_356A8 == 5) then
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_356A8 = 6;
											end
											if (FlatIdent_356A8 == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_356A8 = 3;
											end
											if (FlatIdent_356A8 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_356A8 = 5;
											end
											if (FlatIdent_356A8 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_356A8 = 2;
											end
											if (6 == FlatIdent_356A8) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_356A8 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_356A8 = 4;
											end
											if (FlatIdent_356A8 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_356A8 = 1;
											end
										end
									else
										Stk[Inst[2]] = Upvalues[Inst[3]];
									end
								elseif (Enum <= 184) then
									if (Enum > 183) then
										Stk[Inst[2]] = #Stk[Inst[3]];
									else
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									end
								elseif (Enum == 185) then
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_8B208 = 0;
									local A;
									while true do
										if (FlatIdent_8B208 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8B208 = 7;
										end
										if (FlatIdent_8B208 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8B208 = 6;
										end
										if (FlatIdent_8B208 == 20) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8B208 = 21;
										end
										if (FlatIdent_8B208 == 21) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8B208 = 22;
										end
										if (FlatIdent_8B208 == 13) then
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											FlatIdent_8B208 = 14;
										end
										if (FlatIdent_8B208 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											FlatIdent_8B208 = 10;
										end
										if (FlatIdent_8B208 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8B208 = 4;
										end
										if (FlatIdent_8B208 == 11) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8B208 = 12;
										end
										if (FlatIdent_8B208 == 14) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_8B208 = 15;
										end
										if (10 == FlatIdent_8B208) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8B208 = 11;
										end
										if (FlatIdent_8B208 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											FlatIdent_8B208 = 2;
										end
										if (FlatIdent_8B208 == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8B208 = 1;
										end
										if (FlatIdent_8B208 == 19) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8B208 = 20;
										end
										if (FlatIdent_8B208 == 17) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8B208 = 18;
										end
										if (FlatIdent_8B208 == 16) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8B208 = 17;
										end
										if (FlatIdent_8B208 == 12) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8B208 = 13;
										end
										if (FlatIdent_8B208 == 18) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_8B208 = 19;
										end
										if (FlatIdent_8B208 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8B208 = 8;
										end
										if (FlatIdent_8B208 == 15) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_8B208 = 16;
										end
										if (FlatIdent_8B208 == 24) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											break;
										end
										if (FlatIdent_8B208 == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8B208 = 5;
										end
										if (23 == FlatIdent_8B208) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											FlatIdent_8B208 = 24;
										end
										if (2 == FlatIdent_8B208) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_8B208 = 3;
										end
										if (FlatIdent_8B208 == 22) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8B208 = 23;
										end
										if (FlatIdent_8B208 == 8) then
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8B208 = 9;
										end
									end
								end
							elseif (Enum <= 190) then
								if (Enum <= 188) then
									if (Enum == 187) then
										local A = Inst[2];
										local B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Stk[Inst[4]]];
									else
										local A;
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									end
								elseif (Enum > 189) then
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Stk[Inst[2]] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local A = Inst[2];
									local T = Stk[A];
									local B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
								end
							elseif (Enum <= 192) then
								if (Enum > 191) then
									Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
								else
									local A = Inst[2];
									do
										return Unpack(Stk, A, Top);
									end
								end
							elseif (Enum <= 193) then
								local B;
								local Edx;
								local Limit;
								local Results;
								local A;
								A = Inst[2];
								Results = {Stk[A]()};
								Limit = Inst[4];
								Edx = 0;
								for Idx = A, Limit do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = #Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Inst[2] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 194) then
								if (Inst[2] <= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 228) then
							if (Enum <= 211) then
								if (Enum <= 203) then
									if (Enum <= 199) then
										if (Enum <= 197) then
											if (Enum == 196) then
												local FlatIdent_50124 = 0;
												local A;
												while true do
													if (FlatIdent_50124 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if not Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_50124 == 0) then
														A = nil;
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_50124 = 1;
													end
													if (FlatIdent_50124 == 3) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_50124 = 4;
													end
													if (1 == FlatIdent_50124) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_50124 = 2;
													end
													if (FlatIdent_50124 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3] ~= 0;
														VIP = VIP + 1;
														FlatIdent_50124 = 3;
													end
												end
											else
												local Results;
												local Edx;
												local Results, Limit;
												local B;
												local A;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_34C5A = 0;
													while true do
														if (FlatIdent_34C5A == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												for Idx = A, Inst[4] do
													local FlatIdent_48817 = 0;
													while true do
														if (FlatIdent_48817 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
											end
										elseif (Enum > 198) then
											local A;
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										else
											Stk[Inst[2]] = not Stk[Inst[3]];
										end
									elseif (Enum <= 201) then
										if (Enum == 200) then
											local Results;
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_4C237 = 0;
												while true do
													if (FlatIdent_4C237 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										else
											Stk[Inst[2]][Inst[3]] = Inst[4];
										end
									elseif (Enum > 202) then
										local Step;
										local Index;
										local A;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = #Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Index = Stk[A];
										Step = Stk[A + 2];
										if (Step > 0) then
											if (Index > Stk[A + 1]) then
												VIP = Inst[3];
											else
												Stk[A + 3] = Index;
											end
										elseif (Index < Stk[A + 1]) then
											VIP = Inst[3];
										else
											Stk[A + 3] = Index;
										end
									else
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if not Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 207) then
									if (Enum <= 205) then
										if (Enum == 204) then
											local FlatIdent_5A208 = 0;
											local A;
											while true do
												if (FlatIdent_5A208 == 0) then
													A = nil;
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_5A208 = 1;
												end
												if (FlatIdent_5A208 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													FlatIdent_5A208 = 3;
												end
												if (FlatIdent_5A208 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5A208 = 2;
												end
												if (FlatIdent_5A208 == 5) then
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_5A208 == 4) then
													Stk[A] = Stk[A]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5A208 = 5;
												end
												if (FlatIdent_5A208 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_5A208 = 4;
												end
											end
										else
											local B;
											local T;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
										end
									elseif (Enum == 206) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 209) then
									if (Enum > 208) then
										local FlatIdent_781FA = 0;
										local A;
										while true do
											if (FlatIdent_781FA == 24) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												break;
											end
											if (FlatIdent_781FA == 23) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_781FA = 24;
											end
											if (FlatIdent_781FA == 13) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_781FA = 14;
											end
											if (FlatIdent_781FA == 19) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_781FA = 20;
											end
											if (FlatIdent_781FA == 12) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_781FA = 13;
											end
											if (FlatIdent_781FA == 5) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_781FA = 6;
											end
											if (FlatIdent_781FA == 17) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_781FA = 18;
											end
											if (FlatIdent_781FA == 10) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_781FA = 11;
											end
											if (FlatIdent_781FA == 20) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_781FA = 21;
											end
											if (FlatIdent_781FA == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_781FA = 1;
											end
											if (FlatIdent_781FA == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_781FA = 3;
											end
											if (FlatIdent_781FA == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_781FA = 5;
											end
											if (FlatIdent_781FA == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_781FA = 9;
											end
											if (FlatIdent_781FA == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_781FA = 8;
											end
											if (FlatIdent_781FA == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_781FA = 4;
											end
											if (FlatIdent_781FA == 11) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_781FA = 12;
											end
											if (FlatIdent_781FA == 15) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_781FA = 16;
											end
											if (FlatIdent_781FA == 18) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_781FA = 19;
											end
											if (FlatIdent_781FA == 22) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_781FA = 23;
											end
											if (FlatIdent_781FA == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_781FA = 2;
											end
											if (FlatIdent_781FA == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_781FA = 10;
											end
											if (FlatIdent_781FA == 21) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_781FA = 22;
											end
											if (14 == FlatIdent_781FA) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_781FA = 15;
											end
											if (FlatIdent_781FA == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_781FA = 7;
											end
											if (FlatIdent_781FA == 16) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_781FA = 17;
											end
										end
									else
										local FlatIdent_81325 = 0;
										local B;
										while true do
											if (0 == FlatIdent_81325) then
												B = Stk[Inst[4]];
												if B then
													VIP = VIP + 1;
												else
													Stk[Inst[2]] = B;
													VIP = Inst[3];
												end
												break;
											end
										end
									end
								elseif (Enum > 210) then
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
								end
							elseif (Enum <= 219) then
								if (Enum <= 215) then
									if (Enum <= 213) then
										if (Enum > 212) then
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										end
									elseif (Enum == 214) then
										local A;
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A = Inst[2];
										do
											return Unpack(Stk, A, A + Inst[3]);
										end
									end
								elseif (Enum <= 217) then
									if (Enum == 216) then
										local FlatIdent_158F3 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_158F3 == 9) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_158F3 = 10;
											end
											if (FlatIdent_158F3 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_158F3 = 8;
											end
											if (FlatIdent_158F3 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_158F3 = 2;
											end
											if (FlatIdent_158F3 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_158F3 = 5;
											end
											if (FlatIdent_158F3 == 3) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_158F3 = 4;
											end
											if (2 == FlatIdent_158F3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_158F3 = 3;
											end
											if (FlatIdent_158F3 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_158F3 = 6;
											end
											if (FlatIdent_158F3 == 12) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_158F3 == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_158F3 = 9;
											end
											if (FlatIdent_158F3 == 10) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_158F3 = 11;
											end
											if (FlatIdent_158F3 == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_158F3 = 7;
											end
											if (FlatIdent_158F3 == 11) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_158F3 = 12;
											end
											if (FlatIdent_158F3 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_158F3 = 1;
											end
										end
									else
										local FlatIdent_20415 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_20415 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_20415 = 4;
											end
											if (FlatIdent_20415 == 5) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_20415 = 6;
											end
											if (2 == FlatIdent_20415) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_20415 = 3;
											end
											if (FlatIdent_20415 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_20415 = 5;
											end
											if (FlatIdent_20415 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_20415 = 1;
											end
											if (FlatIdent_20415 == 6) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_20415 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_20415 = 2;
											end
										end
									end
								elseif (Enum > 218) then
									local FlatIdent_5BF0C = 0;
									local A;
									while true do
										if (FlatIdent_5BF0C == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_5BF0C = 3;
										end
										if (4 == FlatIdent_5BF0C) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_5BF0C = 5;
										end
										if (FlatIdent_5BF0C == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_5BF0C = 2;
										end
										if (FlatIdent_5BF0C == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5BF0C = 4;
										end
										if (FlatIdent_5BF0C == 5) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_5BF0C == 0) then
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5BF0C = 1;
										end
									end
								else
									local A;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 223) then
								if (Enum <= 221) then
									if (Enum > 220) then
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									end
								elseif (Enum == 222) then
									local FlatIdent_2ABD9 = 0;
									local A;
									while true do
										if (FlatIdent_2ABD9 == 17) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2ABD9 = 18;
										end
										if (FlatIdent_2ABD9 == 24) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_2ABD9 = 25;
										end
										if (FlatIdent_2ABD9 == 2) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2ABD9 = 3;
										end
										if (FlatIdent_2ABD9 == 0) then
											A = nil;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_2ABD9 = 1;
										end
										if (25 == FlatIdent_2ABD9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											break;
										end
										if (FlatIdent_2ABD9 == 14) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2ABD9 = 15;
										end
										if (FlatIdent_2ABD9 == 13) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_2ABD9 = 14;
										end
										if (FlatIdent_2ABD9 == 20) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2ABD9 = 21;
										end
										if (FlatIdent_2ABD9 == 23) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_2ABD9 = 24;
										end
										if (5 == FlatIdent_2ABD9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_2ABD9 = 6;
										end
										if (16 == FlatIdent_2ABD9) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2ABD9 = 17;
										end
										if (FlatIdent_2ABD9 == 12) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_2ABD9 = 13;
										end
										if (FlatIdent_2ABD9 == 19) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_2ABD9 = 20;
										end
										if (10 == FlatIdent_2ABD9) then
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2ABD9 = 11;
										end
										if (FlatIdent_2ABD9 == 21) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2ABD9 = 22;
										end
										if (FlatIdent_2ABD9 == 4) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_2ABD9 = 5;
										end
										if (FlatIdent_2ABD9 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_2ABD9 = 8;
										end
										if (FlatIdent_2ABD9 == 18) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_2ABD9 = 19;
										end
										if (FlatIdent_2ABD9 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_2ABD9 = 7;
										end
										if (FlatIdent_2ABD9 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2ABD9 = 9;
										end
										if (FlatIdent_2ABD9 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2ABD9 = 4;
										end
										if (FlatIdent_2ABD9 == 9) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2ABD9 = 10;
										end
										if (FlatIdent_2ABD9 == 15) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2ABD9 = 16;
										end
										if (FlatIdent_2ABD9 == 11) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											FlatIdent_2ABD9 = 12;
										end
										if (FlatIdent_2ABD9 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2ABD9 = 2;
										end
										if (FlatIdent_2ABD9 == 22) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2ABD9 = 23;
										end
									end
								else
									Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
								end
							elseif (Enum <= 225) then
								if (Enum > 224) then
									local B;
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								else
									local FlatIdent_829BD = 0;
									while true do
										if (FlatIdent_829BD == 2) then
											Inst = Instr[VIP];
											do
												return;
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_829BD = 3;
										end
										if (FlatIdent_829BD == 0) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_829BD = 1;
										end
										if (FlatIdent_829BD == 3) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_829BD == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_829BD = 2;
										end
									end
								end
							elseif (Enum <= 226) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif (Enum > 227) then
								local A = Inst[2];
								local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								local Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_9908F = 0;
									while true do
										if (FlatIdent_9908F == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							else
								local FlatIdent_13C0 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_13C0 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_13C0 = 2;
									end
									if (FlatIdent_13C0 == 8) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_13C0 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_13C0 = 1;
									end
									if (FlatIdent_13C0 == 7) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_13C0 = 8;
									end
									if (3 == FlatIdent_13C0) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_13C0 = 4;
									end
									if (FlatIdent_13C0 == 2) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_13C0 = 3;
									end
									if (FlatIdent_13C0 == 4) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_13C0 = 5;
									end
									if (FlatIdent_13C0 == 5) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_13C0 = 6;
									end
									if (FlatIdent_13C0 == 6) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_13C0 = 7;
									end
								end
							end
						elseif (Enum <= 244) then
							if (Enum <= 236) then
								if (Enum <= 232) then
									if (Enum <= 230) then
										if (Enum > 229) then
											local A;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										else
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
										end
									elseif (Enum > 231) then
										local FlatIdent_5694C = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_5694C == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												FlatIdent_5694C = 8;
											end
											if (FlatIdent_5694C == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5694C = 3;
											end
											if (0 == FlatIdent_5694C) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_5694C = 1;
											end
											if (FlatIdent_5694C == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5694C = 6;
											end
											if (4 == FlatIdent_5694C) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5694C = 5;
											end
											if (FlatIdent_5694C == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												for Idx = A, Inst[4] do
													local FlatIdent_528F6 = 0;
													while true do
														if (FlatIdent_528F6 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												FlatIdent_5694C = 9;
											end
											if (FlatIdent_5694C == 6) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_5694C = 7;
											end
											if (FlatIdent_5694C == 9) then
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_5694C == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5694C = 2;
											end
											if (FlatIdent_5694C == 3) then
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_5694C = 4;
											end
										end
									else
										local FlatIdent_33825 = 0;
										while true do
											if (FlatIdent_33825 == 4) then
												if not Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_33825 == 0) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_33825 = 1;
											end
											if (FlatIdent_33825 == 2) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_33825 = 3;
											end
											if (FlatIdent_33825 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_33825 = 2;
											end
											if (FlatIdent_33825 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_33825 = 4;
											end
										end
									end
								elseif (Enum <= 234) then
									if (Enum > 233) then
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
									else
										local FlatIdent_75E50 = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_75E50 == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_75E50 = 3;
											end
											if (FlatIdent_75E50 == 1) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_75E50 = 2;
											end
											if (FlatIdent_75E50 == 6) then
												for Idx = A, Inst[4] do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_75E50 == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												FlatIdent_75E50 = 1;
											end
											if (FlatIdent_75E50 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												FlatIdent_75E50 = 6;
											end
											if (FlatIdent_75E50 == 4) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_75E50 = 5;
											end
											if (FlatIdent_75E50 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												FlatIdent_75E50 = 4;
											end
										end
									end
								elseif (Enum == 235) then
									local NewProto = Proto[Inst[3]];
									local NewUvals;
									local Indexes = {};
									NewUvals = Setmetatable({}, {__index=function(_, Key)
										local Val = Indexes[Key];
										return Val[1][Val[2]];
									end,__newindex=function(_, Key, Value)
										local Val = Indexes[Key];
										Val[1][Val[2]] = Value;
									end});
									for Idx = 1, Inst[4] do
										VIP = VIP + 1;
										local Mvm = Instr[VIP];
										if (Mvm[1] == 53) then
											Indexes[Idx - 1] = {Stk,Mvm[3]};
										else
											Indexes[Idx - 1] = {Upvalues,Mvm[3]};
										end
										Lupvals[#Lupvals + 1] = Indexes;
									end
									Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
								else
									local B;
									local A;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 240) then
								if (Enum <= 238) then
									if (Enum == 237) then
										local FlatIdent_167C0 = 0;
										local Results;
										local Edx;
										local Limit;
										local A;
										local K;
										local B;
										while true do
											if (FlatIdent_167C0 == 6) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_167C0 = 7;
											end
											if (FlatIdent_167C0 == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												FlatIdent_167C0 = 10;
											end
											if (FlatIdent_167C0 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_167C0 = 3;
											end
											if (FlatIdent_167C0 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_167C0 = 6;
											end
											if (FlatIdent_167C0 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_167C0 = 5;
											end
											if (FlatIdent_167C0 == 8) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_167C0 = 9;
											end
											if (3 == FlatIdent_167C0) then
												B = Inst[3];
												K = Stk[B];
												for Idx = B + 1, Inst[4] do
													K = K .. Stk[Idx];
												end
												Stk[Inst[2]] = K;
												FlatIdent_167C0 = 4;
											end
											if (FlatIdent_167C0 == 1) then
												K = nil;
												B = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_167C0 = 2;
											end
											if (FlatIdent_167C0 == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_167C0 = 1;
											end
											if (FlatIdent_167C0 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												FlatIdent_167C0 = 8;
											end
											if (FlatIdent_167C0 == 10) then
												for Idx = A, Inst[4] do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
										end
									else
										local Step;
										local Index;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Index = Stk[A];
										Step = Stk[A + 2];
										if (Step > 0) then
											if (Index > Stk[A + 1]) then
												VIP = Inst[3];
											else
												Stk[A + 3] = Index;
											end
										elseif (Index < Stk[A + 1]) then
											VIP = Inst[3];
										else
											Stk[A + 3] = Index;
										end
									end
								elseif (Enum == 239) then
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										local FlatIdent_B964 = 0;
										while true do
											if (FlatIdent_B964 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
								end
							elseif (Enum <= 242) then
								if (Enum > 241) then
									local A;
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								else
									local FlatIdent_5353A = 0;
									local A;
									while true do
										if (FlatIdent_5353A == 3) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_5353A = 4;
										end
										if (FlatIdent_5353A == 0) then
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_5353A = 1;
										end
										if (FlatIdent_5353A == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											FlatIdent_5353A = 3;
										end
										if (1 == FlatIdent_5353A) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_5353A = 2;
										end
										if (FlatIdent_5353A == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
									end
								end
							elseif (Enum == 243) then
								local FlatIdent_4D69 = 0;
								local A;
								while true do
									if (FlatIdent_4D69 == 9) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4D69 = 10;
									end
									if (FlatIdent_4D69 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_4D69 = 4;
									end
									if (FlatIdent_4D69 == 13) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_4D69 = 14;
									end
									if (FlatIdent_4D69 == 18) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_4D69 = 19;
									end
									if (24 == FlatIdent_4D69) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
									if (FlatIdent_4D69 == 10) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_4D69 = 11;
									end
									if (FlatIdent_4D69 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_4D69 = 5;
									end
									if (FlatIdent_4D69 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4D69 = 6;
									end
									if (FlatIdent_4D69 == 2) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4D69 = 3;
									end
									if (1 == FlatIdent_4D69) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_4D69 = 2;
									end
									if (FlatIdent_4D69 == 23) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_4D69 = 24;
									end
									if (FlatIdent_4D69 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_4D69 = 8;
									end
									if (FlatIdent_4D69 == 21) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_4D69 = 22;
									end
									if (22 == FlatIdent_4D69) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_4D69 = 23;
									end
									if (FlatIdent_4D69 == 20) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4D69 = 21;
									end
									if (FlatIdent_4D69 == 14) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4D69 = 15;
									end
									if (FlatIdent_4D69 == 16) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_4D69 = 17;
									end
									if (FlatIdent_4D69 == 11) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_4D69 = 12;
									end
									if (FlatIdent_4D69 == 12) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_4D69 = 13;
									end
									if (FlatIdent_4D69 == 17) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_4D69 = 18;
									end
									if (FlatIdent_4D69 == 6) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_4D69 = 7;
									end
									if (FlatIdent_4D69 == 8) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_4D69 = 9;
									end
									if (0 == FlatIdent_4D69) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4D69 = 1;
									end
									if (FlatIdent_4D69 == 15) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4D69 = 16;
									end
									if (19 == FlatIdent_4D69) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_4D69 = 20;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							end
						elseif (Enum <= 252) then
							if (Enum <= 248) then
								if (Enum <= 246) then
									if (Enum > 245) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									else
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum > 247) then
									local B;
									local A;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_1944D = 0;
									local A;
									while true do
										if (FlatIdent_1944D == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											FlatIdent_1944D = 2;
										end
										if (FlatIdent_1944D == 7) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1944D = 8;
										end
										if (FlatIdent_1944D == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_1944D = 4;
										end
										if (FlatIdent_1944D == 8) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1944D = 9;
										end
										if (FlatIdent_1944D == 9) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_1944D == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_1944D = 1;
										end
										if (FlatIdent_1944D == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_1944D = 5;
										end
										if (FlatIdent_1944D == 6) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1944D = 7;
										end
										if (FlatIdent_1944D == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_1944D = 6;
										end
										if (FlatIdent_1944D == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_1944D = 3;
										end
									end
								end
							elseif (Enum <= 250) then
								if (Enum > 249) then
									local FlatIdent_6C354 = 0;
									local B;
									local A;
									while true do
										if (17 == FlatIdent_6C354) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6C354 = 18;
										end
										if (FlatIdent_6C354 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											FlatIdent_6C354 = 3;
										end
										if (FlatIdent_6C354 == 14) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6C354 = 15;
										end
										if (FlatIdent_6C354 == 16) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											FlatIdent_6C354 = 17;
										end
										if (FlatIdent_6C354 == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_6C354 = 6;
										end
										if (FlatIdent_6C354 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_6C354 = 9;
										end
										if (7 == FlatIdent_6C354) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_6C354 = 8;
										end
										if (FlatIdent_6C354 == 10) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_6C354 = 11;
										end
										if (FlatIdent_6C354 == 4) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_6C354 = 5;
										end
										if (FlatIdent_6C354 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6C354 = 7;
										end
										if (FlatIdent_6C354 == 12) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6C354 = 13;
										end
										if (FlatIdent_6C354 == 13) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_6C354 = 14;
										end
										if (FlatIdent_6C354 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6C354 = 1;
										end
										if (FlatIdent_6C354 == 1) then
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6C354 = 2;
										end
										if (FlatIdent_6C354 == 11) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6C354 = 12;
										end
										if (FlatIdent_6C354 == 18) then
											B = Stk[Inst[4]];
											if not B then
												VIP = VIP + 1;
											else
												Stk[Inst[2]] = B;
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_6C354 == 15) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_6C354 = 16;
										end
										if (FlatIdent_6C354 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6C354 = 4;
										end
										if (FlatIdent_6C354 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6C354 = 10;
										end
									end
								else
									local A = Inst[2];
									local Results = {Stk[A]()};
									local Limit = Inst[4];
									local Edx = 0;
									for Idx = A, Limit do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								end
							elseif (Enum == 251) then
								local FlatIdent_3D9E5 = 0;
								local A;
								while true do
									if (FlatIdent_3D9E5 == 1) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_3D9E5 = 2;
									end
									if (FlatIdent_3D9E5 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3D9E5 = 1;
									end
									if (5 == FlatIdent_3D9E5) then
										if not Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (2 == FlatIdent_3D9E5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_3D9E5 = 3;
									end
									if (FlatIdent_3D9E5 == 4) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3D9E5 = 5;
									end
									if (3 == FlatIdent_3D9E5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3D9E5 = 4;
									end
								end
							else
								local FlatIdent_86204 = 0;
								local B;
								local T;
								local A;
								while true do
									if (FlatIdent_86204 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_86204 = 5;
									end
									if (FlatIdent_86204 == 11) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_86204 = 12;
									end
									if (8 == FlatIdent_86204) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_86204 = 9;
									end
									if (FlatIdent_86204 == 9) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_86204 = 10;
									end
									if (FlatIdent_86204 == 12) then
										A = Inst[2];
										T = Stk[A];
										B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
										break;
									end
									if (FlatIdent_86204 == 0) then
										B = nil;
										T = nil;
										A = nil;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_86204 = 1;
									end
									if (FlatIdent_86204 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_86204 = 6;
									end
									if (FlatIdent_86204 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_86204 = 8;
									end
									if (FlatIdent_86204 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_86204 = 2;
									end
									if (FlatIdent_86204 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_86204 = 3;
									end
									if (FlatIdent_86204 == 3) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_86204 = 4;
									end
									if (FlatIdent_86204 == 10) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_86204 = 11;
									end
									if (6 == FlatIdent_86204) then
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_86204 = 7;
									end
								end
							end
						elseif (Enum <= 256) then
							if (Enum <= 254) then
								if (Enum > 253) then
									local FlatIdent_75C2E = 0;
									local A;
									while true do
										if (FlatIdent_75C2E == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_75C2E = 3;
										end
										if (FlatIdent_75C2E == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											FlatIdent_75C2E = 4;
										end
										if (FlatIdent_75C2E == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_75C2E == 0) then
											A = nil;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_75C2E = 1;
										end
										if (FlatIdent_75C2E == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_75C2E = 2;
										end
									end
								elseif (Stk[Inst[2]] ~= Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 255) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Inst[2] <= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								B = Stk[Inst[4]];
								if B then
									VIP = VIP + 1;
								else
									local FlatIdent_59D2A = 0;
									while true do
										if (FlatIdent_59D2A == 0) then
											Stk[Inst[2]] = B;
											VIP = Inst[3];
											break;
										end
									end
								end
							end
						elseif (Enum <= 258) then
							if (Enum > 257) then
								local A;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 259) then
							Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
						elseif (Enum > 260) then
							local FlatIdent_190A = 0;
							local Edx;
							local Results;
							local Limit;
							local A;
							while true do
								if (FlatIdent_190A == 4) then
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_190A = 5;
								end
								if (FlatIdent_190A == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_190A = 3;
								end
								if (FlatIdent_190A == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									FlatIdent_190A = 10;
								end
								if (FlatIdent_190A == 3) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_190A = 4;
								end
								if (FlatIdent_190A == 13) then
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Top));
									break;
								end
								if (8 == FlatIdent_190A) then
									Stk[Inst[2]] = #Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
									FlatIdent_190A = 9;
								end
								if (FlatIdent_190A == 10) then
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
									FlatIdent_190A = 11;
								end
								if (FlatIdent_190A == 0) then
									Edx = nil;
									Results, Limit = nil;
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_190A = 1;
								end
								if (FlatIdent_190A == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = #Stk[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_190A = 7;
								end
								if (FlatIdent_190A == 12) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Stk[A + 1]));
									FlatIdent_190A = 13;
								end
								if (FlatIdent_190A == 5) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_190A = 6;
								end
								if (7 == FlatIdent_190A) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] + Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_190A = 8;
								end
								if (FlatIdent_190A == 11) then
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_63758 = 0;
										while true do
											if (0 == FlatIdent_63758) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									FlatIdent_190A = 12;
								end
								if (FlatIdent_190A == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_190A = 2;
								end
							end
						else
							local B;
							local A;
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_1BCFB == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_1BCFB = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!B7052Q0003063Q00737472696E6703043Q006368617203043Q00627974652Q033Q0073756203053Q0062697433322Q033Q0062697403043Q0062786F7203053Q007461626C6503063Q00636F6E63617403063Q00696E73657274025Q006C914003053Q000D50106F3003083Q00825D3C7F1B433CB9025Q005C914003093Q00B7DB240CAFDF3E1D8F03043Q0078E3BE5C025Q0048914003053Q00F24AADAAAC03063Q00CDB438CCC7C9025Q00389140030A3Q0022BC5370C112AC6663C903053Q00A071C92116025Q002C914003083Q00D9AA4D6D4F460EE703073Q006989C622191C2F025Q0024914003053Q002D4BA9328D03053Q00E16024CD57025Q00D8904003053Q0068332Q53D703073Q0051255C3736BBDA025Q00C8904003083Q00D4BF17076B5DE4AA03063Q003C96DE64623B025Q00B89040030E3Q0040A24645EDE04EBC7F43F6EB41A403063Q008E2FD02F2284025Q00B0904003053Q00ED3E89ECF203063Q00608E52E68297025Q00A89040030B3Q0030D6E4247AFD26C5E3247803063Q009976A48D4114025Q00A4904003083Q00E03CEAFF8EFA14D903073Q007BAD5D8391DC95025Q00A09040030D3Q008AD0FC8AAAD2C588AFD7E08AB803043Q00E7CBBE95025Q009C904003083Q00C8B13AA690C1FFB303063Q00A898DD55D2C3025Q007C904003093Q00CAFDA652F7303DFBF403073Q005F9E98DE26BB51025Q0074904003083Q00FF857A00FC80721A03043Q0074AFE915025Q006C904003053Q0004D7A4108803083Q00E449B8C075E45994025Q0060904003053Q0012723F4D3103043Q0039421E50025Q0054904003063Q00EAA907E133D803083Q002BBEDB668847ABCB025Q0050904003053Q00B6553C7AB603063Q0071E6275519D3025Q004C904003083Q006DB9A25354A5B95C03043Q003220CCD6025Q00489040030A3Q00CAEACE1DFFEED411E2E103043Q00788D8FA0025Q00449040030B3Q00A383DF1D3AF4A7A98BC10803073Q00DEE7EAAC6D5695025Q0040904003063Q000AE5FCB8E75303083Q00AC58848ED1932A58025Q003C9040030D3Q00F9247DEBAFD41A7BE2A7CD276703053Q00CEB84A1486025Q002C904003063Q00499937507F8303043Q003C1AED58025Q0024904003093Q00258113BE8957DA4C1D03083Q002971E46BCAC536B8025Q0018904003053Q00E3A8B4EA7203083Q00D6AEC7D08F1E6CDA025Q00F88F40030E3Q002809AFA22A2098A50C15AEAA2A2803083Q00D36967C6CF4B4CD7025Q00D08F40030E3Q005606F02B0E7530610DEB2E0A781B03073Q007F176899466F19025Q00C08F4003053Q003AD61FAC5E03063Q00C177B97BC932025Q00888F4003053Q0093ADEA0BB203043Q006EDEC28E025Q00608F4003053Q003FF6EBC9BB03073Q004372998FACD7B0025Q00288F4003053Q00EC370732CD03043Q0057A15863025Q00F88E4003053Q0011C003C82903073Q007C5CAF67AD456E025Q00E08E4003083Q003A0DD9FCD31803C403053Q0081776CB092025Q00D88E40030D3Q0004BAE95C24B8D05E21BDF55C3603043Q003145D480025Q00D08E4003083Q003570DE3A3675D62003043Q004E651CB1025Q00988E4003063Q00E7D229FF2CE103053Q004184B45B9E025Q00908E4003043Q000A3FAC3803083Q00C37A53C34CE248D2025Q00808E40030A3Q00795F99534512AB464F5703043Q00273C32E9025Q00708E4003093Q00C5AFC04DA921A958FD03083Q003D91CAB839E540CB025Q00488E4003053Q00CE3112215F03053Q003A8843734C025Q00288E40030A3Q008BDCAEF836C52F9FDCB503073Q004AD8A9DC9E57A6025Q00108E4003083Q00E126EA0D94D82DEB03053Q00C7B14A8579026Q008E4003053Q00D4EF7481AB03053Q00C7998010E4025Q00E08D4003073Q005D7CA0597B70B803043Q00351E13CC025Q00D08D4003053Q00E5ECE3CAB903063Q005BB69C82BDD7025Q00608D4003063Q0037FA4CBE39F903043Q00DF549C3E025Q00588D4003053Q00248571587503083Q00DD47E91E3610B0AD025Q00508D4003053Q003D8714AD1E03043Q00D96DEB7B025Q00C88C4003103Q00821D45EE85A5014CDD84A51C78EE99BE03053Q00EBCA68288F025Q00A88C4003053Q003DB608F9AC03063Q00B670D96C9CC0025Q00608C402Q033Q001AC84D03053Q005B54AD39BD025Q00508C4003083Q0040C9D2B45BCBBC2403083Q005710A8B1DF3AACD9025Q00408C402Q033Q006A23BB03073Q002B3C65E3A956BC025Q00288C4003093Q00E389BA2180B5B225D303043Q0055A0E1DB025Q00108C40030D3Q00E5B895B508CAF3B186BE0F9EC503063Q00EAB6D7E0DB6C025Q00F88B4003053Q00EBB4CBBC0003053Q0063A6C1B8D5025Q00D08B4003063Q00D320A2C90CEF03063Q009DBD55CFAB69025Q00C08B4003093Q001AAE2F7FBD0635A53C03063Q007F5ACB591ACF025Q00A08B4003043Q003A4F3B5103043Q002878205F025Q00908B40030C3Q005AAFBB5359D90C3494AC575903073Q007819C0D5273CB7025Q00888B4003073Q0007E2FEA3A22QA703073Q00D44F879F2QC7D5025Q00808B4003043Q001A51F64F03083Q00844A1EA51B65C77A025Q00788B4003063Q003AFF3488DDCA03063Q00AE779A40E0B2025Q00688B402Q033Q00626A5A03073Q00A8371836A23F73025Q00608B4003063Q00EA46FF31AD5D03063Q002E8F2B9D54C9025Q00508B40030A3Q00DFB07CC42C69E1B36FDC03063Q001BBEC61DB04D025Q00488B40030D3Q0010002A520A0F2A100F0E2E5F0D03043Q0030636B43025Q00408B4003083Q0097F68621DA1A058703073Q0068E285E353B47B025Q00388B4003073Q0030C42QF84CF62703063Q009853AB968C29025Q00188B4003063Q00A1D0EC13B7F103073Q003FD2A49E7AD996026Q008B4003063Q00C781F2E18DD103053Q00E9A2EC9084025Q00F08A40030A3Q00D5CB202D1AC6E2342B1703053Q007BB4BD4159025Q00E88A40030D3Q005954184CD04E565142DC47501F03053Q00B92A3F712E025Q00E08A4003083Q00EB3581B27CA5F32303063Q00C49E46E4C012025Q00D88A4003073Q0051F2E3C972BB4603063Q00D5329D8DBD17025Q00D08A4003093Q00EEFA43D1A1C4F1C0FA03073Q009EAE9F35B4D3BD025Q00B08A4003353Q0080ECBE3CA9E7F92DA5E2F917A9EEB635ECCBAC39ECC2AC2F2QA39434BEE6B029ADA3F11789C2921E88A39B02ECCE8B1D89C28A0FE503043Q005BCC83D9025Q00A88A4003043Q00121C650C03043Q007866791D025Q00A08A4003063Q008B00E3B4E99F03053Q008CED6F8CC0025Q00988A4003063Q000AF3D9F30DF803043Q009A639DB5025Q00888A4003103Q0079D8D92CF649BBE12AB568F4DC2BC80A03053Q0095229BB545025Q00808A4003053Q00FA25C4BDF203063Q00C28C44A8C897025Q00708A4003043Q00CFA6190003083Q00C2A1C774658183BF025Q00688A4003063Q00E6135C5B89DB03083Q00CD8F7D3032E7BE64025Q00588A4003053Q00DD251E387D03053Q0018AB44724D025Q00488A4003043Q00544DB8EB03063Q004C3A2CD58EB1025Q00408A4003063Q00F8EBFD59FFE003043Q0030918591025Q00388A4003053Q003F7FCDF6F003073Q00E0491EA18395CA025Q00288A4003043Q007AD52A5303073Q00E514B44736C4EB025Q00208A4003063Q00897B3646E08503053Q008EE0155A2F025Q00F0894003053Q000C8987C51F03043Q00B07AE8EB025Q00E0894003043Q002A0935D803083Q0093446858BDBC34B5025Q00D8894003063Q00F1F42FD009EB03073Q00AD979D4ABC6D98025Q00D0894003273Q000CCB782DA315A9052DCD6027AE0EE5751ADA712BB815EC317F843401A315EC397FEE7B2FAA04ED03083Q00555FA21448CD6189025Q00C8894003053Q000426FD001503043Q006C704F89025Q00C0894003053Q0004FFE8A55203063Q00AB679084CA20025Q00508940031B3Q003108C92FE1F8C6F10D089D3EB3FFC0EA1103C922FDB9DFF31013C703083Q009F7F67E94D9399AF025Q00308940030A3Q00571BD4AD1EDC4605C8AB03063Q008A2769BDCE7B025Q0020894003093Q00646B3D19EE03F4BF6003083Q00C71419547A8B5791025Q0018894003083Q00BB74AE38BD7DB50B03043Q006EDC11C0025Q0008894003073Q00C64C132C4FA4D503063Q00DCA1297D782A026Q00894003073Q00CFA72B35A595F403063Q00E29AC9405BCA025Q00F0884003043Q00415F3E4C03053Q00EC2F3E5329025Q00E8884003053Q006BBDC3D3FB03053Q009E3BCFAAB0025Q00D88840030B3Q00134061F8FB36505CE9FA3203053Q009757291288025Q00C88840030E3Q005BBA22857BB8049E7FA6238D7BB003043Q00E81AD44B025Q00988840030A3Q002B713AADFB26E3CC037A03083Q00A56C1454C8894797025Q002Q884003093Q009EE9139F86ED098EA603043Q00EBCA8C6B025Q0070884003223Q00FC3AFC508939F54DDD69FA4DDC25FD02C726ED02CB2CB94BCD2CF756C02FF047CD6703043Q0022A94999025Q0048884003093Q008CD4E8063BB9D3F51E03053Q0077D8B19072025Q0038884003093Q00D4F91844C3E1FE055C03053Q008F809C6030025Q0028884003083Q00B52BD623038A4CAD03083Q00C3E547B95750E32B025Q0018884003053Q00010ED8367D03053Q00114C61BC53025Q00F8874003053Q009B2AC83EB903053Q00CACB46A74A025Q00D887402Q033Q00DAF02003083Q0029BFC112DF63DE36025Q00C0874003023Q0041B703073Q0047248EA85673B0025Q00A8874003023Q003CB003053Q005B598626CF025Q0090874003023Q002FE803053Q00174ADBA2E4025Q0048874003063Q00B21A149CA20603043Q00D5E45F46025Q00308740030C3Q00D264DE5BE617DF0AC453E41503063Q005E9B2A881AAA025Q00208740030B3Q00D2445FD79B6E4AC0D0585D03043Q00B2A63D2F025Q0010874003053Q00F6B1E1357103073Q00C195DE85504C3A025Q00D88640030B3Q00B3F00288A99E159EB1F00C03043Q00DCE8D051025Q0060864003083Q000D50EE2D1F50EF3C03043Q00484F319D025Q0008864003083Q0025A5BB31591DD21603073Q00BD64CBD25C3869025Q00F8854003133Q00DA25B11A5CEF22B7197EF425AC0552F727BD0503053Q003D9B4BD877025Q0070854003113Q00D1331CE7C7B03AF73308CADDA03EF7253303073Q005B83566C8BAED3025Q0060854003063Q00C1B2284A0BF503053Q006E87DD442E025Q0048854003283Q003BC8D73C4BAF79079ADB2749BC7A0ECEDD66049C7A0AD9D12643EC780ECD982957BF731FC996660A03073Q00166BBAB84824CC025Q00D88440033E3Q0019246FF8CD9591847F2373F1C198C281333E7FB6DDD4C6873A3F69B889F7D187362574FFC7D294842A3B76FFCAD4C08930253AE6DBDAC08F3C2476B8879B03083Q00E05F4B1A96A9B5B4025Q00C08440030B3Q0083663A3E01FC9C04304A1D03063Q00B2D846696A40025Q00888440032E3Q00D44CE0191E7970E2BA57A11D18706DF5BA45AF1A117139E9F403B9000A67392QF64CB4415F547BE9E857A901183B03083Q00869A23C06F7F1519025Q00788440032B3Q009820ABA983AEF6AC63B3A898B5B8BB2FA5B3CDA1F7B963A2AE8AAFB5BD22A6B288E7F9B830AFB39EE9B6E503073Q0098CB43CAC7EDC7025Q0068844003263Q008CE10EA723F05150A4EF40AF21EA5F58A4EB05E63CE0455AA2FA0FA826E34A4DA3E70EE861B703083Q0039CA8860C64F992B025Q0060844003243Q0077FB3E1849E7304C43E5380245ED77094EFD3E1849EC244C54E6770145E4381E59A7794203043Q006C208957025Q0058844003233Q0057E19C44A8BFD57BFFCC44B5B8D538FB8440BAB89C7DF99F4DFBAFD470FB8756F5E29203073Q00BC1598EC25DBCC025Q0050844003203Q00C182F17B094BF293E8790708FC85EB72035CB397F378104DE193E8721306BDC903063Q002893E7811760025Q0048844003263Q0026A916D62CB0C20EAB1D9922B4DB08B7039929BEC447AB1FCE6FB8D814B11BD72CB4C549EB5403073Q00B667C57AB94FD1025Q0040844003203Q0077EBF77DE3F257EBFA38E4F34EE9F47BE1F257EAF338F0E75DEEF86CF3A810AB03063Q00863E859D1880025Q0038844003283Q00A162D2018B73D6048A7D821E8168D408963AD0089476CB0E856ECB028A3AD108966CCB0E81348C4303043Q006DE41AA2025Q00308440031D3Q0066EEF2CF11FE4DF9E58E12E14BE3A2DE07FF49FEF1DD0BE24AE4AC804C03063Q008D249782AE62025Q00E0834003053Q001EAD03053D03043Q006858DF62025Q0078834003053Q0024585CD71203083Q008E622A3DBA776762025Q00508340030B3Q001AA197046B0FC586090A1C03053Q002A4181C450025Q00F0824003093Q0036AF9EC604DA00AF8A03063Q00BB62CAE6B248025Q00A0824003053Q00A04BF48A7903083Q00ACE63995E71C5AE1025Q0070824003893Q0076F0DEE5F4A902F25D9FEED5BEE53FF959CBE3CFA0A926E857DCEFD3BDA921F354D3AAC6AFE03ABA51D9AACFBAE133E818CFE6C1B7EC24E918DEF8C5EEF924FF4BDAE4D4EEE038BA41D0FFD2EEFA33E84EDAF88EEEDD3EFF51CDAAC1BDFA33EE4B9FE3CEBAEC24FC5DCDEF80B9E022F218CBE2C5EEF933E855D6F9D3A7E638BA5DC7FACCA1E022E91603083Q009A38BF8AA0CE8956025Q0010824003093Q00C65F2022DE5B3A33FE03043Q0056923A58025Q00F0814003083Q00856838D8DBFFEAED03083Q009FD0217BB7A9918F025Q00C8814003143Q008CB618A7342921F8AE63C2564A5081AD1AAD404B03073Q0011C8E348E21418025Q00608140030A3Q00C3EDC1BBD5FDCDBBF8E603043Q00CF9788B9025Q00388140031C3Q00399B85FD68968D025B8D91E46A8D81172F808BFA0691961F378090ED03083Q00567BC9C4B426C4C2025Q00F8804003093Q00C2A769E69A1EB7F3AE03073Q00D596C21192D67F025Q00D8804003083Q00F53FE0F44AE622F703083Q0085A076A39B388847025Q0070804003053Q0056EC031B4103053Q0024109E6276025Q0050804003063Q001610E1FBCB1B03053Q009E5265919E025Q0040804003093Q00C619DEF5A2051ECBFC03083Q00BE957AAC90C76B59025Q00F07F4003073Q0087F2D036023C0C03073Q007FC69CB95B6350025Q00C07F40030A3Q00A5DB40574E90DC46545C03053Q002FE4B5293A025Q00A07F4003103Q008BEDBF381F9EEAB93B2A85C0BA3A108F03053Q007EEA83D655025Q00907F40030C3Q00B711238348B70E97112D844003073Q0061D47D42EA25E3025Q00607F40030C3Q005D0B09F8A005C26D1707E1AB03073Q00AD2E7B688FCE51025Q00507F40030C3Q004DEBE2C84CD0E9EE4CEBE8C803043Q00AD208486025Q00407F4003043Q00F15EC5BF03083Q0081BC3FACD14F7B87025Q00107F4003053Q00AE70EC228003043Q004BED1C8D025Q00F07E4003043Q00E42BBE7803063Q0085AD4FD21D10025Q00D07E4003083Q00CA07CA49F2F91AD103053Q00A29868A53D025Q00907E4003053Q00F7A97147D603043Q0022BAC615026Q007E40030D3Q0059F1144879F32D4A7CF608486B03043Q0025189F7D025Q00D07D4003093Q0069B2EBC96B1F5FB2FF03063Q007E3DD793BD27025Q00807D4003053Q00C6C11C5D7703073Q005380B37D3012E7025Q00407D40030A3Q00DCD72Q4FF1ECC77A5CF903053Q00908FA23D29025Q00107D4003083Q00F6AF149DFCCFA41503053Q00AFA6C37BE9025Q00F07C4003053Q00DD0376734903063Q00B3906C121625025Q00A07C4003053Q0096BA58C7B503043Q00B3C6D637025Q00807C402Q033Q00D4798E03043Q0094B148BC025Q00507C4003023Q00521703063Q001F372E88AB34025Q00207C4003023Q00C07903073Q006BA54F98C9981D025Q00F07B4003023Q00CE8D03053Q0097ABBE4D65025Q00707B4003083Q006DF7327503CCC84A03073Q00AD38BE711A71A2025Q00207B4003063Q00B42E6802A43203043Q004BE26B3A025Q00507A40030A3Q00E6B6D8521634EDC6BCCE03073Q0099B2D3A0265441025Q00107A4003083Q00F3D0DA59367EC3EB03063Q0010A62Q993644025Q00A0784003073Q00F1C69FA38DCADB03053Q00CFA5A3E7D7025Q0040784003793Q00D05D31FAA4323CD0EB3208CAED6645CFEC7D13D6FA7745CBF67745D3F77C0E9FF87D179FEA7A009FEE600CC9FF66009FED7717C9FB6045C6F16745DEEC7745DCEB6017DAF06609C6BE7B0B93BE7D11D7FB6012D6ED7745CBF67745DBEB6209D6FD7311D6F17C45CFEC7D06DAED6145C8F77E099FF8730CD3B003043Q00BF9E1265025Q0080774003093Q00EF4E2QB9F74AA3A8D703043Q00CDBB2BC1025Q0030774003313Q003C31BC2552097DA9364E1A34BD21010D7DA936481A3CAD21011F38AB32441E7DB52D4F077DAD2B010F32B730480228BC6A03053Q00216C5DD944025Q0070764003093Q004DF100173826117CF803073Q0073199478637447025Q0020764003173Q003C9CBE8306572980A98A17503287CA9906482880B88E0703063Q00197DC9EACB43025Q0060754003093Q00C9E44E4C29FCE3535403053Q00659D813638025Q0020754003083Q00CF07174B5537B22603083Q00549A4E54242759D7025Q0050744003053Q000899E20B2B03043Q00664EEB83025Q00107440030C3Q005ABF42AD76BF4CB059B857AC03043Q00C418CD23025Q00F0734003093Q0034CB670DBD09EF600103053Q00D867A81568025Q00B073402Q033Q00DCECFB03063Q00D1B8889C2D21025Q005073402Q033Q000FE42403083Q001F6B8043874AA55F025Q00C072402Q033Q0020BFC903043Q00D544DBAE025Q0090724003063Q00C36F45E7B1D703053Q00DFB01B378E025Q0050724003193Q00925B7DC15034A14668F77828925C72D3703DA4417DC17035BF03063Q005AD1331CB519025Q00307240030F3Q0086DDC2613B35CE2D81DDC863113ECA03083Q0059D2B8BA15785DAF025Q00F0714003053Q00C3404F89F403043Q00E7902F3A025Q00A0714003053Q001625B94F4B03073Q00C5454ACC212F1F025Q003071402Q033Q00CBE85203053Q009B858D267A025Q0010714003083Q00C71BA7CD15FBCC5D03083Q002E977AC4A6749CA9025Q00F07040030E3Q007611D7A2B9495EEEB2B1401FD6A103053Q00D02C7EBAC0025Q00E0704003153Q00481F3243C07748033243C077481F3243C03B7B183903063Q005712765031A1025Q00D07040030F3Q0069EFEBDB015DF3B8CD5951E7F1C64403053Q0021308A98A8025Q00C07040030B3Q006B7F24E4AA552E37507C2603083Q00583C104986C5757C025Q00B0704003133Q00EFFA0A4A05A33818D6AF355515BD3402D6E10903083Q0076B98F663E70D151025Q00A0704003113Q00B14DBB15E2954DF626EA975CA306E2894D03053Q008BE72CD665025Q0090704003133Q00803CA17F8DBB27F45B88B423B17383A027BA7403053Q00E4D54ED41D025Q00807040030E3Q00D0A8B9CB81F8EAE689C685E5F1A903063Q008C85C6DAA7E8025Q002Q7040030F3Q00CF0BD2E3382CC2BB3CD8EC372CC3F403073Q00AD9B7EB9825642025Q0060704003133Q00CA25E3BBEDB7FB25F9F7D0A8EB3BFFB4EDB4FF03063Q00DA9E5796D784025Q00507040031B3Q00659EA1634185E8474383B86358CC9C615E9CB87211B8BA7A419CA903043Q001331ECC8025Q00407040030D3Q00B1F1E6C913AFC5D7FDD613B68C03063Q00C6E5838FB963025Q00307040030A3Q00B95A8DEA7BB981418AE603063Q00D6ED28E48910025Q0020704003123Q00BF3CBC237B36FD8A2DF5023A10EE8921BA2D03073Q008FEB4ED5405B62025Q0010704003173Q00BCC9D8A2AE05B2319DC1C7A3E122B3318AD49DF8F146F603083Q0043E8BBBDCCC176C6026Q00704003173Q00F5E7801BEBADC6D3E09F0FEBFEE6D4E7871AA4ED8291A503073Q00B2A195E57584DE025Q00E06F4003113Q0009022FF4DD3334042FB8E82D3C1C2FF4DD03063Q005F5D704E98BC025Q00C06F4003113Q00F31C5412C602500CC84E610CC6025412C603043Q007EA76E35025Q00A06F40030A3Q002DFA43BC3B15ED46BF3403053Q005A798822D0025Q00806F4003123Q00C1EA262157FAEA286267FCF6283142E0EA2803053Q002395984742025Q00606F40031C3Q002321880B18379C0B18279C040273AD0D1B32990D1B328D1D04279C1203043Q00687753E9025Q00406F4003193Q0019A56EBAC338AD75A6D924EA58BAD62AA572AEC538BE75A6DE03053Q00B74DCA1CC8025Q00206F4003123Q00FC564C76E06FDC56055CEA78C95A4673EB7403063Q001BA839251A85026Q006F40030D3Q006B27AC4462502AA74462502AA703053Q00363F48CE64025Q00E06E40030E3Q002ACEE0F0B2320ACEE0D7BC7A0BD303063Q00127EA1C084DD025Q00C06E4003193Q004EEFF7315C461F7BEAEC33510F2073F4EC3459441576E7EE3703073Q00741A868558302F025Q00A06E40030E3Q00E3E1B22597DCAD3CDEA8962DD4E703043Q004CB788C2025Q00806E40030A3Q00B911170DAE101F489E1D03043Q002DED787A025Q00606E4003133Q0017DD733BDEFA2AD3662C91D031C16026DFF82A03063Q009643B41449B1025Q00406E4003153Q00C9C2AAF0A0F8F4C5A4A29EF5E9CEBFEFACF8F4C5A403063Q00949DABCD82C9025Q00206E40030C3Q00442QA3FE7873EA93EB7165B803053Q001910CAC08A026Q006E40030E3Q0077425B01021C9B4A0B28340349BD03073Q00CF232B7B556B3C025Q00E06D4003113Q0015D8B4660E22D2B67D4F15D8B97C0622D203053Q006F41BDDA12025Q00C06D4003093Q0069E9488F50E3569E5803043Q00EA3D8C24025Q00A06D40030E3Q007EDF56E6D2418A4F9A25D3DF14AC03073Q00DE2ABA76B2B761025Q00806D4003123Q00D8203A127A9FEC2BED610B0F6899FC3EE22003083Q004C8C4148661BED99025Q00606D40030A3Q0037D130B28911D125A88703053Q00E863B042C6025Q00406D4003123Q001423E3A2B9BCEFE72762C6A0F58DFAE82E2503083Q008940428DC599E88E025Q00206D40030D3Q001719D23A2963692A58F82F3A2C03073Q002D4378BE4A4843026Q006D4003123Q00C48AA918BEBCE48AEA35A5B6F988A612B8B403063Q00D590EBCA77CC025Q00E06C4003103Q002F8D7A3B5BA06C371095391617837A3F03043Q00547BEC19025Q00C06C4003113Q00C8081F4FE9BC3D5E3BDCFD496C7AE0E91B03053Q00889C693F1B025Q00A06C4003123Q0094A1C0D2AEB9C89C85B8C4DEA6A5CDD5A9B803043Q00BCC7D7A9025Q00806C4003133Q001DE89817D62CF99804D86ED98613D126FD840203053Q00A14E9CEA76025Q00606C4003193Q00B33AAD4AC0E9D8923CBA47DBE29DA622BE46DEE5DA8522B34203073Q00BDE04EDF2BB78B025Q00406C40030A3Q000FEEF6C5D0A2363DF1E203073Q00585C9F83A4BCC3025Q00206C4003113Q0089F215E9EEA3A21BE8E1FAD20FEBF5B1FB03053Q0085DA827A86026Q006C4003123Q00ED9B7030293F9EA76A3C293F9EA97330212D03063Q0046BEEB1F5F42025Q00E06B4003113Q008EFB36AFC7B4F930E0EEB2E72AA2C0AFE403053Q00A9DD8B5FC0025Q00C06B4003123Q00D5EF8BA4D9E3EB9EAA91D2EA8BAFD4F2EB8303053Q00B1869FEAC3025Q00A06B4003093Q00DEAB86721CB65D26E203083Q005C8DC5E71B70D333025Q00806B4003113Q00B0FBBF87D1F6B0FBBF87D1F6B0FBBF87D103063Q00D6E390CAEBBD025Q00606B4003103Q0096F94FCAAAE24D8486F15AC5B5F14BC103043Q00A4C59028025Q00406B40030A3Q002415C853C9999D1E0EC303073Q00DA777CAF3EA8B9025Q00206B4003093Q002914391534B106150403073Q00447A7D5E785591026Q006B4003123Q0026A7FC0A3E01E2D30D381EBBBF3A371AA1F403053Q005B75C29F78025Q00E06A4003113Q0029265F0134E312AE29374B0828FF12E01303083Q008E7A47326C4D8D7B025Q00C06A4003113Q0079FFAE437C2844F1E272742F4DEBAB4C7E03063Q00412A9EC22211025Q00A06A4003103Q00F57CF3F6458740F5F959D371E8F144C803053Q002AA7149A98025Q00806A4003133Q00BF41E3468209C24D8140E9479D5DEF5A8447E503043Q0028ED298A025Q00606A40030D3Q00E4A7E9C03985DFA8E0875BA2C503063Q00D7B6C687A719025Q00406A4003123Q00160EA1442B00AC4E6425A349200AAE4E2A0603043Q0027446FC2025Q00206A4003123Q00FD2BB6E6C531B3F98C1FB2F5C03BB0FEC23703043Q0090AC5EDF026Q006A4003123Q0060BD01E01D13515DA40BB32A165541A116FC03073Q003831C864937C77025Q00E0694003143Q00BC25FD375CE5843CF4251DC29F3FFB2B59E8813103063Q0081ED5098443D025Q00C0694003083Q00D639A95B2D63EB2D03063Q0016874CC83846025Q00A0694003123Q0018B4C96C152A3F2B6892D4651A26232B26A803083Q004248C1A41C7E4351025Q00806940030B3Q000831F7BAD9FFDEA13337ED03083Q00D1585E839A898AB3025Q00606940030B3Q006B3DB800D55426BF50F24F03053Q009D3B52CC20025Q00406940030D3Q0088B70C7C88B70C7C8BB91429AA03043Q005C2QD87C025Q00206940030B3Q007D183CE60D2123FB4C052303043Q008F2D714C026Q00694003093Q00FCC4927806E7C4957803053Q0026ACADE211025Q00E06840030A3Q00C32E00165A38FC351E1603063Q007B9347707F7A025Q00C06840030C3Q00F4C45735B22FE3CBCE4638FD03073Q0095A4AD275C926E025Q00A0684003153Q004CD3D658563FDD68CED71D7121C768CED94F5E3DDD03073Q00B21CBAB83D3753025Q0080684003143Q0060823D7459843072449F3F377D8A3D745882307603043Q001730EB5E025Q0060684003113Q00F380C78288DACD8C84AC80D6C081CD8F8003063Q00B5A3E9A42QE1025Q0040684003103Q00B5CC67D1AD5E884191C035ECA112B04E03083Q0020E5A54781C47EDF025Q00206840030F3Q001E0BE9E4271AF4B60C1BE9E4271AF403043Q00964E6E9B026Q00684003163Q008E752QC800BD861DB27F9AEB06B88C1FBD78DFCB0FBA03083Q0071DE10BAA763D5E3025Q00E0674003113Q00F3034DD552772ACC4660DD447137CA084C03073Q0044A36623B2271E025Q00C0674003133Q0018DA53864F7C2BD2538B0E5D29D55C8C47712103063Q001F48BB3DE22E025Q00A06740030F3Q00F37DEC0057CB71E6065BC268EE1C5703053Q0036A31C8772025Q00806740030E3Q00C73B46CB2973B4F62E40D8257AAD03073Q00D9975A2DB9481B025Q00606740030F3Q009CC4CEC0C5A851B296E2D3CAA049B203073Q0025D3B6ADA1A9C1025Q00406740030F3Q00956DD072521FA870935C4C19BB73D203063Q007ADA1FB3133E025Q0020674003154Q000C2E2406123B1721234126211F212B121426102603063Q00674F7E4F4A61026Q00674003103Q00AEC258FC897888C811D6C052C1E244FC03063Q003CE1A63192A9025Q00E0664003133Q00D1260A0637F9ED3C492E3BF6F0201A0B27EAF003063Q00989F53696A52025Q00C06640030F3Q0084BEE2E837C35EEA99E2F364FE48BE03073Q0027CAD18D87178E025Q00A0664003113Q003A828A352E571DCDB53E3D4315838C392E03063Q003974EDE55747025Q00806640030E3Q007903311F7FCD6252143F527BDA2703073Q0042376C5E3F12B4025Q00606640030C3Q00A5D53AA68B0A70258AD431FF03083Q0066EBBA5586E67350025Q0040664003123Q0033F961C2E38859FA0BE37ED3AAA915D91DEB03083Q00B67E8015AA8AEB79025Q00206640030E3Q0079138ABBBCF0A5590486BAA4B29103073Q00E43466E7D6C5D0026Q006640030F3Q003556EEC70F590B2A42F3DA0F425F1703073Q002B782383AA6636025Q00E0654003113Q002F4FE3F61B00C0FC0C45F4B33255EAF41B03043Q009362208D025Q00C0654003173Q007DF003AB5A6BFC7342F8469D567CF0795CFC12BA566DF803083Q001A309966DF3F1F99025Q00A0654003053Q00D2E5BDAE0403063Q005E9F80D2D968025Q0080654003063Q00613BF7BA0C4303053Q00692C5A83CE025Q0060654003183Q00F8CAE5BBACF273B1C1C2F5A0E3C279B3D0DBFFAAA7F972BA03083Q00DFB5AB96CFC3961C025Q0040654003113Q0031FA18EB1DF802EB5CD805F01DE105EC1503043Q00827C9B6A025Q0020654003133Q006E1EB4A00D7F4A11B3E73272510DB5A40B7D4A03063Q0013237FDAC762026Q006540030E3Q0015331F82353753A235330186343703043Q00E3585273025Q00E06440030E3Q00A72Q1EAF9CB8161BA4D59E1617AF03053Q00BCEA7F79C6025Q00C0644003153Q00DD2A5EAFEDE42B4AFBCCFF2259FAD7F62644FBD6E203053Q00B991452D8F025Q00A0644003103Q003471300B9F0A7F2F4AA71D6C2A5FA40B03053Q00CB781E432B025Q00806440030A3Q00AF58C35569309143C50603063Q005FE337B0753D025Q00606440030E3Q001EEC9B2Q7D5322EAC80948593DF003063Q003A5283E85D29025Q00406440030D3Q00D5D819E38AD357A7EBDE1EA2AD03083Q00C899B76AC3DEB234025Q00206440030E3Q002156247E16E8145D322Q2CF6044A03063Q00986D39575E45026Q00644003183Q0066B80F95729CAC45BC05956283AE48BE12D45285AC44B60F03073Q00C32AD77CB521EC025Q00E06340030A3Q00FFB63C47E3AB260ADCAA03043Q0067B3D94F025Q00C06340030D3Q00FC8DAAB32CF1D7D18EB0E70CF003073Q00B4B0E2D9936383025Q00A0634003183Q006AC4E0A952E049C4B3C465AF6EC4E7FA6CE052D8FAFD73FC03063Q008F26AB93891C025Q00806340030C3Q000A2436FFCF292427B6EF2F3803053Q0081464B45DF025Q00606340030B3Q00CF4AA5F630BAE14CBABF0E03063Q00D583252QD67D025Q00406340030B3Q0093392EC39DF5F7AB33329003073Q0083DF565DE3D094025Q0020634003103Q0067CC07AD03BD48C80DAD0DA444C01FFE03063Q00C82BA3748D4F026Q006340030E3Q0020FDEEC85A0DE0F68D6305E6F29B03053Q00116C929DE8025Q00E06240030C3Q005485DD03855D3F52719EC15003083Q003118EAAE23CF325D025Q00C0624003103Q0032BF154830E70AA316070CFB17A4091B03063Q00887ED0666878025Q00A0624003113Q00DDEC236387E3EC332CA0F8EF3C2AB0FEF003053Q00C491835043025Q0080624003113Q00CA0B32796F0877E40D2F385F0E75E8053203073Q001A866441592C67025Q0060624003103Q0001B4FD7A0EB3E73921BEFA3F24A9EF2903043Q005A4DDB8E025Q0040624003083Q0039F9E35929541AE503063Q0026759690796B025Q00206240030E3Q00A1FF96AF1F82FD87E63384E48AFC03053Q005DED90E58F026Q00624003063Q007F0467336C0403053Q005A336B1413025Q00C0614003103Q00EF32E21CFD3A8318EC11EC23D03EE11B03063Q0056A35B8D7298025Q00A06140030E3Q00298C0201D84A4D10851506C1435A03073Q003F65E97074B42F025Q0080614003173Q0023AEBD53C9E9FDC406BBAF00BFDBEDC51ABDA01AEBE9FF03083Q00B16FCFCE739F888C025Q0060614003103Q000EDED6E6D39E167D23D3C0B4EE98166203083Q001142BFA5C687EC77025Q0040614003073Q00A4A0FA824781B203053Q0014E8C189A2025Q00206140030E3Q0056BD2134A5346B9E79B43B7A872603083Q00EB1ADC5214E6551B026Q006140031A3Q00D2A2894155FDA0C83767FFB7DC655AF1E3FA7640EBB1C77E40FF03053Q00349EC3A917025Q00E0604003183Q00993EA710558301B47FCD27578B0DF513EE28408510BC31E803073Q0062D55F874634E0025Q00C0604003133Q00FBD9070BD6DB487FF4D74A3DDED6462CDED74903043Q005FB7B827025Q00A0604003163Q00D42E7E1BC0551041F52A7E0BDA48004DF62E2D21DA4B03083Q0024984F5E48B52562025Q0080604003103Q0095B2E72C98FCFFB2AAE7389AF2FEBDB603073Q0090D9D3C77FE893025Q002Q604003153Q002C88A98D058AFBBB14C9CAB10D8BE0B0019AE0B10E03043Q00DE60E989025Q0040604003143Q00CC0262DAFECCF51162CAF0C9E20A2CE8ECCDEF0D03063Q00A4806342899F025Q0020604003183Q009DB34E06F6C8ABB4A0052CE59A83BEBF0C24F9DBB3B8BD0003073Q00C0D1D26E4D97BA026Q00604003153Q00D53E58C3EB3E16E0FC7F3BEBF43D11EAF82C11EBF703043Q0084995F78025Q00C05F4003113Q00F6DEE3A2CBCED6AD84C79AF8B186DDDEDA03053Q00B3BABFC3E7025Q00805F40030C3Q0094DC3621A7577934B9DE7E2Q03083Q0046D8BD1662D23418025Q00405F40030B3Q0095CF901C4EAACF901D40B603053Q002FD9AEB05F026Q005F4003103Q0006FE3ECA1DD7C21DED2CD348EC832AE503073Q00E24D8C4BBA68BC025Q00C05E40030D3Q00C328BD5A62BDD5F8C328B94E6603083Q00D8884DC92F12DCA1025Q00805E4003143Q0059EDD0A003566B67A8C5AD0F035467FBD0B6195603073Q00191288A4C36B23025Q00405E4003103Q00054A2CDE5403F72F597EFE4403F73B5903073Q009C4E2B5EB53171026Q005E40030C3Q0088A7DDC13835CD98A2AEDAD803083Q00CBC3C6AFAA5D47ED025Q00C05D4003113Q00223318002E02FF48161542443EFC00290803073Q009D685C7A20646D025Q00805D40030A3Q00FC742AA8E89EA51ADA7403083Q0076B61549C387ECCC025Q00405D4003103Q008A4206E5AF0336FEA15500E0B44C16EF03043Q008EC02365026Q005D40030F3Q0072C454F14C73DD59C65CBA6932F45303073Q009738A5379A2353025Q00C05C40030D3Q00C6B2EA8645D0E0B4B8A14DD6E303063Q00B98EDD98E322025Q00805C4003113Q0095E225A2CB59AEF4648EC84EAEE229A7C903063Q003CDD8744C6A7025Q00405C4003093Q00C2A85223DB74B3EB0103063Q005485DD3750AF026Q005C4003113Q00ABCD13CBAA599ED756FDB15785CC17D5BD03063Q0030ECB876B9D8025Q00C05B4003103Q00DB45FC5C436FEF44BD78567EE944EE5C03063Q001A9C379D3533025Q00805B4003183Q00098C024F25D621C327473DDF3C8E154A26D42A91194A25D503063Q00BA4EE3702649025Q00405B4003123Q000EA3223125A03F781AB9322F26A3363D3BA303043Q005849CC50026Q005B4003133Q001BD1CC0137339DE5012028C9CC172735D1CF1C03053Q00555CBDA373025Q00C05A40030F3Q0079C8B927C95F818823C35BD2BF34CA03053Q00AF3EA1CB46025Q00805A40030E3Q000B78F04C256DEB2Q1878E757387603043Q00384C1984025Q00405A4003113Q000D29B557773E21AF4C360431A04D7F242703053Q00164A48C123026Q005A4003143Q00CDB436E24D3EAAB42AE70012EBB131ED442AE4B203063Q005F8AD5448320025Q00C0594003103Q006D5986E5594C8DF00A7E87ED5E5D9AE303043Q00822A38E8025Q0080594003133Q009388DE293DA32FB185DC277C9927A185D1223D03073Q0055D4E9B04E5CCD025Q00405940030E3Q00A245F15D8543F11AB45EEC5B905803043Q003AE4379E026Q005940030A3Q0037B4A4A1763D18A8A7AF03063Q007371C6CDCE56025Q00C05840030C3Q00DC5EEBFB78BA6FE3F172F64303053Q00179A2C829C025Q00805840030B3Q008B385242BDA8244758B3A203053Q00D6CD4A332C025Q0040584003103Q009C9478F450C225FAAA78B373CF64968703073Q0044DAE619933FAE026Q005840030A3Q000A5C49AACAAD2E39425D03073Q00424C303CD8A3CB025Q00C0574003113Q0065B0B3EA1E43BCE7D70241A4A6EF1552A703053Q007020C8C783025Q00805740030E3Q00D83E111B0723E96628131D34F82903063Q00409D46657269025Q0040574003113Q00631BFD255D155243CB2D5F1A4311E0225203063Q00762663894C33026Q00574003083Q0086A5EBCDC3077F7603083Q0018C3D382A1A66310025Q00C0564003103Q00CED6A1F3CBF8D6BEA1FDE2C2BFEEDCEA03053Q00AE8BA5D181025Q00805640030C3Q00091AE9076C3AE3072305E70403043Q006C4C6986025Q00405640030E3Q00C8F208F5F9D9F9F14DD5EADEEAF103063Q00B78D9E6D9398026Q005640030B3Q008BDECD8E8BDECD8E8BDECD03043Q00AECFABA1025Q00C05540030B3Q008D1DD9C13BBC0F9E852AAE03053Q005FC968BEE1025Q0080554003113Q002DBF3C7406A37D5008A3337605A1327D0003043Q001369CD5D025Q0040554003103Q007EA7A3855FBAE2AB54B8AD8958A1B68603043Q00E73DD5C2026Q00554003143Q002888B64A4BA4AB5605C7874B1989E4770A8FB15603043Q00246BE7C4025Q00C05440030D3Q002B560A501B500756487408520903043Q003F683969025Q0080544003123Q0016827850D4AEBACC3ACD5E53D7A9B5D6218203083Q00B855ED1B3FB2CFD4025Q0040544003103Q0087E844A3F70FE4E143B7A431B1E55EBC03063Q0060C4802DD384026Q00544003143Q00DA1CCFF19CA0FE2FF01ACFBCAEA0FE34F71DC8F503083Q00559974A69CECC190025Q00C05340030D3Q000E3CACD07AA6D9C60E3CACD07F03083Q00E64D54C5BC16CFB7025Q0080534003133Q0086820CC66C77AB830BC73942A4890AC07078AC03063Q0016C5EA65AE19025Q00405340031C3Q000FD9CF19FEC4F94F25C3CF14F381CF432FD8C516F7D5E8433ED8C81B03083Q002A4CB1A67A92A18D026Q00534003183Q00945FCC1E2DBBA352CC0F20FE955EC614222QB243C01433BF03063Q00DED737A57D41025Q00C0524003123Q0056B95E4C9656A35A48C474B25A4ED777A35A03053Q00B615D13B2A025Q0080524003093Q00394A22A0374CE6061303083Q006E7A2243C35F2985025Q0040524003153Q0027EAA8D63D5B16ECADCD381A32E6A7CA3E490DE1AD03063Q003A648FC4A351026Q00524003103Q001F44CAB5F671027C73D5A6EE68022F4A03073Q006D5C25BCD49A1D025Q00C0514003123Q00FDA5495E4BC841D0AD1B6E56DD41D0AD554503073Q0028BEC43B2C24BC025Q0080514003063Q001ED5A8D1784103083Q00325DB4DABD172E47025Q0040514003133Q00A88527BAE38E71878B759DE78769998139B7E103073Q001DEBE455DB8EEB026Q00514003133Q0053CE2Q99AA1573C68786FF357CC09E87B6187F03063Q007610AF2QE9DF025Q00C0504003143Q00D2EB3CA630F2E925B82AB1CB3FA524E2F925B82A03053Q0045918A4CD6025Q00805040030D3Q00F9884F0B18ECD4861F2F03EFC303063Q008DBAE93F626C025Q0040504003093Q00D5F76908C6E8F7F57603063Q00BC2Q961961E6026Q00504003103Q00E539BA22B642EE31A939A90DD239B43903063Q0062A658D956D9025Q00804F4003133Q00E875C63F5D310BC260CA777F2615C47ACC235D03073Q0079AB14A5573243026Q004F4003113Q00E5D880DF3DE3D2D6C3ED2FFEC7D58ACA2103063Q008AA6B9E3BE4E025Q00804E40030F3Q00E63A333606D02061060ECA2B28300003053Q006FA44F4144026Q004E4003123Q00766114345B4677145508370E726A4D61143C03073Q0018341466532E34025Q00804D4003123Q00C52FF972E636E47EEE7AC77FEB33E77FEB3303043Q0010875A8B026Q004D40031A3Q0031B98A5E1AB8891C31AD88581AB8891C27BE875707A3945507A303043Q003C73CCE6025Q00804C40030D3Q0016A52BE974B426A612A526E13B03043Q008654D043026Q004C40030F3Q00A0C3B499AD8BC2F6A88CB59196C5AE03063Q00E4E2B1C1EDD9025Q00804B40031E3Q00214DD1F2437DD1E90A1FE1F2004AD0BB2756C0EE101FE1F40E5DCAF8164C03043Q009B633FA3026Q004B4003123Q00592EAD00B4C831917E34FF70B0CF78B56E3103083Q00C51B5CDF20D1BB11025Q00804A40030F3Q00EA481C6D3BCABDC3F85B1A2C09D1A203083Q00E3A83A6E4D79B8CF026Q004A4003133Q002295A343098BAB5E09C78055128EAF520989AB03043Q003060E7C2025Q0080494003183Q0026574523C7164A506AEE0B410406DC074E5D6AEB084A472103053Q00A96425244A026Q004940030F3Q00C7D6063625E499293E24E4D509313303053Q004685B96853025Q0080484003113Q006A7EB9FCCA4573BDF0CC0856A1EDCC467803053Q00A52811D49E026Q00484003143Q001BA9B82B8B2BB3C92BA9F50A9836B4CF3DAFB92603083Q00A059C6D549EA59D7025Q0080474003133Q000D1D5F4CF6950F261C5B0EC388193B1B5C47FE03073Q006B4F72322E97E7026Q00474003103Q001B7C7855C72D7C3960DB2B726D48DA3603053Q00AE59131921025Q0080464003173Q00FA4A1576A9AECA54097DA5A298690367A4BBCD55097DA203063Q00CBB8266013CB026Q004640030E3Q008140801FB707AC40845C9B00A25803063Q006FC32CE17CDC025Q0080454003123Q006D5C67072Q417148685C61185F5C600D5D5003043Q00682F3514026Q004540030D3Q00FF23FA56B9DC66D446B9C821F703053Q00D5BD469623025Q0080444003103Q00D7BF041F7EECFAFE281475EAFCAA1E1403063Q009895DE6A7B17026Q004440030F3Q00A47C2313D1D8DDC65C3518D4C5C68903073Q00B2E61D4D77B8AC025Q0080434003103Q008CEEB3BDA0E6A9B3EECDBCB2AAE6A9B303043Q00DCCE8FDD026Q00434003133Q00DD705AB738D7E8FE3170B93ACEF4F67F5DA23703073Q009C9F1134D656BE025Q0080424003113Q002F30387F183E2F30387F182Q3E303D681F03063Q001E6D51551D6D026Q00424003103Q0074AE311C1AEDFA168C2E1100F7FA58A603073Q009336CF5C7E7383025Q0080414003103Q00755908D2524A0DD0581828D15B5708D103043Q00BE373864026Q00414003143Q00C9C2ECD544F9CAEED801C8C2F0C954E8C0E9D74003053Q00218BA380B9025Q00802Q40030C3Q002FBB7FE70A8601BF79E8078303063Q00E26ECD10846B026Q002Q40030F3Q000500A3E230F4DE2A1FECC624F6D12B03073Q00B74476CC815190026Q003F4003143Q007A168208240B18A55240AC0531061DA44B09830203083Q00CB3B60ED6B456F71026Q003E4003083Q001758E6117DCF235D03063Q00AE5629937013026Q003D4003073Q00A526B2CED65ABD03073Q00D2E448C6A1B833026Q003C40030C3Q00FEE9BED9FFD6A78CD9F1DAEB03053Q0093BF87CEB8026Q003B4003074Q004D5517E4552C03073Q004341213064973C026Q003A4003123Q00F382DD3195A05ADBC5D022C79955DE8CD22A03073Q0034B2E5BC43E7C9026Q00394003113Q008AC7464F4D0A1758A8C852066146344EA003083Q002DCBA32B26232A5B026Q00384003023Q006FFF03073Q006E59C82C78A082026Q00374003073Q00410C63ED87B6F303073Q00C270745295B6CE026Q00364003073Q00F71C44961A1E3B03083Q003E857935E37F6D4F026Q002A4003093Q00B2425E46B5DB79974703073Q003EE22E2Q3FD0A9026Q00244003093Q008F7AF0FE9EA874E1F003053Q00EDD8158295026Q00204003073Q00208E59012C029103053Q004970E23878026Q00184003113Q00C52C263F8375F268F22D05278564F27BF203083Q001C97495653EA1693026Q001040030B3Q006B5817D644E7B0554500C303073Q00C2232C63A6178203073Q0067657467656E76030E3Q0055736572576562682Q6F6B55524C03793Q00682Q7470733A2Q2F646973636F72642E636F6D2F6170692F776562682Q6F6B732F3134313637333133303738373831322Q352Q382F423646717635544A446C39384C61437A6D4A456B71526D4862675439584D48416953353Q3139505F744E647853464A5272575A2Q4C4941627333514D736E7A665A504603113Q005573657250696E675468726573686F6C64024Q0084D7874103043Q0067616D65030A3Q0047657453657276696365030B3Q004C6F63616C506C61796572030C3Q0057616974466F724368696C642Q033Q0073796E03093Q00776562736F636B657403073Q00636F2Q6E65637403093Q00576562536F636B657403073Q007265717565737403043Q00682Q7470030C3Q00682Q74705F7265717565737403063Q00666C7578757303023Q005F47030F3Q004C6972696CC3AC204C6172696CC3A003053Q007063612Q6C03043Q007461736B03053Q00737061776E03083Q00496E7374616E63652Q033Q006E657703043Q004E616D65030C3Q0052657365744F6E537061776E03063Q00506172656E7403043Q0053697A6503053Q005544696D32028Q00025Q00407A4003083Q00506F736974696F6E026Q00E03F025Q00406AC0026Q005EC003103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q003440030C3Q00426F72646572436F6C6F7233030F3Q00426F7264657253697A65506978656C026Q00F03F03063Q0041637469766503093Q004472612Q6761626C65030C3Q00436F726E657252616469757303043Q005544696D026Q0034C0030B3Q00416E63686F72506F696E7403073Q00566563746F723203163Q004261636B67726F756E645472616E73706172656E637903043Q00466F6E7403043Q00456E756D030A3Q00476F7468616D426F6C6403043Q0054657874030A3Q0054657874436F6C6F723303083Q005465787453697A6503063Q00476F7468616D026Q002C40026Q0044C0026Q002840030B3Q00546578745772612Q706564030F3Q00506C616365686F6C6465725465787403213Q00682Q7470733A2Q2F726F626C6F782E636F6D2F73686172653F636F64653D3Q2E026Q003040034Q0003103Q00436C656172546578744F6E466F637573026Q003EC0026Q00324003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E65637400C2103Q00CA7Q00122Q000100013Q00202Q00010001000200122Q000200013Q00202Q00020002000300122Q000300013Q00202Q00030003000400122Q000400053Q00062Q0004000B000100010004B33Q000B000100126C000400063Q00200100050004000700126C000600083Q00200100060006000900126C000700083Q00200100070007000A0006EB00083Q000100062Q00353Q00074Q00353Q00014Q00353Q00054Q00353Q00024Q00353Q00034Q00353Q00064Q0030000900083Q00122Q000A000C3Q00122Q000B000D6Q0009000B000200104Q000B00094Q000900083Q00122Q000A000F3Q00122Q000B00106Q0009000B000200104Q000E00094Q000900083Q00122Q000A00123Q00122Q000B00136Q0009000B000200104Q001100094Q000900083Q00122Q000A00153Q00122Q000B00166Q0009000B000200104Q001400094Q000900083Q00122Q000A00183Q00122Q000B00196Q0009000B000200104Q001700094Q000900083Q00122Q000A001B3Q00122Q000B001C6Q0009000B000200104Q001A00094Q000900083Q00122Q000A001E3Q00122Q000B001F6Q0009000B000200104Q001D00094Q000900083Q00122Q000A00213Q00122Q000B00226Q0009000B000200104Q002000094Q000900083Q00122Q000A00243Q00122Q000B00256Q0009000B000200104Q002300094Q000900083Q00122Q000A00273Q00122Q000B00286Q0009000B000200104Q002600094Q000900083Q00122Q000A002A3Q00122Q000B002B6Q0009000B000200104Q002900094Q000900083Q00122Q000A002D3Q00122Q000B002E6Q0009000B000200104Q002C00094Q000900083Q00122Q000A00303Q00122Q000B00316Q0009000B000200104Q002F00094Q000900083Q00122Q000A00333Q00122Q000B00346Q0009000B000200104Q003200094Q000900083Q00122Q000A00363Q00122Q000B00376Q0009000B000200104Q003500094Q000900083Q00122Q000A00393Q00122Q000B003A6Q0009000B000200104Q003800092Q0030000900083Q00122Q000A003C3Q00122Q000B003D6Q0009000B000200104Q003B00094Q000900083Q00122Q000A003F3Q00122Q000B00406Q0009000B000200104Q003E00094Q000900083Q00122Q000A00423Q00122Q000B00436Q0009000B000200104Q004100094Q000900083Q00122Q000A00453Q00122Q000B00466Q0009000B000200104Q004400094Q000900083Q00122Q000A00483Q00122Q000B00496Q0009000B000200104Q004700094Q000900083Q00122Q000A004B3Q00122Q000B004C6Q0009000B000200104Q004A00094Q000900083Q00122Q000A004E3Q00122Q000B004F6Q0009000B000200104Q004D00094Q000900083Q00122Q000A00513Q00122Q000B00526Q0009000B000200104Q005000094Q000900083Q00122Q000A00543Q00122Q000B00556Q0009000B000200104Q005300094Q000900083Q00122Q000A00573Q00122Q000B00586Q0009000B000200104Q005600094Q000900083Q00122Q000A005A3Q00122Q000B005B6Q0009000B000200104Q005900094Q000900083Q00122Q000A005D3Q00122Q000B005E6Q0009000B000200104Q005C00094Q000900083Q00122Q000A00603Q00122Q000B00616Q0009000B000200104Q005F00094Q000900083Q00122Q000A00633Q00122Q000B00646Q0009000B000200104Q006200094Q000900083Q00122Q000A00663Q00122Q000B00676Q0009000B000200104Q006500094Q000900083Q00122Q000A00693Q00122Q000B006A6Q0009000B000200104Q006800092Q0030000900083Q00122Q000A006C3Q00122Q000B006D6Q0009000B000200104Q006B00094Q000900083Q00122Q000A006F3Q00122Q000B00706Q0009000B000200104Q006E00094Q000900083Q00122Q000A00723Q00122Q000B00736Q0009000B000200104Q007100094Q000900083Q00122Q000A00753Q00122Q000B00766Q0009000B000200104Q007400094Q000900083Q00122Q000A00783Q00122Q000B00796Q0009000B000200104Q007700094Q000900083Q00122Q000A007B3Q00122Q000B007C6Q0009000B000200104Q007A00094Q000900083Q00122Q000A007E3Q00122Q000B007F6Q0009000B000200104Q007D00094Q000900083Q00122Q000A00813Q00122Q000B00826Q0009000B000200104Q008000094Q000900083Q00122Q000A00843Q00122Q000B00856Q0009000B000200104Q008300094Q000900083Q00122Q000A00873Q00122Q000B00886Q0009000B000200104Q008600094Q000900083Q00122Q000A008A3Q00122Q000B008B6Q0009000B000200104Q008900094Q000900083Q00122Q000A008D3Q00122Q000B008E6Q0009000B000200104Q008C00094Q000900083Q00122Q000A00903Q00122Q000B00916Q0009000B000200104Q008F00094Q000900083Q00122Q000A00933Q00122Q000B00946Q0009000B000200104Q009200094Q000900083Q00122Q000A00963Q00122Q000B00976Q0009000B000200104Q009500094Q000900083Q00122Q000A00993Q00122Q000B009A6Q0009000B000200104Q009800092Q0030000900083Q00122Q000A009C3Q00122Q000B009D6Q0009000B000200104Q009B00094Q000900083Q00122Q000A009F3Q00122Q000B00A06Q0009000B000200104Q009E00094Q000900083Q00122Q000A00A23Q00122Q000B00A36Q0009000B000200104Q00A100094Q000900083Q00122Q000A00A53Q00122Q000B00A66Q0009000B000200104Q00A400094Q000900083Q00122Q000A00A83Q00122Q000B00A96Q0009000B000200104Q00A700094Q000900083Q00122Q000A00AB3Q00122Q000B00AC6Q0009000B000200104Q00AA00094Q000900083Q00122Q000A00AE3Q00122Q000B00AF6Q0009000B000200104Q00AD00094Q000900083Q00122Q000A00B13Q00122Q000B00B26Q0009000B000200104Q00B000094Q000900083Q00122Q000A00B43Q00122Q000B00B56Q0009000B000200104Q00B300094Q000900083Q00122Q000A00B73Q00122Q000B00B86Q0009000B000200104Q00B600094Q000900083Q00122Q000A00BA3Q00122Q000B00BB6Q0009000B000200104Q00B900094Q000900083Q00122Q000A00BD3Q00122Q000B00BE6Q0009000B000200104Q00BC00094Q000900083Q00122Q000A00C03Q00122Q000B00C16Q0009000B000200104Q00BF00094Q000900083Q00122Q000A00C33Q00122Q000B00C46Q0009000B000200104Q00C200094Q000900083Q00122Q000A00C63Q00122Q000B00C76Q0009000B000200104Q00C500094Q000900083Q00122Q000A00C93Q00122Q000B00CA6Q0009000B000200104Q00C800092Q0030000900083Q00122Q000A00CC3Q00122Q000B00CD6Q0009000B000200104Q00CB00094Q000900083Q00122Q000A00CF3Q00122Q000B00D06Q0009000B000200104Q00CE00094Q000900083Q00122Q000A00D23Q00122Q000B00D36Q0009000B000200104Q00D100094Q000900083Q00122Q000A00D53Q00122Q000B00D66Q0009000B000200104Q00D400094Q000900083Q00122Q000A00D83Q00122Q000B00D96Q0009000B000200104Q00D700094Q000900083Q00122Q000A00DB3Q00122Q000B00DC6Q0009000B000200104Q00DA00094Q000900083Q00122Q000A00DE3Q00122Q000B00DF6Q0009000B000200104Q00DD00094Q000900083Q00122Q000A00E13Q00122Q000B00E26Q0009000B000200104Q00E000094Q000900083Q00122Q000A00E43Q00122Q000B00E56Q0009000B000200104Q00E300094Q000900083Q00122Q000A00E73Q00122Q000B00E86Q0009000B000200104Q00E600094Q000900083Q00122Q000A00EA3Q00122Q000B00EB6Q0009000B000200104Q00E900094Q000900083Q00122Q000A00ED3Q00122Q000B00EE6Q0009000B000200104Q00EC00094Q000900083Q00122Q000A00F03Q00122Q000B00F16Q0009000B000200104Q00EF00094Q000900083Q00122Q000A00F33Q00122Q000B00F46Q0009000B000200104Q00F200094Q000900083Q00122Q000A00F63Q00122Q000B00F76Q0009000B000200104Q00F500094Q000900083Q00122Q000A00F93Q00122Q000B00FA6Q0009000B000200104Q00F800092Q0037000900083Q00122Q000A00FC3Q00122Q000B00FD6Q0009000B000200104Q00FB00092Q008A000900083Q00122Q000A00FF3Q00122Q000B2Q00015Q0009000B000200104Q00FE000900122Q0009002Q015Q000A00083Q00122Q000B0002012Q00122Q000C0003015Q000A000C00026Q0009000A00122Q00090004015Q000A00083Q00122Q000B0005012Q00122Q000C0006015Q000A000C00026Q0009000A00122Q00090007015Q000A00083Q00122Q000B0008012Q00122Q000C0009015Q000A000C00026Q0009000A00122Q0009000A015Q000A00083Q00122Q000B000B012Q00122Q000C000C015Q000A000C00026Q0009000A00122Q0009000D015Q000A00083Q00122Q000B000E012Q00122Q000C000F015Q000A000C00026Q0009000A00122Q00090010015Q000A00083Q00122Q000B0011012Q00122Q000C0012015Q000A000C00026Q0009000A00122Q00090013015Q000A00083Q00122Q000B0014012Q00122Q000C0015015Q000A000C00026Q0009000A00122Q00090016015Q000A00083Q00122Q000B0017012Q00122Q000C0018015Q000A000C00026Q0009000A00122Q00090019015Q000A00083Q00122Q000B001A012Q00122Q000C001B015Q000A000C00026Q0009000A00122Q0009001C015Q000A00083Q00122Q000B001D012Q00122Q000C001E015Q000A000C00026Q0009000A00122Q0009001F015Q000A00083Q00122Q000B0020012Q00122Q000C0021015Q000A000C00026Q0009000A00122Q00090022015Q000A00083Q00122Q000B0023012Q00122Q000C0024015Q000A000C00026Q0009000A00122Q00090025015Q000A00083Q00122Q000B0026012Q001275000C0027013Q0062000A000C00026Q0009000A00122Q00090028015Q000A00083Q00122Q000B0029012Q00122Q000C002A015Q000A000C00026Q0009000A00122Q0009002B015Q000A00083Q00122Q000B002C012Q00122Q000C002D015Q000A000C00026Q0009000A00122Q0009002E015Q000A00083Q00122Q000B002F012Q00122Q000C0030015Q000A000C00026Q0009000A00122Q00090031015Q000A00083Q00122Q000B0032012Q00122Q000C0033015Q000A000C00026Q0009000A00122Q00090034015Q000A00083Q00122Q000B0035012Q00122Q000C0036015Q000A000C00026Q0009000A00122Q00090037015Q000A00083Q00122Q000B0038012Q00122Q000C0039015Q000A000C00026Q0009000A00122Q0009003A015Q000A00083Q00122Q000B003B012Q00122Q000C003C015Q000A000C00026Q0009000A00122Q0009003D015Q000A00083Q00122Q000B003E012Q00122Q000C003F015Q000A000C00026Q0009000A00122Q00090040015Q000A00083Q00122Q000B0041012Q00122Q000C0042015Q000A000C00026Q0009000A00122Q00090043015Q000A00083Q00122Q000B0044012Q00122Q000C0045015Q000A000C00026Q0009000A00122Q00090046015Q000A00083Q00122Q000B0047012Q00122Q000C0048015Q000A000C00026Q0009000A00122Q00090049015Q000A00083Q00122Q000B004A012Q00122Q000C004B015Q000A000C00026Q0009000A00122Q0009004C015Q000A00083Q00122Q000B004D012Q00122Q000C004E015Q000A000C00026Q0009000A0012750009004F013Q0045000A00083Q00122Q000B0050012Q00122Q000C0051015Q000A000C00026Q0009000A00122Q00090052015Q000A00083Q00122Q000B0053012Q00122Q000C0054015Q000A000C00026Q0009000A00122Q00090055015Q000A00083Q00122Q000B0056012Q00122Q000C0057015Q000A000C00026Q0009000A00122Q00090058015Q000A00083Q00122Q000B0059012Q00122Q000C005A015Q000A000C00026Q0009000A00122Q0009005B015Q000A00083Q00122Q000B005C012Q00122Q000C005D015Q000A000C00026Q0009000A00122Q0009005E015Q000A00083Q00122Q000B005F012Q00122Q000C0060015Q000A000C00026Q0009000A00122Q00090061015Q000A00083Q00122Q000B0062012Q00122Q000C0063015Q000A000C00026Q0009000A00122Q00090064015Q000A00083Q00122Q000B0065012Q00122Q000C0066015Q000A000C00026Q0009000A00122Q00090067015Q000A00083Q00122Q000B0068012Q00122Q000C0069015Q000A000C00026Q0009000A00122Q0009006A015Q000A00083Q00122Q000B006B012Q00122Q000C006C015Q000A000C00026Q0009000A00122Q0009006D015Q000A00083Q00122Q000B006E012Q00122Q000C006F015Q000A000C00026Q0009000A00122Q00090070015Q000A00083Q00122Q000B0071012Q00122Q000C0072015Q000A000C00026Q0009000A00122Q00090073015Q000A00083Q00122Q000B0074012Q00122Q000C0075015Q000A000C00026Q0009000A00122Q00090076015Q000A00083Q00122Q000B0077012Q001275000C0078013Q0062000A000C00026Q0009000A00122Q00090079015Q000A00083Q00122Q000B007A012Q00122Q000C007B015Q000A000C00026Q0009000A00122Q0009007C015Q000A00083Q00122Q000B007D012Q00122Q000C007E015Q000A000C00026Q0009000A00122Q0009007F015Q000A00083Q00122Q000B0080012Q00122Q000C0081015Q000A000C00026Q0009000A00122Q00090082015Q000A00083Q00122Q000B0083012Q00122Q000C0084015Q000A000C00026Q0009000A00122Q00090085015Q000A00083Q00122Q000B0086012Q00122Q000C0087015Q000A000C00026Q0009000A00122Q00090088015Q000A00083Q00122Q000B0089012Q00122Q000C008A015Q000A000C00026Q0009000A00122Q0009008B015Q000A00083Q00122Q000B008C012Q00122Q000C008D015Q000A000C00026Q0009000A00122Q0009008E015Q000A00083Q00122Q000B008F012Q00122Q000C0090015Q000A000C00026Q0009000A00122Q00090091015Q000A00083Q00122Q000B0092012Q00122Q000C0093015Q000A000C00026Q0009000A00122Q00090094015Q000A00083Q00122Q000B0095012Q00122Q000C0096015Q000A000C00026Q0009000A00122Q00090097015Q000A00083Q00122Q000B0098012Q00122Q000C0099015Q000A000C00026Q0009000A00122Q0009009A015Q000A00083Q00122Q000B009B012Q00122Q000C009C015Q000A000C00026Q0009000A00122Q0009009D015Q000A00083Q00122Q000B009E012Q00122Q000C009F015Q000A000C00026Q0009000A001275000900A0013Q0045000A00083Q00122Q000B00A1012Q00122Q000C00A2015Q000A000C00026Q0009000A00122Q000900A3015Q000A00083Q00122Q000B00A4012Q00122Q000C00A5015Q000A000C00026Q0009000A00122Q000900A6015Q000A00083Q00122Q000B00A7012Q00122Q000C00A8015Q000A000C00026Q0009000A00122Q000900A9015Q000A00083Q00122Q000B00AA012Q00122Q000C00AB015Q000A000C00026Q0009000A00122Q000900AC015Q000A00083Q00122Q000B00AD012Q00122Q000C00AE015Q000A000C00026Q0009000A00122Q000900AF015Q000A00083Q00122Q000B00B0012Q00122Q000C00B1015Q000A000C00026Q0009000A00122Q000900B2015Q000A00083Q00122Q000B00B3012Q00122Q000C00B4015Q000A000C00026Q0009000A00122Q000900B5015Q000A00083Q00122Q000B00B6012Q00122Q000C00B7015Q000A000C00026Q0009000A00122Q000900B8015Q000A00083Q00122Q000B00B9012Q00122Q000C00BA015Q000A000C00026Q0009000A00122Q000900BB015Q000A00083Q00122Q000B00BC012Q00122Q000C00BD015Q000A000C00026Q0009000A00122Q000900BE015Q000A00083Q00122Q000B00BF012Q00122Q000C00C0015Q000A000C00026Q0009000A00122Q000900C1015Q000A00083Q00122Q000B00C2012Q00122Q000C00C3015Q000A000C00026Q0009000A00122Q000900C4015Q000A00083Q00122Q000B00C5012Q00122Q000C00C6015Q000A000C00026Q0009000A00122Q000900C7015Q000A00083Q00122Q000B00C8012Q001275000C00C9013Q0062000A000C00026Q0009000A00122Q000900CA015Q000A00083Q00122Q000B00CB012Q00122Q000C00CC015Q000A000C00026Q0009000A00122Q000900CD015Q000A00083Q00122Q000B00CE012Q00122Q000C00CF015Q000A000C00026Q0009000A00122Q000900D0015Q000A00083Q00122Q000B00D1012Q00122Q000C00D2015Q000A000C00026Q0009000A00122Q000900D3015Q000A00083Q00122Q000B00D4012Q00122Q000C00D5015Q000A000C00026Q0009000A00122Q000900D6015Q000A00083Q00122Q000B00D7012Q00122Q000C00D8015Q000A000C00026Q0009000A00122Q000900D9015Q000A00083Q00122Q000B00DA012Q00122Q000C00DB015Q000A000C00026Q0009000A00122Q000900DC015Q000A00083Q00122Q000B00DD012Q00122Q000C00DE015Q000A000C00026Q0009000A00122Q000900DF015Q000A00083Q00122Q000B00E0012Q00122Q000C00E1015Q000A000C00026Q0009000A00122Q000900E2015Q000A00083Q00122Q000B00E3012Q00122Q000C00E4015Q000A000C00026Q0009000A00122Q000900E5015Q000A00083Q00122Q000B00E6012Q00122Q000C00E7015Q000A000C00026Q0009000A00122Q000900E8015Q000A00083Q00122Q000B00E9012Q00122Q000C00EA015Q000A000C00026Q0009000A00122Q000900EB015Q000A00083Q00122Q000B00EC012Q00122Q000C00ED015Q000A000C00026Q0009000A00122Q000900EE015Q000A00083Q00122Q000B00EF012Q00122Q000C00F0015Q000A000C00026Q0009000A001275000900F1013Q0045000A00083Q00122Q000B00F2012Q00122Q000C00F3015Q000A000C00026Q0009000A00122Q000900F4015Q000A00083Q00122Q000B00F5012Q00122Q000C00F6015Q000A000C00026Q0009000A00122Q000900F7015Q000A00083Q00122Q000B00F8012Q00122Q000C00F9015Q000A000C00026Q0009000A00122Q000900FA015Q000A00083Q00122Q000B00FB012Q00122Q000C00FC015Q000A000C00026Q0009000A00122Q000900FD015Q000A00083Q00122Q000B00FE012Q00122Q000C00FF015Q000A000C00026Q0009000A00122Q00092Q00025Q000A00083Q00122Q000B0001022Q00122Q000C002Q025Q000A000C00026Q0009000A00122Q00090003025Q000A00083Q00122Q000B0004022Q00122Q000C0005025Q000A000C00026Q0009000A00122Q00090006025Q000A00083Q00122Q000B0007022Q00122Q000C0008025Q000A000C00026Q0009000A00122Q00090009025Q000A00083Q00122Q000B000A022Q00122Q000C000B025Q000A000C00026Q0009000A00122Q0009000C025Q000A00083Q00122Q000B000D022Q00122Q000C000E025Q000A000C00026Q0009000A00122Q0009000F025Q000A00083Q00122Q000B0010022Q00122Q000C0011025Q000A000C00026Q0009000A00122Q00090012025Q000A00083Q00122Q000B0013022Q00122Q000C0014025Q000A000C00026Q0009000A00122Q00090015025Q000A00083Q00122Q000B0016022Q00122Q000C0017025Q000A000C00026Q0009000A00122Q00090018025Q000A00083Q00122Q000B0019022Q001275000C001A023Q0062000A000C00026Q0009000A00122Q0009001B025Q000A00083Q00122Q000B001C022Q00122Q000C001D025Q000A000C00026Q0009000A00122Q0009001E025Q000A00083Q00122Q000B001F022Q00122Q000C0020025Q000A000C00026Q0009000A00122Q00090021025Q000A00083Q00122Q000B0022022Q00122Q000C0023025Q000A000C00026Q0009000A00122Q00090024025Q000A00083Q00122Q000B0025022Q00122Q000C0026025Q000A000C00026Q0009000A00122Q00090027025Q000A00083Q00122Q000B0028022Q00122Q000C0029025Q000A000C00026Q0009000A00122Q0009002A025Q000A00083Q00122Q000B002B022Q00122Q000C002C025Q000A000C00026Q0009000A00122Q0009002D025Q000A00083Q00122Q000B002E022Q00122Q000C002F025Q000A000C00026Q0009000A00122Q00090030025Q000A00083Q00122Q000B0031022Q00122Q000C0032025Q000A000C00026Q0009000A00122Q00090033025Q000A00083Q00122Q000B0034022Q00122Q000C0035025Q000A000C00026Q0009000A00122Q00090036025Q000A00083Q00122Q000B0037022Q00122Q000C0038025Q000A000C00026Q0009000A00122Q00090039025Q000A00083Q00122Q000B003A022Q00122Q000C003B025Q000A000C00026Q0009000A00122Q0009003C025Q000A00083Q00122Q000B003D022Q00122Q000C003E025Q000A000C00026Q0009000A00122Q0009003F025Q000A00083Q00122Q000B0040022Q00122Q000C0041025Q000A000C00026Q0009000A00127500090042023Q0045000A00083Q00122Q000B0043022Q00122Q000C0044025Q000A000C00026Q0009000A00122Q00090045025Q000A00083Q00122Q000B0046022Q00122Q000C0047025Q000A000C00026Q0009000A00122Q00090048025Q000A00083Q00122Q000B0049022Q00122Q000C004A025Q000A000C00026Q0009000A00122Q0009004B025Q000A00083Q00122Q000B004C022Q00122Q000C004D025Q000A000C00026Q0009000A00122Q0009004E025Q000A00083Q00122Q000B004F022Q00122Q000C0050025Q000A000C00026Q0009000A00122Q00090051025Q000A00083Q00122Q000B0052022Q00122Q000C0053025Q000A000C00026Q0009000A00122Q00090054025Q000A00083Q00122Q000B0055022Q00122Q000C0056025Q000A000C00026Q0009000A00122Q00090057025Q000A00083Q00122Q000B0058022Q00122Q000C0059025Q000A000C00026Q0009000A00122Q0009005A025Q000A00083Q00122Q000B005B022Q00122Q000C005C025Q000A000C00026Q0009000A00122Q0009005D025Q000A00083Q00122Q000B005E022Q00122Q000C005F025Q000A000C00026Q0009000A00122Q00090060025Q000A00083Q00122Q000B0061022Q00122Q000C0062025Q000A000C00026Q0009000A00122Q00090063025Q000A00083Q00122Q000B0064022Q00122Q000C0065025Q000A000C00026Q0009000A00122Q00090066025Q000A00083Q00122Q000B0067022Q00122Q000C0068025Q000A000C00026Q0009000A00122Q00090069025Q000A00083Q00122Q000B006A022Q001275000C006B023Q0062000A000C00026Q0009000A00122Q0009006C025Q000A00083Q00122Q000B006D022Q00122Q000C006E025Q000A000C00026Q0009000A00122Q0009006F025Q000A00083Q00122Q000B0070022Q00122Q000C0071025Q000A000C00026Q0009000A00122Q00090072025Q000A00083Q00122Q000B0073022Q00122Q000C0074025Q000A000C00026Q0009000A00122Q00090075025Q000A00083Q00122Q000B0076022Q00122Q000C0077025Q000A000C00026Q0009000A00122Q00090078025Q000A00083Q00122Q000B0079022Q00122Q000C007A025Q000A000C00026Q0009000A00122Q0009007B025Q000A00083Q00122Q000B007C022Q00122Q000C007D025Q000A000C00026Q0009000A00122Q0009007E025Q000A00083Q00122Q000B007F022Q00122Q000C0080025Q000A000C00026Q0009000A00122Q00090081025Q000A00083Q00122Q000B0082022Q00122Q000C0083025Q000A000C00026Q0009000A00122Q00090084025Q000A00083Q00122Q000B0085022Q00122Q000C0086025Q000A000C00026Q0009000A00122Q00090087025Q000A00083Q00122Q000B0088022Q00122Q000C0089025Q000A000C00026Q0009000A00122Q0009008A025Q000A00083Q00122Q000B008B022Q00122Q000C008C025Q000A000C00026Q0009000A00122Q0009008D025Q000A00083Q00122Q000B008E022Q00122Q000C008F025Q000A000C00026Q0009000A00122Q00090090025Q000A00083Q00122Q000B0091022Q00122Q000C0092025Q000A000C00026Q0009000A00127500090093023Q0045000A00083Q00122Q000B0094022Q00122Q000C0095025Q000A000C00026Q0009000A00122Q00090096025Q000A00083Q00122Q000B0097022Q00122Q000C0098025Q000A000C00026Q0009000A00122Q00090099025Q000A00083Q00122Q000B009A022Q00122Q000C009B025Q000A000C00026Q0009000A00122Q0009009C025Q000A00083Q00122Q000B009D022Q00122Q000C009E025Q000A000C00026Q0009000A00122Q0009009F025Q000A00083Q00122Q000B00A0022Q00122Q000C00A1025Q000A000C00026Q0009000A00122Q000900A2025Q000A00083Q00122Q000B00A3022Q00122Q000C00A4025Q000A000C00026Q0009000A00122Q000900A5025Q000A00083Q00122Q000B00A6022Q00122Q000C00A7025Q000A000C00026Q0009000A00122Q000900A8025Q000A00083Q00122Q000B00A9022Q00122Q000C00AA025Q000A000C00026Q0009000A00122Q000900AB025Q000A00083Q00122Q000B00AC022Q00122Q000C00AD025Q000A000C00026Q0009000A00122Q000900AE025Q000A00083Q00122Q000B00AF022Q00122Q000C00B0025Q000A000C00026Q0009000A00122Q000900B1025Q000A00083Q00122Q000B00B2022Q00122Q000C00B3025Q000A000C00026Q0009000A00122Q000900B4025Q000A00083Q00122Q000B00B5022Q00122Q000C00B6025Q000A000C00026Q0009000A00122Q000900B7025Q000A00083Q00122Q000B00B8022Q00122Q000C00B9025Q000A000C00026Q0009000A00122Q000900BA025Q000A00083Q00122Q000B00BB022Q001275000C00BC023Q0062000A000C00026Q0009000A00122Q000900BD025Q000A00083Q00122Q000B00BE022Q00122Q000C00BF025Q000A000C00026Q0009000A00122Q000900C0025Q000A00083Q00122Q000B00C1022Q00122Q000C00C2025Q000A000C00026Q0009000A00122Q000900C3025Q000A00083Q00122Q000B00C4022Q00122Q000C00C5025Q000A000C00026Q0009000A00122Q000900C6025Q000A00083Q00122Q000B00C7022Q00122Q000C00C8025Q000A000C00026Q0009000A00122Q000900C9025Q000A00083Q00122Q000B00CA022Q00122Q000C00CB025Q000A000C00026Q0009000A00122Q000900CC025Q000A00083Q00122Q000B00CD022Q00122Q000C00CE025Q000A000C00026Q0009000A00122Q000900CF025Q000A00083Q00122Q000B00D0022Q00122Q000C00D1025Q000A000C00026Q0009000A00122Q000900D2025Q000A00083Q00122Q000B00D3022Q00122Q000C00D4025Q000A000C00026Q0009000A00122Q000900D5025Q000A00083Q00122Q000B00D6022Q00122Q000C00D7025Q000A000C00026Q0009000A00122Q000900D8025Q000A00083Q00122Q000B00D9022Q00122Q000C00DA025Q000A000C00026Q0009000A00122Q000900DB025Q000A00083Q00122Q000B00DC022Q00122Q000C00DD025Q000A000C00026Q0009000A00122Q000900DE025Q000A00083Q00122Q000B00DF022Q00122Q000C00E0025Q000A000C00026Q0009000A00122Q000900E1025Q000A00083Q00122Q000B00E2022Q00122Q000C00E3025Q000A000C00026Q0009000A001275000900E4023Q0045000A00083Q00122Q000B00E5022Q00122Q000C00E6025Q000A000C00026Q0009000A00122Q000900E7025Q000A00083Q00122Q000B00E8022Q00122Q000C00E9025Q000A000C00026Q0009000A00122Q000900EA025Q000A00083Q00122Q000B00EB022Q00122Q000C00EC025Q000A000C00026Q0009000A00122Q000900ED025Q000A00083Q00122Q000B00EE022Q00122Q000C00EF025Q000A000C00026Q0009000A00122Q000900F0025Q000A00083Q00122Q000B00F1022Q00122Q000C00F2025Q000A000C00026Q0009000A00122Q000900F3025Q000A00083Q00122Q000B00F4022Q00122Q000C00F5025Q000A000C00026Q0009000A00122Q000900F6025Q000A00083Q00122Q000B00F7022Q00122Q000C00F8025Q000A000C00026Q0009000A00122Q000900F9025Q000A00083Q00122Q000B00FA022Q00122Q000C00FB025Q000A000C00026Q0009000A00122Q000900FC025Q000A00083Q00122Q000B00FD022Q00122Q000C00FE025Q000A000C00026Q0009000A00122Q000900FF025Q000A00083Q00122Q000B2Q00032Q00122Q000C0001035Q000A000C00026Q0009000A00122Q00090002035Q000A00083Q00122Q000B002Q032Q00122Q000C0004035Q000A000C00026Q0009000A00122Q00090005035Q000A00083Q00122Q000B0006032Q00122Q000C0007035Q000A000C00026Q0009000A00122Q00090008035Q000A00083Q00122Q000B0009032Q00122Q000C000A035Q000A000C00026Q0009000A00122Q0009000B035Q000A00083Q00122Q000B000C032Q001275000C000D033Q0062000A000C00026Q0009000A00122Q0009000E035Q000A00083Q00122Q000B000F032Q00122Q000C0010035Q000A000C00026Q0009000A00122Q00090011035Q000A00083Q00122Q000B0012032Q00122Q000C0013035Q000A000C00026Q0009000A00122Q00090014035Q000A00083Q00122Q000B0015032Q00122Q000C0016035Q000A000C00026Q0009000A00122Q00090017035Q000A00083Q00122Q000B0018032Q00122Q000C0019035Q000A000C00026Q0009000A00122Q0009001A035Q000A00083Q00122Q000B001B032Q00122Q000C001C035Q000A000C00026Q0009000A00122Q0009001D035Q000A00083Q00122Q000B001E032Q00122Q000C001F035Q000A000C00026Q0009000A00122Q00090020035Q000A00083Q00122Q000B0021032Q00122Q000C0022035Q000A000C00026Q0009000A00122Q00090023035Q000A00083Q00122Q000B0024032Q00122Q000C0025035Q000A000C00026Q0009000A00122Q00090026035Q000A00083Q00122Q000B0027032Q00122Q000C0028035Q000A000C00026Q0009000A00122Q00090029035Q000A00083Q00122Q000B002A032Q00122Q000C002B035Q000A000C00026Q0009000A00122Q0009002C035Q000A00083Q00122Q000B002D032Q00122Q000C002E035Q000A000C00026Q0009000A00122Q0009002F035Q000A00083Q00122Q000B0030032Q00122Q000C0031035Q000A000C00026Q0009000A00122Q00090032035Q000A00083Q00122Q000B0033032Q00122Q000C0034035Q000A000C00026Q0009000A00127500090035033Q0045000A00083Q00122Q000B0036032Q00122Q000C0037035Q000A000C00026Q0009000A00122Q00090038035Q000A00083Q00122Q000B0039032Q00122Q000C003A035Q000A000C00026Q0009000A00122Q0009003B035Q000A00083Q00122Q000B003C032Q00122Q000C003D035Q000A000C00026Q0009000A00122Q0009003E035Q000A00083Q00122Q000B003F032Q00122Q000C0040035Q000A000C00026Q0009000A00122Q00090041035Q000A00083Q00122Q000B0042032Q00122Q000C0043035Q000A000C00026Q0009000A00122Q00090044035Q000A00083Q00122Q000B0045032Q00122Q000C0046035Q000A000C00026Q0009000A00122Q00090047035Q000A00083Q00122Q000B0048032Q00122Q000C0049035Q000A000C00026Q0009000A00122Q0009004A035Q000A00083Q00122Q000B004B032Q00122Q000C004C035Q000A000C00026Q0009000A00122Q0009004D035Q000A00083Q00122Q000B004E032Q00122Q000C004F035Q000A000C00026Q0009000A00122Q00090050035Q000A00083Q00122Q000B0051032Q00122Q000C0052035Q000A000C00026Q0009000A00122Q00090053035Q000A00083Q00122Q000B0054032Q00122Q000C0055035Q000A000C00026Q0009000A00122Q00090056035Q000A00083Q00122Q000B0057032Q00122Q000C0058035Q000A000C00026Q0009000A00122Q00090059035Q000A00083Q00122Q000B005A032Q00122Q000C005B035Q000A000C00026Q0009000A00122Q0009005C035Q000A00083Q00122Q000B005D032Q001275000C005E033Q0062000A000C00026Q0009000A00122Q0009005F035Q000A00083Q00122Q000B0060032Q00122Q000C0061035Q000A000C00026Q0009000A00122Q00090062035Q000A00083Q00122Q000B0063032Q00122Q000C0064035Q000A000C00026Q0009000A00122Q00090065035Q000A00083Q00122Q000B0066032Q00122Q000C0067035Q000A000C00026Q0009000A00122Q00090068035Q000A00083Q00122Q000B0069032Q00122Q000C006A035Q000A000C00026Q0009000A00122Q0009006B035Q000A00083Q00122Q000B006C032Q00122Q000C006D035Q000A000C00026Q0009000A00122Q0009006E035Q000A00083Q00122Q000B006F032Q00122Q000C0070035Q000A000C00026Q0009000A00122Q00090071035Q000A00083Q00122Q000B0072032Q00122Q000C0073035Q000A000C00026Q0009000A00122Q00090074035Q000A00083Q00122Q000B0075032Q00122Q000C0076035Q000A000C00026Q0009000A00122Q00090077035Q000A00083Q00122Q000B0078032Q00122Q000C0079035Q000A000C00026Q0009000A00122Q0009007A035Q000A00083Q00122Q000B007B032Q00122Q000C007C035Q000A000C00026Q0009000A00122Q0009007D035Q000A00083Q00122Q000B007E032Q00122Q000C007F035Q000A000C00026Q0009000A00122Q00090080035Q000A00083Q00122Q000B0081032Q00122Q000C0082035Q000A000C00026Q0009000A00122Q00090083035Q000A00083Q00122Q000B0084032Q00122Q000C0085035Q000A000C00026Q0009000A00127500090086033Q0045000A00083Q00122Q000B0087032Q00122Q000C0088035Q000A000C00026Q0009000A00122Q00090089035Q000A00083Q00122Q000B008A032Q00122Q000C008B035Q000A000C00026Q0009000A00122Q0009008C035Q000A00083Q00122Q000B008D032Q00122Q000C008E035Q000A000C00026Q0009000A00122Q0009008F035Q000A00083Q00122Q000B0090032Q00122Q000C0091035Q000A000C00026Q0009000A00122Q00090092035Q000A00083Q00122Q000B0093032Q00122Q000C0094035Q000A000C00026Q0009000A00122Q00090095035Q000A00083Q00122Q000B0096032Q00122Q000C0097035Q000A000C00026Q0009000A00122Q00090098035Q000A00083Q00122Q000B0099032Q00122Q000C009A035Q000A000C00026Q0009000A00122Q0009009B035Q000A00083Q00122Q000B009C032Q00122Q000C009D035Q000A000C00026Q0009000A00122Q0009009E035Q000A00083Q00122Q000B009F032Q00122Q000C00A0035Q000A000C00026Q0009000A00122Q000900A1035Q000A00083Q00122Q000B00A2032Q00122Q000C00A3035Q000A000C00026Q0009000A00122Q000900A4035Q000A00083Q00122Q000B00A5032Q00122Q000C00A6035Q000A000C00026Q0009000A00122Q000900A7035Q000A00083Q00122Q000B00A8032Q00122Q000C00A9035Q000A000C00026Q0009000A00122Q000900AA035Q000A00083Q00122Q000B00AB032Q00122Q000C00AC035Q000A000C00026Q0009000A00122Q000900AD035Q000A00083Q00122Q000B00AE032Q001275000C00AF033Q0062000A000C00026Q0009000A00122Q000900B0035Q000A00083Q00122Q000B00B1032Q00122Q000C00B2035Q000A000C00026Q0009000A00122Q000900B3035Q000A00083Q00122Q000B00B4032Q00122Q000C00B5035Q000A000C00026Q0009000A00122Q000900B6035Q000A00083Q00122Q000B00B7032Q00122Q000C00B8035Q000A000C00026Q0009000A00122Q000900B9035Q000A00083Q00122Q000B00BA032Q00122Q000C00BB035Q000A000C00026Q0009000A00122Q000900BC035Q000A00083Q00122Q000B00BD032Q00122Q000C00BE035Q000A000C00026Q0009000A00122Q000900BF035Q000A00083Q00122Q000B00C0032Q00122Q000C00C1035Q000A000C00026Q0009000A00122Q000900C2035Q000A00083Q00122Q000B00C3032Q00122Q000C00C4035Q000A000C00026Q0009000A00122Q000900C5035Q000A00083Q00122Q000B00C6032Q00122Q000C00C7035Q000A000C00026Q0009000A00122Q000900C8035Q000A00083Q00122Q000B00C9032Q00122Q000C00CA035Q000A000C00026Q0009000A00122Q000900CB035Q000A00083Q00122Q000B00CC032Q00122Q000C00CD035Q000A000C00026Q0009000A00122Q000900CE035Q000A00083Q00122Q000B00CF032Q00122Q000C00D0035Q000A000C00026Q0009000A00122Q000900D1035Q000A00083Q00122Q000B00D2032Q00122Q000C00D3035Q000A000C00026Q0009000A00122Q000900D4035Q000A00083Q00122Q000B00D5032Q00122Q000C00D6035Q000A000C00026Q0009000A001275000900D7033Q0045000A00083Q00122Q000B00D8032Q00122Q000C00D9035Q000A000C00026Q0009000A00122Q000900DA035Q000A00083Q00122Q000B00DB032Q00122Q000C00DC035Q000A000C00026Q0009000A00122Q000900DD035Q000A00083Q00122Q000B00DE032Q00122Q000C00DF035Q000A000C00026Q0009000A00122Q000900E0035Q000A00083Q00122Q000B00E1032Q00122Q000C00E2035Q000A000C00026Q0009000A00122Q000900E3035Q000A00083Q00122Q000B00E4032Q00122Q000C00E5035Q000A000C00026Q0009000A00122Q000900E6035Q000A00083Q00122Q000B00E7032Q00122Q000C00E8035Q000A000C00026Q0009000A00122Q000900E9035Q000A00083Q00122Q000B00EA032Q00122Q000C00EB035Q000A000C00026Q0009000A00122Q000900EC035Q000A00083Q00122Q000B00ED032Q00122Q000C00EE035Q000A000C00026Q0009000A00122Q000900EF035Q000A00083Q00122Q000B00F0032Q00122Q000C00F1035Q000A000C00026Q0009000A00122Q000900F2035Q000A00083Q00122Q000B00F3032Q00122Q000C00F4035Q000A000C00026Q0009000A00122Q000900F5035Q000A00083Q00122Q000B00F6032Q00122Q000C00F7035Q000A000C00026Q0009000A00122Q000900F8035Q000A00083Q00122Q000B00F9032Q00122Q000C00FA035Q000A000C00026Q0009000A00122Q000900FB035Q000A00083Q00122Q000B00FC032Q00122Q000C00FD035Q000A000C00026Q0009000A00122Q000900FE035Q000A00083Q00122Q000B00FF032Q001275000C2Q00043Q0062000A000C00026Q0009000A00122Q00090001045Q000A00083Q00122Q000B0002042Q00122Q000C0003045Q000A000C00026Q0009000A00122Q0009002Q045Q000A00083Q00122Q000B0005042Q00122Q000C0006045Q000A000C00026Q0009000A00122Q00090007045Q000A00083Q00122Q000B0008042Q00122Q000C0009045Q000A000C00026Q0009000A00122Q0009000A045Q000A00083Q00122Q000B000B042Q00122Q000C000C045Q000A000C00026Q0009000A00122Q0009000D045Q000A00083Q00122Q000B000E042Q00122Q000C000F045Q000A000C00026Q0009000A00122Q00090010045Q000A00083Q00122Q000B0011042Q00122Q000C0012045Q000A000C00026Q0009000A00122Q00090013045Q000A00083Q00122Q000B0014042Q00122Q000C0015045Q000A000C00026Q0009000A00122Q00090016045Q000A00083Q00122Q000B0017042Q00122Q000C0018045Q000A000C00026Q0009000A00122Q00090019045Q000A00083Q00122Q000B001A042Q00122Q000C001B045Q000A000C00026Q0009000A00122Q0009001C045Q000A00083Q00122Q000B001D042Q00122Q000C001E045Q000A000C00026Q0009000A00122Q0009001F045Q000A00083Q00122Q000B0020042Q00122Q000C0021045Q000A000C00026Q0009000A00122Q00090022045Q000A00083Q00122Q000B0023042Q00122Q000C0024045Q000A000C00026Q0009000A00122Q00090025045Q000A00083Q00122Q000B0026042Q00122Q000C0027045Q000A000C00026Q0009000A00127500090028043Q0045000A00083Q00122Q000B0029042Q00122Q000C002A045Q000A000C00026Q0009000A00122Q0009002B045Q000A00083Q00122Q000B002C042Q00122Q000C002D045Q000A000C00026Q0009000A00122Q0009002E045Q000A00083Q00122Q000B002F042Q00122Q000C0030045Q000A000C00026Q0009000A00122Q00090031045Q000A00083Q00122Q000B0032042Q00122Q000C0033045Q000A000C00026Q0009000A00122Q00090034045Q000A00083Q00122Q000B0035042Q00122Q000C0036045Q000A000C00026Q0009000A00122Q00090037045Q000A00083Q00122Q000B0038042Q00122Q000C0039045Q000A000C00026Q0009000A00122Q0009003A045Q000A00083Q00122Q000B003B042Q00122Q000C003C045Q000A000C00026Q0009000A00122Q0009003D045Q000A00083Q00122Q000B003E042Q00122Q000C003F045Q000A000C00026Q0009000A00122Q00090040045Q000A00083Q00122Q000B0041042Q00122Q000C0042045Q000A000C00026Q0009000A00122Q00090043045Q000A00083Q00122Q000B0044042Q00122Q000C0045045Q000A000C00026Q0009000A00122Q00090046045Q000A00083Q00122Q000B0047042Q00122Q000C0048045Q000A000C00026Q0009000A00122Q00090049045Q000A00083Q00122Q000B004A042Q00122Q000C004B045Q000A000C00026Q0009000A00122Q0009004C045Q000A00083Q00122Q000B004D042Q00122Q000C004E045Q000A000C00026Q0009000A00122Q0009004F045Q000A00083Q00122Q000B0050042Q001275000C0051043Q0062000A000C00026Q0009000A00122Q00090052045Q000A00083Q00122Q000B0053042Q00122Q000C0054045Q000A000C00026Q0009000A00122Q00090055045Q000A00083Q00122Q000B0056042Q00122Q000C0057045Q000A000C00026Q0009000A00122Q00090058045Q000A00083Q00122Q000B0059042Q00122Q000C005A045Q000A000C00026Q0009000A00122Q0009005B045Q000A00083Q00122Q000B005C042Q00122Q000C005D045Q000A000C00026Q0009000A00122Q0009005E045Q000A00083Q00122Q000B005F042Q00122Q000C0060045Q000A000C00026Q0009000A00122Q00090061045Q000A00083Q00122Q000B0062042Q00122Q000C0063045Q000A000C00026Q0009000A00122Q00090064045Q000A00083Q00122Q000B0065042Q00122Q000C0066045Q000A000C00026Q0009000A00122Q00090067045Q000A00083Q00122Q000B0068042Q00122Q000C0069045Q000A000C00026Q0009000A00122Q0009006A045Q000A00083Q00122Q000B006B042Q00122Q000C006C045Q000A000C00026Q0009000A00122Q0009006D045Q000A00083Q00122Q000B006E042Q00122Q000C006F045Q000A000C00026Q0009000A00122Q00090070045Q000A00083Q00122Q000B0071042Q00122Q000C0072045Q000A000C00026Q0009000A00122Q00090073045Q000A00083Q00122Q000B0074042Q00122Q000C0075045Q000A000C00026Q0009000A00122Q00090076045Q000A00083Q00122Q000B0077042Q00122Q000C0078045Q000A000C00026Q0009000A00127500090079043Q0045000A00083Q00122Q000B007A042Q00122Q000C007B045Q000A000C00026Q0009000A00122Q0009007C045Q000A00083Q00122Q000B007D042Q00122Q000C007E045Q000A000C00026Q0009000A00122Q0009007F045Q000A00083Q00122Q000B0080042Q00122Q000C0081045Q000A000C00026Q0009000A00122Q00090082045Q000A00083Q00122Q000B0083042Q00122Q000C0084045Q000A000C00026Q0009000A00122Q00090085045Q000A00083Q00122Q000B0086042Q00122Q000C0087045Q000A000C00026Q0009000A00122Q00090088045Q000A00083Q00122Q000B0089042Q00122Q000C008A045Q000A000C00026Q0009000A00122Q0009008B045Q000A00083Q00122Q000B008C042Q00122Q000C008D045Q000A000C00026Q0009000A00122Q0009008E045Q000A00083Q00122Q000B008F042Q00122Q000C0090045Q000A000C00026Q0009000A00122Q00090091045Q000A00083Q00122Q000B0092042Q00122Q000C0093045Q000A000C00026Q0009000A00122Q00090094045Q000A00083Q00122Q000B0095042Q00122Q000C0096045Q000A000C00026Q0009000A00122Q00090097045Q000A00083Q00122Q000B0098042Q00122Q000C0099045Q000A000C00026Q0009000A00122Q0009009A045Q000A00083Q00122Q000B009B042Q00122Q000C009C045Q000A000C00026Q0009000A00122Q0009009D045Q000A00083Q00122Q000B009E042Q00122Q000C009F045Q000A000C00026Q0009000A00122Q000900A0045Q000A00083Q00122Q000B00A1042Q001275000C00A2043Q0062000A000C00026Q0009000A00122Q000900A3045Q000A00083Q00122Q000B00A4042Q00122Q000C00A5045Q000A000C00026Q0009000A00122Q000900A6045Q000A00083Q00122Q000B00A7042Q00122Q000C00A8045Q000A000C00026Q0009000A00122Q000900A9045Q000A00083Q00122Q000B00AA042Q00122Q000C00AB045Q000A000C00026Q0009000A00122Q000900AC045Q000A00083Q00122Q000B00AD042Q00122Q000C00AE045Q000A000C00026Q0009000A00122Q000900AF045Q000A00083Q00122Q000B00B0042Q00122Q000C00B1045Q000A000C00026Q0009000A00122Q000900B2045Q000A00083Q00122Q000B00B3042Q00122Q000C00B4045Q000A000C00026Q0009000A00122Q000900B5045Q000A00083Q00122Q000B00B6042Q00122Q000C00B7045Q000A000C00026Q0009000A00122Q000900B8045Q000A00083Q00122Q000B00B9042Q00122Q000C00BA045Q000A000C00026Q0009000A00122Q000900BB045Q000A00083Q00122Q000B00BC042Q00122Q000C00BD045Q000A000C00026Q0009000A00122Q000900BE045Q000A00083Q00122Q000B00BF042Q00122Q000C00C0045Q000A000C00026Q0009000A00122Q000900C1045Q000A00083Q00122Q000B00C2042Q00122Q000C00C3045Q000A000C00026Q0009000A00122Q000900C4045Q000A00083Q00122Q000B00C5042Q00122Q000C00C6045Q000A000C00026Q0009000A00122Q000900C7045Q000A00083Q00122Q000B00C8042Q00122Q000C00C9045Q000A000C00026Q0009000A001275000900CA043Q0045000A00083Q00122Q000B00CB042Q00122Q000C00CC045Q000A000C00026Q0009000A00122Q000900CD045Q000A00083Q00122Q000B00CE042Q00122Q000C00CF045Q000A000C00026Q0009000A00122Q000900D0045Q000A00083Q00122Q000B00D1042Q00122Q000C00D2045Q000A000C00026Q0009000A00122Q000900D3045Q000A00083Q00122Q000B00D4042Q00122Q000C00D5045Q000A000C00026Q0009000A00122Q000900D6045Q000A00083Q00122Q000B00D7042Q00122Q000C00D8045Q000A000C00026Q0009000A00122Q000900D9045Q000A00083Q00122Q000B00DA042Q00122Q000C00DB045Q000A000C00026Q0009000A00122Q000900DC045Q000A00083Q00122Q000B00DD042Q00122Q000C00DE045Q000A000C00026Q0009000A00122Q000900DF045Q000A00083Q00122Q000B00E0042Q00122Q000C00E1045Q000A000C00026Q0009000A00122Q000900E2045Q000A00083Q00122Q000B00E3042Q00122Q000C00E4045Q000A000C00026Q0009000A00122Q000900E5045Q000A00083Q00122Q000B00E6042Q00122Q000C00E7045Q000A000C00026Q0009000A00122Q000900E8045Q000A00083Q00122Q000B00E9042Q00122Q000C00EA045Q000A000C00026Q0009000A00122Q000900EB045Q000A00083Q00122Q000B00EC042Q00122Q000C00ED045Q000A000C00026Q0009000A00122Q000900EE045Q000A00083Q00122Q000B00EF042Q00122Q000C00F0045Q000A000C00026Q0009000A00122Q000900F1045Q000A00083Q00122Q000B00F2042Q001275000C00F3043Q0062000A000C00026Q0009000A00122Q000900F4045Q000A00083Q00122Q000B00F5042Q00122Q000C00F6045Q000A000C00026Q0009000A00122Q000900F7045Q000A00083Q00122Q000B00F8042Q00122Q000C00F9045Q000A000C00026Q0009000A00122Q000900FA045Q000A00083Q00122Q000B00FB042Q00122Q000C00FC045Q000A000C00026Q0009000A00122Q000900FD045Q000A00083Q00122Q000B00FE042Q00122Q000C00FF045Q000A000C00026Q0009000A00122Q00092Q00055Q000A00083Q00122Q000B0001052Q00122Q000C0002055Q000A000C00026Q0009000A00122Q00090003055Q000A00083Q00122Q000B0004052Q00122Q000C002Q055Q000A000C00026Q0009000A00122Q00090006055Q000A00083Q00122Q000B0007052Q00122Q000C0008055Q000A000C00026Q0009000A00122Q00090009055Q000A00083Q00122Q000B000A052Q00122Q000C000B055Q000A000C00026Q0009000A00122Q0009000C055Q000A00083Q00122Q000B000D052Q00122Q000C000E055Q000A000C00026Q0009000A00122Q0009000F055Q000A00083Q00122Q000B0010052Q00122Q000C0011055Q000A000C00026Q0009000A00122Q00090012055Q000A00083Q00122Q000B0013052Q00122Q000C0014055Q000A000C00026Q0009000A00122Q00090015055Q000A00083Q00122Q000B0016052Q00122Q000C0017055Q000A000C00026Q0009000A00122Q00090018055Q000A00083Q00122Q000B0019052Q00122Q000C001A055Q000A000C00026Q0009000A0012750009001B053Q0045000A00083Q00122Q000B001C052Q00122Q000C001D055Q000A000C00026Q0009000A00122Q0009001E055Q000A00083Q00122Q000B001F052Q00122Q000C0020055Q000A000C00026Q0009000A00122Q00090021055Q000A00083Q00122Q000B0022052Q00122Q000C0023055Q000A000C00026Q0009000A00122Q00090024055Q000A00083Q00122Q000B0025052Q00122Q000C0026055Q000A000C00026Q0009000A00122Q00090027055Q000A00083Q00122Q000B0028052Q00122Q000C0029055Q000A000C00026Q0009000A00122Q0009002A055Q000A00083Q00122Q000B002B052Q00122Q000C002C055Q000A000C00026Q0009000A00122Q0009002D055Q000A00083Q00122Q000B002E052Q00122Q000C002F055Q000A000C00026Q0009000A00122Q00090030055Q000A00083Q00122Q000B0031052Q00122Q000C0032055Q000A000C00026Q0009000A00122Q00090033055Q000A00083Q00122Q000B0034052Q00122Q000C0035055Q000A000C00026Q0009000A00122Q00090036055Q000A00083Q00122Q000B0037052Q00122Q000C0038055Q000A000C00026Q0009000A00122Q00090039055Q000A00083Q00122Q000B003A052Q00122Q000C003B055Q000A000C00026Q0009000A00122Q0009003C055Q000A00083Q00122Q000B003D052Q00122Q000C003E055Q000A000C00026Q0009000A00122Q0009003F055Q000A00083Q00122Q000B0040052Q00122Q000C0041055Q000A000C00026Q0009000A00122Q00090042055Q000A00083Q00122Q000B0043052Q001275000C0044053Q0062000A000C00026Q0009000A00122Q00090045055Q000A00083Q00122Q000B0046052Q00122Q000C0047055Q000A000C00026Q0009000A00122Q00090048055Q000A00083Q00122Q000B0049052Q00122Q000C004A055Q000A000C00026Q0009000A00122Q0009004B055Q000A00083Q00122Q000B004C052Q00122Q000C004D055Q000A000C00026Q0009000A00122Q0009004E055Q000A00083Q00122Q000B004F052Q00122Q000C0050055Q000A000C00026Q0009000A00122Q00090051055Q000A00083Q00122Q000B0052052Q00122Q000C0053055Q000A000C00026Q0009000A00122Q00090054055Q000A00083Q00122Q000B0055052Q00122Q000C0056055Q000A000C00026Q0009000A00122Q00090057055Q000A00083Q00122Q000B0058052Q00122Q000C0059055Q000A000C00026Q0009000A00122Q0009005A055Q000A00083Q00122Q000B005B052Q00122Q000C005C055Q000A000C00026Q0009000A00122Q0009005D055Q000A00083Q00122Q000B005E052Q00122Q000C005F055Q000A000C00026Q0009000A00122Q00090060055Q000A00083Q00122Q000B0061052Q00122Q000C0062055Q000A000C00026Q0009000A00122Q00090063055Q000A00083Q00122Q000B0064052Q00122Q000C0065055Q000A000C00026Q0009000A00122Q00090066055Q000A00083Q00122Q000B0067052Q00122Q000C0068055Q000A000C00026Q0009000A00122Q00090069055Q000A00083Q00122Q000B006A052Q00122Q000C006B055Q000A000C00026Q0009000A00121D0009006C055Q000A00083Q00122Q000B006D052Q00122Q000C006E055Q000A000C00026Q0009000A00122Q0009006F055Q000A00083Q00122Q000B0070052Q00122Q000C0071053Q00AF000A000C00022Q00CC3Q0009000A00122Q00090072055Q00090001000200122Q000A0073052Q00122Q000B0074055Q0009000A000B00122Q00090072055Q00090001000200122Q000A0075052Q00122Q000B0076053Q00330009000A000B00124800090077052Q00122Q000B0078055Q00090009000B00122Q000B006F055Q000B3Q000B4Q0009000B000200122Q000A0077052Q00122Q000C0078055Q000A000A000C00122Q000C006C053Q00F4000C3Q000C2Q0089000A000C000200122Q000B0077052Q00122Q000D0078055Q000B000B000D00122Q000D0069055Q000D3Q000D4Q000B000D000200122Q000C0077052Q00122Q000E0078055Q000C000C000E001275000E0066053Q00A6000E3Q000E4Q000C000E000200122Q000D0079055Q000D000B000D00122Q0010007A055Q000E000D001000122Q00100063055Q00103Q00104Q000E0010000200122Q000F007B052Q00065E000F00C60A013Q0004B33Q00C60A0100126C000F007B052Q0012E70010007C055Q000F000F001000122Q0010007D055Q000F000F001000062Q000F00D20A0100010004B33Q00D20A0100126C000F0072053Q0039000F000100020012750010007E053Q00F4000F000F001000065E000F00D20A013Q0004B33Q00D20A0100126C000F0072053Q00BC000F0001000200122Q0010007E055Q000F000F001000122Q0010007D055Q000F000F001000126C0010007B052Q00065E001000DA0A013Q0004B33Q00DA0A0100126C0010007B052Q0012750011007F053Q00F40010001000110006B9001000F10A0100010004B33Q00F10A0100126C00100080052Q00065E001000E20A013Q0004B33Q00E20A0100126C00100080052Q0012750011007F053Q00F40010001000110006B9001000F10A0100010004B33Q00F10A0100126C00100081052Q0006B9001000F10A0100010004B33Q00F10A0100126C00100082052Q00065E001000ED0A013Q0004B33Q00ED0A0100126C00100082052Q0012750011007F053Q00F40010001000110006B9001000F10A0100010004B33Q00F10A0100126C00100083052Q00127500110060053Q00F400113Q00112Q00F40010001000112Q008500113Q00300012D40012005D055Q00123Q00124Q001300016Q00110012001300122Q0012005A055Q00123Q00124Q001300016Q00110012001300122Q00120057055Q00123Q00124Q001300016Q00110012001300122Q00120054055Q00123Q00124Q001300016Q00110012001300122Q00120051055Q00123Q00124Q001300016Q00110012001300122Q0012004E055Q00123Q00124Q001300016Q00110012001300122Q0012004B055Q00123Q00124Q001300016Q00110012001300122Q00120048055Q00123Q00124Q001300016Q00110012001300122Q00120045055Q00123Q00124Q001300016Q00110012001300122Q00120042055Q00123Q00124Q001300016Q00110012001300122Q0012003F055Q00123Q00124Q001300016Q00110012001300122Q0012003C055Q00123Q00124Q001300016Q00110012001300122Q00120039055Q00123Q00124Q001300016Q00110012001300122Q00120036055Q00123Q00124Q001300016Q00110012001300122Q00120033055Q00123Q00124Q001300016Q00110012001300122Q00120030055Q00123Q00124Q001300016Q00110012001300122Q0012002D055Q00123Q00124Q001300016Q00110012001300122Q0012002A055Q00123Q00124Q001300016Q00110012001300122Q00120027055Q00123Q00124Q001300016Q00110012001300122Q00120024055Q00123Q00124Q001300016Q0011001200130012D400120021055Q00123Q00124Q001300016Q00110012001300122Q0012001E055Q00123Q00124Q001300016Q00110012001300122Q0012001B055Q00123Q00124Q001300016Q00110012001300122Q00120018055Q00123Q00124Q001300016Q00110012001300122Q00120015055Q00123Q00124Q001300016Q00110012001300122Q00120012055Q00123Q00124Q001300016Q00110012001300122Q0012000F055Q00123Q00124Q001300016Q00110012001300122Q0012000C055Q00123Q00124Q001300016Q00110012001300122Q00120009055Q00123Q00124Q001300016Q00110012001300122Q00120006055Q00123Q00124Q001300016Q00110012001300122Q00120003055Q00123Q00124Q001300016Q00110012001300122Q00122Q00055Q00123Q00124Q001300016Q00110012001300122Q001200FD045Q00123Q00124Q001300016Q00110012001300122Q001200FA045Q00123Q00124Q001300016Q00110012001300122Q001200F7045Q00123Q00124Q001300016Q00110012001300122Q001200F4045Q00123Q00124Q001300016Q00110012001300122Q001200F1045Q00123Q00124Q001300016Q00110012001300122Q001200EE045Q00123Q00124Q001300016Q00110012001300122Q001200EB045Q00123Q00124Q001300016Q00110012001300122Q001200E8045Q00123Q00124Q001300016Q0011001200130012D4001200E5045Q00123Q00124Q001300016Q00110012001300122Q001200E2045Q00123Q00124Q001300016Q00110012001300122Q001200DF045Q00123Q00124Q001300016Q00110012001300122Q001200DC045Q00123Q00124Q001300016Q00110012001300122Q001200D9045Q00123Q00124Q001300016Q00110012001300122Q001200D6045Q00123Q00124Q001300016Q00110012001300122Q001200D3045Q00123Q00124Q001300016Q00110012001300122Q001200D0045Q00123Q00124Q001300016Q00110012001300122Q001200CD045Q00123Q00124Q001300016Q00110012001300122Q001200CA045Q00123Q00124Q001300016Q00110012001300122Q001200C7045Q00123Q00124Q001300016Q00110012001300122Q001200C4045Q00123Q00124Q001300016Q00110012001300122Q001200C1045Q00123Q00124Q001300016Q00110012001300122Q001200BE045Q00123Q00124Q001300016Q00110012001300122Q001200BB045Q00123Q00124Q001300016Q00110012001300122Q001200B8045Q00123Q00124Q001300016Q00110012001300122Q001200B5045Q00123Q00124Q001300016Q00110012001300122Q001200B2045Q00123Q00124Q001300016Q00110012001300122Q001200AF045Q00123Q00124Q001300016Q00110012001300122Q001200AC045Q00123Q00124Q001300016Q0011001200130012D4001200A9045Q00123Q00124Q001300016Q00110012001300122Q001200A6045Q00123Q00124Q001300016Q00110012001300122Q001200A3045Q00123Q00124Q001300016Q00110012001300122Q001200A0045Q00123Q00124Q001300016Q00110012001300122Q0012009D045Q00123Q00124Q001300016Q00110012001300122Q0012009A045Q00123Q00124Q001300016Q00110012001300122Q00120097045Q00123Q00124Q001300016Q00110012001300122Q00120094045Q00123Q00124Q001300016Q00110012001300122Q00120091045Q00123Q00124Q001300016Q00110012001300122Q0012008E045Q00123Q00124Q001300016Q00110012001300122Q0012008B045Q00123Q00124Q001300016Q00110012001300122Q00120088045Q00123Q00124Q001300016Q00110012001300122Q00120085045Q00123Q00124Q001300016Q00110012001300122Q00120082045Q00123Q00124Q001300016Q00110012001300122Q0012007F045Q00123Q00124Q001300016Q00110012001300122Q0012007C045Q00123Q00124Q001300016Q00110012001300122Q00120079045Q00123Q00124Q001300016Q00110012001300122Q00120076045Q00123Q00124Q001300016Q00110012001300122Q00120073045Q00123Q00124Q001300016Q00110012001300122Q00120070045Q00123Q00124Q001300016Q0011001200130012D40012006D045Q00123Q00124Q001300016Q00110012001300122Q0012006A045Q00123Q00124Q001300016Q00110012001300122Q00120067045Q00123Q00124Q001300016Q00110012001300122Q00120064045Q00123Q00124Q001300016Q00110012001300122Q00120061045Q00123Q00124Q001300016Q00110012001300122Q0012005E045Q00123Q00124Q001300016Q00110012001300122Q0012005B045Q00123Q00124Q001300016Q00110012001300122Q00120058045Q00123Q00124Q001300016Q00110012001300122Q00120055045Q00123Q00124Q001300016Q00110012001300122Q00120052045Q00123Q00124Q001300016Q00110012001300122Q0012004F045Q00123Q00124Q001300016Q00110012001300122Q0012004C045Q00123Q00124Q001300016Q00110012001300122Q00120049045Q00123Q00124Q001300016Q00110012001300122Q00120046045Q00123Q00124Q001300016Q00110012001300122Q00120043045Q00123Q00124Q001300016Q00110012001300122Q00120040045Q00123Q00124Q001300016Q00110012001300122Q0012003D045Q00123Q00124Q001300016Q00110012001300122Q0012003A045Q00123Q00124Q001300016Q00110012001300122Q00120037045Q00123Q00124Q001300016Q00110012001300122Q00120034045Q00123Q00124Q001300016Q0011001200130012D400120031045Q00123Q00124Q001300016Q00110012001300122Q0012002E045Q00123Q00124Q001300016Q00110012001300122Q0012002B045Q00123Q00124Q001300016Q00110012001300122Q00120028045Q00123Q00124Q001300016Q00110012001300122Q00120025045Q00123Q00124Q001300016Q00110012001300122Q00120022045Q00123Q00124Q001300016Q00110012001300122Q0012001F045Q00123Q00124Q001300016Q00110012001300122Q0012001C045Q00123Q00124Q001300016Q00110012001300122Q00120019045Q00123Q00124Q001300016Q00110012001300122Q00120016045Q00123Q00124Q001300016Q00110012001300122Q00120013045Q00123Q00124Q001300016Q00110012001300122Q00120010045Q00123Q00124Q001300016Q00110012001300122Q0012000D045Q00123Q00124Q001300016Q00110012001300122Q0012000A045Q00123Q00124Q001300016Q00110012001300122Q00120007045Q00123Q00124Q001300016Q00110012001300122Q0012002Q045Q00123Q00124Q001300016Q00110012001300122Q00120001045Q00123Q00124Q001300016Q00110012001300122Q001200FE035Q00123Q00124Q001300016Q00110012001300122Q001200FB035Q00123Q00124Q001300016Q00110012001300122Q001200F8035Q00123Q00124Q001300016Q00110012001300127500120084053Q0007001300016Q00110012001300122Q001200F5035Q00123Q00124Q001300016Q00110012001300122Q001200F2035Q00123Q00124Q001300016Q00110012001300122Q001200EF035Q00123Q00124Q001300016Q00110012001300122Q001200EC035Q00123Q00124Q001300016Q00110012001300122Q001200E9035Q00123Q00124Q001300016Q00110012001300122Q001200E6035Q00123Q00124Q001300016Q00110012001300122Q001200E3035Q00123Q00124Q001300016Q00110012001300122Q001200E0035Q00123Q00124Q001300016Q00110012001300122Q001200DD035Q00123Q00124Q001300016Q00110012001300122Q001200DA035Q00123Q00124Q001300016Q00110012001300122Q001200D7035Q00123Q00124Q001300016Q00110012001300122Q001200D4035Q00123Q00124Q001300016Q00110012001300122Q001200D1035Q00123Q00124Q001300016Q00110012001300122Q001200CE035Q00123Q00124Q001300016Q00110012001300122Q001200CB035Q00123Q00124Q001300016Q00110012001300122Q001200C8035Q00123Q00124Q001300016Q00110012001300122Q001200C5035Q00123Q00124Q001300016Q00110012001300122Q001200C2035Q00123Q00124Q001300016Q00110012001300122Q001200BF035Q00123Q00124Q001300016Q00110012001300122Q001200BC035Q00123Q00122Q0007001300016Q00110012001300122Q001200B9035Q00123Q00124Q001300016Q00110012001300122Q001200B6035Q00123Q00124Q001300016Q00110012001300122Q001200B3035Q00123Q00124Q001300016Q00110012001300122Q001200B0035Q00123Q00124Q001300016Q00110012001300122Q001200AD035Q00123Q00124Q001300016Q00110012001300122Q001200AA035Q00123Q00124Q001300016Q00110012001300122Q001200A7035Q00123Q00124Q001300016Q00110012001300122Q001200A4035Q00123Q00124Q001300016Q00110012001300122Q001200A1035Q00123Q00124Q001300016Q00110012001300122Q0012009E035Q00123Q00124Q001300016Q00110012001300122Q0012009B035Q00123Q00124Q001300016Q00110012001300122Q00120098035Q00123Q00124Q001300016Q00110012001300122Q00120095035Q00123Q00124Q001300016Q00110012001300122Q00120092035Q00123Q00124Q001300016Q00110012001300122Q0012008F035Q00123Q00124Q001300016Q00110012001300122Q0012008C035Q00123Q00124Q001300016Q00110012001300122Q00120089035Q00123Q00124Q001300016Q00110012001300122Q00120086035Q00123Q00124Q001300016Q00110012001300122Q00120083035Q00123Q00124Q001300016Q00110012001300122Q00120080035Q00123Q00122Q0007001300016Q00110012001300122Q0012007D035Q00123Q00124Q001300016Q00110012001300122Q0012007A035Q00123Q00124Q001300016Q00110012001300122Q00120077035Q00123Q00124Q001300016Q00110012001300122Q00120074035Q00123Q00124Q001300016Q00110012001300122Q00120071035Q00123Q00124Q001300016Q00110012001300122Q0012006E035Q00123Q00124Q001300016Q00110012001300122Q0012006B035Q00123Q00124Q001300016Q00110012001300122Q00120068035Q00123Q00124Q001300016Q00110012001300122Q00120065035Q00123Q00124Q001300016Q00110012001300122Q00120062035Q00123Q00124Q001300016Q00110012001300122Q0012005F035Q00123Q00124Q001300016Q00110012001300122Q0012005C035Q00123Q00124Q001300016Q00110012001300122Q00120059035Q00123Q00124Q001300016Q00110012001300122Q00120056035Q00123Q00124Q001300016Q00110012001300122Q00120053035Q00123Q00124Q001300016Q00110012001300122Q00120050035Q00123Q00124Q001300016Q00110012001300122Q0012004D035Q00123Q00124Q001300016Q00110012001300122Q0012004A035Q00123Q00124Q001300016Q00110012001300122Q00120047035Q00123Q00124Q001300016Q00110012001300122Q00120044035Q00123Q00122Q0007001300016Q00110012001300122Q00120041035Q00123Q00124Q001300016Q00110012001300122Q0012003E035Q00123Q00124Q001300016Q00110012001300122Q0012003B035Q00123Q00124Q001300016Q00110012001300122Q00120038035Q00123Q00124Q001300016Q00110012001300122Q00120035035Q00123Q00124Q001300016Q00110012001300122Q00120032035Q00123Q00124Q001300016Q00110012001300122Q0012002F035Q00123Q00124Q001300016Q00110012001300122Q0012002C035Q00123Q00124Q001300016Q00110012001300122Q00120029035Q00123Q00124Q001300016Q00110012001300122Q00120026035Q00123Q00124Q001300016Q00110012001300122Q00120023035Q00123Q00124Q001300016Q00110012001300122Q00120020035Q00123Q00124Q001300016Q00110012001300122Q0012001D035Q00123Q00124Q001300016Q00110012001300122Q0012001A035Q00123Q00124Q001300016Q00110012001300122Q00120017035Q00123Q00124Q001300016Q00110012001300122Q00120014035Q00123Q00124Q001300016Q00110012001300122Q00120011035Q00123Q00124Q001300016Q00110012001300122Q0012000E035Q00123Q00124Q001300016Q00110012001300122Q0012000B035Q00123Q00124Q001300016Q00110012001300122Q00120008035Q00123Q00122Q0007001300016Q00110012001300122Q00120005035Q00123Q00124Q001300016Q00110012001300122Q00120002035Q00123Q00124Q001300016Q00110012001300122Q001200FF025Q00123Q00124Q001300016Q00110012001300122Q001200FC025Q00123Q00124Q001300016Q00110012001300122Q001200F9025Q00123Q00124Q001300016Q00110012001300122Q001200F6025Q00123Q00124Q001300016Q00110012001300122Q001200F3025Q00123Q00124Q001300016Q00110012001300122Q001200F0025Q00123Q00124Q001300016Q00110012001300122Q001200ED025Q00123Q00124Q001300016Q00110012001300122Q001200EA025Q00123Q00124Q001300016Q00110012001300122Q001200E7025Q00123Q00124Q001300016Q00110012001300122Q001200E4025Q00123Q00124Q001300016Q00110012001300122Q001200E1025Q00123Q00124Q001300016Q00110012001300122Q001200DE025Q00123Q00124Q001300016Q00110012001300122Q001200DB025Q00123Q00124Q001300016Q00110012001300122Q001200D8025Q00123Q00124Q001300016Q00110012001300122Q001200D5025Q00123Q00124Q001300016Q00110012001300122Q001200D2025Q00123Q00124Q001300016Q00110012001300122Q001200CF025Q00123Q00124Q001300016Q00110012001300122Q001200CC025Q00123Q00122Q0007001300016Q00110012001300122Q001200C9025Q00123Q00124Q001300016Q00110012001300122Q001200C6025Q00123Q00124Q001300016Q00110012001300122Q001200C3025Q00123Q00124Q001300016Q00110012001300122Q001200C0025Q00123Q00124Q001300016Q00110012001300122Q001200BD025Q00123Q00124Q001300016Q00110012001300122Q001200BA025Q00123Q00124Q001300016Q00110012001300122Q001200B7025Q00123Q00124Q001300016Q00110012001300122Q001200B4025Q00123Q00124Q001300016Q00110012001300122Q001200B1025Q00123Q00124Q001300016Q00110012001300122Q001200AE025Q00123Q00124Q001300016Q00110012001300122Q001200AB025Q00123Q00124Q001300016Q00110012001300122Q001200A8025Q00123Q00124Q001300016Q00110012001300122Q001200A5025Q00123Q00124Q001300016Q00110012001300122Q001200A2025Q00123Q00124Q001300016Q00110012001300122Q0012009F025Q00123Q00124Q001300016Q00110012001300122Q0012009C025Q00123Q00124Q001300016Q00110012001300122Q00120099025Q00123Q00124Q001300016Q00110012001300122Q00120096025Q00123Q00124Q001300016Q00110012001300122Q00120093025Q00123Q00124Q001300016Q00110012001300122Q00120090025Q00123Q00122Q00AC001300016Q00110012001300122Q0012008D025Q00123Q00124Q001300016Q00110012001300122Q0012008A025Q00123Q00124Q001300016Q0011001200130012B700120087025Q00123Q00124Q001300016Q00110012001300122Q00120084025Q00123Q00124Q001300016Q00110012001300122Q00120081025Q00123Q00122Q00AC001300016Q00110012001300122Q0012007E025Q00123Q00124Q001300016Q00110012001300122Q0012007B025Q00123Q00124Q001300016Q00110012001300127500120078023Q00F400123Q00122Q003E001300014Q003300110012001300126C00120085052Q0006EB00130001000100022Q00353Q000A4Q00358Q008200120002000100126C00120086052Q00127500130087053Q00F40012001200130006EB00130002000100012Q00358Q008200120002000100126C00120086052Q00127500130087053Q00F40012001200130006EB00130003000100032Q00358Q00353Q000D4Q00353Q000B4Q008800120002000100122Q00120088052Q00122Q00130089055Q00120012001300122Q00130057025Q00133Q00134Q00120002000200122Q0013008A052Q00122Q00140054025Q00143Q00144Q00120013001400122Q0013008B055Q00148Q00120013001400122Q0013008C055Q00120013000E00122Q00130088052Q00122Q00140089055Q00130013001400122Q00140051025Q00143Q00144Q001500126Q00130015000200122Q0014008D052Q00122Q0015008E052Q00122Q00160089055Q00150015001600122Q0016008F052Q00122Q00170090052Q00122Q0018008F052Q00122Q001900D5025Q0015001900024Q00130014001500122Q00140091052Q00122Q0015008E052Q00122Q00160089055Q00150015001600122Q00160092052Q00122Q00170093052Q00122Q00180092052Q00122Q00190094055Q0015001900024Q00130014001500122Q00140095052Q00122Q00150096052Q00122Q00160097055Q00150015001600122Q00160098052Q00122Q00170098052Q00122Q00180057055Q0015001800024Q00130014001500122Q00140099052Q00122Q00150096052Q00122Q00160097055Q00150015001600122Q001600A8022Q00122Q001700EE042Q00122Q001800EE045Q0015001800024Q00130014001500122Q0014009A052Q00122Q0015009B055Q00130014001500122Q0014009C055Q001500016Q00130014001500122Q0014009D055Q001500016Q00130014001500122Q00140088052Q00122Q00150089055Q00140014001500122Q0015004E025Q00153Q00154Q001600136Q00140016000200122Q0015009E052Q00122Q0016009F052Q00122Q00170089053Q00F40016001600170012870017008F052Q00122Q0018006C055Q0016001800024Q00140015001600122Q00140088052Q00122Q00150089055Q00140014001500122Q0015004B025Q00153Q00154Q001600136Q00140016000200122Q0015008D052Q00122Q0016008E052Q00122Q00170089055Q00160016001700122Q0017009B052Q00122Q001800A0052Q00122Q0019008F052Q00122Q001A000C055Q0016001A00024Q00140015001600122Q00150091052Q00122Q0016008E052Q00122Q00170089055Q00160016001700122Q00170092052Q00122Q0018008F052Q00122Q0019008F052Q00122Q001A008F055Q0016001A00024Q00140015001600122Q001500A1052Q00122Q001600A2052Q00122Q00170089055Q00160016001700122Q00170092052Q00122Q0018008F055Q0016001800024Q00140015001600122Q001500A3052Q00122Q0016009B055Q00140015001600122Q001500A4052Q00122Q001600A5052Q00122Q001700A4055Q00160016001700122Q001700A6055Q0016001600174Q00140015001600122Q001500A7052Q00122Q00160048025Q00163Q00164Q00140015001600122Q001500A8052Q00122Q00160096052Q00122Q00170097055Q00160016001700122Q001700A8022Q00122Q001800A8022Q00122Q001900A8025Q0016001900024Q00140015001600122Q001500A9052Q00122Q00160060055Q00140015001600122Q00150088052Q00122Q00160089055Q00150015001600122Q00160045025Q00163Q00164Q001700136Q00150017000200122Q0016008D052Q00122Q0017008E052Q00122Q00180089055Q00170017001800122Q0018009B052Q00122Q001900A0052Q00122Q001A008F052Q00122Q001B0098053Q00AF0017001B00022Q006500150016001700122Q00160091052Q00122Q0017008E052Q00122Q00180089055Q00170017001800122Q00180092052Q00122Q0019008F052Q00122Q001A008F052Q00122Q001B001B055Q0017001B00024Q00150016001700122Q001600A1052Q00122Q001700A2052Q00122Q00180089055Q00170017001800122Q00180092052Q00122Q0019008F055Q0017001900024Q00150016001700122Q001600A3052Q00122Q0017009B055Q00150016001700122Q001600A4052Q00122Q001700A5052Q00122Q001800A4055Q00170017001800122Q001800AA055Q0017001700184Q00150016001700122Q001600A7052Q00122Q00170042025Q00173Q00174Q00150016001700122Q001600A8052Q00122Q00170096052Q00122Q00180097055Q00170017001800122Q001800C5032Q00122Q001900C5032Q00122Q001A00C5035Q0017001A00024Q00150016001700122Q001600A9052Q00122Q001700AB055Q00150016001700122Q00160088052Q00122Q00170089055Q00160016001700122Q0017003F025Q00173Q00174Q001800136Q00160018000200122Q0017008D052Q00122Q0018008E052Q00122Q00190089055Q00180018001900122Q0019009B052Q00122Q001A00AC052Q00122Q001B008F052Q00122Q001C002A055Q0018001C00024Q00160017001800122Q00170091052Q00122Q0018008E052Q00122Q00190089055Q00180018001900122Q00190092052Q00122Q001A008F052Q00122Q001B008F052Q00122Q001C00D0045Q0018001C00024Q00160017001800122Q001700A1052Q00122Q001800A2052Q00122Q00190089055Q00180018001900122Q00190092052Q00122Q001A008F055Q0018001A00024Q001600170018001275001700A3052Q00129F0018009B055Q00160017001800122Q001700A4052Q00122Q001800A5052Q00122Q001900A4055Q00180018001900122Q001900AA055Q0018001800194Q00160017001800122Q001700A7052Q00122Q0018003C025Q00183Q00184Q00160017001800122Q001700A8052Q00122Q00180096052Q00122Q00190097055Q00180018001900122Q001900A8022Q00122Q001A0089032Q00122Q001B008F055Q0018001B00024Q00160017001800122Q001700A9052Q00122Q001800AD055Q00160017001800122Q001700AE055Q001800016Q00160017001800122Q00170088052Q00122Q00180089055Q00170017001800122Q00180039025Q00183Q00184Q001900136Q00170019000200122Q0018008D052Q00122Q0019008E052Q00122Q001A0089055Q00190019001A00122Q001A009B052Q00122Q001B00AC052Q00122Q001C008F052Q00122Q001D002A055Q0019001D00024Q00170018001900122Q00180091052Q00122Q0019008E052Q00122Q001A0089055Q00190019001A00122Q001A0092052Q00122Q001B008F052Q00122Q001C0092052Q00122Q001D0057055Q0019001D00024Q00170018001900122Q001800A1052Q00122Q001900A2052Q00122Q001A0089055Q00190019001A00122Q001A0092052Q00122Q001B0092055Q0019001B00024Q00170018001900122Q00180095052Q00122Q00190096052Q00122Q001A0097055Q00190019001A00122Q001A0039052Q00122Q001B0039052Q00122Q001C002A055Q0019001C00024Q00170018001900122Q00180099052Q00122Q00190096052Q00122Q001A0097055Q00190019001A00122Q001A000C052Q00122Q001B000C052Q00122Q001C00FD045Q0019001C00022Q00330017001800190012BA001800A4052Q00122Q001900A5052Q00122Q001A00A4055Q00190019001A00122Q001A00AA055Q00190019001A4Q00170018001900122Q001800AF052Q00122Q001900B0055Q00170018001900122Q001800A8052Q00122Q00190096052Q00122Q001A0097055Q00190019001A00122Q001A00F3022Q00122Q001B00F3022Q00122Q001C00F3025Q0019001C00024Q00170018001900122Q001800A9052Q00122Q001900B1055Q00170018001900122Q001800A7052Q00122Q001900B2055Q00170018001900122Q001800B3055Q001900016Q00170018001900122Q00180088052Q00122Q00190089055Q00180018001900122Q00190036025Q00193Q00194Q001A00176Q0018001A000200122Q0019009E052Q00122Q001A009F052Q00122Q001B0089055Q001A001A001B00122Q001B008F052Q00122Q001C006F055Q001A001C00024Q00180019001A00122Q00180088052Q00122Q00190089055Q00180018001900122Q00190033025Q00193Q00194Q001A00136Q0018001A000200122Q0019008D052Q00122Q001A008E052Q00122Q001B0089055Q001A001A001B00122Q001B009B052Q00122Q001C00AC052Q00122Q001D008F052Q00122Q001E002A055Q001A001E00024Q00180019001A00122Q00190091052Q00122Q001A008E052Q00122Q001B0089055Q001A001A001B00122Q001B0092052Q00122Q001C008F052Q00122Q001D009B052Q00122Q001E00B4055Q001A001E00024Q00180019001A00122Q001900A1052Q00122Q001A00A2052Q00122Q001B0089055Q001A001A001B00122Q001B0092052Q00122Q001C009B055Q001A001C00024Q00180019001A00122Q00190095052Q00122Q001A0096052Q0012B4001B0097055Q001A001A001B00122Q001B00A8022Q00122Q001C00EE042Q00122Q001D00EE045Q001A001D00024Q00180019001A00122Q001900A4052Q00122Q001A00A5052Q00122Q001B00A4053Q00F4001A001A001B00125B001B00A6055Q001A001A001B4Q00180019001A00122Q001900A7052Q00122Q001A0030025Q001A3Q001A4Q00180019001A00122Q001900A8052Q00122Q001A0096052Q00122Q001B0097053Q00F4001A001A001B00122Q001B00A8022Q00122Q001C00A8022Q00122Q001D00A8025Q001A001D00024Q00180019001A00122Q001900A9052Q00122Q001A00B5055Q00180019001A00122Q00190088052Q00122Q001A0089053Q00F400190019001A0012B2001A002D025Q001A3Q001A4Q001B00186Q0019001B000200122Q001A009E052Q00122Q001B009F052Q00122Q001C0089055Q001B001B001C00122Q001C008F052Q00122Q001D006F053Q00AF001B001D00022Q00330019001A001B0006EB00190004000100052Q00358Q00353Q000C4Q00353Q000D4Q00353Q000A4Q00353Q000E3Q001275001A00B6053Q00F4001A0018001A001275001C00B7053Q00BB001A001A001C0006EB001C00050001000C2Q00353Q00174Q00358Q00353Q00184Q00353Q00124Q00353Q000D4Q00353Q000C4Q00353Q000B4Q00353Q00104Q00353Q00094Q00353Q000A4Q00353Q00114Q00353Q00194Q002A001A001C00012Q003100096Q001C3Q00013Q00063Q00023Q00026Q00F03F026Q00704002264Q00CB00025Q00122Q000300016Q00045Q00122Q000500013Q00042Q0003002100012Q00B600076Q0005010800026Q000900016Q000A00026Q000B00036Q000C00046Q000D8Q000E00063Q00202Q000F000600014Q000C000F6Q000B3Q00024Q000C00036Q000D00046Q000E00016Q000F00016Q000F0006000F00102Q000F0001000F4Q001000016Q00100006001000102Q00100001001000202Q0010001000014Q000D00106Q000C8Q000A3Q000200202Q000A000A00024Q0009000A6Q00073Q00010004500003000500012Q00B6000300054Q0035000400024Q00AE000300044Q00BF00036Q001C3Q00017Q00073Q00028Q00030C3Q0057616974466F724368696C64025Q00107140026Q001440025Q00307140031D3Q0052452F4E6F74696669636174696F6E536572766963652F4E6F7469667903073Q0044657374726F79001B3Q0012753Q00014Q007A000100013Q0026A03Q0002000100010004B33Q000200012Q00B600025Q0020EC0002000200024Q000400013Q00202Q00040004000300122Q000500046Q00020005000200202Q0002000200024Q000400013Q00202Q00040004000500122Q000500046Q00020005000200202Q00020002000200122Q000400063Q00122Q000500046Q0002000500024Q000100023Q00062Q0001001A00013Q0004B33Q001A00010020790002000100072Q00820002000200010004B33Q001A00010004B33Q000200012Q001C3Q00017Q00093Q00028Q0003063Q0069706169727303043Q0067616D65030E3Q0047657444657363656E64616E74732Q033Q00497341025Q00A0714003053Q007063612Q6C030F3Q0044657363656E64616E74412Q64656403073Q00436F2Q6E65637400253Q0012753Q00014Q007A000100013Q0026A03Q0002000100010004B33Q00020001001275000100013Q0026A000010005000100010004B33Q0005000100126C000200023Q0012CF000300033Q00202Q0003000300044Q000300046Q00023Q000400044Q001800010020790007000600052Q00B600095Q0020010009000900062Q00AF00070009000200065E0007001700013Q0004B33Q0017000100126C000700073Q0006EB00083Q000100012Q00353Q00064Q00820007000200012Q003100055Q0006230002000D000100020004B33Q000D000100126C000200033Q0020010002000200080020790002000200090006EB00040001000100012Q00B68Q002A0002000400010004B33Q002400010004B33Q000500010004B33Q002400010004B33Q000200012Q001C3Q00013Q00023Q00023Q0003063Q00566F6C756D65029Q00034Q00B67Q0030C93Q000100022Q001C3Q00017Q00033Q002Q033Q00497341025Q00F0714003053Q007063612Q6C010B3Q00207200013Q00014Q00035Q00202Q0003000300024Q00010003000200062Q0001000A00013Q0004B33Q000A000100126C000100033Q0006EB00023Q000100012Q00358Q00820001000200012Q001C3Q00013Q00013Q00023Q0003063Q00566F6C756D65029Q00034Q00B67Q0030C93Q000100022Q001C3Q00017Q00013Q0003053Q007063612Q6C00073Q00126C3Q00013Q0006EB00013Q000100032Q00B68Q00B63Q00014Q00B63Q00024Q00823Q000200012Q001C3Q00013Q00013Q000E3Q00028Q0003043Q0067616D65030A3Q0047657453657276696365025Q00307240030E3Q0046696E6446697273744368696C64025Q00507240030F3Q004D652Q73616765526563656976656403073Q00436F2Q6E656374026Q00F03F030B3Q00506C61796572412Q64656403063Q00697061697273030A3Q00476574506C617965727303073Q004368612Q746564027Q004000443Q0012753Q00014Q007A000100013Q0026A03Q0002000100010004B33Q0002000100126C000200023Q0020420002000200034Q00045Q00202Q0004000400044Q0002000400024Q000100023Q00062Q0001001E00013Q0004B33Q001E00010020790002000100052Q00B600045Q0020010004000400062Q00AF00020004000200065E0002001E00013Q0004B33Q001E0001001275000200013Q0026A000020013000100010004B33Q001300010020010003000100070020790003000300080006EB00053Q000100022Q00B68Q00B63Q00014Q002A0003000500012Q001C3Q00013Q0004B33Q001300010004B33Q00430001001275000200014Q007A000300033Q000E8000090036000100020004B33Q003600012Q00B6000400023Q0020C800040004000A00202Q0004000400084Q000600036Q00040006000100122Q0004000B6Q000500023Q00202Q00050005000C4Q000500066Q00043Q000600044Q0033000100200100090008000D0020790009000900080006EB000B0001000100022Q00B68Q00B63Q00014Q002A0009000B00010006230004002D000100020004B33Q002D00010012750002000E3Q0026A00002003D000100010004B33Q003D00012Q007A000300033Q0006EB00030002000100022Q00B68Q00B63Q00013Q001275000200093Q000E80000E0020000100020004B33Q002000012Q001C3Q00013Q0004B33Q002000010004B33Q004300010004B33Q000200012Q001C3Q00013Q00033Q00093Q00028Q0003043Q005465787403043Q0074797065025Q0090724003053Q006C6F776572025Q00C0724003043Q007461736B03043Q007761697403043Q004B69636B01233Q00065E3Q002200013Q0004B33Q00220001001275000100014Q007A000200023Q0026A000010004000100010004B33Q0004000100200100023Q00020012BE000300036Q000400026Q0003000200024Q00045Q00202Q00040004000400062Q00030022000100040004B33Q0022000100200100033Q000200209E0003000300054Q0003000200024Q00045Q00202Q00040004000600062Q00030022000100040004B33Q00220001001275000300013Q0026A000030016000100010004B33Q0016000100126C000400073Q0020E20004000400084Q0004000100014Q000400013Q00202Q0004000400094Q00040002000100044Q002200010004B33Q001600010004B33Q002200010004B33Q000400012Q001C3Q00017Q00063Q0003053Q006C6F776572025Q00507340028Q0003043Q007461736B03043Q007761697403043Q004B69636B01123Q00209E00013Q00014Q0001000200024Q00025Q00202Q00020002000200062Q00010011000100020004B33Q00110001001275000100033Q0026A000010007000100030004B33Q0007000100126C000200043Q0020E20002000200054Q0002000100014Q000200013Q00202Q0002000200064Q00020002000100044Q001100010004B33Q000700012Q001C3Q00017Q00023Q0003073Q004368612Q74656403073Q00436F2Q6E65637401073Q00200100013Q00010020790001000100020006EB00033Q000100022Q00B68Q00B63Q00014Q002A0001000300012Q001C3Q00013Q00013Q00063Q0003053Q006C6F776572025Q00B07340028Q0003043Q007461736B03043Q007761697403043Q004B69636B01183Q00209E00013Q00014Q0001000200024Q00025Q00202Q00020002000200062Q00010017000100020004B33Q00170001001275000100034Q007A000200023Q0026A000010008000100030004B33Q00080001001275000200033Q0026A00002000B000100030004B33Q000B000100126C000300043Q0020E20003000300054Q0003000100014Q000300013Q00202Q0003000300064Q00030002000100044Q001700010004B33Q000B00010004B33Q001700010004B33Q000800012Q001C3Q00017Q004A3Q0003083Q00496E7374616E63652Q033Q006E6577025Q0040804003043Q004E616D65025Q00508040030C3Q0052657365744F6E537061776E010003063Q00506172656E74025Q0070804003043Q0053697A6503053Q005544696D32028Q00025Q00207C40025Q0040704003083Q00506F736974696F6E026Q00E03F025Q00206CC0025Q004060C003103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q003440026Q003940030C3Q00426F72646572436F6C6F7233026Q005E40025Q00E06F40030F3Q00426F7264657253697A65506978656C026Q00F03F03063Q004163746976652Q0103093Q004472612Q6761626C65025Q00D88040030C3Q00436F726E657252616469757303043Q005544696D026Q002040025Q00F88040026Q00494003163Q004261636B67726F756E645472616E73706172656E637903043Q00466F6E7403043Q00456E756D03043Q00436F646503043Q0054657874025Q00388140030A3Q0054657874436F6C6F723303083Q005465787453697A65026Q003840025Q00608140026Q0044C0026Q0024C0030B3Q00416E63686F72506F696E7403073Q00566563746F7232025Q00C88140025Q00F08140026Q001840025Q00108240026Q004E4003063Q00476F7468616D025Q00708240025Q00806640026Q002840030B3Q00546578745772612Q706564025Q00A08240026Q00244003073Q0056697369626C65025Q00F08240026Q003E40025Q00508340026Q006940026Q003040025Q00788340025Q00804140025Q00E0834003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E6563740065012Q0006EB5Q000100012Q00B67Q0006EB00010001000100052Q00B63Q00014Q00B68Q00B63Q00024Q00358Q00B63Q00033Q0012D1000200013Q00202Q0002000200024Q00035Q00202Q0003000300034Q0002000200024Q00035Q00202Q00030003000500102Q00020004000300302Q0002000600074Q000300043Q00102Q00020008000300122Q000300013Q00202Q0003000300024Q00045Q00202Q0004000400094Q000500026Q00030005000200122Q0004000B3Q00202Q00040004000200122Q0005000C3Q00122Q0006000D3Q00122Q0007000C3Q00122Q0008000E6Q00040008000200102Q0003000A000400122Q0004000B3Q00202Q00040004000200122Q000500103Q00122Q000600113Q00122Q000700103Q00122Q000800126Q00040008000200102Q0003000F000400122Q000400143Q00202Q00040004001500122Q000500163Q00122Q000600163Q00122Q000700176Q00040007000200102Q00030013000400122Q000400143Q00202Q00040004001500122Q000500193Q00122Q0006000C3Q00122Q0007001A6Q00040007000200102Q00030018000400302Q0003001B001C00302Q0003001D001E00302Q0003001F001E00122Q000400013Q00202Q0004000400024Q00055Q00202Q0005000500204Q000600036Q00040006000200122Q000500223Q00202Q00050005000200122Q0006000C3Q00122Q000700236Q00050007000200102Q00040021000500122Q000400013Q00202Q0004000400024Q00055Q00202Q0005000500244Q000600036Q00040006000200122Q0005000B3Q00202Q00050005000200122Q0006001C3Q00122Q0007000C3Q00122Q0008000C3Q00122Q000900256Q00050009000200102Q0004000A000500302Q00040026001C00122Q000500283Q00202Q00050005002700202Q0005000500290010180004002700052Q000F00055Q00202Q00050005002B00102Q0004002A000500122Q000500143Q00202Q00050005001500122Q0006001A3Q00122Q0007001A3Q00122Q0008001A6Q00050008000200102Q0004002C000500302Q0004002D002E00122Q000500013Q00202Q0005000500024Q00065Q00202Q00060006002F4Q000700036Q00050007000200122Q0006000B3Q00202Q00060006000200122Q0007001C3Q00122Q000800303Q00122Q0009000C3Q00122Q000A00256Q0006000A000200102Q0005000A000600122Q0006000B3Q00202Q00060006000200122Q000700103Q00122Q0008000C3Q00122Q000900103Q00122Q000A00316Q0006000A000200102Q0005000F000600122Q000600333Q00202Q00060006000200122Q000700103Q00122Q000800106Q00060008000200102Q00050032000600122Q000600143Q00202Q00060006001500122Q000700193Q00122Q0008000C3Q00122Q0009001A6Q00060009000200102Q00050013000600122Q000600283Q00202Q00060006002700202Q00060006002900102Q0005002700064Q00065Q00202Q00060006003400102Q0005002A000600122Q000600143Q00202Q00060006001500122Q0007001A3Q00122Q0008001A3Q00122Q0009001A6Q00060009000200102Q0005002C000600302Q0005002D001600122Q000600013Q00202Q0006000600024Q00075Q00202Q0007000700354Q000800056Q00060008000200122Q000700223Q00202Q00070007000200122Q0008000C3Q00122Q000900366Q00070009000200102Q00060021000700122Q000600013Q00202Q0006000600024Q00075Q00202Q0007000700374Q000800036Q00060008000200122Q0007000B3Q00200100070007000200126B0008001C3Q00122Q000900303Q00122Q000A000C3Q00122Q000B00386Q0007000B000200102Q0006000A000700122Q0007000B3Q00202Q00070007000200122Q000800103Q00122Q0009000C3Q00122Q000A001C3Q00122Q000B00306Q0007000B000200102Q0006000F000700122Q000700333Q00202Q00070007000200122Q000800103Q00122Q000900106Q00070009000200102Q00060032000700302Q00060026001C00122Q000700283Q00202Q00070007002700202Q00070007003900102Q0006002700074Q00075Q00202Q00070007003A00102Q0006002A000700122Q000700143Q00202Q00070007001500122Q0008001A3Q00122Q0009003B3Q00122Q000A000C6Q0007000A000200102Q0006002C000700302Q0006002D003C00302Q0006003D001E00122Q000700013Q00202Q0007000700024Q00085Q00202Q00080008003E4Q000900036Q00070009000200122Q0008000B3Q00202Q00080008000200122Q0009001C3Q00122Q000A00303Q00122Q000B000C3Q00122Q000C00196Q0008000C000200102Q0007000A000800122Q0008000B3Q00202Q00080008000200122Q000900103Q00122Q000A000C3Q00122Q000B00103Q00122Q000C003F6Q0008000C000200102Q0007000F000800122Q000800333Q00202Q00080008000200122Q000900103Q00122Q000A00106Q0008000A000200102Q00070032000800302Q00070026001C00302Q00070040000700122Q000800013Q00202Q0008000800024Q00095Q00202Q0009000900414Q000A00076Q0008000A000200122Q0009000B3Q00202Q00090009000200122Q000A001C3Q00122Q000B000C3Q00122Q000C000C3Q00122Q000D00426Q0009000D00020010180008000A00090012F30009000B3Q00202Q00090009000200122Q000A00103Q00122Q000B000C3Q00122Q000C000C3Q00122Q000D00166Q0009000D000200102Q0008000F000900122Q000900333Q00202Q00090009000200122Q000A00103Q00122Q000B000C6Q0009000B000200102Q00080032000900302Q00080026001C00122Q000900283Q00202Q00090009002700202Q00090009002900102Q0008002700094Q00095Q00202Q00090009004300102Q0008002A000900122Q000900143Q00202Q00090009001500122Q000A00443Q00122Q000B00443Q00122Q000C00446Q0009000C000200102Q0008002C000900302Q0008002D004500122Q000900013Q00202Q0009000900024Q000A5Q00202Q000A000A00464Q000B00076Q0009000B000200122Q000A000B3Q00202Q000A000A000200122Q000B001C3Q00122Q000C000C3Q00122Q000D000C3Q00122Q000E003F6Q000A000E000200102Q0009000A000A00122Q000A000B3Q00202Q000A000A000200122Q000B00103Q00122Q000C000C3Q00122Q000D000C3Q00122Q000E00386Q000A000E000200102Q0009000F000A00122Q000A00333Q00202Q000A000A000200122Q000B00103Q00122Q000C000C6Q000A000C000200102Q00090032000A00122Q000A00143Q00202Q000A000A001500122Q000B00423Q00122Q000C00423Q00122Q000D00476Q000A000D000200102Q00090013000A00122Q000A00143Q00202Q000A000A001500122Q000B00193Q00122Q000C000C3Q00122Q000D001A6Q000A000D000200102Q00090018000A00302Q0009001B001C00122Q000A00013Q00202Q000A000A00024Q000B5Q00202Q000B000B00484Q000C00096Q000A000C000200122Q000B00143Q002001000B000B00150012D8000C00193Q00122Q000D000C3Q00122Q000E001A6Q000B000E000200102Q000A0013000B00122Q000B000B3Q00202Q000B000B000200122Q000C000C3Q00122Q000D000C3Q00122Q000E001C3Q00122Q000F000C6Q000B000F000200102Q000A000A000B00202Q000B0005004900202Q000B000B004A0006EB000D0002000100072Q00353Q00054Q00353Q00074Q00B68Q00353Q00084Q00353Q00014Q00353Q000A4Q00B63Q00014Q002A000B000D00012Q001C3Q00013Q00033Q000E3Q00028Q0003083Q00746F737472696E6703043Q006773756203063Q005B242C2F735D034Q0003013Q004B025Q00F07B4003013Q004D025Q00207C4003013Q0042025Q00507C4003013Q0054025Q00807C4003083Q00746F6E756D62657201323Q0006B93Q0005000100010004B33Q00050001001275000100014Q002F000100023Q0004B33Q00310001001275000100014Q007A000200023Q0026A000010007000100010004B33Q00070001001275000300013Q0026A00003000A000100010004B33Q000A000100126C000400024Q004600058Q00040002000200202Q00040004000300122Q000600043Q00122Q000700056Q00040007000200202Q00040004000300122Q000600066Q00075Q00202Q0007000700074Q00040007000200202Q00040004000300122Q000600086Q00075Q00202Q0007000700094Q00040007000200202Q00040004000300122Q0006000A6Q00075Q00202Q00070007000B4Q00040007000200202Q00040004000300122Q0006000C6Q00075Q00202Q00070007000D4Q0004000700024Q000200043Q00122Q0004000E6Q000500026Q00040002000200062Q0004002E000100010004B33Q002E0001001275000400014Q002F000400023Q0004B33Q000A00010004B33Q000700012Q001C3Q00017Q00143Q00028Q00030E3Q0046696E6446697273744368696C64025Q00A07C40026Q00F03F030B3Q00446973706C61794E616D6503073Q002773204261736503063Q00697061697273030B3Q004765744368696C6472656E2Q033Q00497341025Q00F07C40025Q00107D4003083Q00506C6F745369676E025Q00407D40030A3Q0053757266616365477569025Q00807D4003053Q004672616D65025Q00D07D4003043Q0054657874026Q007E4003053Q007063612Q6C008A3Q0012753Q00014Q007A000100023Q0026A03Q0015000100010004B33Q00150001001275000300013Q0026A000030010000100010004B33Q001000012Q008500046Q00D9000100046Q00045Q00202Q0004000400024Q000600013Q00202Q0006000600034Q0004000600024Q000200043Q00122Q000300043Q000E8000040005000100030004B33Q000500010012753Q00043Q0004B33Q001500010004B33Q000500010026A03Q0002000100040004B33Q000200010006B90002001B000100010004B33Q001B00012Q002F000100023Q0004B33Q00890001001275000300014Q007A000400053Q0026A000030025000100010004B33Q002500012Q007A000400044Q000A000600023Q00202Q00060006000500122Q000700066Q00050006000700122Q000300043Q0026A00003001D000100040004B33Q001D000100126C000600073Q0020790007000200082Q0036000700084Q00E400063Q00080004B33Q00590001002079000B000A00092Q00B6000D00013Q002001000D000D000A2Q00AF000B000D000200065E000B005900013Q0004B33Q00590001002079000B000A00022Q004B000D00013Q00202Q000D000D000B4Q000E00016Q000B000E000200062Q000B005200013Q0004B33Q00520001002001000B000A000C00204A000B000B00024Q000D00013Q00202Q000D000D000D4Q000E00016Q000B000E000200062Q000B005200013Q0004B33Q00520001002001000B000A000C002024000B000B000E00202Q000B000B00024Q000D00013Q00202Q000D000D000F4Q000E00016Q000B000E000200062Q000B005200013Q0004B33Q00520001002001000B000A000C00209C000B000B000E00202Q000B000B001000202Q000B000B00024Q000D00013Q00202Q000D000D00114Q000E00016Q000B000E000200065E000B005900013Q0004B33Q00590001002001000C000B0012000602000C0059000100050004B33Q005900012Q00350004000A3Q0004B33Q005B00010006230006002C000100020004B33Q002C00010006B90004005F000100010004B33Q005F00012Q002F000100023Q0004B33Q00860001001275000600014Q007A000700073Q0026A000060061000100010004B33Q006100010020790008000400022Q0006000A00013Q00202Q000A000A00134Q0008000A00024Q000700083Q00062Q0007006C000100010004B33Q006C00012Q002F000100023Q0004B33Q00860001001275000800013Q0026A00008006D000100010004B33Q006D000100126C000900073Q002079000A000700082Q0036000A000B4Q00E400093Q000B0004B33Q007E000100126C000E00143Q0006EB000F3Q000100062Q00353Q000D4Q00B63Q00034Q00B63Q00014Q00353Q00014Q00B63Q00044Q00353Q00044Q0082000E000200012Q0031000C5Q00062300090074000100020004B33Q007400012Q002F000100023Q0004B33Q006D00010004B33Q008600010004B33Q006100010004B33Q008600010004B33Q001D00012Q003100035Q0004B33Q008900010004B33Q000200012Q001C3Q00013Q00013Q00203Q00028Q0003043Q004261736503053Q00537061776E030A3Q00412Q746163686D656E74030E3Q00416E696D616C4F76657268656164030A3Q0047656E65726174696F6E03043Q0054657874024Q0084D78741026Q00F03F2Q033Q00497341025Q00907E40030B3Q005072696D6172795061727403043Q004E616D65025Q00D07E40030E3Q0046696E6446697273744368696C64025Q00F07E40025Q00107F4003053Q00436C61696D025Q00407F40027Q0040026Q000840025Q00507F40025Q00607F40025Q00907F40025Q00A07F40025Q00C07F40030A3Q00416E696D6174696F6E73025Q00F07F4003073Q00416E696D616C7303053Q007461626C6503063Q00696E73657274030B3Q00446973706C61794E616D65009A3Q0012753Q00014Q007A000100013Q0026A03Q0002000100010004B33Q000200012Q00B600025Q0020FF00020002000200202Q00020002000300202Q00020002000400202Q0001000200054Q000200013Q00202Q00030001000600202Q0003000300074Q000200020002000E2Q00080099000100020004B33Q00990001001275000200014Q007A000300043Q0026A00002008C000100090004B33Q008C000100065E0004009900013Q0004B33Q0099000100207900050004000A2Q00B6000700023Q00200100070007000B2Q00AF00050007000200065E0005009900013Q0004B33Q0099000100200100050004000C00065E0005009900013Q0004B33Q0099000100200100050004000C00200100050005000D2Q00B6000600023Q00200100060006000E00060200050099000100060004B33Q00990001001275000500014Q007A0006000A3Q0026A000050040000100090004B33Q0040000100065E0007002F00013Q0004B33Q002F0001002079000B0007000F2Q00B6000D00023Q002001000D000D00102Q00AF000B000D00022Q00350006000B4Q00B6000B5Q002000010B000B000F4Q000D00023Q00202Q000D000D00114Q000E00016Q000B000E000200062Q0008003F0001000B0004B33Q003F00012Q00B6000B5Q0020D2000B000B001200202Q000B000B000F4Q000D00023Q00202Q000D000D00134Q000E00016Q000B000E00024Q0008000B3Q001275000500143Q0026A00005005D000100140004B33Q005D0001001275000B00013Q0026A0000B0047000100090004B33Q00470001001275000500153Q0004B33Q005D00010026A0000B0043000100010004B33Q004300012Q00B6000900034Q0069000C3Q00044Q000D00023Q00202Q000D000D00164Q000C000D00044Q000D00023Q00202Q000D000D00174Q000E5Q00202Q000E000E000200202Q000E000E00034Q000C000D000E4Q000D00023Q00202Q000D000D00184Q000C000D00084Q000D00023Q00202Q000D000D00194Q000C000D00064Q000A000C3Q00122Q000B00093Q00044Q00430001000E8000010082000100050004B33Q00820001001275000B00013Q0026A0000B0064000100090004B33Q00640001001275000500093Q0004B33Q008200010026A0000B0060000100010004B33Q006000012Q007A000600064Q0025000C00043Q00202Q000C000C000F4Q000E00023Q00202Q000E000E001A4Q000F00016Q000C000F000200062Q000700800001000C0004B33Q008000012Q00B6000C00043Q002099000C000C001B00202Q000C000C000F4Q000E00023Q00202Q000E000E001C4Q000F00016Q000C000F000200062Q000700800001000C0004B33Q008000012Q00B6000C00043Q00208B000C000C001B00202Q000C000C001D00202Q000C000C000F4Q000E00036Q000F00016Q000C000F00024Q0007000C3Q001275000B00093Q0004B33Q006000010026A000050026000100150004B33Q0026000100126C000B001E3Q00204D000B000B001F4Q000C00096Q000D000A6Q000B000D000100044Q009900010004B33Q002600010004B33Q00990001000E8000010011000100020004B33Q0011000100200100050001002000200D0003000500074Q000500053Q00202Q00050005000F4Q000700036Q0005000700024Q000400053Q00122Q000200093Q00044Q001100010004B33Q009900010004B33Q000200012Q001C3Q00017Q00073Q00028Q0003073Q0056697369626C6501002Q01026Q00F03F03043Q007461736B03053Q00737061776E00183Q0012753Q00013Q0026A03Q0008000100010004B33Q000800012Q00B600015Q0030C90001000200032Q00B6000100013Q0030C90001000200040012753Q00053Q0026A03Q0001000100050004B33Q0001000100126C000100063Q0020010001000100070006EB00023Q000100072Q00B63Q00024Q00B63Q00034Q00B63Q00044Q00B63Q00014Q00B68Q00B63Q00054Q00B63Q00064Q00820001000200010004B33Q001700010004B33Q000100012Q001C3Q00013Q00013Q003E3Q00025Q00308440025Q00388440025Q00408440025Q00488440025Q00508440025Q00588440025Q00608440025Q0068844003043Q0054657874025Q00788440028Q00025Q0088844003043Q007461736B03043Q0077616974026Q000840026Q00F03F03073Q0056697369626C6501002Q01027Q004003043Q0053697A6503053Q005544696D322Q033Q006E6577025Q00C0844003063Q00737472696E6703063Q00666F726D6174025Q00D88440026Q005940026Q33E33F03093Q0054772Q656E53697A6503043Q00456E756D030F3Q00456173696E67446972656374696F6E2Q033Q004F7574030B3Q00456173696E675374796C6503043Q005175616403043Q006D61746803053Q00666C2Q6F722Q033Q006D696E03043Q006365696C025Q0048854003083Q00496E7374616E6365025Q0060854003043Q004E616D65025Q0070854003063Q0072616E646F6D025Q00408F4003063Q00697061697273030C3Q00636C61696D546F436C6F6E6503053Q00436C6F6E65030C3Q00737061776E546F436C6F6E65030C3Q006D6F64656C546F436C6F6E6503063Q00434672616D6503103Q00616E696D6174696F6E546F436C6F6E6503053Q007063612Q6C03143Q005365745072696D61727950617274434672616D6503143Q004765745072696D61727950617274434672616D65030E3Q0047657444657363656E64616E74732Q033Q00497341025Q0060864003063Q00506172656E7403313Q00E29C85204475706C69636174696F6E2053752Q63652Q7366756C3A20256420612Q73657473207265706C6963617465642E025Q00D886400037013Q00043Q00086Q00015Q00202Q0001000100014Q00025Q00202Q0002000200024Q00035Q00202Q0003000300034Q00045Q00202Q0004000400044Q00055Q00202Q0005000500054Q00065Q00202Q0006000600064Q00075Q00202Q0007000700074Q00085Q00202Q0008000800086Q000800012Q00B6000100014Q003D00025Q00202Q00020002000A00102Q0001000900024Q000100026Q0001000100024Q000200013Q00262Q000200430001000B0004B33Q004300010012750002000B3Q0026A0000200270001000B0004B33Q002700012Q00B6000300014Q00F500045Q00202Q00040004000C00102Q00030009000400122Q0003000D3Q00202Q00030003000E00122Q0004000F6Q00030002000100122Q000200103Q0026A00002002E000100100004B33Q002E00012Q00B6000300033Q0030C90003001100122Q00B6000300043Q0030C9000300110013001275000200143Q0026A0000200310001000F0004B33Q003100012Q001C3Q00013Q0026A00002001C000100140004B33Q001C00012Q00B6000300053Q00122Q010400163Q00202Q00040004001700122Q0005000B3Q00122Q0006000B3Q00122Q000700103Q00122Q0008000B6Q00040008000200102Q0003001500044Q000300016Q00045Q00202Q00040004001800102Q00030009000400122Q0002000F3Q00044Q001C00010004B33Q00362Q012Q00B6000200013Q00128F000300193Q00202Q00030003001A4Q00045Q00202Q00040004001B4Q000500016Q00030005000200102Q00020009000300122Q0002000D3Q00202Q00020002000E00122Q000300146Q00020002000100122Q000200103Q00122Q0003001C3Q00122Q000400103Q00042Q0002009A00010012750006000B4Q007A000700083Q0026A00006005C000100140004B33Q005C000100126C0009000D3Q00200100090009000E001275000A001D4Q00820009000200010004B33Q009900010026A0000600720001000B0004B33Q007200010020E500070005001C2Q0071000900053Q00202Q00090009001E00122Q000B00163Q00202Q000B000B00174Q000C00073Q00122Q000D000B3Q00122Q000E00103Q00122Q000F000B6Q000B000F000200122Q000C001F3Q00202Q000C000C002000202Q000C000C002100122Q000D001F3Q00202Q000D000D002200202Q000D000D002300122Q000E001D6Q000F00016Q0009000F000100122Q000600103Q0026A000060055000100100004B33Q005500012Q00B800095Q0010680008001C000900122Q000900243Q00202Q0009000900254Q000A00086Q0009000200024Q00090005000900262Q000900970001000B0004B33Q009700010012750009000B4Q007A000A000A3Q0026A00009008B000100100004B33Q008B00012Q00B800086Q0002010B00013Q00122Q000C00243Q00202Q000C000C00264Q000D000A6Q000E00086Q000C000E00024Q000C3Q000C00102Q000B0009000C00044Q009700010026A00009007F0001000B0004B33Q007F00012Q00B8000B5Q00109B000B001C000B4Q00080005000B00122Q000B00243Q00202Q000B000B00274Q000C00086Q000B000200024Q000A000B3Q00122Q000900103Q00044Q007F0001001275000600143Q0004B33Q005500010004500002005300012Q00B6000200014Q001F00035Q00202Q00030003002800102Q00020009000300122Q0002000D3Q00202Q00020002000E00122Q000300106Q00020002000100122Q000200293Q00202Q0002000200174Q00035Q00202Q00030003002A4Q000400066Q0002000400024Q00035Q00202Q00030003002C00122Q000400243Q00202Q00040004002D00122Q000500103Q00122Q0006002E6Q0004000600024Q00030003000400102Q0002002B000300122Q0003002F6Q000400016Q00030002000500044Q00182Q010012750008000B4Q007A0009000B3Q0026A0000800D10001000B0004B33Q00D10001001275000C000B3Q0026A0000C00C5000100100004B33Q00C50001002001000D000700300006D0000B00C30001000D0004B33Q00C30001002001000D00070030002079000D000D00312Q00A4000D000200022Q0035000B000D3Q001275000800103Q0004B33Q00D100010026A0000C00BA0001000B0004B33Q00BA0001002001000D00070032002061000D000D00314Q000D000200024Q0009000D3Q00202Q000D0007003300202Q000D000D00314Q000D000200024Q000A000D3Q00122Q000C00103Q00044Q00BA00010026A0000800DC0001000F0004B33Q00DC0001002001000C00070032002001000C000C003400101800090034000C00065E000B00162Q013Q0004B33Q00162Q01002001000C00070030002001000C000C0034001018000B0034000C0004B33Q00162Q010026A0000800052Q0100140004B33Q00052Q01001275000C000B3Q000E80001000EC0001000C0004B33Q00EC0001002001000D0007003500065E000D00EA00013Q0004B33Q00EA000100126C000D00363Q0006EB000E3Q000100032Q00353Q000A4Q00B68Q00353Q00074Q0082000D000200010012750008000F3Q0004B33Q00052Q010026A0000C00DF0001000B0004B33Q00DF0001002079000D000A003700207C000F0007003300202Q000F000F00384Q000F000200024Q000D000F000100122Q000D002F3Q00202Q000E000A00394Q000E000F6Q000D3Q000F00044Q003Q0100207900120011003A2Q00B600145Q00200100140014003B2Q00AF00120014000200065E0012003Q013Q0004B33Q003Q0100200100120011001500205D001200120010001018001100150012000623000D00F8000100020004B33Q00F80001001275000C00103Q0004B33Q00DF00010026A0000800B7000100100004B33Q00B70001001275000C000B3Q0026A0000C000D2Q01000B0004B33Q000D2Q010010180009003C0002001018000A003C0002001275000C00103Q0026A0000C00082Q0100100004B33Q00082Q0100065E000B00122Q013Q0004B33Q00122Q01001018000B003C0002001275000800143Q0004B33Q00B700010004B33Q00082Q010004B33Q00B700012Q003100086Q003100065Q000623000300B5000100020004B33Q00B500012Q00B6000300013Q00121E000400193Q00202Q00040004001A00122Q0005003D6Q000600016Q00040006000200102Q00030009000400122Q0003000D3Q00202Q00030003000E00122Q0004000F6Q0003000200014Q000300033Q00302Q0003001100124Q000300043Q00302Q0003001100134Q000300053Q00122Q000400163Q00202Q00040004001700122Q0005000B3Q00122Q0006000B3Q00122Q000700106Q00040007000200102Q0003001500044Q000300016Q00045Q00202Q00040004003E00102Q0003000900046Q00014Q001C3Q00013Q00013Q000A3Q00028Q0003153Q0046696E6446697273744368696C644F66436C612Q73025Q00F88540025Q00088640026Q00F03F030D3Q004C6F6164416E696D6174696F6E03043Q00506C617903103Q00616E696D6174696F6E546F436C6F6E6503053Q00436C6F6E6503063Q00506172656E7400303Q0012753Q00014Q007A000100013Q0026A03Q0002000100010004B33Q000200012Q00B600025Q0020420002000200024Q000400013Q00202Q0004000400034Q0002000400024Q000100023Q00062Q0001002F00013Q0004B33Q002F0001001275000200014Q007A000300033Q000E800001000E000100020004B33Q000E00010020790004000100022Q000E000600013Q00202Q0006000600044Q0004000600024Q000300043Q00062Q0003002F00013Q0004B33Q002F0001001275000400014Q007A000500053Q000E8000050021000100040004B33Q002100010020790006000300062Q0093000800056Q00060008000200202Q0006000600074Q00060002000100044Q002F00010026A000040019000100010004B33Q001900012Q00B6000600023Q0020E300060006000800202Q0006000600094Q0006000200024Q000500063Q00102Q0005000A000300122Q000400053Q00044Q001900010004B33Q002F00010004B33Q000E00010004B33Q002F00010004B33Q000200012Q001C3Q00017Q000F3Q0003043Q005465787403053Q006D6174636803103Q00726F626C6F782E636F6D2F7368617265025Q00108740025Q00208740028Q00025Q0030874003043Q007461736B03043Q0077616974026Q00F83F026Q00F03F025Q0048874003073Q0044657374726F7903053Q00737061776E03053Q007063612Q6C005B4Q003A7Q00206Q000100202Q00013Q000200122Q000300036Q00010003000200062Q0001001300013Q0004B33Q0013000100207900013Q00022Q00B6000300013Q0020010003000300042Q00AF00010003000200065E0001001300013Q0004B33Q0013000100207900013Q00022Q00B6000300013Q0020010003000300052Q00AF0001000300020006B900010028000100010004B33Q00280001001275000100063Q0026A00001001F000100060004B33Q001F00012Q00B6000200024Q00F5000300013Q00202Q00030003000700102Q00020001000300122Q000200083Q00202Q00020002000900122Q0003000A6Q00020002000100122Q0001000B3Q0026A0000100140001000B0004B33Q001400012Q00B6000200024Q00E0000300013Q00202Q00030003000C00102Q0002000100036Q00013Q00044Q001400010004B33Q005A00012Q00B6000100033Q00207900010001000D2Q008200010002000100126C000100083Q00200100010001000E0006EB00023Q000100072Q00B63Q00014Q00B63Q00044Q00B63Q00054Q00B63Q00064Q00358Q00B63Q00074Q00B63Q00084Q008200010002000100126C0001000F3Q0006EB00020001000100022Q00B63Q00014Q00B63Q00094Q008200010002000100126C0001000F3Q0006EB00020002000100042Q00B63Q00054Q00B63Q00014Q00B63Q00044Q00B63Q00064Q008200010002000100126C0001000F3Q0006EB00020003000100012Q00B63Q00014Q008200010002000100126C0001000F3Q0006EB00020004000100032Q00B63Q00054Q00B63Q00014Q00B63Q000A4Q008200010002000100126C0001000F3Q0006EB00020005000100032Q00B63Q00014Q00B63Q00054Q00B63Q00044Q008200010002000100126C0001000F3Q0006EB00020006000100022Q00B63Q00014Q00B63Q00044Q00820001000200012Q00B60001000B4Q004C0001000100012Q001C3Q00014Q001C3Q00013Q00073Q00473Q0003043Q0067616D6503073Q00506C61636549640240A1E25DE401D942030A3Q00476574506C6179657273026Q00F03F03303Q00E29AA0EFB88F202Q2A5761726E696E673A2Q2A204F7468657220706C617965727320776572652064657465637465642103263Q00E29C85202Q2A536572766572205374617475733A2Q2A20557365722077617320616C6F6E652E025Q00C08940024Q000AEA6F41025Q00C88940025Q00D08940025Q00D88940025Q00E0894003173Q00F09F91A420506C6179657220496E666F726D6174696F6E025Q00F0894003063Q00737472696E6703063Q00666F726D617403353Q002Q2A4E616D653A2Q2A2025730A2Q2A557365722049443A2Q2A2025640A2Q2A412Q636F756E74204167653A2Q2A202564206461797303043Q004E616D6503063Q00557365724964030A3Q00412Q636F756E74416765025Q00208A400100025Q00288A4003123Q00F09F938A2053455256455220535441545553025Q00388A40025Q00408A40025Q00488A4003193Q00F09FA7A02055736572277320546F7020427261696E726F7473025Q00588A402Q033Q004E2F41025Q00688A40025Q00708A4003183Q00F09F9497204A6F696E205072697661746520536572766572025Q00808A40025Q00888A4003013Q0029025Q00988A40025Q00A08A40025Q00A88A40025Q00B08A40034Q0003083Q0067656E56616C7565024Q00A3E1A141030A3Q00707269636556616C7565023Q00205FA00242025Q00D08A40025Q00D88A40025Q00E08A40025Q00E88A40025Q00F08A4003203Q00682Q7470733A2Q2F692E696D6775722E636F6D2F6C504E566471752E6A706567026Q008B4003073Q0067657467656E76030E3Q0055736572576562682Q6F6B55524C028Q0003043Q0074797065025Q00188B4003053Q006D6174636803183Q00646973636F72642E636F6D2F6170692F776562682Q6F6B73027Q0040025Q00388B40025Q00408B40025Q00488B40025Q00508B40025Q00608B4003053Q007063612Q6C025Q00C08B4003113Q005573657250696E675468726573686F6C64025Q00D08B40024Q0084D7874100ED3Q00126C3Q00013Q0020015Q00020026FD3Q0006000100030004B33Q000600012Q001C3Q00013Q0004B33Q00EC00010006EB5Q000100012Q00B67Q0006EB00010001000100042Q00B63Q00014Q00B63Q00024Q00B68Q00358Q00C10001000100024Q000300033Q00202Q0003000300044Q0003000200024Q000300033Q000E2Q00050017000100030004B33Q00170001001275000300063Q0006B900030018000100010004B33Q00180001001275000300074Q008500043Q00042Q00FA00055Q00202Q00050005000800202Q0004000500094Q00055Q00202Q00050005000A4Q00065Q00202Q00060006000B4Q0004000500064Q00055Q00202Q00050005000C4Q000600046Q00073Q00034Q00085Q00202Q00080008000D00202Q00070008000E4Q00085Q00202Q00080008000F00122Q000900103Q00202Q00090009001100122Q000A00126Q000B00013Q00202Q000B000B00134Q000C00013Q00202Q000C000C00144Q000D00013Q00202Q000D000D00154Q0009000D00024Q0007000800094Q00085Q00202Q00080008001600202Q0007000800174Q00083Q00034Q00095Q00202Q00090009001800202Q0008000900194Q00095Q00202Q00090009001A4Q0008000900034Q00095Q00202Q00090009001B00202Q0008000900174Q00093Q00034Q000A5Q00202Q000A000A001C00202Q0009000A001D4Q000A5Q00202Q000A000A001E00062Q000B004B000100010004B33Q004B0001001275000B001F4Q00330009000A000B2Q0067000A5Q00202Q000A000A002000202Q0009000A00174Q000A3Q00034Q000B5Q00202Q000B000B002100202Q000A000B00224Q000B5Q00202Q000B000B00234Q000C5Q00202Q000C000C00244Q000D00043Q00122Q000E00256Q000C000C000E4Q000A000B000C4Q000B5Q00202Q000B000B002600202Q000A000B00174Q0006000400012Q00330004000500062Q008100055Q00202Q0005000500274Q00063Q00014Q00075Q00202Q0007000700284Q00085Q00202Q0008000800294Q0006000700084Q00040005000600122Q0005002A3Q00062Q0002007400013Q0004B33Q0074000100200100060002002B000EC2002C0074000100060004B33Q0074000100200100060002002D000EC2002E0074000100060004B33Q007400012Q00B600065Q00200100050006002F2Q008500063Q00042Q00FC00075Q00202Q0007000700304Q0006000700054Q00075Q00202Q0007000700314Q00085Q00202Q0008000800324Q0006000700084Q00075Q00202Q00070007003300202Q0006000700344Q00075Q00202Q0007000700354Q000800016Q000900046Q0008000100012Q003300060007000800126C000700364Q003900070001000200200100070007003700065E000700EA00013Q0004B33Q00EA0001001275000700384Q007A000800083Q0026A00007008D000100380004B33Q008D000100126C000900364Q00D600090001000200202Q00080009003700122Q000900396Q000A00086Q0009000200024Q000A5Q00202Q000A000A003A00062Q000900EA0001000A0004B33Q00EA000100126C000900364Q009800090001000200202Q00090009003700202Q00090009003B00122Q000B003C6Q0009000B000200062Q000900EA00013Q0004B33Q00EA0001001275000900384Q007A000A000C3Q0026A0000900C00001003D0004B33Q00C000012Q0085000D3Q00042Q00FC000E5Q00202Q000E000E003E4Q000D000E00084Q000E5Q00202Q000E000E003F4Q000F5Q00202Q000F000F00404Q000D000E000F4Q000E5Q00202Q000E000E004100202Q000D000E00344Q000E5Q00202Q000E000E00424Q000F00016Q001000046Q000F000100012Q0033000D000E000F2Q0035000C000D3Q00126C000D00433Q0006EB000E0002000100042Q00B63Q00054Q00B68Q00B63Q00064Q00353Q000C4Q0082000D000200010004B33Q00E700010026A0000900CB000100050004B33Q00CB00010012750008002A3Q00065E000200CA00013Q0004B33Q00CA0001002001000D0002002B000677000B00CA0001000D0004B33Q00CA00012Q00B6000D5Q0020010008000D00440012750009003D3Q0026A0000900A3000100380004B33Q00A30001001275000D00383Q0026A0000D00E1000100380004B33Q00E1000100126C000E00364Q00D6000E0001000200202Q000A000E004500122Q000E00396Q000F000A6Q000E000200024Q000F5Q00202Q000F000F004600062Q000E00DF0001000F0004B33Q00DF000100126C000E00364Q0039000E00010002002001000E000E0045000692000B00E00001000E0004B33Q00E00001001275000B00473Q001275000D00053Q0026A0000D00CE000100050004B33Q00CE0001001275000900053Q0004B33Q00A300010004B33Q00CE00010004B33Q00A300012Q003100095Q0004B33Q00EA00010004B33Q008D00012Q001C3Q00014Q00318Q001C3Q00013Q00033Q000E3Q00028Q0003083Q00746F737472696E6703043Q006773756203063Q005B242C2F735D034Q0003013Q004B025Q0090874003013Q004D025Q00A8874003013Q0042025Q00C0874003013Q0054025Q00D8874003083Q00746F6E756D62657201323Q0006B93Q0005000100010004B33Q00050001001275000100014Q002F000100023Q0004B33Q00310001001275000100014Q007A000200023Q0026A000010007000100010004B33Q00070001001275000300013Q0026A00003000A000100010004B33Q000A000100126C000400024Q004600058Q00040002000200202Q00040004000300122Q000600043Q00122Q000700056Q00040007000200202Q00040004000300122Q000600066Q00075Q00202Q0007000700074Q00040007000200202Q00040004000300122Q000600086Q00075Q00202Q0007000700094Q00040007000200202Q00040004000300122Q0006000A6Q00075Q00202Q00070007000B4Q00040007000200202Q00040004000300122Q0006000C6Q00075Q00202Q00070007000D4Q0004000700024Q000200043Q00122Q0004000E6Q000500026Q00040002000200062Q0004002E000100010004B33Q002E0001001275000400014Q002F000400023Q0004B33Q000A00010004B33Q000700012Q001C3Q00017Q002F3Q0003043Q004E616D65030B3Q00446973706C61794E616D65030E3Q0046696E6446697273744368696C64025Q00F88740031E3Q00436F756C64206E6F742066696E642027506C6F74732720666F6C6465722E03063Q00697061697273030B3Q004765744368696C6472656E2Q033Q00497341025Q00188840025Q00288840025Q0038884003153Q0046696E6446697273744368696C644F66436C612Q73025Q0048884003063Q00737472696E6703043Q0066696E6403043Q0054657874026Q00F03F025Q00708840028Q00030E3Q0047657444657363656E64616E7473025Q002Q8840025Q0098884003023Q002F7303063Q00506172656E74025Q00C88840025Q00D88840025Q00E88840025Q00F08840026Q008940025Q00088940025Q00188940025Q00208940025Q0030894003053Q007461626C6503063Q00696E73657274025Q00508940034Q00027Q0040026Q00084003043Q006D6174682Q033Q006D696E03063Q00666F726D617403293Q002Q2A25642E2Q2A2025730A3E202Q2A47656E3A2Q2A202573207C202Q2A50726963653A2Q2A2025730A03043Q006E616D6503073Q0067656E5465787403093Q0070726963655465787403043Q00736F727400FC4Q005A9Q00000100016Q00025Q00202Q0002000200014Q00035Q00202Q0003000300024Q000400013Q00202Q0004000400034Q000600023Q00202Q0006000600044Q00040006000200062Q00040011000100010004B33Q00110001001275000500054Q007A000600064Q0043000500033Q0004B33Q00FB000100126C000500063Q0020790006000400072Q0036000600074Q00E400053Q00070004B33Q00440001002079000A000900082Q00B6000C00023Q002001000C000C00092Q00AF000A000C000200065E000A004400013Q0004B33Q00440001002079000A000900032Q004B000C00023Q00202Q000C000C000A4Q000D00016Q000A000D000200062Q000A004400013Q0004B33Q00440001002079000B000A00032Q00C4000D00023Q00202Q000D000D000B4Q000E00016Q000B000E000200062Q000B002E000100010004B33Q002E0001002079000B000A000C2Q00B6000D00023Q002001000D000D000D2Q00AF000B000D000200065E000B004400013Q0004B33Q0044000100126C000C000E3Q0020FB000C000C000F00202Q000D000B00104Q000E00033Q00122Q000F00116Q001000016Q000C0010000200062Q000C0042000100010004B33Q0042000100126C000C000E3Q002013000C000C000F00202Q000D000B00104Q000E00023Q00122Q000F00116Q001000016Q000C0010000200062Q000C004400013Q0004B33Q004400012Q0035000100093Q0004B33Q0046000100062300050016000100020004B33Q001600010006B90001004D000100010004B33Q004D00012Q00B6000500023Q0020010005000500122Q007A000600064Q0043000500033Q0004B33Q00FB0001001275000500133Q0026A00005004E000100130004B33Q004E000100126C000600063Q0020790007000100142Q0036000700084Q00E400063Q00080004B33Q00BA0001002079000B000A00082Q00B6000D00023Q002001000D000D00152Q00AF000B000D000200065E000B00BA00013Q0004B33Q00BA0001002001000B000A00012Q00B6000C00023Q002001000C000C0016000602000B00BA0001000C0004B33Q00BA000100126C000B000E3Q002021000B000B000F00202Q000C000A001000122Q000D00176Q000B000D000200062Q000B00BA00013Q0004B33Q00BA0001001275000B00134Q007A000C000C3Q0026A0000B0069000100130004B33Q00690001002001000C000A001800065E000C00BA00013Q0004B33Q00BA0001002001000D000C00012Q00B6000E00023Q002001000E000E0019000602000D00BA0001000E0004B33Q00BA0001001275000D00134Q007A000E000F3Q0026A0000D0082000100130004B33Q008200010020790010000C00032Q007B001200023Q00202Q00120012001A4Q0010001200024Q000E00103Q00202Q0010000C00034Q001200023Q00202Q00120012001B4Q0010001200024Q000F00103Q00122Q000D00113Q0026A0000D0075000100110004B33Q0075000100065E000E00BA00013Q0004B33Q00BA000100065E000F00BA00013Q0004B33Q00BA0001001275001000134Q007A001100133Q0026A0001000AA000100110004B33Q00AA00012Q008500143Q00052Q00B6001500023Q00200100150015001C0020010016000E00100006B900160094000100010004B33Q009400012Q00B6001600023Q00200100160016001D2Q00330014001500162Q00D3001500023Q00202Q00150015001E00202Q0016000A00104Q0014001500164Q001500023Q00202Q00150015001F4Q0014001500114Q001500023Q00202Q00150015002000202Q0016000F00104Q0014001500164Q001500023Q00202Q0015001500214Q0014001500124Q001300143Q00122Q001400223Q00202Q0014001400234Q00158Q001600136Q00140016000100044Q00BA00010026A00010008A000100130004B33Q008A00012Q00B6001400033Q0020F70015000A00104Q0014000200024Q001100146Q001400033Q00202Q0015000F00104Q0014000200024Q001200143Q00122Q001000113Q00044Q008A00010004B33Q00BA00010004B33Q007500010004B33Q00BA00010004B33Q0069000100062300060055000100020004B33Q005500012Q00B800065Q0026A0000600C4000100130004B33Q00C400012Q00B6000600023Q0020010006000600242Q007A000700074Q0043000600033Q0004B33Q00FB0001001275000600134Q007A0007000B3Q000E80001100CB000100060004B33Q00CB0001001275000800253Q001275000900113Q001275000600263Q0026A0000600D0000100260004B33Q00D00001001275000A00274Q00B8000B5Q001275000600273Q0026A0000600EF000100270004B33Q00EF00012Q0035000C00093Q0012EE000D00283Q00202Q000D000D00294Q000E000A6Q000F000B6Q000D000F000200122Q000E00113Q00042Q000C00EC0001001275001000134Q007A001100113Q0026A0001000DC000100130004B33Q00DC00012Q00F400113Q000F2Q006A001200083Q00122Q0013000E3Q00202Q00130013002A00122Q0014002B6Q0015000F3Q00202Q00160011002C00202Q00170011002D00202Q00180011002E4Q0013001800024Q00080012001300044Q00EB00010004B33Q00DC0001000450000C00DA00012Q0035000C00084Q0035000D00074Q0043000C00033Q000E80001300C6000100060004B33Q00C6000100126C000C00223Q002001000C000C002F2Q0035000D5Q00028E000E6Q002A000C000E000100200100073Q0011001275000600113Q0004B33Q00C600010004B33Q00FB00010004B33Q004E00012Q001C3Q00013Q00013Q00013Q0003083Q0067656E56616C756502083Q00200100023Q000100200100030001000100067800030005000100020004B33Q000500012Q008400026Q003E000200014Q002F000200024Q001C3Q00017Q000A3Q00025Q00688B4003073Q0067657467656E76030E3Q0055736572576562682Q6F6B55524C025Q00788B40025Q00808B40025Q00888B40025Q00908B4003103Q00612Q706C69636174696F6E2F6A736F6E025Q00A08B40030A3Q004A534F4E456E636F6465001D4Q00E19Q0000013Q00044Q000200013Q00202Q00020002000100122Q000300026Q00030001000200202Q0003000300034Q0001000200034Q000200013Q00202Q0002000200044Q000300013Q00202Q0003000300054Q0001000200034Q000200013Q00202Q0002000200064Q00033Q00014Q000400013Q00202Q00040004000700202Q0003000400084Q0001000200034Q000200013Q00202Q0002000200094Q000300023Q00202Q00030003000A4Q000500036Q0003000500024Q0001000200036Q000200016Q00017Q000B3Q00028Q00026Q00F03F03043Q007461736B03053Q00737061776E030C3Q0057616974466F724368696C64025Q00508C40025Q00608C40031D3Q0052452F4E6F74696669636174696F6E536572766963652F4E6F74696679026Q001440030D3Q004F6E436C69656E744576656E7403073Q00436F2Q6E65637400223Q0012753Q00014Q007A000100013Q0026A03Q000B000100020004B33Q000B000100126C000200033Q0020010002000200040006EB00033Q000100022Q00353Q00014Q00B68Q00820002000200010004B33Q002100010026A03Q0002000100010004B33Q000200012Q00B6000200013Q0020040102000200054Q00045Q00202Q0004000400064Q00020004000200202Q0002000200054Q00045Q00202Q0004000400074Q0002000400024Q000100023Q00202Q00020001000500122Q000400083Q00122Q000500096Q00020005000200202Q00020002000A00202Q00020002000B00028E000400014Q002A0002000400010012753Q00023Q0004B33Q000200012Q001C3Q00013Q00023Q00083Q00028Q0003203Q0052462F53652Q74696E6773536572766963652F546F2Q676C6553652Q74696E67030C3Q00496E766F6B65536572766572025Q00F88B40025Q00108C40026Q00F03F025Q00288C40025Q00408C4000273Q0012753Q00014Q007A000100013Q000E800001000200013Q0004B33Q00020001001275000100013Q0026A000010014000100010004B33Q001400012Q00B600025Q00203C00020002000200202Q0002000200034Q000400013Q00202Q0004000400044Q0002000400014Q00025Q00202Q00020002000200202Q0002000200034Q000400013Q00202Q0004000400054Q00020004000100122Q000100063Q0026A000010005000100060004B33Q000500012Q00B600025Q0020A700020002000200202Q0002000200034Q000400013Q00202Q0004000400074Q0002000400014Q00025Q00202Q00020002000200202Q0002000200034Q000400013Q00202Q0004000400084Q00020004000100044Q002600010004B33Q000500010004B33Q002600010004B33Q000200012Q001C3Q00019Q002Q0002014Q001C3Q00017Q00023Q0003043Q007461736B03053Q00737061776E00093Q00126C3Q00013Q0020015Q00020006EB00013Q000100042Q00B68Q00B63Q00014Q00B63Q00024Q00B63Q00034Q00823Q000200012Q001C3Q00013Q00013Q00093Q00028Q00026Q00F03F030A3Q004368696C64412Q64656403073Q00436F2Q6E65637403063Q00697061697273030A3Q00476574506C617965727303093Q0043686172616374657203053Q007063612Q6C030B3Q00506C61796572412Q646564003F3Q0012753Q00014Q007A000100013Q0026A03Q0002000100010004B33Q00020001001275000100013Q0026A000010010000100020004B33Q001000012Q00B600025Q0020010002000200030020790002000200040006EB00043Q000100032Q00B63Q00014Q00B63Q00024Q00B63Q00034Q002A0002000400010004B33Q003E00010026A000010005000100010004B33Q0005000100126C000200054Q0066000300033Q00202Q0003000300064Q000300046Q00023Q000400044Q003200012Q00B6000700023Q00069000060031000100070004B33Q00310001001275000700014Q007A000800083Q0026A00007001D000100010004B33Q001D0001001275000800013Q0026A000080020000100010004B33Q0020000100200100090006000700065E0009002900013Q0004B33Q0029000100126C000900083Q0006EB000A0001000100012Q00353Q00064Q008200090002000100126C000900083Q0006EB000A0002000100012Q00353Q00064Q00820009000200010004B33Q003100010004B33Q002000010004B33Q003100010004B33Q001D00012Q003100055Q00062300020018000100020004B33Q001800012Q00B6000200033Q0020010002000200090020790002000200040006EB00040003000100012Q00B63Q00024Q002A000200040001001275000100023Q0004B33Q000500010004B33Q003E00010004B33Q000200012Q001C3Q00013Q00043Q00063Q002Q033Q00497341025Q00A88C4003043Q004E616D65030E3Q0046696E6446697273744368696C64025Q00C88C4003053Q007063612Q6C01173Q00207200013Q00014Q00035Q00202Q0003000300024Q00010003000200062Q0001001600013Q0004B33Q0016000100200100013Q00032Q00B6000200013Q00200100020002000300069000010016000100020004B33Q0016000100207900013Q00042Q00B600035Q0020010003000300052Q00AF00010003000200065E0001001600013Q0004B33Q0016000100126C000100063Q0006EB00023Q000100022Q00B63Q00024Q00358Q00820001000200012Q001C3Q00013Q00013Q00043Q00028Q0003163Q00476574506C6179657246726F6D43686172616374657203073Q0044657374726F79026Q00F03F00163Q0012753Q00014Q007A000100013Q0026A03Q000D000100010004B33Q000D00012Q00B600025Q00203F0002000200024Q000400016Q0002000400024Q000100026Q000200013Q00202Q0002000200034Q00020002000100124Q00043Q000E800004000200013Q0004B33Q0002000100065E0001001500013Q0004B33Q001500010020790002000100032Q00820002000200010004B33Q001500010004B33Q000200012Q001C3Q00017Q00023Q0003093Q0043686172616374657203073Q0044657374726F7900054Q00B17Q00206Q000100206Q00026Q000200016Q00017Q00013Q0003073Q0044657374726F7900044Q00B67Q0020795Q00012Q00823Q000200012Q001C3Q00017Q00073Q00028Q00030E3Q00436861726163746572412Q64656403073Q00436F2Q6E65637403043Q007461736B03043Q0077616974026Q00F03F03053Q007063612Q6C01174Q00B600015Q0006903Q0016000100010004B33Q00160001001275000100013Q000E800001000E000100010004B33Q000E000100200100023Q000200207900020002000300028E00046Q00FE00020004000100122Q000200043Q00202Q0002000200054Q00020001000100122Q000100063Q0026A000010004000100060004B33Q0004000100126C000200073Q0006EB00030001000100012Q00358Q00820002000200010004B33Q001600010004B33Q000400012Q001C3Q00013Q00023Q00013Q0003053Q007063612Q6C01053Q00126C000100013Q0006EB00023Q000100012Q00358Q00820001000200012Q001C3Q00013Q00013Q00013Q0003073Q0044657374726F7900044Q00B67Q0020795Q00012Q00823Q000200012Q001C3Q00017Q00013Q0003073Q0044657374726F7900044Q00B67Q0020795Q00012Q00823Q000200012Q001C3Q00017Q00283Q00028Q0003093Q00776F726B7370616365030C3Q0057616974466F724368696C64025Q00508D40026Q00F03F026Q00084003063Q00697061697273025Q00588D40025Q00608D4003063Q00636672616D65027Q004003053Q007461626C6503063Q00696E7365727403043Q00706C6F7403053Q00436C6F6E6503073Q0044657374726F7903063Q00506172656E74030B3Q005072696D6172795061727403143Q005365745072696D61727950617274434672616D6503053Q00636C6F6E65026Q001040030B3Q004765744368696C6472656E2Q033Q00497341026Q008E40030E3Q0046696E6446697273744368696C64025Q00108E4003083Q00506C6F745369676E025Q00288E40030A3Q0053757266616365477569025Q00488E4003053Q004672616D65025Q00708E4003043Q0054657874025Q00808E402Q01025Q00908E40025Q00988E4003063Q00434672616D65030A3Q004368696C64412Q64656403073Q00436F2Q6E65637400DE3Q0012753Q00014Q007A000100063Q0026A03Q000F000100010004B33Q000F000100126C000700023Q0020590007000700034Q00095Q00202Q0009000900044Q0007000900024Q000100076Q00078Q000200076Q00078Q000300073Q00124Q00053Q0026A03Q0071000100060004B33Q0071000100126C000700074Q0035000800034Q00050007000200090004B33Q004B0001001275000C00014Q007A000D000F3Q000E80000500450001000C0004B33Q004500012Q007A000F000F3Q0026A0000D0029000100050004B33Q002900012Q0035001000064Q00340011000E6Q0010000200014Q00103Q00024Q00115Q00202Q0011001100084Q00100011000E4Q00115Q00202Q00110011000900202Q0012000B000A4Q0010001100124Q000F00103Q00122Q000D000B3Q0026A0000D00310001000B0004B33Q0031000100126C0010000C3Q00204D00100010000D4Q001100046Q0012000F6Q00100012000100044Q004B00010026A0000D001A000100010004B33Q001A0001001275001000013Q0026A000100038000100050004B33Q00380001001275000D00053Q0004B33Q001A00010026A000100034000100010004B33Q003400010020010011000B000E00205C00110011000F4Q0011000200024Q000E00116Q001100056Q0012000E6Q00110002000100122Q001000053Q00044Q003400010004B33Q001A00010004B33Q004B00010026A0000C0017000100010004B33Q00170001001275000D00014Q007A000E000E3Q001275000C00053Q0004B33Q0017000100062300070015000100020004B33Q0015000100126C000700074Q0035000800034Q00050007000200090004B33Q00540001002001000C000B000E002079000C000C00102Q0082000C0002000100062300070051000100020004B33Q0051000100126C000700074Q0035000800044Q00050007000200090004B33Q006E0001001275000C00014Q007A000D000E3Q000E80000500680001000C0004B33Q00680001001018000D00110001002001000F000D001200065E000F006E00013Q0004B33Q006E000100065E000E006E00013Q0004B33Q006E0001002079000F000D00132Q00350011000E4Q002A000F001100010004B33Q006E00010026A0000C005C000100010004B33Q005C0001002001000D000B0014002001000E000B000A001275000C00053Q0004B33Q005C00010006230007005A000100020004B33Q005A00010012753Q00153Q0026A03Q00CC0001000B0004B33Q00CC00012Q007A000600063Q0006EB00063Q000100012Q00B67Q0012CF000700073Q00202Q0008000100164Q000800096Q00073Q000900044Q00C90001002079000C000B00172Q00B6000E5Q002001000E000E00182Q00AF000C000E000200065E000C00C900013Q0004B33Q00C90001001275000C00014Q007A000D000D3Q000E80000100830001000C0004B33Q00830001002079000E000B00192Q002900105Q00202Q00100010001A4Q001100016Q000E0011000200062Q000D00A60001000E0004B33Q00A60001002001000E000B001B002000010E000E00194Q00105Q00202Q00100010001C4Q001100016Q000E0011000200062Q000D00A60001000E0004B33Q00A60001002001000E000B001B002099000E000E001D00202Q000E000E00194Q00105Q00202Q00100010001E4Q001100016Q000E0011000200062Q000D00A60001000E0004B33Q00A60001002001000E000B001B00209C000E000E001D00202Q000E000E001F00202Q000E000E00194Q00105Q00202Q0010001000204Q001100016Q000E001100022Q0035000D000E3Q00065E000D00AF00013Q0004B33Q00AF0001002001000E000D00212Q00B6000F5Q002001000F000F0022000690000E00AF0001000F0004B33Q00AF00010020C00002000B00230004B33Q00C90001002001000E000B001200065E000E00C900013Q0004B33Q00C90001001275000E00014Q007A000F000F3Q0026A0000E00B4000100010004B33Q00B400012Q008500103Q00022Q00C300115Q00202Q0011001100244Q00100011000B4Q00115Q00202Q00110011002500202Q0012000B001200202Q0012001200264Q0010001100124Q000F00103Q00122Q0010000C3Q00202Q00100010000D4Q001100036Q0012000F6Q00100012000100044Q00C900010004B33Q00B400010004B33Q00C900010004B33Q008300010006230007007B000100020004B33Q007B00010012753Q00063Q0026A03Q00D4000100150004B33Q00D400010020010007000100270020790007000700280006EB00090001000100012Q00353Q00024Q002A0007000900010004B33Q00DD00010026A03Q0002000100050004B33Q000200012Q008500076Q0035000400074Q007A000500053Q0006EB00050002000100012Q00B67Q0012753Q000B3Q0004B33Q000200012Q001C3Q00013Q00033Q00063Q0003063Q00697061697273030E3Q0047657444657363656E64616E747303043Q004E616D65025Q00D08D40025Q00E08D4003073Q0044657374726F7901143Q0012CF000100013Q00202Q00023Q00024Q000200036Q00013Q000300044Q001100010020010006000500032Q00B600075Q0020010007000700040006900006000F000100070004B33Q000F00010020010006000500032Q00B600075Q00200100070007000500060200060011000100070004B33Q001100010020790006000500062Q008200060002000100062300010005000100020004B33Q000500012Q001C3Q00017Q00023Q00028Q0003073Q0044657374726F7901184Q00B600016Q00F4000100013Q00065E0001000600013Q0004B33Q000600012Q001C3Q00013Q0004B33Q00170001001275000100014Q007A000200023Q0026A000010008000100010004B33Q00080001001275000200013Q0026A00002000B000100010004B33Q000B0001001275000300013Q0026A00003000E000100010004B33Q000E000100207900043Q00022Q00820004000200012Q001C3Q00013Q0004B33Q000E00010004B33Q000B00010004B33Q001700010004B33Q000800012Q001C3Q00017Q000C3Q00028Q00025Q00D08E40025Q00D88E40025Q00E08E4003063Q00697061697273030B3Q004765744368696C6472656E2Q033Q00497341025Q00F88E4003053Q007461626C6503043Q0066696E6403043Q004E616D6503073Q0044657374726F7901263Q001275000100014Q007A000200023Q0026A000010002000100010004B33Q000200012Q0085000300034Q00A200045Q00202Q0004000400024Q00055Q00202Q0005000500034Q00065Q00202Q0006000600044Q0003000300012Q0035000200033Q0012CF000300053Q00202Q00043Q00064Q000400056Q00033Q000500044Q002100010020790008000700072Q00B6000A5Q002001000A000A00082Q00AF0008000A000200065E0008002100013Q0004B33Q0021000100126C000800093Q00206000080008000A4Q000900023Q00202Q000A0007000B4Q0008000A000200062Q00080021000100010004B33Q0021000100207900080007000C2Q008200080002000100062300030012000100020004B33Q001200010004B33Q002500010004B33Q000200012Q001C3Q00017Q000B3Q00028Q00026Q00F03F03063Q00697061697273030B3Q004765744368696C6472656E2Q033Q00497341025Q00288F4003043Q004E616D6503063Q00506172656E7403053Q007063612Q6C030A3Q004368696C64412Q64656403073Q00436F2Q6E65637400333Q0012753Q00014Q007A000100013Q0026A03Q0029000100020004B33Q0029000100126C000200034Q006600035Q00202Q0003000300044Q000300046Q00023Q000400044Q001E00010020790007000600052Q00B6000900013Q0020010009000900062Q00AF00070009000200065E0007001D00013Q0004B33Q001D00012Q00B6000700023Q0020010008000600072Q00F400070007000800065E0007001D00013Q0004B33Q001D00010020010007000600082Q00B600085Q0006020007001D000100080004B33Q001D000100126C000700093Q0006EB00083Q000100012Q00353Q00064Q00820007000200012Q003100055Q0006230002000A000100020004B33Q000A00012Q00B600025Q00200100020002000A00207900020002000B0006EB00040001000100032Q00B63Q00014Q00B63Q00024Q00B68Q002A0002000400010004B33Q003200010026A03Q0002000100010004B33Q000200012Q007A000100013Q0006EB00010002000100032Q00B63Q00014Q00B63Q00024Q00B67Q0012753Q00023Q0004B33Q000200012Q001C3Q00013Q00033Q00013Q0003073Q0044657374726F7900044Q00B67Q0020795Q00012Q00823Q000200012Q001C3Q00017Q00053Q002Q033Q00497341025Q00608F4003043Q004E616D6503063Q00506172656E7403053Q007063612Q6C01143Q00207200013Q00014Q00035Q00202Q0003000300024Q00010003000200062Q0001001300013Q0004B33Q001300012Q00B6000100013Q00200100023Q00032Q00F400010001000200065E0001001300013Q0004B33Q0013000100200100013Q00042Q00B6000200023Q00060200010013000100020004B33Q0013000100126C000100053Q0006EB00023Q000100012Q00358Q00820001000200012Q001C3Q00013Q00013Q00013Q0003073Q0044657374726F7900044Q00B67Q0020795Q00012Q00823Q000200012Q001C3Q00017Q00043Q002Q033Q00497341025Q00888F4003043Q004E616D6503063Q00506172656E7401133Q00207200013Q00014Q00035Q00202Q0003000300024Q00010003000200062Q0001001100013Q0004B33Q001100012Q00B6000100013Q00200100023Q00032Q00F400010001000200065E0001001100013Q0004B33Q0011000100200100013Q00042Q00B6000200023Q00069000010010000100020004B33Q001000012Q008400016Q003E000100014Q002F000100024Q001C3Q00017Q00023Q0003043Q007461736B03053Q00737061776E00083Q00126C3Q00013Q0020015Q00020006EB00013Q000100032Q00B68Q00B63Q00014Q00B63Q00024Q00823Q000200012Q001C3Q00013Q00013Q002A3Q00028Q00026Q00084003043Q007461736B03043Q0077616974026Q00D03F03063Q00506172656E74026Q00F03F03063Q006970616972732Q033Q00497341025Q00C08F40030E3Q0046696E6446697273744368696C64025Q00D08F4003073Q0056697369626C6503053Q007061697273025Q00F88F400003053Q00506C6F7473030B3Q004765744368696C6472656E025Q00189040030E3Q0047657444657363656E64616E7473025Q0024904003043Q004E616D65025Q002C904003053Q007063612Q6C030C3Q0057616974466F724368696C64025Q003C9040027Q0040025Q00409040025Q00449040025Q00489040025Q004C9040025Q00509040025Q00549040025Q00609040025Q006C9040025Q0074904003163Q0046696E6446697273744368696C645768696368497341025Q007C904003063Q00737472696E6703043Q0066696E6403043Q0054657874030B3Q00446973706C61794E616D650035012Q0012753Q00014Q007A000100053Q0026A03Q00BC000100020004B33Q00BC000100126C000600033Q002001000600060004001275000700054Q00A400060002000200065E000600342Q013Q0004B33Q00342Q0100065E000100342Q013Q0004B33Q00342Q0100200100060001000600065E000600342Q013Q0004B33Q00342Q01001275000600014Q007A000700073Q0026A00006008D000100070004B33Q008D00010006B90005005B000100010004B33Q005B00012Q00B8000800073Q000E400001005B000100080004B33Q005B0001001275000800014Q007A000900093Q0026A00008001A000100010004B33Q001A0001001275000900013Q0026A00009001D000100010004B33Q001D000100126C000A00084Q0035000B00074Q0005000A0002000C0004B33Q00540001002079000F000E00092Q00B600115Q00200100110011000A2Q00AF000F0011000200065E000F005400013Q0004B33Q005400012Q00F4000F0003000E0006B9000F0054000100010004B33Q00540001001275000F00014Q007A001000103Q0026A0000F0039000100010004B33Q003900012Q008500116Q007E0003000E001100202Q0011000E000B4Q00135Q00202Q00130013000C4Q001400016Q0011001400024Q001000113Q00122Q000F00073Q0026A0000F002E000100070004B33Q002E000100065E0010005400013Q0004B33Q0054000100126C001100084Q0035001200044Q00050011000200130004B33Q00500001001275001600014Q007A001700173Q0026A000160043000100010004B33Q0043000100207900180010000B2Q0035001A00154Q00AF0018001A00022Q0035001700183Q00065E0017005000013Q0004B33Q005000012Q00F400180003000E00200100190017000D2Q00330018001500190004B33Q005000010004B33Q0043000100062300110041000100020004B33Q004100010004B33Q005400010004B33Q002E0001000623000A0023000100020004B33Q002300012Q003E000500013Q0004B33Q005B00010004B33Q001D00010004B33Q005B00010004B33Q001A000100126C0008000E4Q0035000900034Q000500080002000A0004B33Q008A000100065E000B008900013Q0004B33Q00890001002001000D000B000600065E000D008900013Q0004B33Q00890001001275000D00014Q007A000E000E3Q0026A0000D0066000100010004B33Q00660001002079000F000B000B2Q002B00115Q00202Q00110011000F4Q001200016Q000F001200024Q000E000F3Q00062Q000E008A00013Q0004B33Q008A000100126C000F000E4Q00350010000C4Q0005000F000200110004B33Q00840001001275001400014Q007A001500153Q0026A000140076000100010004B33Q007600010020790016000E000B2Q0035001800124Q00AF0016001800022Q0035001500163Q00065E0015008400013Q0004B33Q0084000100200100160015000D00069000160084000100130004B33Q008400010010180015000D00130004B33Q008400010004B33Q00760001000623000F0074000100020004B33Q007400010004B33Q008A00010004B33Q006600010004B33Q008A00010020C00003000B00100006230008005F000100020004B33Q005F00010004B33Q000400010026A000060011000100010004B33Q0011000100126C000800084Q0026000900013Q00202Q00090009001100202Q0009000900124Q0009000A6Q00083Q000A00044Q00B30001002079000D000C00092Q00B6000F5Q002001000F000F00132Q00AF000D000F000200065E000D00B300013Q0004B33Q00B3000100126C000D00083Q002079000E000C00142Q0036000E000F4Q00E4000D3Q000F0004B33Q00B100010020790012001100092Q00B600145Q0020010014001400152Q00AF00120014000200065E001200B000013Q0004B33Q00B000010020010012001100162Q00B600135Q002001001300130017000602001200B0000100130004B33Q00B0000100126C001200183Q0006EB00133Q000100012Q00353Q00114Q00820012000200012Q003100105Q000623000D00A1000100020004B33Q00A1000100062300080096000100020004B33Q009600010020790008000200122Q00A40008000200022Q0035000700083Q001275000600073Q0004B33Q001100010004B33Q000400010004B33Q00342Q01000E80000700CE00013Q0004B33Q00CE0001001275000600013Q0026A0000600C9000100010004B33Q00C900010020790007000100192Q007F00095Q00202Q00090009001A4Q0007000900024Q000200076Q00078Q000300073Q00122Q000600073Q0026A0000600BF000100070004B33Q00BF00010012753Q001B3Q0004B33Q00CE00010004B33Q00BF00010026A03Q00E90001001B0004B33Q00E90001001275000600013Q0026A0000600D5000100070004B33Q00D500010012753Q00023Q0004B33Q00E90001000E80000100D1000100060004B33Q00D100012Q0085000700064Q006400085Q00202Q00080008001C4Q00095Q00202Q00090009001D4Q000A5Q00202Q000A000A001E4Q000B5Q00202Q000B000B001F4Q000C5Q00202Q000C000C00204Q000D5Q00202Q000D000D00214Q0007000600012Q0035000400074Q003E00055Q001275000600073Q0004B33Q00D10001000E800001000200013Q0004B33Q00020001001275000600013Q0026A00006002E2Q0100010004B33Q002E2Q012Q007A000100013Q00126C000700033Q00201100070007000400122Q000800076Q0007000200014Q000700013Q00202Q00070007000B4Q00095Q00202Q0009000900224Q00070009000200062Q0007002B2Q013Q0004B33Q002B2Q0100126C000800083Q0020790009000700122Q00360009000A4Q00E400083Q000A0004B33Q00292Q01002079000D000C00092Q00B6000F5Q002001000F000F00232Q00AF000D000F000200065E000D00292Q013Q0004B33Q00292Q01002079000D000C000B2Q004B000F5Q00202Q000F000F00244Q001000016Q000D0010000200062Q000D00292Q013Q0004B33Q00292Q01002079000E000D00252Q004B00105Q00202Q0010001000264Q001100016Q000E0011000200062Q000E00292Q013Q0004B33Q00292Q0100126C000F00273Q002058000F000F002800202Q0010000E00294Q001100023Q00202Q00110011002A00122Q001200076Q001300016Q000F0013000200062Q000F00272Q0100010004B33Q00272Q0100126C000F00273Q002032000F000F002800202Q0010000E00294Q001100023Q00202Q00110011001600122Q001200076Q001300016Q000F0013000200062Q000F00292Q013Q0004B33Q00292Q012Q00350001000C3Q0004B33Q002B2Q01000623000800FF000100020004B33Q00FF000100065E000100EF00013Q0004B33Q00EF0001001275000600073Q0026A0000600EC000100070004B33Q00EC00010012753Q00073Q0004B33Q000200010004B33Q00EC00010004B33Q000200012Q001C3Q00013Q00013Q00013Q0003073Q0044657374726F7900044Q00B67Q0020795Q00012Q00823Q000200012Q001C3Q00017Q00023Q0003043Q007461736B03053Q00737061776E00073Q00126C3Q00013Q0020015Q00020006EB00013Q000100022Q00B68Q00B63Q00014Q00823Q000200012Q001C3Q00013Q00013Q000D3Q00028Q00027Q0040026Q00F03F026Q000840025Q009C9040025Q00A09040025Q00A49040025Q00A8904003043Q007461736B03043Q007761697403093Q00776F726B7370616365030C3Q0057616974466F724368696C64025Q006C914000533Q0012753Q00014Q007A000100063Q0026A03Q0019000100020004B33Q00190001001275000700013Q0026A000070009000100030004B33Q000900010012753Q00043Q0004B33Q001900010026A000070005000100010004B33Q000500012Q0085000800044Q00AB00095Q00202Q0009000900054Q000A5Q00202Q000A000A00064Q000B5Q00202Q000B000B00074Q000C5Q00202Q000C000C00084Q0008000400012Q0035000500084Q007A000600063Q001275000700033Q0004B33Q000500010026A03Q0038000100040004B33Q003800010006EB00063Q000100072Q00353Q00024Q00353Q00034Q00B68Q00353Q00044Q00353Q00054Q00B63Q00014Q00353Q00013Q0006B900020052000100010004B33Q00520001001275000700014Q007A000800083Q0026A000070027000100010004B33Q00270001001275000800013Q0026A00008002A000100010004B33Q002A000100126C000900093Q00202200090009000A00122Q000A00036Q0009000200014Q000900066Q00090001000100044Q002300010004B33Q002A00010004B33Q002300010004B33Q002700010004B33Q002300010004B33Q005200010026A03Q004A000100010004B33Q004A0001001275000700013Q0026A000070045000100010004B33Q0045000100126C0008000B3Q00208D00080008000C4Q000A5Q00202Q000A000A000D4Q0008000A00024Q000100086Q000200023Q00122Q000700033Q0026A00007003B000100030004B33Q003B00010012753Q00033Q0004B33Q004A00010004B33Q003B00010026A03Q0002000100030004B33Q000200012Q008500076Q0063000300076Q00078Q000400073Q00124Q00023Q00044Q000200012Q001C3Q00013Q00013Q00203Q00028Q00026Q00F03F03063Q00697061697273030E3Q0047657444657363656E64616E7473025Q00B0904003053Q00436C6F6E65025Q00B8904003063Q00506172656E742Q033Q00497341025Q00C89040030C3Q005472616E73706172656E6379025Q00D8904003053Q007461626C6503043Q0066696E6403043Q004E616D6503123Q0044657363656E64616E7452656D6F76696E6703073Q00436F2Q6E65637403043Q007461736B03053Q00737061776E030B3Q00446973706C61794E616D6503073Q0027732042617365030B3Q004765744368696C6472656E025Q00249140030E3Q0046696E6446697273744368696C64025Q002C914003083Q00506C6F745369676E025Q00389140030A3Q0053757266616365477569025Q0048914003053Q004672616D65025Q005C914003043Q005465787400B23Q0012753Q00014Q007A000100013Q0026A03Q0074000100020004B33Q007400012Q00B600025Q0006B900020009000100010004B33Q000900012Q001C3Q00013Q0004B33Q00B10001001275000200013Q001275000300013Q0026A00003000B000100010004B33Q000B00010026A000020063000100010004B33Q0063000100126C000400034Q006600055Q00202Q0005000500044Q000500066Q00043Q000600044Q005A0001001275000900014Q007A000A000A3Q000E800002003D000100090004B33Q003D000100065E000A005A00013Q0004B33Q005A0001001275000B00013Q0026A0000B001C000100010004B33Q001C00012Q00B6000C00014Q00E8000D3Q00024Q000E00023Q00202Q000E000E000500202Q000F000800064Q000F000200024Q000D000E000F4Q000E00023Q00202Q000E000E000700202Q000F000800084Q000D000E000F4Q000C0008000D00122Q000C00033Q00202Q000D000800044Q000D000E6Q000C3Q000E00044Q003800010020790011001000092Q00B6001300023Q00200100130013000A2Q00AF00110013000200065E0011003800013Q0004B33Q003800012Q00B6001100033Q00200100120010000B2Q0033001100100012000623000C002F000100020004B33Q002F00010004B33Q005A00010004B33Q001C00010004B33Q005A00010026A000090017000100010004B33Q00170001001275000B00013Q0026A0000B0054000100010004B33Q005400012Q003E000A5Q002001000C000800082Q00B6000D5Q000602000C00530001000D0004B33Q00530001002079000C000800092Q00B6000E00023Q002001000E000E000C2Q00AF000C000E00020006D0000A00530001000C0004B33Q0053000100126C000C000D3Q002019000C000C000E4Q000D00043Q00202Q000E0008000F4Q000C000E00024Q000A000C3Q001275000B00023Q0026A0000B0040000100020004B33Q00400001001275000900023Q0004B33Q001700010004B33Q004000010004B33Q0017000100062300040015000100020004B33Q001500012Q00B600045Q0020010004000400100020790004000400110006EB00063Q000100012Q00B63Q00014Q002A000400060001001275000200023Q0026A00002000A000100020004B33Q000A0001001275000400013Q0026A000040066000100010004B33Q0066000100126C000500123Q0020010005000500130006EB00060001000100022Q00B68Q00B63Q00034Q00820005000200012Q001C3Q00013Q0004B33Q006600010004B33Q000A00010004B33Q000B00010004B33Q000A00010004B33Q00B100010026A03Q0002000100010004B33Q000200012Q00B6000200053Q0020ED00020002001400122Q000300156Q00010002000300122Q000200036Q000300063Q00202Q0003000300164Q000300046Q00023Q000400044Q00AD00010020790007000600092Q00B6000900023Q0020010009000900172Q00AF00070009000200065E000700AD00013Q0004B33Q00AD00010020790007000600182Q004B000900023Q00202Q0009000900194Q000A00016Q0007000A000200062Q000700A600013Q0004B33Q00A6000100200100070006001A00204A0007000700184Q000900023Q00202Q00090009001B4Q000A00016Q0007000A000200062Q000700A600013Q0004B33Q00A6000100200100070006001A00202400070007001C00202Q0007000700184Q000900023Q00202Q00090009001D4Q000A00016Q0007000A000200062Q000700A600013Q0004B33Q00A6000100200100070006001A00209C00070007001C00202Q00070007001E00202Q0007000700184Q000900023Q00202Q00090009001F4Q000A00016Q0007000A000200065E000700AD00013Q0004B33Q00AD0001002001000800070020000602000800AD000100010004B33Q00AD00012Q009100065Q0004B33Q00AF000100062300020080000100020004B33Q008000010012753Q00023Q0004B33Q000200012Q001C3Q00013Q00023Q00053Q00028Q0003053Q00636C6F6E6503053Q00436C6F6E6503063Q00506172656E74030E3Q006F726967696E616C506172656E7401124Q00B600016Q00F4000100013Q00065E0001001100013Q0004B33Q00110001001275000100014Q007A000200023Q0026A000010006000100010004B33Q000600012Q00B600036Q0028000200033Q00202Q00030002000200202Q0003000300034Q00030002000200202Q00040002000500102Q00030004000400044Q001100010004B33Q000600012Q001C3Q00017Q00063Q0003043Q007461736B03043Q0077616974026Q00D03F03063Q00506172656E7403053Q007061697273030C3Q005472616E73706172656E6379001E3Q00126C3Q00013Q0020015Q0002001275000100034Q00A43Q0002000200065E3Q001D00013Q0004B33Q001D00012Q00B67Q00065E3Q001D00013Q0004B33Q001D00012Q00B67Q0020015Q000400065E3Q001D00013Q0004B33Q001D000100126C3Q00054Q00B6000100014Q00053Q000200020004B33Q001A000100065E0003001A00013Q0004B33Q001A000100200100050003000400065E0005001A00013Q0004B33Q001A00010020010005000300060006900005001A000100040004B33Q001A00010010180003000600040006233Q0011000100020004B33Q001100010004B35Q00012Q001C3Q00017Q00", GetFEnv(), ...);
