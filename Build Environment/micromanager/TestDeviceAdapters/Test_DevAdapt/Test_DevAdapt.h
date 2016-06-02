///////////////////////////////////////////////////////////////////////////////
// FILE:          Test_DevAdapt.h
// PROJECT:       Micro-Manager
// SUBSYSTEM:     DeviceAdapters
//-----------------------------------------------------------------------------
// DESCRIPTION:   Minimal code for a Micro-Manager Device Adapter
//                
// AUTHOR:        Kyle Douglass, http://kmdouglass.github.io
//                
// COPYRIGHT:     ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
//                Laboratory of Experimental Biophysics (LEB), 2016
//

#ifndef _TEST_DEVADAPT_H_
#define _TEST_DEVADAPT_H_

#include "DeviceBase.h"

class Test_DevAdapt : public CGenericBase<Test_DevAdapt>  
{
public:
   Test_DevAdapt();
   ~Test_DevAdapt();
  
   // MMDevice API
   // ------------
   int Initialize();
   int Shutdown();
  
   void GetName(char* name) const;
   
   // This is necessary to implement the Device interface, but I don't know why.
   bool Busy() {return false;}; 
   
private:
	int meaningOfLife_;
	bool initialized_;
};

#endif //_TEST_DEVADAPT_H_
