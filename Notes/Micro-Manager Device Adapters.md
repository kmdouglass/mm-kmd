# Building Micro-Manager Device Adapters

## Note
These notes apply to Micro-Manager (MM) version 2.0 and Windows Server R2012.
They are not guaranteed to work for other versions of Micro-Manager or other
operating systems.

Most of these notes were taken while writing a minimum device adapter and
reading the
[MM device adapter programming guide](https://micro-manager.org/wiki/Building_Micro-Manager_Device_Adapters).

# Building MM 2.0 on Windows

## Microsoft Visual Studio 2015

- I sometimes encounter security exceptions when attempting to sign in to use
  the VS 2015. When I see these, I add the site as a trusted site by going to
  **Start > Control Panel > Internet Options**, clicking the **Security** tab,
  and clicking the **Trusted Sites** picture, and then clicking the **Sites**
  button. Then I add the website that was listed in the exception to the list.
- To enable the properties manager for importing property sheets, you need to
  navigate to **Tools > Import and Export Settings...**. In this window, select
  **Import selected environment settings**, then click **Next.** There is no
  need to save the current settings in the next window, so select **No, just
  import new settings, overwriting my current settings** and click **Next**.
  Select **Visual C++** in the next window and click **Next >**. Finally, click
  **Finish** in the final window. The property manager should now appear as a
  tab at the bottom of the Solution Explorer.
- You may also need to update the **Platform Toolset** and
  **Target Platform Version** of the MMDevice-SharedRuntime reference to match
  the settings of the device adapter for VS 2015. For me, these are **Visual
  Studio (v140)** and **8.1**, respectively.

## Download and install the software

These instructions loosely follow those listed
[here](https://micro-manager.org/wiki/Building_MM_on_Windows) for building MM
on Windows, but deviate significantly due to Visual Studio 2010 being phased-out
by Microsoft. Instead, I am using Microsoft Visual Studio 2015 Community Edition
2 from EPFL's Distrilog server. Refer to
[this thread](http://micro-manager.3463995.n2.nabble.com/Building-Device-Adapters-on-Windows-10-with-Visual-Studio-2015-Community-td7587098.html#none)
for tips on building MM with VS2015.

1. If not already installed, download and install Git.
2. Navigate into your preferred source directory and clone the Github MM
   repository. I do this in Git Bash.
3. After cloning, cd into the micro-manager repository and checkout the mm2
   branch.

```
git checkout mm2
```

4. Download [SlikSVN](https://sliksvn.com/download/) and install
   it. SVN is used to checkout the 3rdpartypublic libraries.
5. `cd ..` back into the source directory (one level above the micro-manager git
   repository) and checkout the 3rdpartypublic repo using SVN:

```
svn checkout https://valelab4.ucsf.edu/svn/3rdpartypublic/
```

   If prompted for a username/password, use guest/guest. If the checkout times
   out due to the large size of the repo, simply run the following commands until
   it finishes to completion. 
   
```
svn cleanup 3rdpartypublic
svn checkout https://valelab4.ucsf.edu/svn/3rdpartypublic/
```
   
   The timeout message will say "The server sent a truncated HTTP response
   body."
   
6. Download and install [WinCDEmu](http://wincdemu.sysprogs.org/download/). This
   is used to mount the Visual Studio installation images.
7. Download the .iso image for Microsoft Visual Studio 2015 Community Edition
   Update 2 from EPFL's Distrilog. After WinCDEmu is installed, right-click
   on the image file and select *Select driver letter & mount* from the context
   menu. Mount is as a **Data disc**, open the mounted image, and double click
   the **vs_community.exe** file.
8. Follow the directions to install VS2015. Please note that I had already
   installed the Windows 7.1 SDK and .NET Framework 4 file as instructed on the
   MM website, so I am not sure whether this is necessary or not. **On Windows
   Server 2016, Visual Studio automatically asked to install the Windows 8.1 SDK
   and Universal CRT SDK when I opened my device adapter solution (.sln) file. I
   installed these toolkits.**

## Java components

To build the Java components, you will also need the following. Versions are the ones that I use; not those recommended on the information page.

- Ant 1.10.3 http://ant.apache.org/bindownload.cgi
- JDK 8u172 http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
   
# Important Files
Paths are relative to the *micro-manager* folder in the build environment.

- **MMDevice/DeviceBase.h** : Implements API common functions for all devices,
  eliminating the need to implement them yourself. There is no corresponding
  .cpp file.
- **MMDevice/MMDevice.h** : Abstract interfaces that a MM device must implement.
  The MM namespace is also defined in this file.
- **MMDevice/ModuleInterface.h** : Defines the required API that must be
  implemented before a device may be loaded into MM.
- **micromanager.sln** - Visual Studio solution for building Micro-Manager.

# Properties
[Properties](https://micro-manager.org/wiki/Building_Micro-Manager_Device_Adapters#Properties)
allow the user to control a device via a device adapter. While using MM,
properties can be found and set inside MM's Device Property Browser.

## General Notes on Properties
- Properties may be defined inside a Device Adapter's constructor or inside the
  `Initialize()` method. Remember that startup properties that change hardware
  behavior should not be set in the constructor but rather inside `Initialize()`
- A good explanation from the MM developers on the mailing list may be found
  here: https://sourceforge.net/p/micro-manager/mailman/message/31973135/

## Read-only Properties
- String properties that are read-only may be created using
  `CreateStringProperty()`, which is defined inside *DeviceBase.h*. For example:

```C++
int nRet = CreateStringProperty(MM::g_Keyword_Name, g_DeviceName, true);
   if (DEVICE_OK != nRet)
      return nRet;
```
