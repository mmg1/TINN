-- SysInfo.lua

local ffi = require("ffi");

local SysInfo_ffi = require("SysInfo_ffi");
local k32Lib = ffi.load("kernel32");

--[[
if UNICODE then
GetComputerName  = k32Lib.GetComputerNameW;
SetComputerName  = k32Lib.SetComputerNameW;
GetComputerNameEx  = k32Lib.GetComputerNameExW;
SetComputerNameEx  = k32Lib.SetComputerNameExW;
DnsHostnameToComputerName  = k32Lib.DnsHostnameToComputerNameW;
else
GetComputerName  = k32Lib.GetComputerNameA;
SetComputerName  = k32Lib.SetComputerNameA;
GetComputerNameEx  = k32Lib.GetComputerNameExA;
SetComputerNameEx  = k32Lib.SetComputerNameExA;
DnsHostnameToComputerName  = k32Lib.DnsHostnameToComputerNameA;
end -- !UNICODE
--]]


local OSVERSIONINFO = ffi.typeof("OSVERSIONINFO")
local OSVERSIONINFO_mt = {
	__new = function(ct)
		local obj = ffi.new("OSVERSIONINFO")
		obj.dwOSVersionInfoSize = ffi.sizeof("OSVERSIONINFO");
		k32Lib.GetVersionExA(obj);

		return obj;
	end,

	__tostring = function(self)
		return string.format("%d.%d.%d", 
			self.dwMajorVersion, self.dwMinorVersion, self.dwBuildNumber);
	end,
}
OSVERSIONINFO = ffi.metatype(OSVERSIONINFO, OSVERSIONINFO_mt);


local GetSystemDirectory = function()
   local lpBuffer = ffi.new("char[?]", ffi.C.MAX_PATH+1);
    local buffSize = k32Lib.GetSystemDirectoryA(lpBuffer, ffi.C.MAX_PATH);
    
    if res == 0 then
        return false, k32Lib.GetLastError();
    end

    return ffi.string(lpBuffer, buffSize);
end


local GetSystemWindowsDirectory = function()
   local lpBuffer = ffi.new("char[?]", ffi.C.MAX_PATH+1);
    local buffSize = k32Lib.GetSystemWindowsDirectoryA(lpBuffer, ffi.C.MAX_PATH);
    
    if res == 0 then
        return false, k32Lib.GetLastError();
    end

    return ffi.string(lpBuffer, buffSize);
end


local systemDirectory = function()
    print(GetSystemDirectory());
end

local windowsDirectory = function()
    print(GetSystemWindowsDirectory());
end

return {
    OSVersionInfo = OSVERSIONINFO;

    getSystemDirectory = GetSystemDirectory;
    getSystemWindowsDirectory = GetSystemWindowsDirectory;

    systemDirectory = systemDirectory,
    windowsDirectory = windowsDirectory,
}

--[[
#ifdef UNICODE
#define GetSystemDirectory  GetSystemDirectoryW
#else
#define GetSystemDirectory  GetSystemDirectoryA
#endif // !UNICODE


#ifdef UNICODE
#define GetWindowsDirectory  GetWindowsDirectoryW
#else
#define GetWindowsDirectory  GetWindowsDirectoryA
#endif // !UNICODE


#ifdef UNICODE
#define GetSystemWindowsDirectory  GetSystemWindowsDirectoryW
#else
#define GetSystemWindowsDirectory  GetSystemWindowsDirectoryA
#endif // !UNICODE



#ifdef UNICODE
#define GetVersionEx  GetVersionExW
#else
#define GetVersionEx  GetVersionExA
#endif // !UNICODE
--]]

--[=[
-- Interesting, but no in the core API set
ffi.cdef[[
BOOL
GetComputerNameA (
    LPSTR lpBuffer,
    LPDWORD nSize
    );

BOOL
GetComputerNameW (
    LPWSTR lpBuffer,
    LPDWORD nSize
    );
]]


ffi.cdef[[
BOOL
SetComputerNameA (
    LPCSTR lpComputerName
    );
BOOL
SetComputerNameW (
    LPCWSTR lpComputerName
    );
]]

BOOL
WINAPI
SetSystemTime(
    __in CONST SYSTEMTIME *lpSystemTime
    );

ffi.cdef[[
BOOL
SetComputerNameExA (
    COMPUTER_NAME_FORMAT NameType,
    LPCSTR lpBuffer
    );
BOOL
SetComputerNameExW (
    COMPUTER_NAME_FORMAT NameType,
    LPCWSTR lpBuffer
    );
]]

ffi.cdef[[
BOOL
DnsHostnameToComputerNameA (
    LPCSTR Hostname,
    LPSTR ComputerName,
    LPDWORD nSize
    );

BOOL
DnsHostnameToComputerNameW (
    LPCWSTR Hostname,
    LPWSTR ComputerName,
    LPDWORD nSize
    );
]]


//
// Routines to convert back and forth between system time and file time
//

WINBASEAPI
BOOL
WINAPI
FileTimeToLocalFileTime(
    __in  CONST FILETIME *lpFileTime,
    __out LPFILETIME lpLocalFileTime
    );

WINBASEAPI
BOOL
WINAPI
LocalFileTimeToFileTime(
    __in  CONST FILETIME *lpLocalFileTime,
    __out LPFILETIME lpFileTime
    );



WINBASEAPI
LONG
WINAPI
CompareFileTime(
    __in CONST FILETIME *lpFileTime1,
    __in CONST FILETIME *lpFileTime2
    );

WINBASEAPI
BOOL
WINAPI
FileTimeToDosDateTime(
    __in  CONST FILETIME *lpFileTime,
    __out LPWORD lpFatDate,
    __out LPWORD lpFatTime
    );

WINBASEAPI
BOOL
WINAPI
DosDateTimeToFileTime(
    __in  WORD wFatDate,
    __in  WORD wFatTime,
    __out LPFILETIME lpFileTime
    );
--]=]
