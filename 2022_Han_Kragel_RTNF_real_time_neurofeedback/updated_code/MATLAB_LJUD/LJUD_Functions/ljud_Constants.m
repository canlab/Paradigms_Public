% device types
LJ_dtUE9 = 9;
LJ_dtU3 = 3;
LJ_dtU6 = 6;
 
% connection types:
LJ_ctUSB = 1; % UE9 + U3
LJ_ctETHERNET = 2; % UE9 only
LJ_ctETHERNET_MB = 3; % Modbus over Ethernet, UE9 only. 

% Raw connection types are used to open a device but not communicate with it
% should only be used if the normal connection types fail and for testing.
% If a device is opened with the raw connection types, only LJ_ioRAW_OUT
% and LJ_ioRAW_IN io types should be used
LJ_ctUSB_RAW = 101; % UE9 + U3
LJ_ctETHERNET_RAW = 102; % UE9 only


% io types:
LJ_ioGET_AIN = 10; % UE9 + U3.  This is single ended version.  
LJ_ioGET_AIN_DIFF = 15; % U3 only.  Put negative channel in x1.  If 32 is passed as x1, Vref will be added to the result. 
LJ_ioGET_AIN_ADVANCED = 16; % For testing purposes. 

LJ_ioPUT_AIN_RANGE = 2000; % UE9
LJ_ioGET_AIN_RANGE = 2001; % UE9

% sets or reads the analog or digital mode of the FIO and EIO pins.  FIO is Channel 0-7, EIO 8-15
LJ_ioPUT_ANALOG_ENABLE_BIT = 2013; % U3 
LJ_ioGET_ANALOG_ENABLE_BIT = 2014; % U3 
% sets or reads the analog or digital mode of the FIO and EIO pins. Channel is starting 
% bit #, x1 is number of bits to read. The pins are set by passing a bitmask as a double
% for the value.  The first bit of the int that the double represents will be the setting 
% for the pin number sent into the channel variable. 
LJ_ioPUT_ANALOG_ENABLE_PORT = 2015; % U3 
LJ_ioGET_ANALOG_ENABLE_PORT = 2016; % U3

LJ_ioPUT_DAC = 20; % UE9 + U3
LJ_ioPUT_DAC_ENABLE = 2002; % UE9 + U3 (U3 on Channel 1 only)
LJ_ioGET_DAC_ENABLE = 2003; % UE9 + U3 (U3 on Channel 1 only)

LJ_ioGET_DIGITAL_BIT = 30; % UE9 + U3  % changes direction of bit to input as well
LJ_ioGET_DIGITAL_BIT_DIR = 31; % U3
LJ_ioGET_DIGITAL_BIT_STATE = 32; % does not change direction of bit, allowing readback of output

% channel is starting bit #, x1 is number of bits to read 
LJ_ioGET_DIGITAL_PORT = 35; % UE9 + U3  % changes direction of bits to input as well
LJ_ioGET_DIGITAL_PORT_DIR = 36; % U3
LJ_ioGET_DIGITAL_PORT_STATE = 37; % U3 does not change direction of bits, allowing readback of output

% digital put commands will set the specified digital line(s) to output
LJ_ioPUT_DIGITAL_BIT = 40; % UE9 + U3
% channel is starting bit #, value is output value, x1 is bits to write
LJ_ioPUT_DIGITAL_PORT = 45; % UE9 + U3

% Used to create a pause between two events in a U3 low-level feedback
% command.  For example, to create a 100 ms positive pulse on FIO0, add a
% request to set FIO0 high, add a request for a wait of 100000, add a
% request to set FIO0 low, then Go.  Channel is ignored.  Value is
% microseconds to wait and should range from 0 to 8388480.  The actual
% resolution of the wait is 128 microseconds.
LJ_ioPUT_WAIT = 70; % U3

% counter.  Input only.
LJ_ioGET_COUNTER = 50; % UE9 + U3

LJ_ioPUT_COUNTER_ENABLE = 2008; % UE9 + U3
LJ_ioGET_COUNTER_ENABLE = 2009; % UE9 + U3


% this will cause the designated counter to reset.  If you want to reset the counter with
% every read, you have to use this command every time.
LJ_ioPUT_COUNTER_RESET = 2012;  % UE9 + U3 


% on UE9: timer only used for input. Output Timers don't use these.  Only Channel used.
% on U3: Channel used (0 or 1).  
LJ_ioGET_TIMER = 60; % UE9 + U3

LJ_ioPUT_TIMER_VALUE = 2006; % UE9 + U3.  Value gets new value
LJ_ioPUT_TIMER_MODE = 2004; % UE9 + U3.  On both Value gets new mode.  
LJ_ioGET_TIMER_MODE = 2005; % UE9

% IOType for use with SHT sensor.  For LJ_ioSHT_GET_READING, a channel of LJ_chSHT_TEMP (5000) will 
% read temperature, and LJ_chSHT_RH (5001) will read humidity.  
LJ_ioSHT_GET_READING = 500; % UE9 + U3.


% Uses settings from LJ_chSPI special channels (set with LJ_ioPUT_CONFIG) to communcaite with
% something using an SPI interface.  The value parameter is the number of bytes to transfer
% and x1 is the address of the buffer.  The data from the buffer will be sent, then overwritten
% with the data read.  The channel parameter is ignored. 
LJ_ioSPI_COMMUNICATION = 503; % UE9 + U3

LJ_ioI2C_COMMUNICATION = 504; % UE9 + U3
LJ_ioASYNCH_COMMUNICATION = 505; % UE9 + U3
LJ_ioTDAC_COMMUNICATION = 506; % UE9 + U3


% Set's the U3 to it's original configuration.  This means sending the following
% to the ConfigIO and TimerClockConfig low level functions
%
% ConfigIO
% Byte #
% 6       WriteMask       15      Write all parameters.
% 8       TimerCounterConfig      0       No timers/counters.  Offset=0.
% 9       DAC1Enable      0       DAC1 disabled.
% 10      FIOAnalog       0       FIO all digital.
% 11      EIOAnalog       0       EIO all digital.
% 
% 
% TimerClockConfig
% Byte #
% 8       TimerClockConfig        130     Set clock to 48 MHz. (24 MHz for U3 hardware version 1.20 or less)
% 9       TimerClockDivisor       0       Divisor = 0.

% 
LJ_ioPIN_CONFIGURATION_RESET = 2017; % U3

% the raw in/out are unusual, channel # corresponds to the particular comm port, which 
% depends on the device.  For example, on the UE9, 0 is main comm port, and 1 is the streaming comm.
% Make sure and pass a porter to a char buffer in x1, and the number of bytes desired in value.  A call 
% to GetResult will return the number of bytes actually read/written.  The max you can send out in one call
% is 512 bytes to the UE9 and 16384 bytes to the U3.
LJ_ioRAW_OUT = 100; % UE9 + U3
LJ_ioRAW_IN = 101; % UE9 + U3
% sets the default power up settings based on the current settings of the device AS THIS DLL KNOWS.  This last part
% basically means that you should set all parameters directly through this driver before calling this.  This writes 
% to flash which has a limited lifetime, so do not do this too often.  Rated endurance is 20,000 writes.
LJ_ioSET_DEFAULTS = 103; % U3

% Requests to create the list of channels to stream.  Usually you will use the CLEAR_STREAM_CHANNELS request first, which
% will clear any existing channels, then use ADD_STREAM_CHANNEL multiple times to add your desired channels.   Note that 
%you can do CLEAR, and then all your ADDs in a single Go() as long as you add the requests in order.
LJ_ioADD_STREAM_CHANNEL = 200; % UE9 + U3
% Put negative channel in x1.  If 32 is passed as x1, Vref will be added to the result. 
LJ_ioADD_STREAM_CHANNEL_DIFF = 206; % U3

LJ_ioCLEAR_STREAM_CHANNELS = 201;
LJ_ioSTART_STREAM = 202;
LJ_ioSTOP_STREAM = 203;
SET_STREAM_CALLBACK = 205;
 
LJ_ioADD_STREAM_DAC = 207;

% Get stream data has several options.  If you just want to get a single channel's data (if streaming multiple channels), you 
% can pass in the desired channel #, then the number of data points desired in Value, and a pointer to an array to put the 
% data into as X1.  This array needs to be an array of doubles. Therefore, the array needs to be 8 * number of 
% requested data points in byte length. What is returned depends on the StreamWaitMode.  If None, this function will only return 
% data available at the time of the call.  You therefore must call GetResult() for this function to retrieve the actually number 
% of points retreived.  If Pump or Sleep, it will return only when the appropriate number of points have been read or no 
% new points arrive within 100ms.  Since there is this timeout, you still need to use GetResult() to determine if the timeout 
% occured.  If AllOrNone, you again need to check GetResult.  

% You can also retreive the entire scan by passing LJ_chALL_CHANNELS.  In this case, the Value determines the number of SCANS 
% returned, and therefore, the array must be 8 * number of scans requested * number of channels in each scan.  Likewise
% GetResult() will return the number of scans, not the number of data points returned.

% Note: data is stored interleaved across all streaming channels.  In other words, if you are streaming two channels, 0 and 1, 
% and you request LJ_chALL_CHANNELS, you will get, Channel0, Channel1, Channel0, Channel1, etc.  Once you have requested the 
% data, any data returned is removed from the internal buffer, and the next request will give new data.

% Note: if reading the data channel by channel and not using LJ_chALL_CHANNELS, the data is not removed from the internal buffer
% until the data from the last channel in the scan is requested.  This means that if you are streaming three channels, 0, 1 and 2,
% and you request data from channel 0, then channel 1, then channel 0 again, the request for channel 0 the second time will 
% return the exact same data.  Also note, that the amount of data that will be returned for each channel request will be
% the same until you've read the last channel in the scan, at which point your next block may be a different size.

% Note: although more convenient, requesting individual channels is slightly slower then using LJ_chALL_CHANNELS.  Since you 
% are probably going to have to split the data out anyway, we have saved you the trouble with this option.  

% Note: if you are only scanning one channel, the Channel parameter is ignored.

LJ_ioGET_STREAM_DATA = 204;

% U3 only:

% Channel = 0 buzz for a count, Channel = 1 buzz continuous
% Value is the Period
% X1 is the toggle count when channel = 0
LJ_ioBUZZER = 300; % U3 
LJ_ioSET_EVENT_CALLBACK = 400;

% these are the possible EventCodes that will be passed:
LJ_ecDISCONNECT = 1;  % called when the device is unplugged from USB.  No Data is passed
LJ_ecRECONNECT = 2;   % called when the device is reconnected to USB.  No Data is passed
LJ_ecSTREAMERROR = 4;  % called when a stream error occurs. Data1 is errorcode, Data2 and Data3 are not used.
% future events will be power of 2.

% config iotypes:
LJ_ioPUT_CONFIG = 1000; % UE9 + U3
LJ_ioGET_CONFIG = 1001; % UE9 + U3



% channel numbers used for CONFIG types:
% UE9 + U3
LJ_chLOCALID = 0; % UE9 + U3
LJ_chHARDWARE_VERSION = 10; % UE9 + U3 (Read Only)
LJ_chSERIAL_NUMBER = 12; % UE9 + U3 (Read Only)
LJ_chFIRMWARE_VERSION = 11; % UE9 + U3 (Read Only)
LJ_chBOOTLOADER_VERSION = 15; % UE9 + U3 (Read Only)

% UE9 specific:
LJ_chCOMM_POWER_LEVEL = 1; %UE9
LJ_chIP_ADDRESS = 2; %UE9
LJ_chGATEWAY = 3; %UE9
LJ_chSUBNET = 4; %UE9
LJ_chPORTA = 5; %UE9
LJ_chPORTB = 6; %UE9
LJ_chDHCP = 7; %UE9
LJ_chPRODUCTID = 8; %UE9
LJ_chMACADDRESS = 9; %UE9
LJ_chCOMM_FIRMWARE_VERSION = 11;  
LJ_chCONTROL_POWER_LEVEL = 13; %UE9 
LJ_chCONTROL_FIRMWARE_VERSION = 14; %UE9 (Read Only)
LJ_chCONTROL_BOOTLOADER_VERSION = 15; %UE9 (Read Only)
LJ_chCONTROL_RESET_SOURCE = 16; %UE9 (Read Only)
LJ_chUE9_PRO = 19; % UE9 (Read Only)

% U3 only:
% sets the state of the LED 
LJ_chLED_STATE = 17; % U3   value = LED state
LJ_chSDA_SCL = 18; % U3   enable / disable SDA/SCL as digital I/O
LJ_chU3HV = 22;

% U6 only:
LJ_chU6_PRO = 23;

% Driver related:
% Number of milliseconds that the driver will wait for communication to complete
LJ_chCOMMUNICATION_TIMEOUT = 20;
LJ_chSTREAM_COMMUNICATION_TIMEOUT = 21;


% Used to access calibration and user data.  The address of an array is passed in as x1.
% For the UE9, a 1024-element buffer of bytes is passed for user data and a 128-element
% buffer of doubles is passed for cal constants.
% For the U3, a 256-element buffer of bytes is passed for user data and a 12-element
% buffer of doubles is passed for cal constants.
% The layout of cal constants are defined in the users guide for each device.
% When the LJ_chCAL_CONSTANTS special channel is used with PUT_CONFIG, a
% special value (0x4C6C) must be passed in to the Value parameter. This makes it
% more difficult to accidently erase the cal constants.  In all other cases the Value
% parameter is ignored.
LJ_chCAL_CONSTANTS = 400; % UE9 + U3
LJ_chUSER_MEM = 402; % UE9 + U3

% Used to write and read the USB descriptor strings.  This is generally for OEMs
% who wish to change the strings.
% Pass the address of an array in x1.  Value parameter is ignored.
% The array should be 128 elements of bytes.  The first 64 bytes are for the
% iManufacturer string, and the 2nd 64 bytes are for the iProduct string.
% The first byte of each 64 byte block (bytes 0 and 64) contains the number
% of bytes in the string.  The second byte (bytes 1 and 65) is the USB spec
% value for a string descriptor (0x03).  Bytes 2-63 and 66-127 contain unicode
% encoded strings (up to 31 characters each).
LJ_chUSB_STRINGS = 404; % U3


% timer/counter related :
LJ_chNUMBER_TIMERS_ENABLED = 1000; % UE9 + U3
LJ_chTIMER_CLOCK_BASE = 1001; % UE9 + U3
LJ_chTIMER_CLOCK_DIVISOR = 1002; % UE9 + U3
LJ_chTIMER_COUNTER_PIN_OFFSET = 1003; % U3

% AIn related :
LJ_chAIN_RESOLUTION = 2000; % UE9 + U3
LJ_chAIN_SETTLING_TIME = 2001; % UE9 + U3
LJ_chAIN_BINARY = 2002; % UE9 + U3


% DAC related :
LJ_chDAC_BINARY = 3000; % UE9 + U3


% SHT related : 
% LJ_chSHT_TEMP and LJ_chSHT_RH are used with LJ_ioSHT_GET_READING to read those values.
% The LJ_chSHT_DATA_CHANNEL and LJ_chSHT_SCK_CHANNEL constants use the passed value 
% to set the appropriate channel for the data and SCK lines for the SHT sensor. 
% Default digital channels are FIO0 for the data channel and FIO1 for the clock channel. 
LJ_chSHT_TEMP = 5000; % UE9 + U3
LJ_chSHT_RH = 5001; % UE9 + U3
LJ_chSHT_DATA_CHANNEL = 5002; % UE9 + U3. Default is FIO0
LJ_chSHT_CLOCK_CHANNEL = 5003; % UE9 + U3. Default is FIO1

% SPI related :
LJ_chSPI_AUTO_CS = 5100; % UE9 + U3
LJ_chSPI_DISABLE_DIR_CONFIG = 5101; % UE9 + U3
LJ_chSPI_MODE = 5102; % UE9 + U3
LJ_chSPI_CLOCK_FACTOR = 5103; % UE9 + U3
LJ_chSPI_MOSI_PIN_NUM = 5104; % UE9 + U3
LJ_chSPI_MISO_PIN_NUM = 5105; % UE9 + U3
LJ_chSPI_CLK_PIN_NUM = 5106; % UE9 + U3
LJ_chSPI_CS_PIN_NUM = 5107; % UE9 + U3

% I2C related :
% used with LJ_ioPUT_CONFIG
LJ_chI2C_ADDRESS_BYTE = 5108; % UE9 + U3
LJ_chI2C_SCL_PIN_NUM = 5109; % UE9 + U3
LJ_chI2C_SDA_PIN_NUM = 5110; % UE9 + U3
LJ_chI2C_OPTIONS = 5111; % UE9 + U3
LJ_chI2C_SPEED_ADJUST = 5112; % UE9 + U3

% used with LJ_ioI2C_COMMUNICATION :
LJ_chI2C_READ = 5113; % UE9 + U3
LJ_chI2C_WRITE = 5114; % UE9 + U3
LJ_chI2C_GET_ACKS = 5115; % UE9 + U3
LJ_chI2C_WRITE_READ = 5130; % UE9 + U3

% ASYNCH related :
% Used with LJ_ioASYNCH_COMMUNICATION
LJ_chASYNCH_RX = 5117; % UE9 + U3
LJ_chASYNCH_TX = 5118; % UE9 + U3
LJ_chASYNCH_FLUSH = 5128; % UE9 + U3
LJ_chASYNCH_ENABLE = 5129; % UE9 + U3

% Used with LJ_ioPUT_CONFIG and LJ_ioGET_CONFIG
LJ_chASYNCH_BAUDFACTOR = 5127; % UE9 + U3

% LJ TickDAC related :
LJ_chTDAC_SCL_PIN_NUM = 5119; % UE9 + U3:  Used with LJ_ioPUT_CONFIG
% Used with LJ_ioTDAC_COMMUNICATION
LJ_chTDAC_SERIAL_NUMBER = 5120; % UE9 + U3: Read only
LJ_chTDAC_READ_USER_MEM = 5121; % UE9 + U3
LJ_chTDAC_WRITE_USER_MEM = 5122; % UE9 + U3
LJ_chTDAC_READ_CAL_CONSTANTS = 5123; % UE9 + U3
LJ_chTDAC_WRITE_CAL_CONSTANTS = 5124; % UE9 + U3
LJ_chTDAC_UPDATE_DACA = 5125; % UE9 + U3
LJ_chTDAC_UPDATE_DACB = 5126; % UE9 + U3


% stream related.  Note, Putting to any of these values will stop any running streams.
LJ_chSTREAM_SCAN_FREQUENCY = 4000;
LJ_chSTREAM_BUFFER_SIZE = 4001;
LJ_chSTREAM_CLOCK_OUTPUT = 4002;
LJ_chSTREAM_EXTERNAL_TRIGGER = 4003;
LJ_chSTREAM_WAIT_MODE = 4004;
LJ_chSTREAM_DISABLE_AUTORECOVERY = 4005; % U3
LJ_chSTREAM_SAMPLES_PER_PACKET = 4108;
LJ_chSTREAM_READS_PER_SECOND = 4109;
LJ_chAIN_STREAM_SETTLING_TIME = 4110; % U6

% readonly stream related
LJ_chSTREAM_BACKLOG_COMM = 4105;
LJ_chSTREAM_BACKLOG_CONTROL = 4106;
LJ_chSTREAM_BACKLOG_UD = 4107;




% special channel #'s
LJ_chALL_CHANNELS = -1;
LJ_INVALID_CONSTANT = -999;


%Thermocouple Type constants.
LJ_ttB = 6001;
LJ_ttE = 6002;
LJ_ttJ = 6003;
LJ_ttK = 6004;
LJ_ttN = 6005;
LJ_ttR = 6006;
LJ_ttS = 6007;
LJ_ttT = 6008;


% other constants:
% ranges (not all are supported by all devices):
LJ_rgAUTO = 0;

LJ_rgBIP20V = 1;  % -20V to +20V
LJ_rgBIP10V = 2;  % -10V to +10V
LJ_rgBIP5V = 3;   % -5V to +5V
LJ_rgBIP4V = 4;   % -4V to +4V
LJ_rgBIP2P5V = 5; % -2.5V to +2.5V
LJ_rgBIP2V = 6;   % -2V to +2V
LJ_rgBIP1P25V = 7;% -1.25V to +1.25V
LJ_rgBIP1V = 8;   % -1V to +1V
LJ_rgBIPP625V = 9;% -0.625V to +0.625V
LJ_rgBIPP1V = 10; % -0.1V to +0.1V
LJ_rgBIPP01V = 11; % -0.01V to +0.01V

LJ_rgUNI20V = 101;  % 0V to +20V
LJ_rgUNI10V = 102;  % 0V to +10V
LJ_rgUNI5V = 103;   % 0V to +5V
LJ_rgUNI4V = 104;   % 0V to +4V
LJ_rgUNI2P5V = 105; % 0V to +2.5V
LJ_rgUNI2V = 106;   % 0V to +2V
LJ_rgUNI1P25V = 107;% 0V to +1.25V
LJ_rgUNI1V = 108;   % 0V to +1V
LJ_rgUNIP625V = 109;% 0V to +0.625V
LJ_rgUNIP5V = 110; % 0V to +0.500V
LJ_rgUNIP25V = 112; % 0V to +0.25V
LJ_rgUNIP3125V = 111; % 0V to +0.3125V
LJ_rgUNIP025V = 113; % 0V to +0.025V
LJ_rgUNIP0025V = 114; % 0V to +0.0025V

% timer modes:
LJ_tmPWM16 = 0; % 16 bit PWM
LJ_tmPWM8 = 1; % 8 bit PWM
LJ_tmRISINGEDGES32 = 2; % 32-bit rising to rising edge measurement
LJ_tmFALLINGEDGES32 = 3; % 32-bit falling to falling edge measurement
LJ_tmDUTYCYCLE = 4; % duty cycle measurement
LJ_tmFIRMCOUNTER = 5; % firmware based rising edge counter
LJ_tmFIRMCOUNTERDEBOUNCE = 6; % firmware counter with debounce
LJ_tmFREQOUT = 7; % frequency output
LJ_tmQUAD = 8; % Quadrature
LJ_tmTIMERSTOP = 9; % stops another timer after n pulses
LJ_tmSYSTIMERLOW = 10; % read lower 32-bits of system timer
LJ_tmSYSTIMERHIGH = 11; % read upper 32-bits of system timer
LJ_tmRISINGEDGES16 = 12; % 16-bit rising to rising edge measurement
LJ_tmFALLINGEDGES16 = 13; % 16-bit falling to falling edge measurement

% timer clocks:
LJ_tc750KHZ = 0;   % UE9: 750 khz 
LJ_tcSYS = 1;      % UE9 & U3: system clock


LJ_tc2MHZ = 10;     % U3: Hardware Version 1.20 or lower
LJ_tc6MHZ = 11;     % U3: Hardware Version 1.20 or lower
LJ_tc24MHZ = 12;     % U3: Hardware Version 1.20 or lower
LJ_tc500KHZ_DIV = 13;% U3: Hardware Version 1.20 or lower
LJ_tc2MHZ_DIV = 14;  % U3: Hardware Version 1.20 or lower
LJ_tc6MHZ_DIV = 15;  % U3: Hardware Version 1.20 or lower
LJ_tc24MHZ_DIV = 16; % U3: Hardware Version 1.20 or lower

LJ_tc4MHZ = 20;     % U3: Hardware Version 1.21 or higher
LJ_tc12MHZ = 21;     % U3: Hardware Version 1.21 or higher
LJ_tc48MHZ = 22;     % U3: Hardware Version 1.21 or higher
LJ_tc1MHZ_DIV = 23;% U3: Hardware Version 1.21 or higher
LJ_tc4MHZ_DIV = 24;  % U3: Hardware Version 1.21 or higher
LJ_tc12MHZ_DIV = 25;  % U3: Hardware Version 1.21 or higher
LJ_tc48MHZ_DIV = 26; % U3: Hardware Version 1.21 or higher


% stream wait modes
LJ_swNONE = 1;  % no wait, return whatever is available
LJ_swALL_OR_NONE = 2; % no wait, but if all points requested aren't available, return none.
LJ_swPUMP = 11;  % wait and pump the message pump.  Prefered when called from primary thread (if you don't know
                           % if you are in the primary thread of your app then you probably are.  Do not use in worker
                           % secondary threads (i.e. ones without a message pump).
LJ_swSLEEP = 12; % wait by sleeping (don't do this in the primary thread of your app, or it will temporarily 
                           % hang)  This is usually used in worker secondary threads.


% BETA CONSTANTS
% Please note that specific usage of these constants and their values might change

% SWDT 
% Sets parameters used to control the software watchdog option.  The device is only 
% communicated with and updated when LJ_ioSWDT_CONFIG is used with LJ_chSWDT_ENABLE
% or LJ_chSWDT_DISABLE.  Thus, to change a value, you must use LJ_io_PUT_CONFIG
% with the appropriate channel constant so set the value inside the driver, then call
% LJ_ioSWDT_CONFIG to enable that change. 
LJ_ioSWDT_CONFIG = 507; % UE9 & U3 - Use with LJ_chSWDT_ENABLE or LJ_chSWDT_DISABLE

LJ_chSWDT_ENABLE = 5200; % UE9 & U3 - used with LJ_ioSWDT_CONFIG to enable watchdog.  Value paramter is number of seconds to trigger
LJ_chSWDT_DISABLE = 5201; % UE9 & U3 - used with LJ_ioSWDT_CONFIG to enable watchdog.

% Used with LJ_io_PUT_CONFIG
LJ_chSWDT_RESET_DEVICE= 5202; % U3 - Reset U3 on watchdog reset.  Write only. 
LJ_chSWDT_RESET_COMM = 5203; % UE9 - Reset Comm on watchdog reset.  Write only. 
LJ_chSWDT_RESET_CONTROL = 5204; % UE9 - Reset Control on watchdog trigger.  Write only. 
LJ_chSWDT_UDPATE_DIOA = 5205; % UE9 & U3 - Update DIO0 settings after reset.  Write only. 
LJ_chSWDT_UPDATE_DIOB = 5206; % UE9 - Update DIO1 settings after reset.  Write only. 
LJ_chSWDT_DIOA_CHANNEL = 5207; % UE9 & U3 - DIO0 channel to be set after reset.  Write only. 
LJ_chSWDT_DIOA_STATE = 5208; % UE9 & U3 - DIO0 state to be set after reset.  Write only. 
LJ_chSWDT_DIOB_CHANNEL = 5209; % UE9 - DIO1 channel to be set after reset.  Write only. 
LJ_chSWDT_DIOB_STATE = 5210; % UE9 - DIO0 state to be set after reset.  Write only. 
LJ_chSWDT_UPDATE_DAC0 = 5211; % UE9 - Update DAC0 settings after reset.  Write only. 
LJ_chSWDT_UPDATE_DAC1 = 5212; % UE9 - Update DAC1 settings after reset.  Write only. 
LJ_chSWDT_DAC0 = 5213; % UE9 - voltage to set DAC0 at on watchdog reset.  Write only. 
LJ_chSWDT_DAC1 = 5214; % UE9 - voltage to set DAC1 at on watchdog reset.  Write only. 
LJ_chSWDT_DAC_ENABLE = 5215; % UE9 - Enable DACs on watchdog reset.  Default is true.  Both DACs are enabled or disabled togeather.  Write only. 


% END BETA CONSTANTS


% error codes:  These will always be in the range of -1000 to 3999 for labView compatibility (+6000)
LJE_NOERROR = 0;
 
LJE_INVALID_CHANNEL_NUMBER = 2; % occurs when a channel that doesn't exist is specified (i.e. DAC #2 on a UE9), or data from streaming is requested on a channel that isn't streaming
LJE_INVALID_RAW_INOUT_PARAMETER = 3;
LJE_UNABLE_TO_START_STREAM = 4;
LJE_UNABLE_TO_STOP_STREAM = 5;
LJE_NOTHING_TO_STREAM = 6;
LJE_UNABLE_TO_CONFIG_STREAM = 7;
LJE_BUFFER_OVERRUN = 8; % occurs when stream buffer overruns (this is the driver buffer not the hardware buffer).  Stream is stopped.
LJE_STREAM_NOT_RUNNING = 9;
LJE_INVALID_PARAMETER = 10;
LJE_INVALID_STREAM_FREQUENCY = 11; 
LJE_INVALID_AIN_RANGE = 12;
LJE_STREAM_CHECKSUM_ERROR = 13; % occurs when a stream packet fails checksum.  Stream is stopped
LJE_STREAM_COMMAND_ERROR = 14; % occurs when a stream packet has invalid command values.  Stream is stopped.
LJE_STREAM_ORDER_ERROR = 15; % occurs when a stream packet is received out of order (typically one is missing).  Stream is stopped.
LJE_AD_PIN_CONFIGURATION_ERROR = 16; % occurs when an analog or digital request was made on a pin that isn't configured for that type of request
LJE_REQUEST_NOT_PROCESSED = 17; % When a LJE_AD_PIN_CONFIGURATION_ERROR occurs, all other IO requests after the request that caused the error won't be processed. Those requests will return this error.


% U3 & U6 Specific Errors
LJE_SCRATCH_ERROR = 19;
LJE_DATA_BUFFER_OVERFLOW = 20;
LJE_ADC0_BUFFER_OVERFLOW = 21; 
LJE_FUNCTION_INVALID = 22;
LJE_SWDT_TIME_INVALID = 23;
LJE_FLASH_ERROR = 24;
LJE_STREAM_IS_ACTIVE = 25;
LJE_STREAM_TABLE_INVALID = 26;
LJE_STREAM_CONFIG_INVALID = 27;
LJE_STREAM_BAD_TRIGGER_SOURCE = 28;
LJE_STREAM_INVALID_TRIGGER = 30;
LJE_STREAM_ADC0_BUFFER_OVERFLOW = 31;
LJE_STREAM_SAMPLE_NUM_INVALID = 33;
LJE_STREAM_BIPOLAR_GAIN_INVALID = 34;
LJE_STREAM_SCAN_RATE_INVALID = 35;
LJE_TIMER_INVALID_MODE = 36;
LJE_TIMER_QUADRATURE_AB_ERROR = 37;
LJE_TIMER_QUAD_PULSE_SEQUENCE = 38;
LJE_TIMER_BAD_CLOCK_SOURCE = 39;
LJE_TIMER_STREAM_ACTIVE = 40;
LJE_TIMER_PWMSTOP_MODULE_ERROR = 41;
LJE_TIMER_SEQUENCE_ERROR = 42;
LJE_TIMER_SHARING_ERROR = 43;
LJE_TIMER_LINE_SEQUENCE_ERROR = 44;
LJE_EXT_OSC_NOT_STABLE = 45;
LJE_INVALID_POWER_SETTING = 46;
LJE_PLL_NOT_LOCKED = 47;
LJE_INVALID_PIN = 48;
LJE_IOTYPE_SYNCH_ERROR = 49;
LJE_INVALID_OFFSET = 50;
LJE_FEEDBACK_IOTYPE_NOT_VALID = 51;
LJE_CANT_CONFIGURE_PIN_FOR_ANALOG = 67;
LJE_CANT_CONFIGURE_PIN_FOR_DIGITAL = 68;
LJE_TC_PIN_OFFSET_MUST_BE_4_TO_8 = 70;
LJE_INVALID_DIFFERENTIAL_CHANNEL = 71;

% Other errors
LJE_SHT_CRC = 52;
LJE_SHT_MEASREADY = 53;
LJE_SHT_ACK = 54;
LJE_SHT_SERIAL_RESET = 55;
LJE_SHT_COMMUNICATION = 56;

LJE_AIN_WHILE_STREAMING = 57;

LJE_STREAM_TIMEOUT = 58;
LJE_STREAM_CONTROL_BUFFER_OVERFLOW = 59;
LJE_STREAM_SCAN_OVERLAP = 60;
LJE_FIRMWARE_VERSION_IOTYPE = 61;
LJE_FIRMWARE_VERSION_CHANNEL = 62;
LJE_FIRMWARE_VERSION_VALUE = 63;
LJE_HARDWARE_VERSION_IOTYPE = 64;
LJE_HARDWARE_VERSION_CHANNEL = 65;
LJE_HARDWARE_VERSION_VALUE = 66;

LJE_LJTDAC_ACK_ERROR = 69;



LJE_MIN_GROUP_ERROR = 1000; % all errors above this number will stop all requests, below this number are request level errors.

LJE_UNKNOWN_ERROR = 1001; % occurs when an unknown error occurs that is caught, but still unknown.
LJE_INVALID_DEVICE_TYPE = 1002; % occurs when devicetype is not a valid device type
LJE_INVALID_HANDLE = 1003; % occurs when invalid handle used
LJE_DEVICE_NOT_OPEN = 1004;  % occurs when Open() fails and AppendRead called despite.
LJE_NO_DATA_AVAILABLE = 1005; % this is cause when GetData() called without calling DoRead(), or when GetData() passed channel that wasn't read
LJE_NO_MORE_DATA_AVAILABLE = 1006;
LJE_LABJACK_NOT_FOUND = 1007; % occurs when the LabJack is not found at the given id or address
LJE_COMM_FAILURE = 1008; % occurs when unable to send or receive the correct # of bytes
LJE_CHECKSUM_ERROR = 1009;
LJE_DEVICE_ALREADY_OPEN = 1010; % occurs when LabJack is already open via USB in another program or process
LJE_COMM_TIMEOUT = 1011;
LJE_USB_DRIVER_NOT_FOUND = 1012;
LJE_INVALID_CONNECTION_TYPE = 1013;
LJE_INVALID_MODE = 1014;

% these errors aren't actually generated by the UD, but could be handy in your code to indicate an event as an error code without
% conflicting with LabJack error codes
LJE_DISCONNECT = 2000; 
LJE_RECONNECT = 2001;

% and an area for your own codes.  This area won't ever be used for LabJack codes.
LJE_MIN_USER_ERROR = 3000;
LJE_MAX_USER_ERROR = 3999;


% warning are negative
LJE_DEVICE_NOT_CALIBRATED = -1; % defaults used instead
LJE_UNABLE_TO_READ_CALDATA = -2; % defaults used instead

% depreciated constants:
LJ_ioANALOG_INPUT = 10;  
LJ_ioANALOG_OUTPUT = 20; % UE9 + U3
LJ_ioDIGITAL_BIT_IN = 30; % UE9 + U3
LJ_ioDIGITAL_PORT_IN = 35; % UE9 + U3 
LJ_ioDIGITAL_BIT_OUT = 40; % UE9 + U3
LJ_ioDIGITAL_PORT_OUT = 45; % UE9 + U3
LJ_ioCOUNTER = 50; % UE9 + U3
LJ_ioTIMER = 60; % UE9 + U3
LJ_ioPUT_COUNTER_MODE = 2010; % UE9
LJ_ioGET_COUNTER_MODE = 2011; % UE9
LJ_ioGET_TIMER_VALUE = 2007; % UE9
LJ_ioCYCLE_PORT = 102;  % UE9 
LJ_chTIMER_CLOCK_CONFIG = 1001; % UE9 + U3 
LJ_ioPUT_CAL_CONSTANTS = 400;
LJ_ioGET_CAL_CONSTANTS = 401;
LJ_ioPUT_USER_MEM = 402;
LJ_ioGET_USER_MEM = 403;
LJ_ioPUT_USB_STRINGS = 404;
LJ_ioGET_USB_STRINGS = 405;
LJ_ioSHT_DATA_CHANNEL = 501; % UE9 + U3
LJ_ioSHT_CLOCK_CHANNEL = 502; % UE9 + U3
LJ_chI2C_ADDRESS = 5108; % UE9 + U3
LJ_chASYNCH_CONFIG = 5116; % UE9 + U3
LJ_rgUNIP500V = 110; % 0V to +0.500V
LJ_ioENABLE_POS_PULLDOWN = 2018; % U6
LJ_ioENABLE_NEG_PULLDOWN = 2019; % U6
