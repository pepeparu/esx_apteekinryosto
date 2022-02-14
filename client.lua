ESX = nil
local ryostamassa = false
--local cooldown_kaynnissa = false 
local cooldown = 0


TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

function sijainnit()
    ESX.TriggerServerCallback("esx_apteekki:sijainnit", function(data)
        rx,ry,rz = table.unpack(data.ryosto)
        mx,my,mz = table.unpack(data.myynti)
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        ESX.TriggerServerCallback("esx_apteekki:poliisimaarat", function(data)
            poliiseja = data
        end)
    end
end)

sijainnit()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        if Vdist2(rx,ry,rz,x,y,z) < Config.Piirtomatka then
            if not ryostamassa then    
                DrawMarker(Config.Tyyppi, rx,ry,rz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Koko, Config.Koko, 1.5, Config.Vari.r, Config.Vari.g, Config.Vari.b, Config.Vari.a, false, true, 2, false, nil, nil, false)
            end
        end
        if Vdist2(mx,my,mz,x,y,z) < Config.Piirtomatka then
            DrawMarker(Config.Tyyppi, mx,my,mz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Koko, Config.Koko, 1.5, Config.Vari.r, Config.Vari.g, Config.Vari.b, Config.Vari.a, false, true, 2, false, nil, nil, false)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)
        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        if Vdist2(rx,ry,rz,x,y,z) < Config.Koko then
            if not ryostamassa then 
                rinkulassa_ryosto = true
                ESX.ShowHelpNotification(_U('ryostaaksesi'))
            else
                rinkulassa_ryosto = false 
            end
        end

        if Vdist2(mx,my,mz,x,y,z) < Config.Koko then
            rinkulassa_myynti = true
            ESX.ShowHelpNotification(_U('myydaksesi'))
        else 
            rinkulassa_myynti = false 
        end

    end
end)


Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if IsControlJustPressed(1, 51) then
            if rinkulassa_myynti then
                myykamat()
            end
        end
    end
end)

function myykamat()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'myynti_menu', 
    {
        title = "Myy lääkkeitä",
        elements = {
            {label = "Myy Pamol F - Paketteja", value = "pamolf"},
            {label = "Myy Burana - Paketteja", value = "burana"},
            {label = "Myy Fentanyyli - Paketteja", value = "fentanyyli"},
            {label = "Myy Morfiini - Purkkeja", value = "morfiini"},
            {label = "Myy Antibiootti - Purkkeja", value = "antibiootti"}
        },
        align = "bottom-right"
    }, function(data, menu)
        if data.current.value == "pamolf" then
            maaramenu(data.current.value)
        end
        if data.current.value == "burana" then
            maaramenu(data.current.value)
        end
        if data.current.value == "fentanyyli" then
            maaramenu(data.current.value)
        end
        if data.current.value == "morfiini" then
            maaramenu(data.current.value)
        end
        if data.current.value == "antibiootti" then
            maaramenu(data.current.value)
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function maaramenu(tuote)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'maara_menu',
    {
        title = "Määrä"
    },
    function(data, menu)
        local maara = tonumber(data.value)
        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        TriggerServerEvent("esx_apteekki:rahat", tuote, maara, x, y, z)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if IsControlJustPressed(1, 51) then
            if rinkulassa_ryosto then
                if not ryostamassa then
                    if (poliiseja > Config.Poliisimaara) then 
                        if IsPedArmed(GetPlayerPed(-1), 4) then
                            if (cooldown == 0) then
                                ESX.ShowNotification(_U('aloitit_ryoston'))
                                ryosta()
                                ryostamassa = true
                            else
                                ESX.ShowNotification(_U('ryostetty_vasta', cooldown))
                            end
                        else 
                            ESX.ShowNotification("~r~Sinulla ei ole asetta!")
                        end
                    else
                        ESX.ShowNotification(_U('ei_tarpeeksi_poliiseja'))
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("esx_apteekki:client:laitablippi")
AddEventHandler("esx_apteekki:client:laitablippi", function()
    blip = AddBlipForCoord(rx, ry)
    SetBlipDisplay(blip, 6)
	SetBlipSprite(blip, 161)
	SetBlipScale(blip, 2.0)
	SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Apteekin ryöstö")
    EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent("esx_apteekki:myyntiblippi")
AddEventHandler("esx_apteekki:myyntiblippi", function()
    myyntiblippi = AddBlipForCoord(mx, my)
    SetBlipDisplay(blip, 6)
	SetBlipSprite(blip, 161)
	SetBlipScale(blip, 2.0)
	SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Aineen myynti")
    EndTextCommandSetBlipName(blip)
    Citizen.Wait(10*1000)
    RemoveBlip(myyntiblippi)
end)

RegisterNetEvent("esx_apteekki:client:poistablippi")
AddEventHandler("esx_apteekki:client:poistablippi", function()
    RemoveBlip(blip)
end)



function ryosta()
    TriggerServerEvent("esx_apteekki:server:laitablippi")
    timeri = Config.Ryostoaika
    if IsPedMale(GetPlayerPed(-1)) then
        TriggerServerEvent("esx_apteekki:halyytapofliis", "Mies")
    else
        TriggerServerEvent("esx_apteekki:halyytapofliis", "Nainen")
    end
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)
            timeri = timeri - 5
            if not (timeri == 0) then
                ESX.ShowNotification(_U('ryostoa_jaljella', timeri))
            end
            local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
            if Vdist2(rx,ry,rz,x,y,z) > 75 then
                if ryostamassa then
                    ESX.ShowNotification(_U('ryosto_keskeytyi'))
                    TriggerServerEvent("esx_apteekki:lahtirinkulasta")
                    ryostamassa = false
                    Citizen.Wait(3000)
                    TriggerServerEvent("esx_apteekki:server:poistablippi")
                    break
                end
            end

            if timeri == 0 then
                local itemit = {
                    "antibiootti",
                    "burana",
                    "fentanyyli",
                    "morfiini",
                    "pamolf"
                }
                local oikeaitemi = itemit[math.random(1, #itemit)] 

                if oikeaitemi == "antibiootti" then
                    itemi = "Antibiootti - Purkki"
                end

                if oikeaitemi == "burana" then
                    itemi = "Burana - Paketti"
                end

                if oikeaitemi == "fentanyyli" then
                    itemi = "Fentanyyli - Paketti"
                end

                if oikeaitemi == "morfiini" then
                    itemi = "Morfiini - Purkki"
                end

                if oikeaitemi == "pamolf" then
                    itemi = "PamolF - Paketti"
                end
                
                local maara = math.random(Config.Maarat.min, Config.Maarat.max)
                ESX.ShowNotification(_('ryosto_onnistui', maara, itemi))
                TriggerServerEvent("esx_apteekki:saalis", oikeaitemi, maara)
                TriggerServerEvent("esx_apteekki:ryostoloppu")
                ryostamassa = false
                cooldowni()
                Citizen.Wait(3000)
                TriggerServerEvent("esx_apteekki:server:poistablippi")
                break
            end
        end
    end)
end

function cooldowni()
    cooldown = Config.Cooldowni
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            cooldown = cooldown - 1
            --cooldowni_kaynnissa = true
            if (cooldown == 0) then
                --cooldowni_kaynnissa = false 
                break
            end
        end
    end)
end




