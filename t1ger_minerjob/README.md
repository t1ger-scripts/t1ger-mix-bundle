# T1GER MINER JOB

## SHOWCASE:
https://youtu.be/i9acAB1fPms

## CFX FORUM POST:
https://forum.cfx.re/t/esx-t1ger-miner-job/4765240/

## FRAMEWORK:
- [ESX Legacy](https://github.com/esx-framework/esx_core)

## DEPENCENCIES:
- [progressBars (OPTIONAL)](https://gitlab.com/t1ger-scripts/t1ger-requirements/-/tree/main/progressBars)

## INSTALLATION:
1. Drag & drop the folder into your `resources` server folder.
2. Configure config.lua to match & satisfy your needs/requirements.
3. Import or execute `items.sql` into your database
4. Install and ensure the necessary dependencies.
5. Add `start t1ger_minerjob` to your server config.

## DISCORD:
https://discord.gg/FdHkq5q

### Config.ProgressBars
- Disable Config.ProgressBars if you want to use your own or just deactive it.

### Config.DatabaseItems
- Make sure the items you've added in your database matches exactly this config table.
- Only change the right side, example: ['pickaxe'] = 'pickaxe'
- Edited: ['pickaxe'] = 'axepick'
- So right side is the name of the item in your database.

### Weight / Limit
- Make sure to set Config.ItemWeightSystem accordingly to whether u are using Weight or Limit system for items.

### ProgressBar Issue?
- If you have any malfunctions or progressBar not appearing, then kindly download my version.