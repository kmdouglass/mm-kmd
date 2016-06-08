# Building Micro-Manager Device Adapters
## Note
These notes apply to Micro-Manager (MM) version 1.4 and Windows 7. They are not guaranteed to work for other versions of Micro-Manager or other operating systems.

Most of these notes were taken while writing a minimum device adapter and reading the [MM device adapter programming guide](https://micro-manager.org/wiki/Building_Micro-Manager_Device_Adapters).

# Important Files
Paths are relative to the *micro-manager* folder in the build environment.

- **MMDevice/DeviceBase.h** : Implements API common functions for all devices, eliminating the need to implement them yourself. There is no corresponding .cpp file.
- **MMDevice/MMDevice.h** : Abstract interfaces that a MM device must implement. The MM namespace is also defined in this file.
- **MMDevice/ModuleInterface.h** : Defines the required API that must be implemented before a device may be loaded into MM.
- **micromanager.sln** - Visual Studio solution for building Micro-Manager.

# Properties
[Properties](https://micro-manager.org/wiki/Building_Micro-Manager_Device_Adapters#Properties) allow the user to control a device via a device adapter. While using MM, properties can be found and set inside MM's Device Property Browser.

## General Notes on Properties
- Properties may be defined inside a Device Adapter's constructor or inside the `Initialize()` method. Remember that startup properties that change hardware behavior should not be set in the constructor but rather inside `Initialize()`
- A good explanation from the MM developers on the mailing list may be found here: https://sourceforge.net/p/micro-manager/mailman/message/31973135/

## Read-only Properties
- String properties that are read-only may be created using `CreateStringProperty()`, which is defined inside *DeviceBase.h*. For example:

```C++
int nRet = CreateStringProperty(MM::g_Keyword_Name, g_DeviceName, true);
   if (DEVICE_OK != nRet)
      return nRet;
```