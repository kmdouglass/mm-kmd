# Building Micro-Manager Device Adapters
## Note
These notes apply to Micro-Manager (MM) version 1.4 and Windows 7. They are not guaranteed to work for other versions of Micro-Manager or other operating systems.

Most of these notes were taken while writing a minimum device adapter and reading the [MM device adapter programming guide](https://micro-manager.org/wiki/Building_Micro-Manager_Device_Adapters).

# Key Files
- **DeviceBase.h** : Implements API common functions for all devices, eliminating the need to implement them yourself. There is no corresponding .cpp file.
- **MMDevice.h** : Abstract interfaces that a MM device must implement. The MM namespace is also defined in this file.
- **ModuleInterface.h** : Defines the required API that must be implemented before a device may be loaded into MM.