#ifndef LJHEADER_H
#define LJHEADER_H

// the version of this driver.  Call GetVersion() to determine the version of the DLL you have.
// It should match this number, otherwise your .h and DLL's are from different versions.
#define DRIVER_VERSION 2.11

#define LJ_HANDLE long
#define LJ_ERROR long

#ifdef  __cplusplus
extern "C"
{
#endif 

LJ_ERROR _stdcall eGet(LJ_HANDLE Handle, long IOType, long Channel, double *pValue, double *Array);
LJ_ERROR _stdcall eGetS(LJ_HANDLE Handle, const char *pIOType, long Channel, double *pValue, long x1);
LJ_ERROR _stdcall eGetSS(LJ_HANDLE Handle, const char *pIOType, const char *pChannel, double *pValue, long x1);

#ifdef  __cplusplus
} // extern C
#endif
 
#endif

