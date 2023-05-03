# T1GER GOLD CURRENCY

## SHOWCASE:
https://youtu.be/p_Yz2f_CLl4

## FRAMEWORK:
- [ESX Legacy](https://github.com/esx-framework/esx_core)

## DEPENCENCIES:
- [progressBars (OPTIONAL)](https://gitlab.com/t1ger-scripts/t1ger-requirements/-/tree/main/progressBars)

## INSTALLATION:
1. Drag & drop the folder into your `resources` server folder.
2. Configure config.lua to match & satisfy your needs/requirements.
3. Import items.sql into your database
4. Add `start t1ger_goldcurrency` to your server config.

## DISCORD:
https://discord.gg/FdHkq5q

### Weight / Limit
- Make sure to set Config.ItemWeightSystem accordingly to whether u are using Weight or Limit system for items.

### Config.ProgressBars
- Disable Config.ProgressBars if you want to use your own or just deactive it.

### Config.DatabaseItems
- Make sure the items you've added in your database matches exactly this config table.
- Only change the right side, example: ['goldwatch'] = 'goldwatch'
- Edited: ['goldwatch'] = 'watchgold'
- So right side is the name of the item in your database.

### Config.JobVehicles
- In this table add as many job vehicles you want - yes, it now supports multiple vehicles. 

### Config.Delivery
- Add/remove delivery locations.
- This is the spot where drug vehicles are delivered.

### GCPHONE / PHONE MESSAGES
- By default my script supports GCPhone with phone messages. 
- In utils.lua find this function: JobNotifyMSG
- TriggerServerEvent('gcPhone:sendMessage', phoneNr, msg) - is the event that sends the message. 
- If u have white screen issue, then your GCPHONE is messed up somehow, in that case have a look here and maybe use this version: https://forum.cfx.re/t/solved-gcphone-white-screen-issue/716438
- Again, this is an extra feature, i do not support your GCPHONE being fucked up.