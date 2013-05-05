-- test_OSModule.lua
--
-- References:
-- http://www.corsix.org/lua/reflect/api.html
--

local ffi = require("ffi");

local libraryloader = require("core_libraryloader_l1_1_1");
local errorhandling = require("core_errorhandling_l1_1_1");
local reflect = require("reflect");
local console = require("core_console");

ffi.cdef[[
typedef struct {
	void *	Handle;
} OSModuleHandle;
]]
local OSModuleHandle = ffi.typeof("OSModuleHandle");
local OSModuleHandle_mt = {
	__gc = function(self)
		print("GC: OSModuleHandle");
		local status = libraryloader.FreeLibrary(self.Handle);
	end,

	__index = {
		getProcAddress = function(self, procName)
			local addr = libraryloader.GetProcAddress(self.Handle, procName);
			return addr;
		end,

	},
}
ffi.metatype(OSModuleHandle, OSModuleHandle_mt);



local OSModule = {}
local OSModule_t = {};

OSModule_t.load = function(self, name, flags)
	flags = flags or 0
	local handle = libraryloader.LoadLibraryExA(name, nil, flags);
	if handle == nil then
		return false, errorhandling.GetLastError();
	end

	return OSModule(handle);
end

setmetatable(OSModule,{
	__call = function(self, ...)
		return self:new(...);
	end,

	__index = OSModule_t,

})

local printTable = function(tbl)
	for k,v in pairs(tbl) do
		print(k,v);
	end
end

--[[
	Metatable for instances of the OSModule 
--]]
local OSModule_mt = {
	__index = function(self, key)
		-- if it's something that can be found
		-- in our internal functions, then just
		-- return that
		if OSModule[key] then
			return OSModule[key];
		end

		-- Otherwise, try to find it as a function
		-- that is actually in the loaded module
		local ffitype = ffi.C[key];
		if not ffitype then
			return false, "function prototype not found"
		end

		-- could use reflect at this point to ensure it is
		-- actually a pointer to a function
		--local refct = reflect.typeof(ffitype);
		--if refct.what ~= "func" then
		--	return false, "not a function"
		--end

		-- turn the function information into a function pointer
		ffitype = ffi.typeof("$ *", ffitype);
		local castval = ffi.cast(ffitype, self.Handle:getProcAddress(key));
		
		return castval;
	end,
};


OSModule.new = function(self, handle)
	local obj = {
		Handle = OSModuleHandle(handle);
	};

	setmetatable(obj, OSModule_mt);

	return obj;
end




--[[
	Test cases


--]]
print("test_OSModule.lua - Test");

test_loadmodule = function()
	local kernel32, err = OSModule:load("kernel32");

	print(kernel32, err);


	local GetConsoleMode = kernel32.GetConsoleMode;

	print("GetConsoleMode", GetConsoleMode);

	local lpMode = ffi.new("DWORD[1]");
	local status = GetConsoleMode(nil, "lpMode");

	print("Status: ", status);
end

test_Signature = function()
ffi.cdef[[
typedef BOOL (* PFNGetConsoleMode)(HANDLE hConsoleHandle, LPDWORD lpMode);
]]

--	ffitype = ffi.typeof("PFNGetConsoleMode");
	ffitype = ffi.typeof("GetConsoleMode");
	local kernel32, err = OSModule:load("kernel32");

	print("ffitype: ", ffitype);
	local func = ffi.cast(ffitype, kernel32.GetConsoleMode);
	print("func: ", func);

	local lpMode = ffi.new("DWORD[1]");
	local status = func(nil, lpMode);
	print("Status: ", status);
	print("  Mode: ", lpMode[0]);
end

--test_Signature();
test_loadmodule();

