LabJackUD drivers need to be installed. They can be found here:
https://labjack.com/support/software/installers/ud
For some reason though this isn't sufficient and some DLLs may need to be manually installed. These are available in the LJUD64bitv328.zip file at the same level of the dir tree as this README. Put LabJackud.dll and LabJackWUSB.dll (found within the zip) into the C:\windows\system32

Matlab is able to make calls directly to the UD library functions (which are not themselves matlab code, and are presumably in those DLLs named above). TriggerThermode(T) is the function responsible for this.