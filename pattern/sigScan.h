#pragma once

#include <Windows.h>
#include <Tlhelp32.h>


class sigScan
{
public:
	sigScan(void);
	~sigScan(void);

	BYTE* bMask;
	char* szMask;

	DWORD dwProcess;
	HANDLE hProcess;

	DWORD dwFindEx();
	DWORD dwFind();

	DWORD dwAddress;
	DWORD dwLen;

	bool bSetLenByModuleSize(wchar_t* szModule);
	bool bSetLenByModuleSizeEx(wchar_t* szModule);

	bool bSetAddressByModule(wchar_t* szModule);
	bool bSetAddressByModuleEx(wchar_t* szModule);

	bool bSetProcessByName(wchar_t* szProcessName, bool bOpenProcess = true);

private:
	BYTE* bDumped;

	bool bDumpMem();
	bool bDataCompare(const BYTE* pData);

	DWORD dwGetModuleSize(wchar_t* szModule);
	DWORD dwGetModuleSizeEx(wchar_t* szModule);

	DWORD dwFindPatternEx();
	DWORD dwFindPattern();

	DWORD dwGetModuleBaseEx(wchar_t* szModuleName);
	DWORD dwGetModuleBase(wchar_t* szModuleName);

	DWORD dwGetProcessByName(wchar_t* szProcessName);
};
