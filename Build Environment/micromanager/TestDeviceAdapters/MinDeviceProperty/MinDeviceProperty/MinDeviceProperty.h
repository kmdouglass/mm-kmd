///////////////////////////////////////////////////////////////////////////////
// FILE:          MinDeviceProperty.h
// PROJECT:       Micro-Manager
// SUBSYSTEM:     DeviceAdapters
//-----------------------------------------------------------------------------
// DESCRIPTION:   Minimal Micro-Manager Device Adapter with properties
//                
// AUTHOR:        Kyle Douglass, http://kmdouglass.github.io
//                
// COPYRIGHT:     ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
//                Laboratory of Experimental Biophysics (LEB), 2016
//

#pragma once
#ifndef _MINDEVICEPROPERTY_H_
#define _MINDEVICEPROPERTY_H_

#include "DeviceBase.h"

class MinDeviceProperty : public CGenericBase<MinDeviceProperty>  
{
// A minimal device adapter that allows one to set properties

public:
   MinDeviceProperty();
   ~MinDeviceProperty();
  
   // MMDevice API
   // ------------
   int Initialize();
   int Shutdown();

   void GetName(char* name) const;
   // Busy() is necessary to implement the Device interface, but I don't know why.
   bool Busy() {return false;}; 
  
   // Settable Properties
   // ------------
   int OnSwitchOnOff(MM::PropertyBase* pProp, MM::ActionType eAct);
   
private:
	bool initialized_;
	bool deviceOn_;

};

#endif // _MINDEVICEPROPERTY_H