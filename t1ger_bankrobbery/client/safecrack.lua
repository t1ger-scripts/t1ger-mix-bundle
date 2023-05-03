-- https://github.com/TimothyDexter/FiveM-SafeCrackingMinigame/blob/master/SafeCracking.cs

SafeCracking = {}

SafeCracking.OnCrackSpot = false
SafeCracking.Active = false
SafeCracking.Status = 'Setup'

local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

local function SetupScaleform2(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 172, true))
    ButtonMessage("Unlock")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 173, true))
    ButtonMessage("Stop/Cancel")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 175, true))
    ButtonMessage("Rotate Right")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, 174, true))
    ButtonMessage("Rotate Left")
    PopScaleformMovieFunctionVoid()

    --[[PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, Config.KeyControls['drill_stop'], true)) -- The button to display
    ButtonMessage("Stop Drilling") -- the message to display next to it
    PopScaleformMovieFunctionVoid()]]

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end


SafeCracking.Start = function(callback, combination)
    if not SafeCracking.Active then
        SafeCracking.Active = true
        SafeCracking.Init(combination)
        SafeCracking.Update(callback)
    end
end

SafeCracking.Init = function(combination)
	RequestStreamedTextureDict('MPSafeCracking', false)
	RequestAmbientAudioBank('SAFE_CRACK', false)

    SafeCracking.RotDirection = 'Clockwise'
    SafeCracking.Combination = combination

	SafeCracking.LockSafe()
	SafeCracking.SetSafeDialStartNum()
end

SafeCracking.LockSafe = function()
    if not SafeCracking.Combination then 
        return 
    end

    SafeCracking.LockStatus = SafeCracking.GetSafeLocks()
    SafeCracking.CurLockNum = 1
    SafeCracking.RequiredRotDirection = SafeCracking.RotDirection
    SafeCracking.OnCrackSpot = false

    for i = 1, #SafeCracking.Combination do
        SafeCracking.LockStatus[i] = true
    end
end

SafeCracking.GetSafeLocks = function()
    if not SafeCracking.Combination then 
        return 
    end
    local r = {}
    for i = 1, #SafeCracking.Combination do
        table.insert(r, true)
    end
    return r
end

SafeCracking.SetSafeDialStartNum = function()
	local startNum = math.random(0,100)
    SafeCracking.SafeDialRot = 3.6 * startNum
end

SafeCracking.Update = function(callback)
    local form = SetupScaleform2("instructional_buttons")
    while SafeCracking.Active do
        SafeCracking.DrawSprites(true)
        SafeCracking.Result = SafeCracking.RunMinigame()
        SafeCracking.DisableControls()
        DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
        Wait(0)
    end
    callback(SafeCracking.Result)
end

SafeCracking.DrawSprites = function(state)
    local txtDict = 'MPSafeCracking'
	local ratio = GetAspectRatio(true)
    
	DrawSprite(txtDict, 'Dial_BG', 0.48 ,0.3, 0.22, (ratio * 0.22), 0, 255, 255, 255, 255)
	DrawSprite(txtDict, 'Dial', 0.48, 0.3, (0.22 * 0.5), (ratio * 0.22 * 0.5), SafeCracking.SafeDialRot, 255, 255, 255, 255)

	if not state then
		return
	end

    local pos = {x = 0.56, y = ((0.35 * 0.5) + 0.035)}

    for _,locked in pairs(SafeCracking.LockStatus) do
        local str
        if locked then 
            str = 'lock_closed'
        else
            str = 'lock_open'
        end
        DrawSprite(txtDict, str, pos.x, pos.y, 0.025, (ratio * 0.020), 0, 231, 194, 81, 255)
		pos.y = (pos.y + 0.05)
    end
end

SafeCracking.RunMinigame = function()
	if SafeCracking.Status == 'Setup' then
		SafeCracking.Status = 'Cracking'
	elseif SafeCracking.Status == 'Cracking' then
        local isDead = GetEntityHealth(PlayerPedId()) <= 101
        if isDead then
            SafeCracking.Stop(false)
			return false
        end

		if IsControlJustPressed(0,173) then -- S
			SafeCracking.Stop(false)
			return false
		end

		if IsControlJustPressed(0,172) then -- W
            if SafeCracking.OnCrackSpot then
                SafeCracking.ReleaseCurPin()
                SafeCracking.OnCrackSpot = false
                if SafeCracking.IsOpen() then
                    SafeCracking.Stop(true)
                    return true
                end
            else
                SafeCracking.Stop(false)
                return false
            end
		end

        SafeCracking.HandleControls()

        local incorrect_move = SafeCracking.CurLockNum ~= 0 and SafeCracking.RequiredRotDirection ~= 'Idle' and SafeCracking.CurDialRotDirection ~= 'Idle' and SafeCracking.CurDialRotDirection ~=  SafeCracking.RequiredRotDirection
        if not incorrect_move then
            local curDialNum = SafeCracking.GetCurSafeDialNum(SafeCracking.SafeDialRot)
            local correct_move = SafeCracking.RequiredRotDirection ~= 'Idle' and (SafeCracking.CurDialRotDirection == SafeCracking.RequiredRotDirection or SafeCracking.LastDialRotDirection == SafeCracking.RequiredRotDirection)
            if correct_move then
                local unlocked = SafeCracking.LockStatus[SafeCracking.CurLockNum] and curDialNum == SafeCracking.Combination[SafeCracking.CurLockNum]
                if unlocked then
					PlaySoundFrontend(0, "TUMBLER_PIN_FALL", "SAFE_CRACK_SOUNDSET", true)
                    SafeCracking.OnCrackSpot = true
                end
            end
        elseif incorrect_move then 
            SafeCracking.OnCrackSpot = false
        end

    end
end

SafeCracking.Stop = function(unlocked)
    if unlocked then 
		PlaySoundFrontend(0, "SAFE_DOOR_OPEN", "SAFE_CRACK_SOUNDSET", true)
    else
		PlaySoundFrontend(0, "SAFE_DOOR_CLOSE", "SAFE_CRACK_SOUNDSET", true)
    end
    SafeCracking.Active = false
    SafeCracking.Status = 'Setup'
	ClearPedTasksImmediately(PlayerPedId())
end

SafeCracking.ReleaseCurPin = function()
    SafeCracking.LockStatus[SafeCracking.CurLockNum] = false
    SafeCracking.CurLockNum = SafeCracking.CurLockNum + 1
    if SafeCracking.RequiredRotDirection == 'Anticlockwise' then 
        SafeCracking.RequiredRotDirection = 'Clockwise'
    else
        SafeCracking.RequiredRotDirection = 'Anticlockwise'
    end
	PlaySoundFrontend(0, "TUMBLER_PIN_FALL_FINAL", "SAFE_CRACK_SOUNDSET", true)
end

SafeCracking.IsOpen = function()
    return SafeCracking.LockStatus[SafeCracking.CurLockNum] == nil
end

SafeCracking.HandleControls = function()
    if IsControlJustPressed(0,174) then -- A
		SafeCracking.RotateSafeDial('Anticlockwise')
	elseif IsControlJustPressed(0,175) then -- D
		SafeCracking.RotateSafeDial('Clockwise')
	else
		SafeCracking.RotateSafeDial('Idle')
	end
end

SafeCracking.RotateSafeDial = function(direction)
    if direction == 'Anticlockwise' or direction == 'Clockwise' then
        local multiplier
        if direction == 'Anticlockwise' then
            multiplier = 1
        elseif direction == 'Clockwise' then 
            multiplier = -1
        end
        SafeCracking.SafeDialRot = SafeCracking.SafeDialRot + (multiplier * 3.6)
		PlaySoundFrontend(0, "TUMBLER_TURN", "SAFE_CRACK_SOUNDSET", true)
    end
    SafeCracking.CurDialRotDirection = direction
    SafeCracking.LastDialRotDirection = direction
end

SafeCracking.GetCurSafeDialNum = function(angle)
    local num = math.floor(100 * (angle/360))
    if num > 0 then
        num = 100 - num
    end
    return math.abs(num)
end

SafeCracking.DisabledControls = {30,31,32,33,34,35}

SafeCracking.DisableControls = function()
    for _,control in ipairs(SafeCracking.DisabledControls) do
        DisableControlAction(0, control, true)
    end
end


AddEventHandler('t1ger_bankrobbery:safecracking:start', SafeCracking.Start)
AddEventHandler('t1ger_bankrobbery:safecracking:stop', SafeCracking.Stop)
