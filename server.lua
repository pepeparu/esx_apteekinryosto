ESX = nil
TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

RegisterNetEvent("esx_apteekki:saalis")
AddEventHandler("esx_apteekki:saalis", function(itemi, maara)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(itemi, maara)
end)


ESX.RegisterServerCallback("esx_apteekki:sijainnit", function(source, cb, target, data)
    local sijainnit = {
        ryosto = vector3(230.6, -1366.6, 38.5),
        myynti = vector3(-1161.5, -973.2, 1.2)
    }
    cb(sijainnit)
end)

ESX.RegisterServerCallback("esx_apteekki:poliisimaarat", function(source, cb, target, data)
    local poliiseja = ESX.GetExtendedPlayers('job', 'police')
    cb(#poliiseja)
end)

RegisterNetEvent("esx_apteekki:halyytapofliis")
AddEventHandler("esx_apteekki:halyytapofliis", function(sukupuoli)
    for _, xPlayer in pairs(ESX.GetExtendedPlayers('job', 'police')) do
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('ryosto_kohteessa', sukupuoli))
    end
end)

RegisterNetEvent("esx_apteekki:ryostoloppu")
AddEventHandler("esx_apteekki:ryostoloppu", function()
    for _, xPlayer in pairs(ESX.GetExtendedPlayers('job', 'police')) do
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('ryosto_ohi'))
    end
end)

RegisterNetEvent("esx_apteekki:lahtirinkulasta")
AddEventHandler("esx_apteekki:lahtirinkulasta", function()
    for _, xPlayer in pairs(ESX.GetExtendedPlayers('job', 'police')) do
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('ryosto_keskeytetty'))
    end
end)

RegisterNetEvent("esx_apteekki:server:laitablippi")
AddEventHandler("esx_apteekki:server:laitablippi", function()
    for _, xPlayer in pairs(ESX.GetExtendedPlayers('job', 'police')) do
        TriggerClientEvent("esx_apteekki:client:laitablippi", xPlayer.source)
    end
end)

RegisterNetEvent("esx_apteekki:server:poistablippi")
AddEventHandler("esx_apteekki:server:poistablippi", function()
    for _, xPlayer in pairs(ESX.GetExtendedPlayers('job', 'police')) do
        TriggerClientEvent("esx_apteekki:client:poistablippi", xPlayer.source)
    end
end)

RegisterNetEvent("esx_apteekki:rahat")
AddEventHandler("esx_apteekki:rahat", function(tuote, maara, x, y, z)
    xPlayer = ESX.GetPlayerFromId(source)
    if not (xPlayer.getInventoryItem(tuote).count > maara) then
        TriggerClientEvent("esx:showNotification", xPlayer.source, _U('ei_tarpeeksi'))
        return
    end
    local randomi = math.random(1, 25)
    if (randomi == 11) then
        for _, pelaaja in pairs(ESX.GetExtendedPlayers('job', 'police')) do
            local hash = GetStreetNameAtCoord(x, y, z, Citizen.ResultAsInteger())
            local tie = GetStreetNameFromHashKey(hash)
            TriggerClientEvent('esx:showNotification', pelaaja.source, _U('myynti_kaynnissa', tie))
            TriggerClientEvent("esx_apteekki:myyntiblippi")
        end
    end

    if (xPlayer.getInventoryItem(tuote).count > xPlayer.getInventoryItem(tuote).weight) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('reppu_taynna'))
        return
    end

    print(xPlayer.getInventoryItem(tuote).count)
    
    xPlayer.removeInventoryItem(tuote, maara)

    if Config.Likainen then
        xPlayer.addAccountMoney('black_money', Config[tuote] * maara)
    else
        xPlayer.addAccountMoney('money', Config[tuote] * maara)
    end
end)


