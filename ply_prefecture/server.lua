--[[Info]]--

require "resources/mysql-async/lib/MySQL"



--[[Register]]--

RegisterServerEvent("ply_prefecture:GetLicences")
RegisterServerEvent("ply_prefecture:CheckForVeh")
RegisterServerEvent("ply_prefecture:CheckForLicences")
RegisterServerEvent("ply_prefecture:SetLicenceForVeh")
RegisterServerEvent("ply_prefecture:Lang")

local owned = {}

--[[Function]]--

function getPlayerID(source)
	return getIdentifiant(GetPlayerIdentifiers(source))
end

function getIdentifiant(id)
	for _, v in ipairs(id) do
		return v
	end
end

function licence(licID)	
	return MySQL.Sync.fetchScalar("SELECT licence_id FROM user_licence WHERE identifier=@identifier AND licence_id=@licID",{['@identifier'] = getPlayerID(source), ['@licID'] = licID})
end

function price(licID)
	return MySQL.Sync.fetchScalar("SELECT price FROM licences WHERE id=@licID",{['@licID'] = licID})
end

--function checkForVeh()
--	return MySQL.Sync.fetchScalar("SELECT personalvehicle FROM users WHERE identifier=@identifier", {['@identifier'] = getPlayerID(source)})
--end



--[[Local/Global]]--

licences = {}



--[[Events]]--
--Langage
AddEventHandler('ply_prefecture:Lang', function(lang)
	if lang == "FR" then
		state_in = "Rentré"
		state_out = "Sortit"
	elseif lang =="EN" then
		state_in = "In"
		state_out = "Out"
	end
end)

AddEventHandler("ply_prefecture:GetLicences", function()
	licences = {}
	MySQL.Async.fetchAll("SELECT * FROM licences",{}, function(data)
	for _, v in ipairs(data) do
		t = { ["name"] = v.name, ["price"] = v.price, ["id"] = v.id }
		table.insert(licences, tonumber(v.id), t)
	end
	TriggerClientEvent("ply_prefecture:GetLicences", source, licences)
	end)
end)

AddEventHandler('ply_prefecture:CheckForLicences', function(licID)
	if licence(licID) then
		TriggerClientEvent("ply_prefecture:LicenseFalse", source)
	else      
		TriggerEvent('ply_essentialmode:getPlayerFromId', source, function(user)
			user:removeMoney((price(licID)))
		end)
		MySQL.Async.execute("INSERT INTO user_licence (identifier,licence_id) VALUES (@identifier,@licID)",{['@identifier'] = getPlayerID(source), ['@licID'] = licID}, function(data)
		end)
		TriggerClientEvent("ply_prefecture:LicenseTrue", source)
	end
end)

AddEventHandler('ply_prefecture:CheckForVeh', function()	
	TriggerEvent('es:getPlayerFromId', source, function(user)
	TriggerEvent('es:exposeDBFunctions', function(db)
		db.getDocumentByRow('es_garages', 'identifier', user.identifier, function(dbuser)
			if(dbuser)then
				for i=1, #dbuser.vehicles do
					owned[i] = dbuser.vehicles[i]
				end
				TriggerClientEvent('ply_prefecture:CheckForRealVeh', source, owned)
			end

			
		end)
	end)
	end)
	
end)

AddEventHandler('ply_prefecture:SetLicenceForVeh', function(name, model, plate, primarycolor, secondarycolor, pearlescentcolor, wheelcolor)
	MySQL.Async.fetchAll("SELECT * FROM vehicles WHERE model=@model", {['@model'] = model}, function(data)
		MySQL.Async.execute("INSERT INTO user_vehicle (identifier,vehicle_name,vehicle_model,vehicle_price,vehicle_plate,vehicle_state,vehicle_colorprimary,vehicle_colorsecondary,vehicle_pearlescentcolor,vehicle_wheelcolor) VALUES (@username,@name,@vehicle,@price,@plate,@state,@primarycolor,@secondarycolor,@pearlescentcolor,@wheelcolor)", {['@username'] = getPlayerID(source), ['@name'] = data[1].name, ['@vehicle'] = model, ['@price'] = data[1].price, ['@plate'] = plate, ['@state'] = "sortit", ['@primarycolor'] = primarycolor, ['@secondarycolor'] = secondarycolor, ['@pearlescentcolor'] = pearlescentcolor, ['@wheelcolor'] = wheelcolor}, function(data)
		end)
		TriggerEvent('es:getPlayerFromId', source, function(user)
	TriggerEvent('es:exposeDBFunctions', function(db)
		db.getDocumentByRow('es_garages', 'identifier', user.identifier, function(dbuser)
			if(dbuser)then
				for i=1, #dbuser.vehicles do
					if dbuser.vehicles[i] == model then
						table.remove(dbuser.vehicles, i)
						--table.remove(dbuser.cost, i)
						
					end
					db.updateDocument('es_garages', dbuser._id, {vehicles = dbuser.vehicles})
				end
				TriggerClientEvent('ply_prefecture:CheckForRealVeh', source, owned)
			end

			
		end)
	end)
	end)
		TriggerClientEvent("ply_prefecture:VehRegistered", source)
	end)
end)
