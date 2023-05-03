-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Lang = {
	-- Police/Dispatch:
	['dispatch_name']           = '^5 Dispatch: ',
	['police_notify']           = '^0ongoing grand theft auto at ^3%s^0',

	-- Menu Texts:
	['button_yes']         	    = 'Yes',
	['button_no']         	    = 'No',
	['button_return']         	= 'Return',
	['menu_main_title']         = 'Traffic Policer',
	['person_lookup']       	= 'Person Lookup',
	['plate_lookup']       		= 'Plate Lookup',
	['impound_vehicle']       	= 'Impound Vehicle',
	['unlock_vehicle']       	= 'Unlock Vehicle',
	['seize_vehicle']       	= 'Seize Vehicle',	-- requires t1ger_garage
	['issue_citation']       	= 'Issue Citation',
	['breathalyzer_test']       = 'Breathalyzer Test',
	['drug_swap_test']       	= 'Drug Swab Test',
	['provide_bac_test']     	= 'Provide BAC Test?',
	['provide_bdc_test']     	= 'Provide Drug Swab Test?',

	-- NOTIFICATIONS
	['no_players_nearby']		= 'No Players Nearby...',
	['request_breathalyzer']	= 'Requesting permission for Breathalyzer Test from Player...',
	['request_drugswab']		= 'Requesting permission for Drug Swab Test from Player...',
	['ply_not_found']			= 'Person ~r~could not~s~ be found in ~b~database~s~...',
	['plate_not_readed']		= 'Plate in direction ~r~could not~s~ be read, ~b~move closer~s~...',
	['no_vehicle_nearby']		= 'No vehicle nearby, move closer/change direction...',
	['vehicle_impounded']		= 'You have ~r~impounded~s~ the closest vehicle with number plate: ~b~%s~s~.',
	['vehicle_unlocked']		= 'You have ~r~unlocked~s~ the closest vehicle.',
	['vehicle_seized']		= 'You have ~r~seized~s~ the closest vehicle with number plate: ~b~%s~s~.',
	['ply_lookup_request']		= '~b~Officer:~s~ Dispatch, I need a person check? ~g~%s~s~ born on ~y~%s~s~.',
	['ply_lookup_reply']		= '~b~Dispatch:~s~ 10-4, stand by for the person check...',
	['ply_lookup_result']		= 'Record for: ~b~%s~s~,\n~y~%s~s~, DOB: ~y~%s~s~.',
	['plate_lookup_request']	= '~b~Officer:~s~ Dispatch, need a ~g~plate check~s~ on a ~y~%s~s~, plate ~b~%s~s~',
	['plate_lookup_reply']		= '~b~Dispatch:~s~ 10-4, stand by for the ~g~plate check~s~...',
	['plate_lookup_result']		= '~y~Plate:~s~ %s\n~y~Model:~s~ %s\n~y~Owner:~s~ %s',
	['rejected_bac_test']		= 'Your ~b~request~s~ for ~y~BAC~s~ test was ~r~rejected~s~.',
	['rejected_bdc_test']		= 'Your ~b~request~s~ for ~y~BDC~s~ test was ~r~rejected~s~.',
	['breathalyzer_result']		= 'BAC: %s\nLegal Limit: ~b~%s%%~s~',
	['drugswab_no_result']		= '~g~Negative~s~ Results\n\nNo trace of known drugs could be detected.',
	['anpr_activated']			= 'ANPR System | ~g~Activated~s~',
	['anpr_deactivated']		= 'ANPR System | ~r~Deactivated~s~',
	['anpr_cmd_error']			= ' - Usage: /anpr [plate] [stolen/bolo] [true/false]\nExample: /anpr "AGS 853" stolen true',
	['anpr_hit_msg']			= 'Plate: ~b~%s~s~\nOwner: ~y~%s~s~\n\n~r~Registered Hit(s): ~s~\n- %s',
	['veh_no_anpr']				= 'Vehicle does not have ANPR equipped',
	['empty_citation_error']	= 'You cannot send an empty citation, please add some offences.',
	['note_added']				= 'Note/Reason ~g~successfully~s~ added:',
	['citiation_signed1']		= 'You signed and paid the citation.',
	['citiation_signed2']		= 'Offender signed and paid the citation.',
	['citiation_no_money1']		= 'Not enough money to sign/pay the citation.',
	['citiation_no_money2']		= 'Offender did not have enough money to pay the citation.',
	['citiation_not_signed1']	= 'You did not sign/pay the citation.',
	['citiation_not_signed2']	= 'Offender did not sign the citation.',

	-- DRAW TEXTS
	['impound_veh']				= '~r~[E]~s~ Impound Vehicle',
	['unlock_veh']				= '~r~[E]~s~ Unlock Vehicle',
	['seize_veh']				= '~r~[E]~s~ Seize Vehicle',

	-- PROGRESSBARS
	['pb_impouding']			= 'Impounding Vehicle',
	['pb_unlocking']			= 'Unlocking Vehicle',
	['pb_seizing']				= 'Seizing Vehicle',
	['pb_breathalyzer']			= 'Performing Breathalyzer Test',
	['pb_drugswab']				= 'Performing Drug Swab Test',
}  