------------Not in Use Currently---------
----------------Just an Idea-------------

meats = 7
flours = 28
vegetabless = 49

RegisterServerEvent('pizzadelivery:removeingredients')
AddEventHandler('pizzadelivery:removeingredients', function(amount)
	meats = meats - amount
	flours = flours - amount
	vegetabless = vegetabless - amount
end)

RegisterServerEvent('pizzadelivery:addingredients')
AddEventHandler('pizzadelivery:addingredients', function(amountm, amountf, amountv)
	meats = meats + amountm
	flours = flours + amountf
	vegetabless = vegetabless + amountv
end)

RegisterServerEvent('pizzadelivery:getingredients')
AddEventHandler('pizzadelivery:getingredients', function()
	local ingr1 = meats
	local ingr2 = flours
	local ingr3 = vegetabless
 	TriggerClientEvent('pizzadelivery:getingredientsc', 1, 2, 3)
end)
