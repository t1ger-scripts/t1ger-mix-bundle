# T1GER TRAFFIC POLICER

## SHOWCASE:
https://youtu.be/0Zm5qMNV9SM

## CFX FORUM POST:
https://forum.cfx.re/t/esx-t1ger-traffic-policer-anpr-traffic-offences-breathalyzer-more/4817081/

## FRAMEWORK:
- [ESX Legacy](https://github.com/esx-framework/esx_core)

## DEPENCENCIES:
- [ProgressBars (OPTIONAL)](https://gitlab.com/t1ger-scripts/t1ger-requirements/-/tree/main/progressBars)

## INSTALLATION:
1. Drag & drop `t1ger_trafficpolicer` into your `resources` server folder.
2. Install & ensure the necessary requirement(s).
3. Configure Config.lua to match & satisfy your needs/requirements.
4. Run/Import `t1ger_trafficpolicer.sql` to your database.
5. Add `start t1ger_trafficpolicer` to your server config.
6. Make sure to fully read through the README!

## DISCORD:
https://discord.gg/FdHkq5q

### Breathalyzer Test & BAC
- Go to Config.Breathalyzer and configure the settings to your likeing. I've done major testings etc., and I finde those values best & most suitable.
- For all your alcohol items, which should have the effect, add this event in the usable item function: `TriggerClientEvent('t1ger_trafficpolicer:useAlcohol', xPlayer.source, 14)`
- The number 14 is the weight of alcohol in grams for that specific item. Keep these values between 10-25, the higher u go, the higher the BAC value, thus the longer it takes to get sober.
- Police can request a breathalyzer test and target player has to either accept/deny the test. This returns the players BAC value. In your server rules, law or whatever it is you can add a legal limit etc., which police officers can compare with.

### Drug Swab Test & BDC
- Go to Config.DrugSwab and configure the settings to your likeing. 
- For all your drug items, which should have the effect, add this event in the usable item function: `TriggerClientEvent('t1ger_trafficpolicer:useDrug', xPlayer.source, 'Cocaine', 10)`
- The first arg is the label for the drug, make sure this label is also added inside Config.DrugSwab.labels array.
- The next arg is duration, until player is cleared for that specific drug. Which means, for each Config.DrugSwab.tick, the duration is decreased by 1.
- Police can request a drug swab test and target player has to either accept/deny the test. This returns the drug and a respective state of POSTIVE/NEGATIVE. Use this in RP however u want to.

### ANPR / ALPR
- To activate/deactivate ANPR, use Config.ANPR.command.str or Config.ANPR.keybind.key
- To add a marker for a vehicle, usse /anpr [plate] [stolen/bolo] [true/false]
- Example #1: /anpr "HSG 752" stolen true
- Example #2: /anpr ASD754SD bolo false
- Reminder: if u have space chars in your plates, remember to use " before and after the plate.
- ANPR will automatically deactivate, when a hit is found. Then you can manually activate it again, by using either command/keybind
- In server/main.lua find the event called `t1ger_trafficpolicer:updateANPR`. In this event u can fetch more data from users table or owned_vehicles table, exampe wanted/warrant state? - and add it into the ANPR table. Just make sure to make the necessary edit client side to. This does require some LUA knowledge, so if your skills are poor, don't even bother. It's not supported by me/staff.

### Vehicle Names NULL?
- This is a you problem, kindly install your add-on vehicles properly.
- You can use this link as reference/guide on how to install add-on vehicles, with names: [https://forum.cfx.re/t/how-to-add-on-vehicles-detailed/37501]
- There are other guides as well on FiveM Forums, simply search: `FiveM Addon Vehicles Name Null`

### Citations 
- inside client/citations.lua you can edit all menu texts etc.
- in Config.Citations you can edit the table of content, fine amount.
- Do not touch the `added = false` inside Config.Citations, make sure its set to false at all times.
- All citations are saved in t1ger_citations table, with identifiers for officers, offenders, fine, offences, note(if added) and paid status
- You can use this table in your MDT/CAD system to pull citation data/stats.

### Barricade System
- My script supports Marcus' Barricade System [https://modit.store/products/barricade-system]
- If you own this product, set the configurable option til true, so it will display menu in my traffic policer menu, which will open his menu.
