---------------------------------
---------------------------------
-----------PIZZA Vars------------
---------------------------------
---------------------------------
meat = 28
flour = 14
vegetables = 49

---------------------------------
---------------------------------
-----------PIZZA Blip------------
---------------------------------
---------------------------------
local blips = {
   {name="Pizzeria", id=279, x=-98.224586486816, y=364.754455556641, z=113.27568054199},
 }

Citizen.CreateThread(function()

    for _, item in pairs(blips) do
      item.blip = AddBlipForCoord(item.x, item.y, item.z)
      SetBlipSprite(item.blip, item.id)
      SetBlipAsShortRange(item.blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(item.name)
      EndTextCommandSetBlipName(item.blip)
    end
end)

---------------------------------
---------------------------------
-----------PIZZA SHOP------------
---------------------------------
---------------------------------

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline, center)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
	if(center)then
		Citizen.Trace("CENTER\n")
		SetTextCentre(false)
	end
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

local PizzaShop = {x= -98.8732986450195, y= 365.145416259766, z= 113.27474975585}
local waitress

local function loadwaitress()
	Citizen.CreateThread(function()
		local waitressmodel = 0xCE9113A9
		local loc = GetEntityCoords(waitress, false)
		-- Load the ped modal from Array
		  RequestModel(waitressmodel)
		while not HasModelLoaded(waitressmodel) do
		    Wait(1)
	  	end
	    -- Spawn the Customer to the coordinates
	    waitress =  CreatePed(5, waitressmodel, -111.409736633301, 355.811004638672, 112.696151733398, false, true)
	    SetPedCombatAttributes(waitress, 46, true)
	    SetPedFleeAttributes(waitress, 0, 0)
	    SetPedRelationshipGroupHash(waitress, GetHashKey("CIVMALE"))
	    SetPedDiesWhenInjured(waitress, false)
	    TaskWanderInArea(waitress, -111.409736633301, 355.811004638672, 112.696151733398, 15.0, 0.5, 15.0)

	end)
end

local function stopwaitress()
	Citizen.CreateThread(function()
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		TaskTurnPedToFaceCoord(waitress, pos.x, pos.y, pos.z)
		Wait(1500)
		TaskStandStill(waitress, 1)	
		TaskWanderInArea(waitress, -111.409736633301, 355.811004638672, 112.696151733398, 15.0, 0.5, 15.0)
	end)
end

Citizen.CreateThread(function()
	Citizen.Wait(1)
	loadwaitress()
	while true do
		Citizen.Wait(1)
		--TaskWanderInArea(waitress, -1125081787109, 355.738403320313, 112.696159362793, 30.0, 10.0, 0)
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		local loc = GetEntityCoords(waitress, false)	    
		if(Vdist(loc.x, loc.y, loc.z, pos.x, pos.y, pos.z) < 60.0)then
			DrawMarker(2, loc.x ,loc.y ,loc.z +1,0,0,0,0,180.0,0,0.401,0.4001,0.3001,0,155,255,200,false,true,0,0)
			if(Vdist(loc.x, loc.y, loc.z, pos.x, pos.y, pos.z) < 2.0)then
				stopwaitress()
				DisplayHelpText("Press ~g~Enter~w~ to buy a ~y~Pizza~w~ for ~g~50")
				if(IsControlJustReleased(1, 18))then
					TriggerServerEvent("es_freeroam:pay", tonumber(50))
					---------------------------------------------------
					-----SPACEHOLDER FOR THE NETWORKED PIZZA ITEM------
					---------------------------------------------------

					SetNotificationTextEntry("STRING")	
					AddTextComponentString("You ~g~bought~w~ a ~y~Pizza~w~ for ~g~50")
					DrawNotification(false, true);
				end
			end
		end
	end
end)

---------------------------------
---------------------------------
----------PIZZA REFILL-----------
---------------------------------
---------------------------------
local PizzaTruck = {{hash= 0x35ED670B, x= -82.7774887084961, y= 391.922088623047, z= 112.430793762207, a= 60.0}}
local blipmission
local blipmissionreturn
local isrefillactive = false
local truck

Citizen.CreateThread(function()
	while true do	
		Citizen.Wait(0)
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		if(Vdist(-90.3726043701172, 395.257049560547, 112.425941467285, pos.x, pos.y, pos.z) < 60.0) then
			if flour <= 0 or meat <= 0 or vegetables <= 0 then
				DrawMarker(1, -90.3726043701172, 395.257049560547, 111.425941467285, 0,0,0,0,0,0,1.001,1.0001,0.5001,212,144,144,200,0,0,0,0)
				if(Vdist(-90.3726043701172, 395.257049560547, 112.425941467285, pos.x, pos.y, pos.z) < 2.0)and isrefillactive == false then
					DisplayHelpText("Start Refillmission: ~g~F~w~lour and Cheese, ~g~M~w~eat, ~g~V~w~egetables")
					if (IsControlJustReleased(1, 23)) then
						spawnptruck()
						startRefill(1, 105, 0, 0)						
					end
					if (IsControlJustReleased(1, 244)) then
						spawnptruck()
						startRefill(2, 0, 105, 0)
					end
					if (IsControlJustReleased(1, 0)) then
						spawnptruck()
						startRefill(3, 0, 0, 105)
					end
				end
			end
		end
	end
end)

function spawnptruck()
	Citizen.CreateThread(function()
		Citizen.Wait(1)
		if GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= truck then
			Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( PizzaScooter ) )
			Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( truck ) )
			RequestModel(0x35ED670B)
			while not HasModelLoaded(0x35ED670B) do
				Citizen.Wait(1)
			end
			for _, item in pairs(PizzaTruck) do
				truck =  CreateVehicle(item.hash, item.x, item.y, item.z, item.a, true, false)
				SetVehicleOnGroundProperly(truck)
			end
			Citizen.Wait(1000)
		end
	end)
end

local refillmissions = {
	{x= 1208.04760742188, y= 1859.6181640625, z= 78.1480484008789},
	{x= 953.663940429688, y= -2106.29467773438, z= 30.0895442962646},
	{x= 411.043548583984, y= 6457.173828125, z= 28.325122833252},
}

function startRefill(ingr, am1, am2, am3)
	local returnmission = false
	blipmissionreturn
	local loc = refillmissions[ingr]
	Citizen.CreateThread(function()
		Citizen.Wait(0)
		RemoveBlip(blipdelivery)
		isrefillactive = true
		SetNotificationTextEntry("STRING")	
		AddTextComponentString("The destination was marked on your map!")
		DrawNotification(false, true);
		blipmission = AddBlipForCoord(loc.x ,loc.y ,loc.z)
		SetBlipColour(blipmission, 2)
		SetBlipSprite(blipmission, 8)
		SetBlipAsShortRange(blipmission, false)
		SetBlipRoute(blipmission, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Refill")
		EndTextCommandSetBlipName(blipmission)
	end)
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			local pos = GetEntityCoords(GetPlayerPed(-1), false)
			if(Vdist(loc.x ,loc.y ,loc.z , pos.x, pos.y, pos.z) < 80.0) and returnmission == false and GetVehiclePedIsIn(GetPlayerPed(-1), false) == truck then
				DrawMarker(1, loc.x ,loc.y ,loc.z-1, 0,0,0,0,0,0,2.501,2.5001,2.0001,212,144,144,200,0,0,0,0)
				if(Vdist(loc.x ,loc.y ,loc.z , pos.x, pos.y, pos.z) < 3.0)then
				DisplayHelpText("Press ~g~Enter~w~ to load the Truck")	
					if(IsControlJustReleased(1, 18))then
						refill(am1, am2, am3)
					end
				end
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local truckloc = GetEntityCoords(truck, false)
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		if(Vdist(truckloc.x, truckloc.y, truckloc.z, pos.x, pos.y, pos.z) > 100.0)and truckloc.x ~= nil then
			Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( truck ) )
			if isrefillactive == true then
				SetNotificationTextEntry("STRING")	
				AddTextComponentString("You Went to far away! The Truck got deleted.")
				DrawNotification(false, true);
			end
			isrefillactive = false
			RemoveBlip(blipmission)
		end
	end
end)

function refill(gam1, gam2, gam3)
	Citizen.CreateThread(function()
		RemoveBlip(blipmission)
		SetNotificationTextEntry("STRING")	
		AddTextComponentString("The ingredient was loaded on the truck! Drive back to the Pizzeria")
		DrawNotification(false, true);
		blipmissionreturn = AddBlipForCoord(-90.3726043701172, 395.257049560547, 112.425941467285)
		SetBlipColour(blipmissionreturn, 2)
		SetBlipSprite(blipmissionreturn, 8)
	    SetBlipAsShortRange(blipmissionreturn, false)
	    SetBlipRoute(blipmissionreturn, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Pizzeria")
		EndTextCommandSetBlipName(blipmissionreturn)
		SetVehicleDoorOpen(truck, 2, false, false)
		SetVehicleDoorOpen(truck, 3, false, false)
		Citizen.Wait(3000)
		SetVehicleDoorsShut(truck, false)
		returnmission = true
	end)
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			local pos = GetEntityCoords(GetPlayerPed(-1), false)
			local ingrd = ingredient
			--for k,v in ipairs(destination) do
			if(Vdist(-90.3726043701172, 395.257049560547, 112.425941467285, pos.x, pos.y, pos.z) < 3.0)and returnmission == true and isrefillactive == true and GetVehiclePedIsIn(GetPlayerPed(-1), false) == truck then
				DisplayHelpText("Press ~g~Enter~w~ to unload the Truck")
				if(IsControlJustReleased(1, 18))then				
					meat = meat + gam2
					flour = flour + gam1
					vegetables = vegetables + gam3
					SetVehicleDoorOpen(truck, 2, false, false)
					SetVehicleDoorOpen(truck, 3, false, false)
					Citizen.Wait(3000)
					SetVehicleDoorsShut(truck, false)
					TriggerServerEvent('mission:completed', 1000)
					RemoveBlip(blipmissionreturn)
					SetNotificationTextEntry("STRING")	
					AddTextComponentString("You sucessfully refilled and recieved ~g~1000!")
					DrawNotification(false, true);
					returnmission = false
					isrefillactive = false
				end
			end
			if(Vdist(locX ,locY ,locZ , pos.x, pos.y, pos.z) < 3)and GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= truck then
				SetNotificationTextEntry("STRING")	
				AddTextComponentString("You lost the Truck! Get back to the Truck and try again!")
				DrawNotification(false, true);
			end
		end
	end)
end

---------------------------------
---------------------------------
---------PIZZA DELIVERY----------
---------------------------------
---------------------------------
local PizzaCustomers = {0x52C824DE,0x06DD569F,0xC2FBFEFE,0x379F9596,0xC19377E7,0x4B64199D,0x5D15BD00,0x1FDF4294,0x31C9E669,0xAB0A7155,0xC1F380E6,0xFDA94268,0x0D810489,0xE793C8E8}
local CustomerLocation = {
	{x= -258.332061767578, y= 396.286315917969, z= 109.566192626953},
	{x= -303.96923828125, y= 383.595672607422, z= 109.869102478027},
	{x= -349.318176269531, y= 367.907958984375, z= 109.546852111816},
	{x= -370.593658447266, y= 349.743041992188, z= 108.908332824707},
	{x= -401.703674316406, y= 345.051391601563, z= 108.241493225098},
	{x= -433.688385009766, y= 345.321899414063, z= 105.370719909668},
	{x= -474.518402099609, y= 353.713531494141, z= 103.544960021973},
	{x= -489.187072753906, y= 407.494903564453, z= 98.766227722168},
	{x= -515.395202636719, y= 428.448455810547, z= 96.6947708129883},
	{x= -457.703979492188, y= 397.374053955078, z= 102.694923400879},
	{x= -395.293823242188, y= 429.424377441406, z= 111.89444732666},
	{x= -349.805419921875, y= 427.983612060547, z= 110.010055541992},
	{x= -318.972534179688, y= 431.781829833984, z= 109.326301574707},--13
	{x= -539.779663085938, y= 482.423461914063, z= 102.485809326172},
	{x= -585.986206054688, y= 500.579223632813, z= 105.588912963867},
	{x= -587.106750488281, y= 529.475158691406, z= 107.435249328613},
	{x= -618.622131347656, y= 491.328216552734, z= 108.114822387695},
	{x= -640.241088867188, y= 518.059692382813, z= 109.200210571289},
	{x= -655.271728515625, y= 489.630981445313, z= 109.249008178711},
	{x= -685.401611328125, y= 504.432037353516, z= 109.699081420898},
	{x= -712.694152832031, y= 489.568176269531, z= 108.490913391113},
	{x= -739.620483398438, y= 444.99658203125, z= 106.241203308105},
	{x= -765.757446289063, y= 442.505401611328, z= 97.7270736694336},
	{x= -779.2353515625, y= 451.848724365234, z= 96.4595184326172},
	{x= -817.0546875, y= 432.710906982422, z= 88.97021484375},
	{x= -839.545959472656, y= 454.306365966797, z= 88.079704284668},
	{x= -863.209350585938, y= 466.518493652344, z= 87.654411315918},
	{x= -850.126159667969, y= 510.074371337891, z= 90.3451385498047},
	{x= -873.3037109375, y= 521.963928222656, z= 89.6058502197266},
	{x= -875.300659179688, y= 545.484802246094, z= 92.8709869384766},
	{x= -906.496398925781, y= 552.930786132813, z= 95.6893157958984},
	{x= -906.376159667969, y= 586.357360839844, z= 100.623054504395},
	{x= -924.225891113281, y= 563.250793457031, z= 99.3047561645508},
	{x= -941.832092285156, y= 587.288208007813, z= 100.290573120117},
	{x= -955.564453125, y= 463.168334960938, z= 80.0272369384766},
	{x= -968.016235351563, y= 455.691284179688, z= 79.8092880249023},
	{x= -971.35791015625, y= 510.268310546875, z= 81.2981109619141},
	{x= -992.19775390625, y= 488.654052734375, z= 81.8944320678711},
	{x= -1006.97100830078, y= 511.749145507813, z= 79.21728515625},
	{x= -1010.79681396484, y= 485.810455322266, z= 78.9575881958008},
	{x= -1018.04571533203, y= 504.632659912109, z= 79.067268371582},
	{x= -1060.37438964844, y= 430.211242675781, z= 73.470947265625},
	{x= -1079.53601074219, y= 425.731506347656, z= 72.0849990844727},
	{x= -1015.33081054688, y= 358.078521728516, z= 70.2523651123047},
	{x= -973.721496582031, y= 586.1708984375, z= 101.520637512207},--45
	{x= -1022.24487304688, y= 592.33984375, z= 102.60173034668},
	{x= -1098.52221679688, y= 594.321960449219, z= 102.698760986328},
	{x= -1094.79541015625, y= 553.199462890625, z= 102.212120056152},
	{x= -1121.17309570313, y= 572.088623046875, z= 102.198295593262},
	{x= -1126.35705566406, y= 554.975402832031, z= 101.816329956055},
	{x= -1146.90148925781, y= 548.359069824219, z= 100.865608215332},
	{x= -1192.23669433594, y= 562.301391601563, z= 99.8595428466797},
	{x= -1180.03857421875, y= 440.316772460938, z= 85.9693984985352},
	{x= -1119.42895507813, y= 477.060272216797, z= 81.6425476074219},
	{x= -1075.67028808594, y= 457.724548339844, z= 77.019172668457},
	{x= -1263.63366699219, y= 455.195983886719, z= 94.2612380981445},
	{x= -1294.62487792969, y= 454.902191162109, z= 96.954704284668},
	{x= -1316.21899414063, y= 454.388397216797, z= 98.6596755981445},
	{x= -1353.85815429688, y= 466.283996582031, z= 102.304786682129},
	{x= -1378.97802734375, y= 452.019134521484, z= 104.239555358887},
	{x= -1424.76184082031, y= 466.969055175781, z= 109.135696411133},
	{x= -1451.61987304688, y= 535.741271972656, z= 118.874137878418},
	{x= -1469.45727539063, y= 510.991119384766, z= 117.162086486816},
	{x= -1491.4228515625, y= 524.613159179688, z= 117.754844665527},
	{x= -1499.11779785156, y= 438.849395751953, z= 111.830543518066},
	{x= -1539.11022949219, y= 422.190338134766, z= 109.500152587891},
	{x= -1407.818359375, y= 533.37744140625, z= 122.404724121094},
	{x= -1409.73803710938, y= 560.131103515625, z= 124.301086425781},
	{x= -1357.05981445313, y= 575.846740722656, z= 130.767486572266},
	{x= -1365.84509277344, y= 610.088928222656, z= 133.424591064453},
	{x= -1284.38232421875, y= 626.367126464844, z= 138.602401733398},
	{x= -1287.60070800781, y= 644.03564453125, z= 138.561996459961},
	{x= -1243.70361328125, y= 649.099426269531, z= 141.173583984375},
	{x= -1242.35437011719, y= 666.450561523438, z= 142.225646972656},
	{x= -1220.07177734375, y= 665.826416015625, z= 143.835479736328},
	{x= -1198.72326660156, y= 693.460815429688, z= 146.801498413086},
	{x= -1161.20959472656, y= 740.310913085938, z= 154.815994262695},
	{x= -1119.98474121094, y= 767.34619140625, z= 162.760162353516},
	{x= -1121.90002441406, y= 784.185852050781, z= 161.802185058594},
	{x= -1096.64587402344, y= 789.79638671875, z= 163.984115600586},
	{x= -1053.17163085938, y= 765.386962890625, z= 167.130325317383},
	{x= -1062.90551757813, y= 730.96533203125, z= 164.945434570313},
	{x= -1018.30578613281, y= 699.4912109375, z= 161.312591552734},
	{x= -1020.16491699219, y= 715.496704101563, z= 163.401458740234},
	{x= -986.5908203125, y= 690.758117675781, z= 157.462310791016},
	{x= -951.516845703125, y= 695.513061523438, z= 153.142684936523},
	{x= -908.068420410156, y= 695.018676757813, z= 150.910263061523},
	{x= -887.562561035156, y= 702.760375976563, z= 150.013336181641},
	{x= -857.521484375, y= 698.698120117188, z= 148.359802246094},
	{x= -813.283813476563, y= 703.753662109375, z= 146.679443359375},
	{x= -759.070495605469, y= 658.253723144531, z= 142.526428222656},
	{x= -752.919555664063, y= 625.124328613281, z= 142.038208007813},
	{x= -732.666748046875, y= 594.4013671875, z= 141.523193359375},
	{x= -705.218688964844, y= 590.776489257813, z= 141.526229858398},
	{x= -689.059448242188, y= 598.367797851563, z= 142.930969238281},
	{x= -671.894409179688, y= 645.699157714844, z= 148.709030151367},
	{x= -717.212524414063, y= 655.568176269531, z= 154.648880004883},
	{x= -665.564880371094, y= 671.768737792969, z= 149.891357421875},
	{x= -697.159423828125, y= 707.174499511719, z= 156.979553222656},
	{x= -667.134338378906, y= 754.189453125, z= 173.871810913086},
	{x= -581.803283691406, y= 736.557800292969, z= 183.085601806641},
	{x= -589.882690429688, y= 782.696716308594, z= 187.918014526367},
	{x= -601.380126953125, y= 804.1904296875, z= 190.618255615234},
	{x= -672.788513183594, y= 802.926025390625, z= 198.482879638672},
	{x= -747.0126953125, y= 813.744689941406, z= 212.951797485352},
	{x= -818.235900878906, y= 810.314331054688, z= 201.147491455078},
	{x= -866.136474609375, y= 789.284301757813, z= 191.217544555664},
	{x= -906.23974609375, y= 787.178283691406, z= 184.940902709961},
	{x= -920.205444335938, y= 810.196411132813, z= 183.818557739258},
	{x= -959.412292480469, y= 800.116333007813, z= 176.996170043945},
	{x= -996.322082519531, y= 810.412475585938, z= 171.979858398438},
	{x= -969.719299316406, y= 762.867431640625, z= 174.841293334961},
	{x= -997.2529296875, y= 787.189819335938, z= 171.471176147461},
	{x= -612.663452148438, y= 678.447265625, z= 149.109466552734},
	{x= -567.605773925781, y= 681.851684570313, z= 145.545761108398},
	{x= -557.328369140625, y= 665.61474609375, z= 144.644775390625},
	{x= -524.099548339844, y= 644.250549316406, z= 137.383392333984},
	{x= -476.488372802734, y= 595.066528320313, z= 127.227989196777},
	{x= -512.477478027344, y= 581.908142089844, z= 120.285545349121},
	{x= -486.177032470703, y= 551.583740234375, z= 119.049407958984},
	{x= -468.412109375, y= 544.580444335938, z= 119.83854675293},
	{x= -439.984741210938, y= 543.358764648438, z= 121.322357177734},
	{x= -419.935028076172, y= 551.286499023438, z= 122.110687255859},
	{x= -381.125427246094, y= 525.121643066406, z= 120.8134765625},
	{x= -382.223724365234, y= 510.5185546875, z= 119.780326843262},
	{x= -362.343933105469, y= 510.135803222656, z= 118.640380859375},
	{x= -351.661376953125, y= 470.704223632813, z= 112.101104736328},
	{x= -318.426605224609, y= 465.894439697266, z= 108.094657897949},
	{x= -482.766296386719, y= 656.177062988281, z= 143.326965332031},
	{x= -443.379943847656, y= 680.997619628906, z= 152.211135864258},
	{x= -429.434539794922, y= 676.472351074219, z= 154.162551879883},
	{x= -357.696380615234, y= 669.721252441406, z= 168.003860473633},
	{x= -345.620208740234, y= 633.109130859375, z= 171.76008605957},
	{x= -318.681762695313, y= 637.874145507813, z= 173.315231323242},
	{x= -275.456146240234, y= 602.818969726563, z= 181.205413818359},
	{x= -269.505340576172, y= 615.956359863281, z= 182.136520385742},
	{x= -255.037322998047, y= 601.045471191406, z= 184.949249267578},
	{x= -188.519226074219, y= 608.897338867188, z= 195.881240844727},
	{x= -180.91960144043, y= 595.260498046875, z= 197.102020263672},
	{x= -140.606018066406, y= 594.580261230469, z= 203.36994934082},
	{x= -166.003753662109, y= 977.110778808594, z= 235.414398193359},
	{x= -120.324012756348, y= 986.246887207031, z= 235.230590820313},
	{x= -158.699249267578, y= 924.150207519531, z= 235.140655517578},
	{x= -96.8475799560547, y= 834.133361816406, z= 235.207641601563},
	{x= 227.757934570313, y= 677.696411132813, z= 188.934417724609},
	{x= 213.85041809082, y= 621.505920410156, z= 186.964614868164},
	{x= 141.696441650391, y= 554.346008300781, z= 183.232208251953},
	{x= 129.113845825195, y= 568.646362304688, z= 182.754745483398},
	{x= 85.2868118286133, y= 566.874389648438, z= 181.407089233398},
	{x= 26.6782073974609, y= 557.946594238281, z= 177.889572143555},
	{x= 10.6893615722656, y= 544.900939941406, z= 175.252777099609},
	{x= -177.803253173828, y= 505.647827148438, z= 135.882400512695},
	{x= -229.852798461914, y= 492.475219726563, z= 127.835479736328},
	{x= -59.1151428222656, y= 494.061248779297, z= 144.162384033203},
	{x= -6.32242631912231, y= 472.529754638672, z= 145.156631469727},
	{x= 56.7809410095215, y= 454.611877441406, z= 146.213424682617},
	{x= 52.8030090332031, y= 466.381561279297, z= 146.130859375},
	{x= 89.2276077270508, y= 482.700408935547, z= 147.04931640625},
	{x= 103.629837036133, y= 476.151397705078, z= 146.80696105957},
	{x= 116.354667663574, y= 491.846343994141, z= 146.598480224609},
	{x= 170.617691040039, y= 482.991638183594, z= 141.872024536133},
	{x= 221.277984619141, y= 514.558471679688, z= 140.130416870117},
	{x= 317.164947509766, y= 565.953063964844, z= 153.911041259766},
	{x= 328.549041748047, y= 536.351806640625, z= 153.255126953125},
	{x= 319.721771240234, y= 498.558135986328, z= 152.082931518555},
	{x= 325.473052978516, y= 486.159545898438, z= 150.752807617188},
	{x= 350.947570800781, y= 444.117553710938, z= 145.759887695313},
	{x= 371.934417724609, y= 431.691497802734, z= 144.399276733398},
	{x= 521.205810546875, y= 245.813125610352, z= 103.201889038086},
	{x= 437.072387695313, y= 216.902053833008, z= 102.656272888184},
	{x= 253.65461730957, y= 356.764190673828, z= 105.012657165527},
	{x= 341.665374755859, y= 37.7552795410156, z= 89.4764785766602},
	{x= 256.94970703125, y= 30.0519561767578, z= 83.5665054321289},
	{x= 206.835708618164, y= 51.168830871582, z= 83.2935028076172},
	{x= 209.916351318359, y= 28.0880718231201, z= 78.6450958251953},
	{x= 164.054565429688, y= 37.4592018127441, z= 74.0353927612305},
	{x= 119.240791320801, y= 29.3322525024414, z= 72.8737564086914},
	{x= 89.0287094116211, y= 46.4968299865723, z= 73.006950378418},
	{x= 32.5636749267578, y= 79.3083724975586, z= 74.5588684082031},
	{x= 32.0955924987793, y= 51.8394546508789, z= 71.9161682128906},
	{x= 10.810601234436, y= -4.04783916473389, z= 69.6475448608398},
	{x= 8.28495407104492, y= -57.7013282775879, z= 62.7321815490723},
	{x= 24.1433181762695, y= -79.7448883056641, z= 60.2005424499512},
	{x= 52.5267372131348, y= -48.7390747070313, z= 68.8791122436523},
	{x= 126.894119262695, y= -65.4717178344727, z= 66.7856521606445},
	{x= 87.3575973510742, y= -81.8950958251953, z= 61.6667594909668},
	{x= 79.9816513061523, y= -99.0922546386719, z= 58.7442321777344},
	{x= 115.593032836914, y= -98.8389434814453, z= 60.240837097168},
	{x= -83.347412109375, y= -46.3259086608887, z= 61.3298988342285},
	{x= -125.266296386719, y= -25.3152027130127, z= 57.6841163635254},
	{x= -141.390579223633, y= 67.5475692749023, z= 70.382942199707},
	{x= -164.579574584961, y= 79.9099197387695, z= 70.0238571166992},
	{x= -160.483184814453, y= 114.006118774414, z= 69.8925170898438},
	{x= -271.833129882813, y= 105.452560424805, z= 68.4101028442383},
	{x= -314.563171386719, y= 110.97730255127, z= 67.0291137695313},
	{x= -345.254913330078, y= 107.194274902344, z= 66.1652145385742},
	{x= -397.998962402344, y= 153.742248535156, z= 65.0114517211914},
	{x= -419.498474121094, y= 104.930854797363, z= 64.0058212280273},
	{x= -515.182678222656, y= 110.335990905762, z= 62.8031997680664},
	{x= -558.028015136719, y= 94.7272033691406, z= 60.1046409606934},
	{x= -599.767883300781, y= 144.752059936523, z= 59.8324661254883},
	{x= -835.279968261719, y= 109.451103210449, z= 54.4203720092773},
	{x= -919.669555664063, y= 110.563369750977, z= 54.8064193725586},
	{x= -958.417907714844, y= 116.204284667969, z= 56.3247947692871},
	{x= -992.050354003906, y= 145.970474243164, z= 60.1427955627441},
	{x= -906.983215332031, y= 188.181930541992, z= 68.9179306030273},
	{x= -956.040832519531, y= 187.239715576172, z= 66.0749893188477},
	{x= -1045.52124023438, y= 218.049209594727, z= 63.2544784545898},
	{x= -826.376159667969, y= 173.410598754883, z= 70.1106262207031},
	{x= -780.077758789063, y= 273.037872314453, z= 85.2648391723633},
	{x= -771.386352539063, y= 304.159240722656, z= 85.1955261230469},
	{x= -869.491638183594, y= 304.314056396484, z= 83.4700469970703},
	{x= -886.314270019531, y= 366.345886230469, z= 84.5094375610352},
	{x= -1045.81909179688, y= 320.481475830078, z= 66.2857818603516},
	{x= -1129.8046875, y= 306.409637451172, z= 65.6664886474609},
}
local DeliveryON = false
local PizzaScooter
local loadedPizzas = 0
local PizzaScooterD = {{hash= 0xB328B188, x= -100.743743896484, y= 399.655792236328, z= 112.426147460938, a= 60.0}}

Citizen.CreateThread(function()
	--TriggerServerEvent('pizzadelivery:getingredients')
	while true do
		Citizen.Wait(0)
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
			if flour >= 1 and meat >= 1 and vegetables >= 1 then
				if(Vdist(-102.879707336426,397.836151123047,112.428863525391, pos.x, pos.y, pos.z) < 80.0)then
					DrawMarker(1, -102.879707336426,397.836151123047,111.428863525391, 0,0,0,0,0,0,1.001,1.0001,0.5001,212,144,144,200,0,0,0,0)
					if(Vdist(-102.879707336426,397.836151123047,112.428863525391, pos.x, pos.y, pos.z) < 3.0)and DeliveryON == false then
						DisplayHelpText("Press ~g~Enter~w~ to start Pizza Delivery.")
						if(IsControlJustReleased(1, 18))then
							if GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= PizzaScooter then
								RequestModel(0xB328B188)
								while not HasModelLoaded(0xB328B188) do
									Citizen.Wait(1)
								end
								for _, item in pairs(PizzaScooterD) do
									PizzaScooter =  CreateVehicle(item.hash, item.x, item.y, item.z, item.a, true, false)
									SetVehicleOnGroundProperly(PizzaScooter)
								end
								Citizen.Wait(1000)
							end						
							DeliveryON = true
							loadedPizzas = 7
							startDelivery()
							SetNotificationTextEntry("STRING")	
							AddTextComponentString("Go to the first Customer!")
							DrawNotification(false, true);	
							if flour > 0 and meat > 0 and vegetables > 0 then
								flour = flour - loadedPizzas
								meat = meat - loadedPizzas
								vegetables = vegetables - loadedPizzas
							end					
						end
					end
				end
			end
			if(Vdist(-102.879707336426,397.836151123047,112.428863525391, pos.x, pos.y, pos.z) < 3.0)and DeliveryON == false then
				if flour < 1 then
					SetNotificationTextEntry("STRING")	
					AddTextComponentString("The Flour and Cheese is Empty! You have to make a Refill bevore You can deliver Pizza.")
					DrawNotification(false, true);	
				end
				if meat < 1 then
					SetNotificationTextEntry("STRING")	
					AddTextComponentString("The Meat is Empty! You have to make a Refill bevore You can deliver Pizza.")
					DrawNotification(false, true);	
				end
				if vegetables < 1 then
					SetNotificationTextEntry("STRING")	
					AddTextComponentString("The Vegetables is Empty! You have to make a Refill bevore You can deliver Pizza.")
					DrawNotification(false, true);	
				end
			end
	end
end)

local blipdelivery 
local customermodel
local customerp

function startDelivery()
	local loc = CustomerLocation[math.random("215")]
	Citizen.CreateThread(function()
			Citizen.Wait(0)
			blipdelivery = AddBlipForCoord(loc.x ,loc.y ,loc.z)
			SetBlipColour(blipdelivery, 2)
			SetBlipSprite(blipdelivery, 8)
	      	SetBlipAsShortRange(blipdelivery, false)
	      	SetBlipRoute(blipdelivery, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Customer")
			EndTextCommandSetBlipName(blipdelivery)	
			loadCustomer(loc)
	end)
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			local pos = GetEntityCoords(GetPlayerPed(-1), false)
			if(Vdist(loc.x ,loc.y ,loc.z, pos.x, pos.y, pos.z) < 80.0)then
				TaskTurnPedToFaceCoord(customerp, pos.x, pos.y, pos.z)
				if DeliveryON == true then
					DrawMarker(2, loc.x ,loc.y ,loc.z + 2,0,0,0,0,180.0,0,0.701,0.7001,0.5001,0,155,255,200,true,true,0,0)
					if(Vdist(loc.x ,loc.y ,loc.z, pos.x, pos.y, pos.z) < 4.0)then
						if(IsControlJustReleased(1, 18))then							
							if GetVehiclePedIsIn(GetPlayerPed(-1), false) == PizzaScooter then
								RemoveBlip(blipdelivery)
								loadedPizzas = loadedPizzas - 1
								local payment = round((Vdist(-102.879707336426,397.836151123047,112.428863525391, pos.x, pos.y, pos.z))/3)
								TriggerServerEvent('mission:completed', payment)
								DisplayHelpText("Delivery Sucessfull!")
								if loadedPizzas > 0 then
									SetNotificationTextEntry("STRING")	
									AddTextComponentString("Go to the next Customer!")
									DrawNotification(false, true);
									Citizen.Wait(1000)
									RemovePedElegantly(customerp)
									startDelivery()
									return
								end
								if loadedPizzas <= 0 then
									SetNotificationTextEntry("STRING")	
									AddTextComponentString("Pick up more Pizza from the Pizzeria!")
									DrawNotification(false, true);
									RemovePedElegantly(customerp)
									DeliveryON = false
									return
								end
							end
						end
						if(IsControlReleased(1, 38))then
							DisplayHelpText("Press ~g~Enter~w~")

						end
						if GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= PizzaScooter then
							RemoveBlip(blipdelivery)	
							DisplayHelpText("You lost the Scooter. Get a new one from the Pizzeria!")
							RemovePedElegantly(customerp)
							DeliveryON = false
							return
						end
					end
				else
					return
				end
			end
		end
	end)
end
function round(number)
    return number - (number % 1)
end
function loadCustomer(loc)
	Citizen.CreateThread(function()
		customermodel = PizzaCustomers[GetRandomIntInRange(1, 14)]
		-- Load the ped modal from Array
		  RequestModel(customermodel)
		while not HasModelLoaded(customermodel) do
		    Wait(1)
	  	end
	    -- Spawn the Customer to the coordinates
	    customerp =  CreatePed(5, customermodel, loc.x ,loc.y ,loc.z, false, true)
	    SetBlockingOfNonTemporaryEvents(customerp, true)
	    SetPedCombatAttributes(customerp, 46, true)
	    SetPedFleeAttributes(customerp, 0, 0)
	    SetPedRelationshipGroupHash(customerp, GetHashKey("CIVFEMALE"))
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local scooterloc = GetEntityCoords(PizzaScooter, false)
		local pos = GetEntityCoords(GetPlayerPed(-1), false)
		if(Vdist(scooterloc.x, scooterloc.y, scooterloc.z, pos.x, pos.y, pos.z) > 100.0)and scooterloc.x ~= nil then
			Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( PizzaScooter ) )
			if DeliveryON == true then
				Citizen.Wait(10000)
				SetNotificationTextEntry("STRING")	
				AddTextComponentString("You Went to far away! The Pizza Scooter got deleted.")
				DrawNotification(false, true);
				RemovePedElegantly(customerp)
			end
			DeliveryON = false
			RemoveBlip(blipdelivery)
			--Citizen.Wait(4000)
			--return
		end
	end
end)
