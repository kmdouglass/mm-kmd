# Building Micro-Manager Components and Device Adapters

## Note
These notes apply to Micro-Manager (MM) version 2.0 and Windows Server R2012.
They are not guaranteed to work for other versions of Micro-Manager or other
operating systems.

Most of these notes were taken while writing a minimum device adapter and
reading the
[MM device adapter programming guide](https://micro-manager.org/wiki/Building_Micro-Manager_Device_Adapters).

# Building MM 2.0 on Windows

## Which Visual Studio, .NET, and SDK and Windows version should I use?
- Visual Studio 2010 (what MM i currently built with) is horribly outdated and has been impossible for me to find. For this reason, I use newer versions of VS.
- Pick the version of Visual Studio and .NET that corresponds to your Windows environment. https://en.wikipedia.org/wiki/.NET_Framework#Release_history

## Installation Order
From a clean system without anything installed (including .NET), the order from first-to-last should be:
- Windows SDK *and* .NET (they often come bundled; for example, if you download the Windows 8.1 SDK, you will have an option during the installation to also install .NET 4.5.1)
- Visual C++ (a.k.a. Visual Studio for newer versions)
- Any service packs for your version of Visual Studio
- If you can't load the Micro-Manager .sln file or update it to your version of Visual Studio, try installing the repairs to the Visual C++ 2010 compilers: https://www.microsoft.com/en-us/download/details.aspx?id=4422

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
- See [https://github.com/kmdouglass/mm-kmd/blob/master/Notes/upgrade_to_vs2015.PNG](https://github.com/kmdouglass/mm-kmd/blob/master/Notes/upgrade_to_vs2015.PNG) for the message that appeared when I first loaded the Micro-manager solution in VS2015.
- After having installed VS2015 on one machine, I was unable to load the projects defined in `micromanager.sln`. I received an error stating that `C:\Program Files (x86)\MSBuild\Microscoft.Cpp\v4.0\Microsoft.Cpp.props` was not found. To fix this, I installed the Visual C++ 2010 compiler fix at https://www.microsoft.com/en-us/download/details.aspx?id=4422.
- You might also receive an **Unknown compiler** warning when building  a project. This is because the version of Boost in the 3rdpartypublic repository is quite old and can't be compiled with VS2015. See https://stackoverflow.com/questions/47004187/visual-studio-unknown-compiler-version-after-upgrading for more information. I downloaded and installed Boost 1.67 msvc-14.0-64 from https://sourceforge.net/projects/boost/files/boost-binaries/1.67.0/.

## Microsoft Visual Studio 2017

- VS 2017 is **much** easier to build Micro-Manager in than VS 2015. After opening the micromanager.sln file from the GitHub source repository, select the solution in the Solution Explorer (it usually is at the top above all the various subcomponents). Then, go to the menu bar and select *Project > Retarget solution*. Upgrade to the VS2017 toolset by selecting v141 for the platform toolset. To ensure compatibility with older Microsoft Windows versions, I used the Windows 8.1 SDK (not the one corresponding to Windows 10).
- Ensure that, when Retargeting the solution, that you scroll ALL the way down to the bottom of the window and ensure that **everything** is set to the Windows 8.1 SDK and VS 141 platform toolset. It's easy to miss some projects because they're options will lie at the bottom of the scrollable dialog window.

## Updating the version of Boost to compile against
1. Download an updated version of Boost from https://sourceforge.net/projects/boost/files/boost-binaries/. Choose a version and the file ending in **msvc-XX.X-64.exe**. Here, XX.X refers to the Microsoft Visual Studio Platform Toolset. (For example, 14.0 is VS 2015 and 14.1 is VS 2017.)
2. Install the Boost libraries into a convenient location, such as 3rdpartypublic/boost-versions/boost_<VERSION>
3. [Source](http://micro-manager.3463995.n2.nabble.com/Building-Device-Adapters-on-Windows-10-with-Visual-Studio-2015-Community-td7587098.html#none): Edit the MMcomon.props file to point to the new library. Navigate to ...\projects\micro-manager\buildscripts\VisualStudio, open MMcomon.props with a text editor, and change lines 8 and 9 to point to the location of the new copy of boost (and the appropriate binary lib files). For example:

```
<MM_BOOST_INCLUDEDIR>$(MM_3RDPARTYPUBLIC)\boost-versions\boost_1_61_0</MM_BOOST_INCLUDEDIR>
<MM_BOOST_LIBDIR>$(MM_3RDPARTYPUBLIC)\boost-versions\boost_1_61_0\lib64-msvc-14.0</MM_BOOST_LIBDIR>
```

# Old installation notes
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

The MM Java components are not necessary for building device adapters, but they are necessary for the Micro-Manager Studio (the ImageJ plugin). To build the Java components, you will also need the following packages. Versions are the ones that I use; not those recommended on the information page.

- Ant 1.10.3 http://ant.apache.org/bindownload.cgi
- JDK 8u172 http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

### Environment variables
Set the following environment variables when building the Java components (change them to where you installed the JDK and Ant on your system):

- **JAVA_HOME** C:\Program Files\Java\jdk1.8.0_172
- **ANT_HOME** C:\Users\douglass\apps\apache-ant-1.10.3
- Append **;%ANT_HOME%\bin** to the end of **PATH**
   
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
