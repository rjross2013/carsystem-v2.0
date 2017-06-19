--[[Register]]--

RegisterNetEvent("ply_prefecture:GetLicences")
RegisterNetEvent("ply_prefecture:CheckForRealVeh")
RegisterNetEvent("ply_prefecture:VehRegistered")
RegisterNetEvent("ply_prefecture:LicenseFalse")
RegisterNetEvent("ply_prefecture:LicenseTrue")


--[[Local/Global]]--

LICENCES = {}
local prefecture_location = {445.5589, -1025.7614, 28.6566}
local prefecture = {title = "Prefecture", currentpos = nil, marker = { r = 0, g = 155, b = 255, a = 200, type = 1 }}
local vehdb = {}


--[[Functions]]--

function configLang(lang)
	local lang = lang
	if lang == "FR" then
		lang_string = {
			menu1 = "Acheter un permis",
			menu2 = "Enregistrer un véhicule",
			menu3 = "Fermer",
			menu4 = "Permis",
			menu5 = "Retour",
			menu10 = "~g~E~s~ pour ouvrir le menu",
			text1 = "Ce n'est pas la bon vehicule",
			text2 = "Aucun véhicule présent",
			text3 = "Vehicule enregistré",
			text4 = "Ce permis est déjà acheté",
			text5 = "Permis acheté"
	}

	elseif lang == "EN" then
		lang_string = {
			menu1 = "Buy a license",
			menu2 = "Register a vehicle",
			menu3 = "Close",
			menu4 = "Licenses",
			menu5 = "Back",
			menu10 = "~g~E~s~ to open menu",
			text1 = "This is not the right vehicle",
			text2 = "No vehicles present",
			text3 = "Vehicle registered",
			text4 = "This license is already purchased", 
			text5 = "License purchased"
	}
	end
end

function MenuPrefecture()
    ped = GetPlayerPed(-1);
    MenuTitle = "Prefecture"
    ClearMenu()
    Menu.addButton(lang_string.menu1,"AcheterPermis",nil)
    Menu.addButton(lang_string.menu2,"EnregistrerVehicule",nil)
    Menu.addButton(lang_string.menu3,"CloseMenu",nil) 
end

function EnregistrerVehicule()
	TriggerServerEvent('ply_prefecture:CheckForVeh',source)
	CloseMenu()
end

function AcheterPermis()
    ped = GetPlayerPed(-1);
    MenuTitle = lang_string.menu4
    ClearMenu()
    for ind, value in pairs(LICENCES) do
            Menu.addButton(tostring(value.name) .. " : " .. tostring(value.price), "OptionPermis", value.id)
    end    
    Menu.addButton(lang_string.menu5,"MenuPrefecture",nil)
end

function OptionPermis(licID)
	local licID = licID
	TriggerServerEvent('ply_prefecture:CheckForLicences', licID)	
	CloseMenu()
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function CloseMenu()
    Menu.hidden = true    
    TriggerServerEvent("ply_prefecture:GetLicences")
end

function LocalPed()
	return GetPlayerPed(-1)
end

function Chat(debugg)
    TriggerEvent("chatMessage", '', { 0, 0x99, 255 }, tostring(debugg))
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end



--[[Events]]--

AddEventHandler("playerSpawned", function()
    local lang = "EN"
    TriggerServerEvent("ply_prefecture:GetLicences")
    TriggerServerEvent("ply_prefecture:Lang", lang)
    configLang(lang)
end)

AddEventHandler("ply_prefecture:GetLicences", function(THELICENCES)
    LICENCES = {}
    LICENCES = THELICENCES
end)


AddEventHandler("ply_prefecture:CheckForRealVeh", function(owned)
	Citizen.CreateThread(function()
		
		--TriggerEvent("chatMessage", "test", {255, 0, 0}," ".. owned[1])
		for i=1, #owned do
		local checkvname1 = true
		local checkvname2 = true
		local model = owned[i]
		local personalvehicle = model
		local modelhash = GetHashKey(owned[i])
		local caisse = GetClosestVehicle(prefecture_location[1],prefecture_location[2],prefecture_location[3], 5.000, 0, 70)
		SetEntityAsMissionEntity(caisse, true, true)		
		if DoesEntityExist(caisse) then
			local vname = GetDisplayNameFromVehicleModel(GetEntityModel(caisse))
			local vname1 = GetLabelText(vname)
			local vname1 = string.lower(vname1)
			local vname1 = vname1:gsub("%s+", "")
			local vname1 = vname1.gsub(vname1, "%s+", "")
			local vname2 = string.lower(vname)
			local vname2 = vname2:gsub("%s+", "")
			local vname2 = vname2.gsub(vname2, "%s+", "")		
			local checks = string.lower(vname)			
			if personalvehicle ~= checks then
				checkvname1 = false
			end					
			if vname2 == "cogcabri" then
				vname2 = "cogcabrio"
			end
			if personalvehicle ~= vname2 then
				checkvname2 = false
			end			
			--if vname2 == "cogcabri" then
			--	vname2 = "cogcabrio"
			--end
			-- if personalvehicle ~= vname2 then
				-- checkvname2 = false
			-- end
			--local lol = checkvname1 .. " " .. checkvname2 .. " " .. owned[i]
			--TriggerEvent("chatMessage", "test", {255, 0, 0}," " .. tostring(personalvehicle) .. " " .. tostring(string.lower(vname)))
			if checkvname1 == false and checkvname2 == false then
				--drawNotification(lang_string.text1)
			else
				TriggerEvent("chatMessage", "test", {255, 0, 0}," got here")
				local name = personalvehicle
				local plate = GetVehicleNumberPlateText(caisse)
				local vehicle = personalvehicle
				local colors = table.pack(GetVehicleColours(caisse))
				local extra_colors = table.pack(GetVehicleExtraColours(caisse))
				--GetVehicleExtraColours(caisse,extra_colors[1],extra_colors[2])
				local primarycolor = GetVehicleColours(caisse,colors[1])
				local secondarycolor = GetVehicleColours(caisse,colors[2])	
				local pearlescentcolor = GetVehicleExtraColours(caisse,extra_colors[1])
				local wheelcolor = GetVehicleExtraColours(caisse,extra_colors[2])

				TriggerServerEvent('ply_prefecture:SetLicenceForVeh', name, model, plate, primarycolor, secondarycolor, pearlescentcolor, wheelcolor)
			end
		else
			--drawNotification(lang_string.text2)
		end   
		end
	end)
	--end
end)

AddEventHandler("ply_prefecture:VehRegistered", function()
    drawNotification(lang_string.text3)
end)

AddEventHandler("ply_prefecture:LicenseFalse", function()
    drawNotification(lang_string.text4)
end)

AddEventHandler("ply_prefecture:LicenseTrue", function()
    drawNotification(lang_string.text5)
end)



--[[Citizen]]--

Citizen.CreateThread(function()
	local loc = prefecture_location
	--pos = prefecture_location
	local blip = AddBlipForCoord(loc[1],loc[2],loc[3])
	SetBlipSprite(blip,267)
	SetBlipColour(blip,1)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Prefecture')
	EndTextCommandSetBlipName(blip)
	SetBlipAsShortRange(blip,true)
	SetBlipAsMissionCreatorBlip(blip,true)
	while true do
		Wait(0)
		DrawMarker(1,prefecture_location[1],prefecture_location[2],prefecture_location[3],0,0,0,0,0,0,4.001,4.0001,0.5001,0,155,255,200,0,0,0,0)
		if GetDistanceBetweenCoords(prefecture_location[1],prefecture_location[2],prefecture_location[3],GetEntityCoords(LocalPed())) < 5 and IsPedInAnyVehicle(LocalPed(), true) == false then
			drawTxt(lang_string.menu10,0,1,0.5,0.8,0.6,255,255,255,255)
			if IsControlJustPressed(1, 38) then
				MenuPrefecture()
				Menu.hidden = not Menu.hidden
			end
			Menu.renderGUI()
		end
	end
end)
