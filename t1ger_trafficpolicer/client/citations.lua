-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

local total_fine = 0
local added_citations = {}
local citation_note = ''
local keyboard_input = false

function OpenCitationMain()
	local elements = {}
	table.insert(elements, {label = 'Select Offences', value = 'select_offences'})
	table.insert(elements, {label = 'Total Fine: $'..total_fine, value = nil})
	table.insert(elements, {label = 'View Selected Offences', value = 'view_selected_offences'})
	table.insert(elements, {label = 'Add Note/Reason', value = 'add_citation_note'})
	table.insert(elements, {label = 'Issue Citation', value = 'issue_citation'})
	table.insert(elements, {label = 'Clear Citation (Reset)', value = 'clear_citation'})
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citations_main', {
		title    = 'Create Citation',
		align    = 'center',
		elements = elements
	}, function(data, menu)
		local action = data.current.value

		-- Select Offences:
		if action == 'select_offences' then SelectOffenceCategory() end

		-- View Selected Offences:
		if action == 'view_selected_offences' then ViewSelectedOffences() end

		-- Add Citation Note/Reason:
		if action == 'add_citation_note' then AddCitationNotes() end 

		-- Issue Citation:
		if action == 'issue_citation' then
			if total_fine ~= 0 then 
				local target = GetClosestPlayer()
				if target then
					menu.close()
					TriggerServerEvent('t1ger_trafficpolicer:sendCitation', GetPlayerServerId(target), total_fine, added_citations, citation_note)
					total_fine = 0
					added_citations = {}
					citation_note = ''
				end
			else
				TriggerEvent('t1ger_trafficpolicer:notify', Lang['empty_citation_error'])
			end
		end

		-- Clear Citation:
		if action == 'clear_citation' then
			for k,v in pairs(Config.Citations) do
				for i = 1, #v do v[i].added = false end
			end
			total_fine = 0
			added_citations = {}
			citation_note = ''
			OpenCitationMain()
		end

	end, function(data, menu)
		menu.close()
		TrafficPolicerMenu()
	end)
end

-- Select Offence Category:
function SelectOffenceCategory()
	local elements = {}
	for k,v in pairs(Config.Citations) do
		table.insert(elements, {label = k, value = v})
	end
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'offence_categories', {
		title    = 'Select a Category',
		align    = 'center',
		elements = elements
	}, function(data, menu)
		menu.close()
		SelectOffenceFromCategory(data.current.label, data.current.value)
	end, function(data, menu)
		menu.close()
		OpenCitationMain()
	end)
end

-- View/Select Offences inside Category:
function SelectOffenceFromCategory(label, entries)
	local elements = {}
	for i = 1, #entries do
		if not entries[i].added then
			table.insert(elements, {
				label = entries[i].offence..' [$'..entries[i].amount..']',
				offence = entries[i].offence,
				fine = entries[i].amount,
				added = entries[i].added,
				num = i
			})
		end
	end
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'category_offences_list', {
		title    = 'Add Offences to Citation',
		align    = 'center',
		elements = elements
	}, function(data, menu)
		table.insert(added_citations, {
			category = label,
			offence = data.current.offence,
			fine = data.current.fine,
			added = not data.current.added,
			num = data.current.num
		})
		Config.Citations[label][data.current.num].added = true
		total_fine = total_fine + data.current.fine
		menu.close()
		SelectOffenceCategory()
	end, function(data, menu)
		menu.close()
		SelectOffenceCategory()
	end)
end

-- Function to View/Remove Selected Offences
function ViewSelectedOffences()
	local elements = {}
	for k,v in pairs(added_citations) do 
		table.insert(elements, {label = v.offence..' [$'..v.fine..']', category = v.category, fine = v.fine, added = v.added, table = k, num = v.num})
	end
	table.insert(elements, {label = 'Return', value = 'return'})
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citations_view_offences', {
		title    = 'View Selected Offences',
		align    = 'center',
		elements = elements
	}, function(data, menu)
		local mks = data.current
		if mks.value == 'return' then
			menu.close()
			OpenCitationMain()
		else
			Config.Citations[mks.category][mks.num].added = false
			total_fine = total_fine - mks.fine
			table.remove(added_citations, mks.table)
			Wait(200)
			ViewSelectedOffences()
		end
	end, function(data, menu)
		menu.close()
		OpenCitationMain()
	end)
end

-- Add Notes/Reason to Citation:
function AddCitationNotes()
	ESX.UI.Menu.CloseAll()
	-- Prepare:
	AddTextEntry("FMMC_KEY_TIP1", 'Add Notes/Reason for Citation (Max Char: 255)')
	DisplayOnscreenKeyboard(false, "FMMC_KEY_TIP1", "", "", "", "", "", 255)
	keyboard_input = true
	-- Handler:
	local inputText = ''
	while keyboard_input do 
		Citizen.Wait(0)
		HideHudAndRadarThisFrame()
		if UpdateOnscreenKeyboard() == 3 then
			keyboard_input = false
		elseif UpdateOnscreenKeyboard() == 1 then
			inputText = GetOnscreenKeyboardResult()
			if string.len(inputText) > 0 then
				keyboard_input = false
			else
				DisplayOnscreenKeyboard(false, "FMMC_KEY_TIP1", "", "", "", "", "", 255)
			end
		elseif UpdateOnscreenKeyboard() == 2 then
			keyboard_input = false
		end
	end
	TriggerEvent('t1ger_trafficpolicer:notify', Lang['note_added'])
	TriggerEvent('t1ger_trafficpolicer:notify', inputText)
	citation_note = inputText
	OpenCitationMain()
end


-- Receive & Sign Citation:
RegisterNetEvent('t1ger_trafficpolicer:receiveCitation')
AddEventHandler('t1ger_trafficpolicer:receiveCitation', function(offender, officer, fine, citation_data, note)
	local elements = {}
	table.insert(elements, {label = 'Total Fine: $'..fine, value = nil})
	table.insert(elements, {label = 'View Selected Offences', value = 'view_offences'})
	table.insert(elements, {label = Lang['button_yes'], value = 'yes', send = true})
	table.insert(elements, {label = Lang['button_no'], value = 'no', send = false})
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sign_citation',
		{
			title    = 'Sign the Citation?',
			align    = 'center',
			elements = elements
		},
	function(data, menu)

		if data.current.value == 'view_offences' then 
			local elements2 = {}
			for k,v in pairs(citation_data) do 
				table.insert(elements2, {label = v.offence..' [$'..v.fine..']', offence = v.offence, fine = v.fine})
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citations_see_offences', {
				title    = 'Offences',
				align    = 'center',
				elements = elements2
			}, function(data2, menu2)
				local mks = data2.current
				if mks.value == 'return' then
					menu2.close()
				end
			end, function(data, menu2)
				menu2.close()
			end)
		end

		if data.current.send ~= nil then
			local array = {}
			for k,v in pairs(citation_data) do
				table.insert(array, v.offence)
			end
			menu.close()
			local info = {offender = offender, officer = officer, fine = fine, offences = array, note = note}
			TriggerServerEvent('t1ger_trafficpolicer:payCitation', info, data.current.send)
		end

	end, function(data, menu)
	end)
end)

