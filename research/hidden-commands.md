### Some of the hidden commands for gen3 robots

```
Log
    Text - write this text to log
    Flush - flush entires

SetUIError
    brief - Sets a UI State Machine Error/Alert
    clearall - Clears all UI Alerts and Errors
    list - Lists all UI Alerts and Errors
    clearalert - Clears the specified UI Alert or Error
    setalert - Sets the specified UI Alert or Error

CopyDumps - Copy All core dumps to emmc and pack them.

GetActiveServices - Displays all running services

GetLoggingType - Displays the type of log (QA, NavPen, or Production)

GetRobotPassword - Returns the robot's saved random password

GetState - Gets the state of the UI Finite State Machine

(NOTE: No idea how it works, what it does)
RunUSMFGTest - Run Ultrasonic MFG Test.

GetI2CBlowerInfo - Get I2C Blower Registers <complete list>(TestMode Only)

(NOTE: No idea how to actually see the data)
GetDatabase - show database tables.
    Database options are: All, Factory, Robot, Runtime, Statistics, System or CleanStats.

RestoreDefaults - Restore user settings to default.

GetRobotPos - Returns Robot position.
    Raw - Return Odometry.
    Smooth - Return smoothed/Localized position.

USBLogCopy - Copies all logs onto a USB drive.

(NOTE: Needs some security key, I don't know how it works)
CalibrateSensor - Automatically calibrates sensors and stores the values into SCB.

(NOTE: Needs some security key, I don't know how it works)
CalibrateAccelerometer - Calibrates the Accelerometer's X/Y Positions.

(NOTE: Just says "Not supported yet...")
GetStats - show system statistics. 

(NOTE: I don't know how it works)
SetApp - Sets the alert/error to be sent to app .
    Alert

UpdateSW - Returns SwUpdate stuff.
    GetStatus - Returns Status of SW Update 
    Verify - Returns Status of SW Update 
    Terminate - Flag to force a shutdown of the SoftwareManager 

TestPWM


GetWifiStatus
    mfgtest - Do MFG Test to determine if the WIFI chip is there
    registry - show WIFI registries
    ? - show wifi log file
    sloginfo - show sloginfo info
    Pattern - display sysloginfo info which matches specified pattern
    Pattern2 - display sysloginfo info which matches both specified patterns.Pattern must be specified. For example, getwifis sloginfo pattern ROSIE pattern2 REPLY
    Exclude - display sysloginfo info which doesn't contain specified pattern.Pattern must be specifed.For example, getwifis sloginfo pattern ROSIE exclude REPLY
    wpacfg - show /emmc/wpa_supplicant.cfg file
    ? - Key to unlock sloginfo retrieval command

    copy sloginfo content to /emmc/black_box/sloginfo.txt and clear sloginfo. For example: getwifis sloginfo clear 1

Clean
    House 
        (Optional) Equivalent to pressing 'Start' button once.
        Starts a house cleaning.
        (House cleaning mode is the default cleaning mode.)
        (Choose only 1 of House,Spot,Stop)
    Spot
        (Optional) Starts a spot clean. (Not available with AutoCycle)
        (Choose only 1 of House,Spot,Stop)
    Persistent
        (Optional) Equivalent to starting a persistent cleaning from the Smart App.
    Width
        (Optional) Spot Width in CM (100-400)(-1=use default).
    Height
        (Optional) Spot Height in CM (100-400)(-1=use default).
    AutoCycle
        Auto cycle Mode. (Shutdown will clear. 'Clean Stop' will also clear.) (Not available with Spot clean.)
    MinCharge
        (Optional) Minimum charge level to trigger a recharge(-1 = use default(50%)).
    Stop
        Stop Cleaning.
        (Choose only 1 of House,Spot,Stop)
    CleaningEnable
        Enables the brush and vacuum during cleaning.
        (Choose only 1 of House,Spot,Stop,NavTest,CleaningEnable,CleaningDisable,IEC1mTest)
    CleaningDisable
        Disables the brush and vacuum during cleaning.
        (Choose only 1 of House,Spot,Stop,NavTest,CleaningEnable,CleaningDisable,IEC1mTest)
    IEC1mTest
        Runs the IEC cleaning test.
        (Choose only 1 of House,Spot,Stop,NavTest,CleaningEnable,CleaningDisable,IEC1mTest)
    MaxModeEnable
        Enable max cleaning mode.
    MaxModeDisable
        Disable max cleaning mode.

ClearFiles
    BB - (Optional) Clears Managed Logs in BlackBox Directory.
    All - (Optional) Additionally clears unmanaged files (Crash, ...) in the specified directories.
    Life - ??
```

### Other Hidden commands
```
NewBattery
    (NOTE: Exact function unknown, but some users report this can fix an issue where a new battery isn't being charged)
    Tells the robot a new battery has been installed.
```

### Hidden gems looking at the decompiled code:
```
YOU OVERFLOWED A 64-bit NUMBER!  WHAT WERE YOU THINKING???

Nice try, but I'm not falling for that one again!  :P

Invalid SCB blower value. How did we get here?!
```
