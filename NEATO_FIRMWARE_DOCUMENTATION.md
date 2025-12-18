# Neato Firmware Protocol Documentation

## Critical Context: Why This Documentation Matters

⚠️ **Neato Robotics ceased operations in 2023, and their cloud services are being shut down in Q4 2025.**

After the cloud shutdown, Neato Connected robots (D3, D4, D5, D6, D7) will **lose most of their functionality** including:

- Remote control via mobile app
- Scheduling through the app
- Software updates
- Cloud-based features and integrations
- Home Assistant cloud integration

**This documentation enables direct local control of Neato robots via serial/UART communication, preserving their functionality after the cloud shutdown.** By using an ESP32/ESP8266 as a serial-to-WiFi bridge, these robots can continue to operate with full local control through Home Assistant or other home automation systems.

This project represents a community effort to keep these robots working long after official support ends.

## Overview

This document contains comprehensive information about the Neato BotVac serial communication protocol, discovered through reverse engineering, official documentation, and testing across multiple firmware versions.

## Firmware Versions Tested

- **Firmware 4.5.3** - Known working (based on original ESPHome implementation)
- **Firmware 4.6.0 (build 72)** - Tested on Neato D7 Connected

## Communication Protocol

### Basic Parameters

- **Baud Rate**: 115200
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None
- **Line Ending**: CRLF (`\r\n`)
- **Response Delimiter**: `\x1A` (SUB character, ASCII 26)

### Command Format

Commands are sent as plain text strings followed by CRLF. Responses end with `\x1A` delimiter.

```
<COMMAND>\r\n
<RESPONSE LINES>\r\n
\x1A
```

## Confirmed Working Commands (Firmware 4.6.0)

### GetErr

**Purpose**: Get current error and alert status
**Response Format**:

```
Error
<error_code> - <error_description>
Alert
<alert_code> - <alert_description>
USB state
<usb_status>
```

**Example**:

```
GetErr
Error
200 -  (UI_ALERT_INVALID)
Alert
200 -  (UI_ALERT_INVALID)
USB state
 NOT connected
```

**Notes**:

- Error 200 / Alert 200 means no error/alert
- USB state can be "NOT connected" or "connected"

### GetState

**Purpose**: Get current UI and robot state
**Response Format**:

```
Current UI State is: <UI_STATE>
Current Robot State is: <ROBOT_STATE>
```

**Example**:

```
GetState
Current UI State is: UIMGR_STATE_IDLE
Current Robot State is: ST_C_Standby
```

**Known UI States**:

- `UIMGR_STATE_IDLE` - Robot is idle
- `UIMGR_STATE_HOUSECLEANINGRUNNING` - Robot is cleaning

**Known Robot States**:

- `ST_C_Standby` - Robot in standby mode
- (More states to be discovered)

### GetCharger

**Purpose**: Get battery and charging information
**Response Format**: CSV with Label,Value pairs

**Example**:

```
GetCharger
Label,Value
FuelPercent,89
BatteryOverTemp,0
ChargingActive,0
ChargingEnabled,1
ConfidentOnFuel,0
OnReservedFuel,0
EmptyFuel,0
BatteryFailure,0
ExtPwrPresent,0
ThermistorPresent,1
BattTempCAvg,23
VBattV,16.18
VExtV,0.00
Charger_mAH,0
Discharge_mAH,86
```

**Fields**:

- `FuelPercent` - Battery percentage (0-100)
- `BatteryOverTemp` - Boolean flag (0/1)
- `ChargingActive` - Boolean flag (0/1)
- `ChargingEnabled` - Boolean flag (0/1)
- `ConfidentOnFuel` - Boolean flag (0/1)
- `OnReservedFuel` - Boolean flag (0/1)
- `EmptyFuel` - Boolean flag (0/1)
- `BatteryFailure` - Boolean flag (0/1)
- `ExtPwrPresent` - External power present (0/1)
- `ThermistorPresent` - Thermistor present (0/1)
- `BattTempCAvg` - Battery temperature in Celsius
- `VBattV` - Battery voltage in volts
- `VExtV` - External voltage in volts
- `Charger_mAH` - Charger mAh
- `Discharge_mAH` - Discharge mAh

### GetVersion

**Purpose**: Get comprehensive version and configuration information
**Response Format**: CSV with Component,Major,Minor,Build,Aux fields

**Example** (partial):

```
GetVersion
Component,Major,Minor,Build,Aux
BaseID,0.0,0.0,0,0,
Beehive URL, beehive.neatocloud.com,
BlowerType,1,BLOWER_ORIG,
Bootloader Version,5e1d6652,,
MainBoard Serial Number,GPC36320,d003eb305754,
MainBoard Version,5,,
Model,BotVacD7Connected,905-0415,
Serial Number,GPC36520,d003eb305754,P
Software,4,6,0,72,0
Time Local,Wed Dec 17 22:18:28 2025
Time UTC,Wed Dec 17 22:18:28 2025
```

**Important Fields**:

- `MainBoard Serial Number` - Main board serial (first field) + hardware ID (second field)
- `MainBoard Version` - Main board version
- `Model` - Robot model name + model number (e.g., "BotVacD7Connected,905-0415")
- `Serial Number` - Robot serial (structured format, see below)
- `Software` - Firmware version (Major,Minor,Build,Aux)
- `Time Local` - Local time on robot
- `Time UTC` - UTC time on robot
- `LDS Serial` - LDS (Laser Distance Sensor) serial
- `LDS Software` - LDS firmware version
- `SmartBatt` fields - Battery information

**Serial Number Format**:
The Serial Number field contains multiple comma-separated components with specific meaning:

```
Serial Number,<main_serial>,<hardware_id>,<variant_flag>
```

**Example**: `Serial Number,GPC36520,d003eb305754,P`

- `GPC36520` - Main serial number (primary identifier)
- `d003eb305754` - Hardware ID (appears to be MAC-like identifier)
- `P` - Variant or production flag

**Validation**: This format is confirmed by the robot's HTTPS API (port 4443) which returns:

```json
{
  "serial": "GPC36520-d003eb305754",
  "model": "BotVacD7Connected",
  "firmware": "4.6.0-72",
  "name": "Neato",
  "easyWifiConnectVersion": "advanced-3"
}
```

The API's `serial` field combines the main serial and hardware ID with a hyphen, confirming these are intentional structured data fields.

**Firmware Version Observations**:

- Multiple fields contain additional comma-separated data (e.g., "BotVacD7Connected,905-0415,")
- These extra fields are **intentional structured data**, not CSV parsing artifacts
- **Unclear if this format existed in 4.5.3** - needs testing to confirm
- The official manual states: "The order and number of the rows and columns is not guaranteed to stay the same from release to release"

**Examples of fields with structured data in firmware 4.6.0**:

- `Model,BotVacD7Connected,905-0415,` → Model name + model number
- `MainBoard Serial Number,GPC36320,d003eb305754,` → Serial + hardware ID
- `Serial Number,GPC36520,d003eb305754,P` → Main serial + hardware ID + variant flag

**Parser Behavior**:
The original parser naturally handles this correctly by using standard CSV parsing which extracts values between commas. Since only the label (first field) is matched, the parser automatically uses only the first value field and ignores additional comma-separated data.

**Note**: The additional fields contain supplementary hardware identification data that is intentionally structured this way.

### GetUserSettings

**Purpose**: Get user preferences and settings
**Response Format**: Key-value pairs with comma separation

**Example**:

```
GetUserSettings
Language, EL_NONE
ClickSounds, ON
LED, ON
Wall Enable, ON
Eco Mode, OFF
IntenseClean, OFF
WiFi, ON
Melody Sounds, OFF
Warning Sounds, OFF
Bin Full Detect, OFF
Filter Change Time (seconds), 43200
Brush Change Time (seconds), 259200
Dirt Bin Alert Reminder Interval (minutes), 90
Current Dirt Bin Runtime is: 37260
Number of Cleanings where Dust Bin was Full is: 0
Schedule is Disabled
```

**Fields**:

- `Language` - Language setting (e.g., EL_NONE)
- `ClickSounds` - ON/OFF
- `LED` - ON/OFF
- `Wall Enable` - ON/OFF (magnetic boundary strip)
- `Eco Mode` - ON/OFF
- `IntenseClean` - ON/OFF
- `WiFi` - ON/OFF
- `Melody Sounds` - ON/OFF
- `Warning Sounds` - ON/OFF
- `Bin Full Detect` - ON/OFF
- `Filter Change Time (seconds)` - Numeric value
- `Brush Change Time (seconds)` - Numeric value
- `Dirt Bin Alert Reminder Interval (minutes)` - Numeric value
- `Current Dirt Bin Runtime is` - Numeric value
- `Number of Cleanings where Dust Bin was Full is` - Numeric value
- `Schedule` - Enabled/Disabled

**Notes**:

- Schedule entries appear after "Schedule is Disabled" with non-printable characters
- Format appears to be day/time entries with `-None-` indicating no schedule

### GetWarranty

**Purpose**: Get warranty and usage statistics
**Response Format**: CSV with Item,Value pairs (values in hexadecimal)

**Example**:

```
GetWarranty
Item,Value
CumulativeCleaningTimeInSecs,000e768f
CumulativeBatteryCycles,02ce
ValidationCode,0fec7271
```

**Fields**:

- `CumulativeCleaningTimeInSecs` - Total cleaning time in seconds (hex)
- `CumulativeBatteryCycles` - Total battery cycles (hex)
- `ValidationCode` - Validation code (hex)

**Parsing**:
Values are in hexadecimal and must be converted to decimal:

- `000e768f` hex = 947855 decimal seconds
- `02ce` hex = 718 decimal battery cycles

### TestMode

**Purpose**: Get test mode status
**Response Format**:

```
TestMode: <status>
```

**Example**:

```
TestMode
TestMode: Off
```

**Known Status Values**:

- `Off` - Test mode is disabled
- (Other states to be discovered)

## Failed Commands (Firmware 4.6.0)

These commands returned "Unknown Cmd" error:

### Err

Attempted as a shortened version of GetErr, but not recognized.

**Response**:

```
Err
Unknown Cmd: 'Err'
```

### tState

Attempted as a shortened version of GetState, but not recognized.

**Response**:

```
tState
Unknown Cmd: 'tState'
```

## Commands Not Yet Tested (From Official Documentation & Community Research)

The following commands are documented in the official Neato Programmer's Manual (for XV series) and various community projects. Many should work on BotVac/D-series models with firmware 4.6.0, but have not been tested yet.

### Informational Commands (Read-Only)

#### GetAccel

**Purpose**: Get accelerometer readings
**Expected Response**: Pitch, roll, X/Y/Z axes readings in G-force
**Status**: Documented in XV manual, implemented in neato-serial Python library

#### GetButtons

**Purpose**: Get button states
**Expected Response**: UI button states (soft key, scroll, start, back)
**Status**: Documented in XV manual

#### GetDigitalSensors

**Purpose**: Get digital sensor readings
**Expected Response**: Digital sensor states (dock connection, dustbin, wheels, bump sensors)
**Options**:

- Default format
- `raw` - Raw millivolt readings
- `stats` - Statistical analysis
  **Status**: Documented in XV manual

#### GetAnalogSensors

**Purpose**: Get analog sensor A2D readings
**Expected Response**: A2D sensor values
**Options**:

- Default format
- `raw` - Raw millivolt readings
- `stats` - Statistical analysis
  **Status**: Documented in XV manual

#### GetMotors

**Purpose**: Get motor states/speeds
**Expected Response**: Motor diagnostics including Vacuum_RPM
**Options**: Brush, Vacuum, LeftWheel, RightWheel, Laser, Charger
**Status**: Documented in XV manual

#### GetLDSScan

**Purpose**: Get LDS (Laser Distance Scanner) scan data
**Expected Response**: LDS scan packet data with distance measurements
**Status**: Documented in XV manual

#### GetSchedule

**Purpose**: Get cleaning schedule
**Expected Response**: Cleaning schedule in 24-hour format by day
**Status**: Documented in XV manual

#### GetTime

**Purpose**: Get robot scheduler time
**Expected Response**: Current scheduler time
**Status**: Documented in XV manual

#### GetCalInfo

**Purpose**: Get calibration data
**Expected Response**: Calibration parameters from system control block
**Status**: Documented in XV manual

#### GetSysLog

**Purpose**: Get system log data
**Expected Response**: System log entries
**Status**: Documented in XV manual

### Cleaning Control Commands

#### Clean

**Purpose**: Start cleaning
**Syntax**:

- `Clean` or `Clean House` - Start house cleaning (default mode)
- `Clean Room` - Start single room cleaning
- `Clean Spot [width] [height]` - Start spot cleaning
- `Clean Stop` - Stop cleaning
  **Status**: Documented in XV manual
  **Note**: BotVac/D-series may have additional cleaning modes

#### wake-up

**Purpose**: Wake up the robot for communication
**Usage**: Sent before main commands to activate the device
**Status**: Used in neato-serial Python library

### Configuration Commands

#### SetMotor

**Purpose**: Set motor speed (TestMode required)
**Syntax**: `SetMotor <motor> <speed> <accel>`
**Parameters**:

- motor: Brush, Vacuum, LeftWheel, RightWheel, Laser, Charger
- speed: RPM or speed value
- accel: Acceleration value
  **Status**: Documented in XV manual
  **Restriction**: Requires TestMode On

#### SetLED

**Purpose**: Control LEDs (TestMode required)
**Syntax**: `SetLED <led> <state>`
**States**: on, off, blink, dim
**LEDs**: LCD backlight, button LEDs
**Status**: Documented in XV manual
**Restriction**: Requires TestMode On

#### SetLCD

**Purpose**: Manage LCD display (TestMode required)
**Syntax**: `SetLCD <parameters>`
**Parameters**: Background color, lines, contrast (0-63)
**Status**: Documented in XV manual
**Restriction**: Requires TestMode On
**Note**: D7 Connected has no LCD panel (UI Name: NONE)

#### SetLDSRotation

**Purpose**: Enable/disable laser scanner rotation (TestMode required)
**Syntax**: `SetLDSRotation On/Off`
**Status**: Documented in XV manual
**Restriction**: Requires TestMode On

#### SetTime

**Purpose**: Set robot scheduler time
**Syntax**: `SetTime <day> <hour> <minute> [seconds]`
**Status**: Documented in XV manual

#### SetFuelGauge

**Purpose**: Calibrate battery fuel gauge
**Syntax**: `SetFuelGauge <percent>`
**Status**: Documented in XV manual
**Warning**: Calibration command - use with caution

#### SetSchedule

**Purpose**: Modify cleaning schedule
**Syntax**: `SetSchedule <day> <time> <mode>`
**Status**: Documented in XV manual

#### SetSystemMode

**Purpose**: Set system operation mode (TestMode required)
**Syntax**: `SetSystemMode <mode>`
**Modes**: shutdown, hibernate, standby
**Status**: Documented in XV manual
**Restriction**: Requires TestMode On

#### SetDistanceCal

**Purpose**: Calibrate distance sensors
**Options**: drop/wall minimum/middle/maximum
**Status**: Documented in XV manual
**Warning**: Calibration command - use with caution

#### SetWallFollower

**Purpose**: Enable/disable wall detection feature
**Syntax**: `SetWallFollower On/Off`
**Status**: Documented in XV manual

#### SetStreamFormat

**Purpose**: Configure I/O stream format
**Syntax**: `SetStreamFormat <format>`
**Formats**: term (terminal), packet
**Status**: Documented in XV manual

#### RestoreDefaults

**Purpose**: Reset settings to factory defaults
**Syntax**: `RestoreDefaults [Language]`
**Status**: Documented in XV manual
**Warning**: Destructive operation

### Sound & User Interface

#### PlaySound

**Purpose**: Play sound by ID
**Syntax**: `PlaySound <id>`
**Sound IDs**: 0-20 (includes startup, completion, alerts)
**Status**: Documented in XV manual

### System & Diagnostic Commands

#### help

**Purpose**: List all available commands
**Syntax**: `help` or `help <commandname>`
**Status**: Documented in XV manual

#### DiagTest

**Purpose**: Run diagnostic tests
**Syntax**: `DiagTest <test>`
**Status**: Mentioned in community documentation

#### Upload

**Purpose**: Firmware updates
**Syntax**: `Upload <module>`
**Modules**: code, sound, LDS
**Status**: Documented in XV manual
**Warning**: Advanced operation - can brick robot if interrupted

### TestMode Commands

TestMode must be enabled to use certain advanced commands (SetMotor, SetLED, SetLCD, SetLDSRotation, SetSystemMode).

**Enable**: `TestMode On`
**Disable**: `TestMode Off`
**Check Status**: `TestMode`
**Status**: ✅ Known to work in firmware 4.5.3, confirmed working in firmware 4.6.0

## Commands Specific to BotVac/D-Series (Not in XV Manual)

### GetUserSettings

**Purpose**: Get user preferences and settings
**Response**: Language, ClickSounds, LED, Wall Enable, Eco Mode, IntenseClean, WiFi, Melody Sounds, Warning Sounds, Bin Full Detect, Filter Change Time, Brush Change Time, Dirt Bin Alert Reminder, Schedule status
**Status**: ✅ Known to work in firmware 4.5.3, confirmed working in firmware 4.6.0
**Credit**: Implemented in original ESPHome neato_vacuum.yaml configuration

### Potential D-Series Commands (Not Yet Tested)

Based on GetUserSettings fields, these set commands may exist:

- `SetClickSounds On/Off`
- `SetLED On/Off` (different from TestMode SetLED)
- `SetWallEnable On/Off`
- `SetEcoMode On/Off`
- `SetIntenseClean On/Off`
- `SetWiFi On/Off`
- `SetMelodySounds On/Off`
- `SetWarningSounds On/Off`
- `SetBinFullDetect On/Off`
- `SetFilterChangeTime <seconds>`
- `SetBrushChangeTime <seconds>`
- `SetDirtBinAlertReminder <minutes>`

## Hidden/Undocumented Commands (Discovered via Reverse Engineering)

The following commands were discovered through reverse engineering of firmware 3.2.0 and confirmed to work in firmware 4.5.3. They are not documented in the official XV Programmer's Manual.

**Credit**: These commands were discovered and documented in the original ESPHome neato_vacuum.yaml project's `hidden-commands.md` file.

### Diagnostic & Logging Commands

#### Log

**Purpose**: Manage robot logs
**Syntax**:

- `Log Text <text>` - Write text to log
- `Log Flush` - Flush log entries
  **Status**: Confirmed in firmware 4.5.3 (via reverse engineering of 3.2.0)

#### GetActiveServices

**Purpose**: Display all running services
**Status**: Confirmed in firmware 4.5.3

#### GetLoggingType

**Purpose**: Display the type of log (QA, NavPen, or Production)
**Status**: Confirmed in firmware 4.5.3

#### USBLogCopy

**Purpose**: Copy all logs onto a USB drive
**Status**: Confirmed in firmware 4.5.3

#### CopyDumps

**Purpose**: Copy all core dumps to emmc and pack them
**Status**: Confirmed in firmware 4.5.3

### Error & Alert Management

#### SetUIError

**Purpose**: Manage UI State Machine errors and alerts
**Syntax**:

- `SetUIError brief` - Sets a UI State Machine Error/Alert
- `SetUIError clearall` - Clears all UI Alerts and Errors
- `SetUIError list` - Lists all UI Alerts and Errors
- `SetUIError clearalert` - Clears the specified UI Alert or Error
- `SetUIError setalert` - Sets the specified UI Alert or Error
  **Status**: Confirmed in firmware 4.5.3

#### SetApp

**Purpose**: Set alert/error to be sent to app
**Syntax**: `SetApp Alert`
**Status**: Confirmed in firmware 4.5.3
**Note**: Exact functionality unknown

### Robot Position & Navigation

#### GetRobotPos

**Purpose**: Get robot position
**Syntax**:

- `GetRobotPos Raw` - Return Odometry
- `GetRobotPos Smooth` - Return smoothed/localized position
  **Status**: Confirmed in firmware 4.5.3

### System Information

#### GetRobotPassword

**Purpose**: Returns the robot's saved random password
**Status**: Confirmed in firmware 4.5.3
**Security Note**: Sensitive command

#### GetDatabase

**Purpose**: Show database tables
**Syntax**: `GetDatabase <option>`
**Options**: All, Factory, Robot, Runtime, Statistics, System, CleanStats
**Status**: Confirmed in firmware 4.5.3
**Note**: Exact data format unknown

#### GetStats

**Purpose**: Show system statistics
**Status**: Confirmed in firmware 4.5.3
**Note**: Response with "Not supported yet..." on some firmware versions

### WiFi Diagnostics

#### GetWifiStatus

**Purpose**: WiFi diagnostic information
**Syntax**:

- `GetWifiStatus mfgtest` - MFG test to determine if WiFi chip is present
- `GetWifiStatus registry` - Show WiFi registries
- `GetWifiStatus sloginfo` - Show sloginfo
- `GetWifiStatus sloginfo pattern <pattern>` - Display sysloginfo matching pattern
- `GetWifiStatus sloginfo pattern <pattern1> pattern2 <pattern2>` - Match both patterns
- `GetWifiStatus sloginfo pattern <pattern> exclude <pattern>` - Match pattern, exclude another
- `GetWifiStatus wpacfg` - Show /emmc/wpa_supplicant.cfg file
- `GetWifiStatus sloginfo clear 1` - Copy sloginfo to /emmc/black_box/sloginfo.txt and clear
  **Status**: Confirmed in firmware 4.5.3

### Hardware Diagnostics

#### GetI2CBlowerInfo

**Purpose**: Get I2C Blower Registers (complete list)
**Status**: Confirmed in firmware 4.5.3
**Restriction**: TestMode only

#### RunUSMFGTest

**Purpose**: Run Ultrasonic MFG Test
**Status**: Confirmed in firmware 4.5.3
**Note**: Exact functionality unknown

#### TestPWM

**Purpose**: Unknown
**Status**: Confirmed in firmware 4.5.3
**Note**: No documentation available

### Calibration Commands

#### CalibrateSensor

**Purpose**: Automatically calibrate sensors and store values into SCB
**Status**: Confirmed in firmware 4.5.3
**Restriction**: Requires security key (method unknown)
**Warning**: Calibration command - use with extreme caution

#### CalibrateAccelerometer

**Purpose**: Calibrate the accelerometer's X/Y positions
**Status**: Confirmed in firmware 4.5.3
**Restriction**: Requires security key (method unknown)
**Warning**: Calibration command - use with extreme caution

### Software Update

#### UpdateSW

**Purpose**: Software update management
**Syntax**:

- `UpdateSW GetStatus` - Returns status of SW update
- `UpdateSW Verify` - Returns status of SW update verification
- `UpdateSW Terminate` - Force shutdown of SoftwareManager
  **Status**: Confirmed in firmware 4.5.3
  **Warning**: Can affect robot operation

### Battery Management

#### NewBattery

**Purpose**: Tell the robot a new battery has been installed
**Status**: Confirmed in firmware 4.5.3
**Note**: Some users report this can fix issues where a new battery isn't being charged properly
**Use Case**: Reset battery learning algorithm

### File Management

#### ClearFiles

**Purpose**: Clear various file categories
**Syntax**:

- `ClearFiles BB` - Clear managed logs in BlackBox directory
- `ClearFiles All` - Additionally clear unmanaged files (Crash, etc.)
- `ClearFiles Life` - Unknown functionality
  **Status**: Confirmed in firmware 4.5.3
  **Warning**: Destructive operation

### Advanced Clean Options

#### Clean (Extended Options)

**Purpose**: Advanced cleaning modes beyond basic Clean command
**Additional Syntax**:

- `Clean Persistent` - Equivalent to starting persistent cleaning from Smart App
- `Clean Width <cm>` - Spot width in CM (100-400, -1=use default)
- `Clean Height <cm>` - Spot height in CM (100-400, -1=use default)
- `Clean AutoCycle` - Auto cycle mode (cleared by shutdown or 'Clean Stop')
- `Clean MinCharge <percent>` - Minimum charge level to trigger recharge (-1=default 50%)
- `Clean CleaningEnable` - Enable brush and vacuum during cleaning
- `Clean CleaningDisable` - Disable brush and vacuum during cleaning
- `Clean IEC1mTest` - Run IEC cleaning test
- `Clean MaxModeEnable` - Enable max cleaning mode
- `Clean MaxModeDisable` - Disable max cleaning mode
  **Status**: Confirmed in firmware 4.5.3
  **Note**: Some options mutually exclusive (see hidden-commands.md for details)

## Error Codes

### Alert Codes (200 series)

- `200` - UI_ALERT_INVALID (no alert)

### Navigation Alerts (239-241)

- `239` - UI_ALERT_NAV_FLOORPLAN_NOT_CREATED
- `240` - UI_ALERT_NAV_FLOORPLAN_ZONE_UNREACHABLE
- `241` - UI_ALERT_NAV_FLOORPLAN_ZONE_WRONG_FLOOR

### Error Codes (223+)

#### Battery Errors (223, 251, 269-282)

- `223` - UI_ALERT_BATTERY_ChargeBaseCommErr - Battery fault
- `251` - UI_ERROR_BATTERY_OVERTEMP - Battery fault
- `269` - UI_ERROR_BATTERY_CRITICAL - Battery fault
- `270` - UI_ERROR_BATTERY_OverVolt - Battery fault
- `271` - UI_ERROR_BATTERY_UnderVolt - Battery fault
- `272` - UI_ERROR_BATTERY_UnderCurrent - Battery fault
- `273` - UI_ERROR_BATTERY_Mismatch - Battery fault
- `274` - UI_ERROR_BATTERY_LithiumAdapterFailure - Battery fault
- `275` - UI_ERROR_BATTERY_UnderTemp - Battery fault
- `276` - UI_ERROR_BATTERY_Unplugged - Battery fault
- `277` - UI_ERROR_BATTERY_NoThermistor - Battery fault
- `278` - UI_ERROR_BATTERY_BattUnderVoltLithiumSafety - Battery fault
- `279` - UI_ERROR_BATTERY_InvalidSensor - Battery fault
- `280` - UI_ERROR_BATTERY_PermanentError - Battery fault
- `281` - UI_ERROR_BATTERY_Fault - Battery fault

#### Dust Bin Errors (249-250)

- `249` - UI_ERROR_DUST_BIN_MISSING - Put dirt bin back in
- `250` - UI_ERROR_DUST_BIN_FULL - Please empty my dirt bin and filter

#### Movement Errors (255-258)

- `255` - UI_ERROR_PICKED_UP - Please put me down
- `256` - UI_ERROR_RECONNECT_FAILED - Move base to new location
- `257` - UI_ERROR_LWHEEL_STUCK - Clean my left wheel
- `258` - UI_ERROR_RWHEEL_STUCK - Clean my right wheel

#### LDS (Laser Distance Sensor) Errors (259-264)

- `259` - UI_ERROR_LDS_JAMMED - Press button on robot to continue (1000)
- `260` - UI_ERROR_LDS_DISCONNECTED - Press button on robot to continue (5000)
- `261` - UI_ERROR_LDS_MISSED_PACKETS - Reboot me
- `262` - UI_ERROR_LDS_BAD_PACKETS - Press button on robot to continue (4000)
- `263` - UI_ERROR_LDS_LASER_OVER_POWER - Vision error (4101)
- `264` - UI_ERROR_LDS_LASER_UNDER_POWER - Vision error (4102)

#### Brush/Vacuum Errors (265-267)

- `265` - UI_ERROR_BRUSH_STUCK - Clean my brush
- `266` - UI_ERROR_BRUSH_OVERLOAD - Clean my brush
- `267` - UI_ERROR_VACUUM_STUCK - Press button on robot to continue

#### Navigation Errors (282-296)

- `282` - UI_ERROR_NAVIGATION_UndockingFailed - Clear my path (2000)
- `283` - UI_ERROR_NAVIGATION_Falling - Clear my path (2001)
- `285` - UI_ERROR_NAVIGATION_NoMotionCommands - Clear my path (2003) - I'm stuck
- `286` - UI_ERROR_NAVIGATION_BackDrop_LeftBump - Clear my path (2004)
- `287` - UI_ERROR_NAVIGATION_BackDrop_FrontBump - Clear my path (2005)
- `288` - UI_ERROR_NAVIGATION_BackDrop_WheelExtended - Clear my path (2006)
- `289` - UI_ERROR_NAVIGATION_RightDrop_LeftBump - Clear my path (2007)
- `290` - UI_ERROR_NAVIGATION_NoExitsToGo - Clear my path (2008)
- `291` - UI_ERROR_NAVIGATION_PathProblems_ReturningHome
- `292` - UI_ERROR_NAVIGATION_NoProgress - Clear my path (2010)
- `293` - UI_ERROR_NAVIGATION_BadMagSensor - Clear my path (2012)
- `295` - UI_ERROR_NAVIGATION_PathBlocked_GoingToZone - The path to a zone is blocked (2013)

#### Other Errors

- `296` - UI_ERROR_SHUTDOWN - Remove me from base to shut down
- `306` - UI_ERROR_DECK_DEBRIS - Dust me off
- `307` - UI_ERROR_RDROP_STUCK - Clear right drop sensor
- `308` - UI_ERROR_LDROP_STUCK - Clear left drop sensor

## Hardware Configuration (D7 Connected)

### Robot Specifications

- **Model**: BotVacD7Connected
- **Model Number**: 905-0415
- **Chassis Revision**: 1
- **Main Board Version**: 5

### Sensors

- **LDS (Laser Distance Sensor)**:
  - CPU: STM32F303CCTx/Y
  - Software: V4.0.0,20
  - Motor Type: 2 (LDS_MOTOR_MABUCHI)
- **Drop Sensor Type**: 1 (DROP_SENSOR_ORIG)
- **Mag Sensor Type**: 1 (MAG_SENSOR_ORIG)
- **Wall Sensor Type**: 1 (WALL_SENSOR_ORIG)

### Motors & Actuators

- **Blower Type**: 1 (BLOWER_ORIG)
- **Vacuum Power**: 70 (normal), 60 (eco)
- **Brush Motor Type**: 1 (BRUSH_MOTOR_ORIG)
- **Brush Speed**: 1400 RPM (normal), 1100 RPM (eco)
- **Brush Motor Resistor**: 100Ω, 500mW
- **Side Brush Type**: 2 (SIDE_BRUSH_PRESENT)
- **Side Brush Power**: 1500
- **Wheel Pod Type**: 1 (WHEEL_POD_ORIG)

### Battery

- **Type**: Lithium-Ion (LION1)
- **Manufacturer**: Panasonic
- **Device Name**: F164A10288
- **Data Version**: 512
- **Software Version**: 2048
- **Smart Battery Authorization**: 1

### Connectivity

- **WiFi**: Supported
- **Beehive URL**: beehive.neatocloud.com
- **Nucleo URL**: nucleo.neatocloud.com
- **NTP URL**: pool.ntp.org
- **HTTPS API**: Port 4443 (local robot API)

### Robot HTTPS API (Port 4443)

The robot exposes a local HTTPS API on port 4443 alongside the UART serial protocol.

**GET `/` Endpoint**:
Returns robot identification information in JSON format.

**Example Request**:

```bash
curl -k https://<robot_ip>:4443/
```

**Example Response**:

```json
{
  "serial": "GPC36520-d003eb305754",
  "model": "BotVacD7Connected",
  "firmware": "4.6.0-72",
  "name": "Neato",
  "easyWifiConnectVersion": "advanced-3"
}
```

**Fields**:

- `serial` - Robot serial number (format: `<main_serial>-<hardware_id>`)
- `model` - Robot model name
- `firmware` - Firmware version (format: `<major>.<minor>.<build>-<aux>`)
- `name` - Robot's user-assigned name
- `easyWifiConnectVersion` - WiFi connection version

**Note**: This API response format validates the structured serial number format seen in the UART `GetVersion` command. The serial from the API matches the first two fields of the `Serial Number` line from GetVersion, combined with a hyphen separator.

### User Interface

- **LCD Panel**: 0,0,0 (no LCD panel on D7 Connected)
- **UI Board Hardware**: 0,0
- **UI Board Software**: 0,0
- **UI Name**: NONE
- **UI Version**: NONE

### Locale

- **Locale**: 1 (LOCALE_USA)

## Boot Sequence Messages

When the robot boots, it sends these informational messages (not commands):

1. `Attempting to start slogger -s 1500k`
2. `Starting slogger -s 1500k`
3. `Booting Main Image`
4. `Starting OTG`
5. `LoadAccelerometerParameters: Starting`
6. `LoadAccelerometerParameters: Setting accelX to <value>`
7. `LoadAccelerometerParameters: Setting accelY to <value>`

These messages should be handled by a catch-all parser and logged for debugging purposes.

## Polling Behavior

The robot firmware appears to poll certain commands automatically:

- `GetErr` and `GetState` are called approximately every 2 seconds
- This polling continues during normal operation

## Firmware Version Differences

### 4.5.3 vs 4.6.0

**Note**: Direct comparison testing between 4.5.3 and 4.6.0 has not been performed. The observations below are based on firmware 4.6.0 testing only. It's unclear whether these behaviors are new in 4.6.0, existed in 4.5.3, or are general CSV format inconsistencies across all versions.

**GetVersion Response Observations (4.6.0)**:

- Some values contain extra comma-separated fields (e.g., "BotVacD7Connected,905-0415,")
- Status: Unknown if this is 4.6.0-specific or general behavior
- The original parser handles this correctly using standard CSV parsing

**GetState Response Observations**:

- Firmware 4.6.0 may include trailing newline/whitespace after robot state
- **Unclear if this is new in 4.6.0 or existed in 4.5.3** - needs testing to confirm
- The original parser handles whitespace correctly

**Software Version Field**:

- Format: `Software,<major>,<minor>,<build>,<aux>,<extra>`
- 4.6.0 example: `Software,4,6,0,72,0`

## Implementation Notes

### ESP32-C3 UART Configuration

For ESPHome integration with ESP32-C3:

- **TX Pin**: GPIO21
- **RX Pin**: GPIO20
- **Baud Rate**: 115200

### Parser Implementation Tips

1. **Line Delimiter**: Always look for `\x1A` as the end of a complete response
2. **Trimming**: Always trim whitespace from parsed values
3. **CSV Parsing**: Use robust CSV parsing for GetCharger, GetVersion, GetWarranty
4. **Hex Conversion**: GetWarranty values are in hex and need conversion to decimal
5. **Structured Fields**: Some values contain multiple comma-separated fields - standard CSV parsing handles this correctly by extracting only the value for the matched label
6. **Unknown Commands**: Implement catch-all parser to log unhandled responses
7. **Boot Messages**: Filter out boot sequence messages that aren't command responses

### State Machine Considerations

The robot can get stuck in certain states (e.g., UIMGR_STATE_HOUSECLEANINGRUNNING) even when idle. A robot reboot clears stuck states.

## Testing & Discovery

### Quick Test Commands

A comprehensive test sequence includes:

1. GetErr
2. GetState
3. GetCharger
4. GetVersion
5. GetUserSettings
6. GetWarranty
7. TestMode

### Command Discovery Process

1. Use debug text input to send custom commands
2. Monitor catch-all parser for responses
3. Look for "Unknown Cmd" responses to identify unsupported commands
4. Check for valid responses to identify supported commands

## References

### Official Documentation

**Neato XV Programmer's Manual (Version 3.1)**

- PDF: https://help.neatorobotics.com/wp-content/uploads/2020/07/XV-ProgrammersManual-3_1.pdf
- Alternative: https://www.robotreviews.com/files/programmersmanual_20140305.pdf
- Hosted on GitHub: https://github.com/jeroenterheerdt/neato-serial/blob/master/XV-ProgrammersManual-3_1.pdf
- ManualsLib: https://www.manualslib.com/manual/2134159/Neato-Robotics-Xv.html
- Scribd: https://www.scribd.com/document/361967622/Neato-Programmer-s-Manual

**Note**: While titled for XV series, this manual documents the serial protocol that is largely compatible with BotVac and D-series robots. Newer models (BotVac/D-series) have additional commands not in this manual.

**Neato Developer Network**

- URL: https://developers.neatorobotics.com/
- Provides: RESTful APIs for cloud-connected robots (iOS, Android, JavaScript SDKs)
- Status: ⚠️ **DEPRECATED - Cloud services shutting down Q4 2025**
- **Note**: This is why local serial control is critical for D-series Connected robots

### Community Documentation

**Robot Reviews Forum**

- Command Table: http://www.robotreviews.com/chat/viewtopic.php?f=20&t=14008
- Programming Guide: https://www.robotreviews.com/chat/viewtopic.php?t=17911
- ESP8266 Remote Control: http://www.robotreviews.com/chat/viewtopic.php?f=20&t=19972
- NeatoControl Tool: https://www.robotreviews.com/chat/viewtopic.php?t=18173
- Firmware Discussions: https://www.robotreviews.com/chat/viewtopic.php?f=20&t=23185

**Neato XV-11 Wiki**

- RECESSIM Wiki: https://wiki.recessim.com/w/index.php?title=Neato_XV-11

### Open Source Projects

**Python Libraries**

- **neato-serial**: https://github.com/jeroenterheerdt/neato-serial

  - Python serial interface for Neato robots (XV series tested, works on others)
  - Implements: GetErr, GetCharger, GetAccel, GetAnalogSensors, GetButtons, GetCalInfo, GetDigitalSensors, GetLDSScan, GetMotors, GetVersion, wake-up

- **pybotvac**: https://github.com/stianaske/pybotvac

  - Python module for Neato Botvac Connected robots
  - Forks: https://github.com/dshokouhi/pybotvac, https://github.com/nathanfaber/pybotvac

- **botvac (Ruby)**: https://github.com/kangguru/botvac
  - Unofficial API client for Neato cloud services

**Serial to WiFi Bridge Projects**

- **botvac-wifi**: https://github.com/sstadlberger/botvac-wifi

  - ESP8266-based serial to websocket bridge
  - Forks: https://github.com/HawtDogFlvrWtr/botvac-wifi, https://github.com/jeroenterheerdt/botvac-wifi

- **Neato Scheduler (12458 fork)**: https://github.com/12458/botvac-wifi
  - ESP8266 WiFi serial adapter framework for BotVac 65, 70e, 75, 80, 85, D75, D80, D85

**Firmware Archives**

- **neato-botvac**: https://github.com/RobertSundling/neato-botvac

  - Firmware images for D3, D3 Pro, D4, D5, D7 models
  - Releases: https://github.com/RobertSundling/neato-botvac/releases

- **Internet Archive**: https://archive.org/details/neato_202306
  - Neato Botvac Connected firmware updates archive

**Home Automation Integrations**

- **OpenHAB Neato Binding**: https://www.openhab.org/addons/bindings/neato/
- **SmartThings Integration**: https://community.smartthings.com/t/release-neato-connect-v1-2-6c-botvac-connected-series/60039
- **MySensors Forum**: https://forum.mysensors.org/topic/2619/hacking-a-neato-robotics-botvac-connected

**GitHub Topics**

- neato topic: https://github.com/topics/neato
- Collection of all Neato-related projects on GitHub

### ESPHome Integration

**Original Project (Firmware 4.5.3)**:

- Project: ESPHome neato_vacuum.yaml configuration
- Implemented commands: GetErr, GetState, GetCharger, GetVersion, GetUserSettings, GetWarranty, TestMode
- Hidden command discovery: Reverse engineering of firmware 3.2.0/4.5.3
- Documentation: `hidden-commands.md` file with undocumented commands

**This Project (Firmware 4.6.0 Adaptation)**:

- Hardware: ESP32-C3 adaptation (GPIO21/GPIO20 for UART)
- Parser improvements: Defensive CSV parsing for extra comma-separated fields
- Debug tools: Quick Test button, text input entity, catch-all logging
- Documentation: `NEATO_FIRMWARE_DOCUMENTATION.md` (this file)
- Shell helper: `esphome.sh` (Docker CLI wrapper)
- Contribution: Confirmed 4.5.3 → 4.6.0 compatibility for all tested commands
- Configuration: `neato-esp.yaml` lambda functions

### Important Notes

**Model Compatibility**

- **XV Series (2010-2013)**: XV-11, XV-21, XV-25, XV Signature, XV Signature Pro

  - Official programmer's manual available
  - Full USB port access standard

- **BotVac Series (2013-2016)**: BotVac 65, 70e, 75, 80, 85, D75, D80, D85

  - Compatible with XV manual commands
  - Some models have USB port, others require internal serial header access

- **D-Series Connected (2016-2023)**: D3, D4, D5, D6, D7
  - **D7 Connected tested with firmware 4.6.0 (build 72)**
  - Additional commands: GetUserSettings, potentially more Set commands
  - Firmware 4.6.0 parser changes documented in this file
  - Some models lack external USB port (internal serial header required)

**Communication Methods**

1. **USB Port**: External USB mini connector (if available on older models)
2. **Internal Serial Header**: 3.3V UART on main board (GPIO access) - **RECOMMENDED for D-series**
3. **Cloud API**: RESTful API - ⚠️ **SHUTTING DOWN Q4 2025** - Do not use for new projects
4. **WiFi Bridge**: ESP8266/ESP32 serial-to-WiFi bridge - **FUTURE-PROOF SOLUTION** (this project uses ESP32-C3)

**Why Local Serial Control Matters:**

- D-series Connected robots were designed to be cloud-dependent
- After Q4 2025, they will be non-functional without local control
- This serial protocol provides the **only path forward** for continued operation
- Local control is faster, more reliable, and privacy-friendly
- No dependency on external servers or internet connectivity

**Firmware Version Detection**
Use `GetVersion` command to check:

- Software field format: `Software,<major>,<minor>,<build>,<aux>,<extra>`
- Example firmware 4.6.0: `Software,4,6,0,72,0`
- Git SHA: `Software Git SHA,4a8a939` (for firmware 4.6.0 build 72)

## Credits & Acknowledgments

This documentation builds upon extensive prior work by the Neato hacking community:

- **Original ESPHome Implementation**: neato_vacuum.yaml configuration for firmware 4.5.3

  - Implemented GetErr, GetState, GetCharger, GetVersion, GetUserSettings, GetWarranty, TestMode parsers
  - Discovered and documented hidden commands via reverse engineering (hidden-commands.md)

- **Neato XV Programmer's Manual**: Official command reference from Neato Robotics

  - Foundation for understanding the serial protocol

- **Community Projects**:
  - neato-serial Python library (jeroenterheerdt)
  - Robot Reviews forum community (command discovery and testing)
  - botvac-wifi ESP8266 bridge projects

**This Documentation's Contribution**:

- Confirmed firmware 4.5.3 → 4.6.0 compatibility for all tested commands
- Consolidated knowledge from official docs, community projects, and reverse engineering
- Documented serial number format and structured data fields via HTTPS API validation
- Documented critical context (cloud shutdown, preservation effort)
- Created comprehensive reference for future robot owners

## Revision History

- **2025-12-17**: Initial comprehensive documentation
  - **Firmware 4.6.0 compatibility testing**: Confirmed GetErr, GetState, GetCharger, GetVersion, GetUserSettings, GetWarranty, TestMode all work (previously known working in 4.5.3)
  - **Serial number format discovery**: Documented structured format of serial numbers via HTTPS API validation
    - Serial Number format: `<main_serial>,<hardware_id>,<variant_flag>`
    - HTTPS API endpoint documented (port 4443, GET `/`)
    - Validated that extra comma-separated fields are intentional structured data, not parsing artifacts
    - Confirmed original parser handles structured data correctly using standard CSV parsing
  - **Failed commands identified**: Err, tState (not recognized in 4.6.0)
  - **Error code mapping**: Documented codes 200-308 from command_mapping.csv
  - **Consolidated documentation**:
    - XV Programmer's Manual commands
    - neato-serial Python library commands
    - Hidden commands from reverse engineering (credit: original neato_vacuum.yaml project)
    - Official and community documentation references
  - **Model compatibility**: Documented XV vs BotVac vs D-series differences
  - **Critical context**: Added preservation rationale (Neato cloud shutdown Q4 2025)
  - **Proper attribution**: Credited original work and community contributions
