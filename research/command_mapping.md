### Command mapping for gen3 robots

```csv
Error, Message, Detail message
223: UI_ALERT_BATTERY_ChargeBaseCommErr, Batter fault, tbd
239: UI_ALERT_NAV_FLOORPLAN_NOT_CREATED
240: UI_ALERT_NAV_FLOORPLAN_ZONE_UNREACHABLE
241: UI_ALERT_NAV_FLOORPLAN_ZONE_WRONG_FLOOR
249: UI_ERROR_DUST_BIN_MISSING, Put dirt bin back in
250: UI_ERROR_DUST_BIN_FULL, Please empty my dirt bin and filter, Empty dirt bin & filter and clean drop & wall sensors
251: UI_ERROR_BATTERY_OVERTEMP, Batter fault, tbd
255: UI_ERROR_PICKED_UP, Please put me down, tbd
256: UI_ERROR_RECONNECT_FAILED, Move base to new location, tbd
257: UI_ERROR_LWHEEL_STUCK, Clean my left wheel, tbd
258: UI_ERROR_RWHEEL_STUCK, Clean my right wheel, tbd
259: UI_ERROR_LDS_JAMMED, Press button on robot to continue (1000), tbd
260: UI_ERROR_LDS_DISCONNECTED, Press button on robot to continue (5000), tbd
261: UI_ERROR_LDS_MISSED_PACKETS, Reboot me, tbd
262: UI_ERROR_LDS_BAD_PACKETS, Press button on robot to continue (4000), tbd
263: UI_ERROR_LDS_LASER_OVER_POWER, Vision error (4101), Please press the start button on the robot to continue. 
264: UI_ERROR_LDS_LASER_UNDER_POWER, Vision error (4102), Please press the start button on the robot to continue. 
265: UI_ERROR_BRUSH_STUCK, Clean my brush
266: UI_ERROR_BRUSH_OVERLOAD, Clean my brush
267: UI_ERROR_VACUUM_STUCK, Press button on robot to continue
269: UI_ERROR_BATTERY_CRITICAL,Battery fault,tbd
270: UI_ERROR_BATTERY_OverVolt,Battery fault,tbd
271: UI_ERROR_BATTERY_UnderVolt,Battery fault,tbd
272: UI_ERROR_BATTERY_UnderCurrent,Battery fault,tbd
273: UI_ERROR_BATTERY_Mismatch,Battery fault,tbd
274: UI_ERROR_BATTERY_LithiumAdapterFailure,Battery fault,tbd
275: UI_ERROR_BATTERY_UnderTemp,Battery fault,tbd
276: UI_ERROR_BATTERY_Unplugged,Battery fault,tbd
277: UI_ERROR_BATTERY_NoThermistor,Battery fault,tbd
278: UI_ERROR_BATTERY_BattUnderVoltLithiumSafety,Battery fault,tbd
279: UI_ERROR_BATTERY_InvalidSensor,Battery fault,tbd
280: UI_ERROR_BATTERY_PermanentError,Battery fault,tbd
281: UI_ERROR_BATTERY_Fault,Battery fault,tbd
282: UI_ERROR_NAVIGATION_UndockingFailed, Clear my path (2000), tbd
283: UI_ERROR_NAVIGATION_Falling, Clear my path (2001), tbd
285: UI_ERROR_NAVIGATION_NoMotionCommands, Clear my path (2003), I'm stuck. Please free me - pick me up and move me no more than 2 feet so I can recover my location.
286: UI_ERROR_NAVIGATION_BackDrop_LeftBump, Clear my path (2004), tbd
287: UI_ERROR_NAVIGATION_BackDrop_FrontBump, Clear my path (2005), tbd
288: UI_ERROR_NAVIGATION_BackDrop_WheelExtended, Clear my path (2006), tbd
289: UI_ERROR_NAVIGATION_RightDrop_LeftBump, Clear my path (2007), tbd
290: UI_ERROR_NAVIGATION_NoExitsToGo, Clear my path (2008), tbd
291: UI_ERROR_NAVIGATION_PathProblems_ReturningHome, tbd
292: UI_ERROR_NAVIGATION_NoProgress, Clear my path (2010), tbd
293: UI_ERROR_NAVIGATION_BadMagSensor, Clear my path (2012), tbd
295: UI_ERROR_NAVIGATION_PathBlocked_GoingToZone, The path to a zone is blocked (2013), tbd
296: UI_ERROR_SHUTDOWN, Remove me from base to shut down, tbd
306: UI_ERROR_DECK_DEBRIS, Dust me off, tbd
307: UI_ERROR_RDROP_STUCK, Clear right drop sensor
308: UI_ERROR_LDROP_STUCK, Clear left drop sensor
```