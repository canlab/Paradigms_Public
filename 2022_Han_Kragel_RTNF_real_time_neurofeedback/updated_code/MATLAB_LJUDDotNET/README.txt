MATLAB - LabJackUD .NET examples for Windows
04/25/2018
support@labjack.com


This package contains MATLAB example scripts for using the UD series of
LabJack: U3, U6, UE9. They demonstrate LabJack usage using the MATLAB .NET
interface and the LabJackUD .NET assembly LJUDDotNet. Examples were last tested
with MATLAB 2018a.


Requirements
-------------

1. Windows operating system
2. MATLAB with .NET interface support. Version 7.8 (R2009a) or newer.
3. LabJackUD library and .NET assembly. Both are provided by the Windows
software installer.

       https://labjack.com/support/software/installers/ud


Getting Started
----------------

First make sure that you have fulfilled the requirements and have extracted the
example scripts somewhere on your computer.

Next, the simple way to get the example scripts running in MATLAB is to click
"Set Path" in the HOME->ENVIRONMENT toolstrip, then click the
"Add with Subfolders" button in the Set Path window and locate the extracted
MATLAB_LJUDDotNET folder. Select the folder and click the "Select Folder"
button. Now back at the "Set Path" window you will see the newly added folders.
Click on the "Save" button and next the "Close" button. In the Command Window
you can now run the example scripts by name, so for example to run the
u3_simple.m script from the MATLAB_LJUDDotNET\Examples\U3 folder type this:

>> u3_simple

All example scripts use the showErrorMessage function in
MATLAB_LJUDDotNET\Examples\showErrorMessage.m.


MATLAB .NET Usage with the LabJackUD .NET Assembly
---------------------------------------------------

To use the LabJackUD .NET assembly in MATLAB use the NET.addAssembly method and
specify 'LJUDDotNet'.

>> ljasm = NET.addAssembly('LJUDDotNet')

That will make the LJUDDotNet's classes accessible in MATLAB. Classes are in
the LabJack.LabJackUD namespace. Information on the UD .NET assembly can be
found in the returned .NET assembly object from the NET.addAssembly call. For
example, to get a list of classes and enumerations type the following:

>> ljasm.Classes
>> ljasm.Enums

To get information on the UD .NET class methods under MATLAB use the
methodsview call. For example:

>> methodsview(LabJack.LabJackUD.LJUD)

For a list of enumeration member names use the enumeration call. For example:

>> enumeration(LabJack.LabJackUD.CHANNEL)

The example scripts will provide more help on MATLAB code and usage.

General UD driver documentation can be found in the device Datasheets,
section 4:

https://labjack.com/support/datasheets/u3/high-level-driver
https://labjack.com/support/datasheets/u6/high-level-driver
https://labjack.com/support/datasheets/ue9/high-level-driver

Example scripts were derived from the .NET C# examples:

https://labjack.com/support/software/examples/ud/dotnet


Changes for MATLAB 2018a and Newer
-----------------------------------

Due to changes in MATLAB 2018a .NET support, the direct way of using inner class
enumerations no longer works. Examples have been updated from using enumerations
for constants to using string (S and SS) versions of methods where the string
names of the constants are used. UD constant names are documented in the device
Datasheets, section 4.3 (Example Pseodocode), and in the LabJackUD.h header file
in the the installed LabJack folder "\Program Files (x86)\LabJack\Drivers".

If you have code from a MATLAB version previous to 2018a, and it now errors
with enumeration constants, similar to (U6 case):

Undefined variable "LabJack" or class "LabJack.LabJackUD.DEVICE.U6".

Your code needs to be updated. Two solutions are:

1. Change to string versions of methods as the examples demonstrate.

2. Access the enumeration constants with a combination of MATLAB methods
AssemblyHandle.GetType and GetEnumValues.Get. For example, getting the
LabJack.LabJackUD.LJUD.IO.GET_STREAM_DATA enumeration:

% Get the type for LabJack.LabJackUD.LJUD+IO enumerations
typeIO = ljasm.AssemblyHandle.GetType('LabJack.LabJackUD.LJUD+IO');
% Get the GET_STREAM_DATA enumeration in LabJack.LabJackUD.LJUD+IO using its
% index, not enum value.
LJ_ioGET_STREAM_DATA = typeIO.GetEnumValues.Get(22)

Only the stream examples use this method for readings stream samples since the
eGetPtr method uses enumerations and has no alternative string method.
