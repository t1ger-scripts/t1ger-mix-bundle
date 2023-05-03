# T1GER INSURANCE

## SHOWCASE:
https://youtu.be/WpxTiwz-HAM

## CFX FORUM POST:
https://forum.cfx.re/t/esx-t1ger-insurance-w-broker-job-police-interaction-and-more/4765266/

## FRAMEWORK:
- [ESX Legacy](https://github.com/esx-framework/esx_core)

## DEPENDENCIES:
- [ESX Society (OPTIONAL)](https://github.com/esx-framework/esx_society)

## INSTALLATION:
1. Drag & drop the folder into your `resources` server folder.
2. Configure config.lua to match & satisfy your needs/requirements.
3. Import or execute `t1ger_insurance.sql` into your database
4. Install and ensure the necessary dependencies.
5. Add `start t1ger_insurance` to your server config.

## DISCORD:
https://discord.gg/FdHkq5q

### Utils
There is a utils.lua file in client folder.
Kindly read carefully on the comments etc. before editing, otherwise use my discord for support.

### AUTO PAY BILLS
Add this event:
    `TriggerClientEvent('t1ger_insurance:getInsuranceBill', xPlayer.source)`
inside this file: `es_extended/server/paycheck.lua`.
Example (look at line 11): https://gyazo.com/8120c0929fc2b662c9b5f17e66dc934e

### BILLING PRICE
For billing based on vehicle price, it requires you to have a model column in owned_vehicles table,
so the resource can get the vehicle price from the vehicles table in database. 
If you do not have a model column, then please set the appropriate Config setting and use the default billing prices.
