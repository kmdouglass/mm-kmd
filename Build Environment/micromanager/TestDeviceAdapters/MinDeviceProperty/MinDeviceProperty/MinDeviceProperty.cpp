///////////////////////////////////////////////////////////////////////////////
// FILE:          MinDeviceProperty.cpp
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

#include "MinDeviceProperty.h"
#include "ModuleInterface.h"
#include <vector>

using namespace std;

const char* g_DeviceName = "MinDeviceProperty";

///////////////////////////////////////////////////////////////////////////////
// Exported MMDevice API
///////////////////////////////////////////////////////////////////////////////

/**
 * List all supported hardware devices here
 */
MODULE_API void InitializeModuleData()
{
   RegisterDevice(g_DeviceName, MM::GenericDevice, "Minimal Device with Properties");
}

MODULE_API MM::Device* CreateDevice(const char* deviceName)
{
   if (deviceName == 0)
      return 0;

   // decide which device class to create based on the deviceName parameter
   if (strcmp(deviceName, g_DeviceName) == 0)
   {
      // create the test device
      return new MinDeviceProperty();
   }

   // ...supplied name not recognized
   return 0;
}

MODULE_API void DeleteDevice(MM::Device* pDevice)
{
   delete pDevice;
}

///////////////////////////////////////////////////////////////////////////////
// MinDeviceProperty implementation
// ~~~~~~~~~~~~~~~~~~~~~~~

/**
* MinDeviceProperty constructor.
* Setup default all variables and create device properties required to exist
* before intialization. In this case, no such properties were required. All
* properties will be created in the Initialize() method.
*
* As a general guideline Micro-Manager devices do not access hardware in the
* the constructor. We should do as little as possible in the constructor and
* perform most of the initialization in the Initialize() method.
*/
MinDeviceProperty::MinDeviceProperty() :
   deviceOn_    (true),
   initialized_ (false)
{
   // call the base class method to set-up default error codes/messages
   InitializeDefaultErrorMessages();

}

/**
* MinDeviceProperty destructor.
* If this device used as intended within the Micro-Manager system,
* Shutdown() will be always called before the destructor. But in any case
* we need to make sure that all resources are properly released even if
* Shutdown() was not called.
*/
MinDeviceProperty::~MinDeviceProperty()
{
   if (initialized_)
      Shutdown();
}

/**
* Obtains device name.
* Required by the MM::Device API.
*/
void MinDeviceProperty::GetName(char* name) const
{
   // We just return the name we use for referring to this
   // device adapter.
   CDeviceUtils::CopyLimitedString(name, g_DeviceName);
}

/**
* Intializes the hardware.
* Typically we access and initialize hardware at this point.
* Device properties are typically created here as well.
* Required by the MM::Device API.
*/
int MinDeviceProperty::Initialize()
{
	if (initialized_)
		return DEVICE_OK;

	// set read-only properties
	// ------------------------
	// Name
	int nRet = CreateStringProperty(MM::g_Keyword_Name, g_DeviceName, true);
	if (DEVICE_OK != nRet)
		return nRet;

	// Description
	nRet = CreateStringProperty(MM::g_Keyword_Description, "A minimal device adapter with properties", true);
	if (DEVICE_OK != nRet)
		return nRet;

	// set settable properties
	// -----------------------
    CPropertyAction* pAct = new CPropertyAction (this, &MinDeviceProperty::OnSwitchOnOff);
    CreateProperty("Switch On/Off", "Off", MM::String, false, pAct);    

    std::vector<std::string> commands;
    commands.push_back("Off");
    commands.push_back("On");
	// BE SURE THE NAME MATCHES THE PROPERTY!
    SetAllowedValues("Switch On/Off", commands);

   // synchronize all properties
   // --------------------------
   int ret = UpdateStatus();
   if (ret != DEVICE_OK)
      return ret;

   initialized_ = true;
   return DEVICE_OK;
}

/**
* Shuts down (unloads) the device.
* Ideally this method will completely unload the device and release all resources.
* Shutdown() may be called multiple times in a row.
* Required by the MM::Device API.
*/
int MinDeviceProperty::Shutdown()
{
   initialized_ = false;
   return DEVICE_OK;
}

/////////////////////////////////////////////
// Property Generators
/////////////////////////////////////////////

int MinDeviceProperty::OnSwitchOnOff(MM::PropertyBase* pProp, MM::ActionType eAct)
{
	// This will hold the current value of the MM dropdown box
	std::string answer;
	if (eAct == MM::BeforeGet)
	{
		if (deviceOn_)
		{
			pProp->Set("On");
		}
		else
		{
			pProp->Set("Off");
		}
	}
	else if (eAct == MM::AfterSet)
	{
		pProp->Get(answer); // answer is reference to a std::string
		if (answer == "Off") {deviceOn_ = false;}
		else if (answer == "On") {deviceOn_ = true;}
		else {return DEVICE_ERR;}
	}

    return DEVICE_OK;
}