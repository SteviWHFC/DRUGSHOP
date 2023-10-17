local QBCore = exports['qb-core']:GetCoreObject()

local isMelting = false
local canTake = false
local meltTime
local meltedItem = {}

RegisterNetEvent('drugshop:client:openMenu', function()
    if Config.UseTimes then
        if GetClockHours() >= Config.TimeOpen and GetClockHours() <= Config.TimeClosed then
            local pawnShop = {
                {
                    header = Lang:t('info.title'),
                    isMenuHeader = true,
                },
                {
                    header = Lang:t('info.sell'),
                    txt = Lang:t('info.sell_pawn'),
                    params = {
                        event = 'drugshop:client:openPawn',
                        args = {
                            items = Config.PawnItems
                        }
                    }
                }
            }
            if not isMelting then
                pawnShop[#pawnShop + 1] = {
                    header = Lang:t('info.melt'),
                    txt = Lang:t('info.melt_pawn'),
                    disabled = true,
                    params = {
                        event = 'drugshop:client:openMelt',
                        args = {
                            items = Config.MeltingItems
                        }
                    }
                }
            end
            if canTake then
                pawnShop[#pawnShop + 1] = {
                    header = Lang:t('info.melt_pickup'),
                    txt = '',
                    params = {
                        isServer = true,
                        event = 'drugshop:server:pickupMelted',
                        args = {
                            items = meltedItem
                        }
                    }
                }
            end
            exports['qb-menu']:openMenu(pawnShop)
        else
            QBCore.Functions.Notify(Lang:t('info.pawn_closed', { value = Config.TimeOpen, value2 = Config.TimeClosed }))
        end
    else
        local pawnShop = {
            {
                header = Lang:t('info.title'),
                isMenuHeader = true,
            },
            {
                header = Lang:t('info.sell'),
                txt = Lang:t('info.sell_pawn'),
                params = {
                    event = 'drugshop:client:openPawn',
                    args = {
                        items = Config.PawnItems
                    }
                }
            }
        }
        if not isMelting then
            pawnShop[#pawnShop + 1] = {
                header = Lang:t('info.melt'),
                txt = Lang:t('info.melt_pawn'),
                params = {
                    event = 'drugshop:client:openMelt',
                    args = {
                        items = Config.MeltingItems
                    }
                }
            }
        end
        if canTake then
            pawnShop[#pawnShop + 1] = {
                header = Lang:t('info.melt_pickup'),
                txt = '',
                params = {
                    isServer = true,
                    event = 'drugshop:server:pickupMelted',
                    args = {
                        items = meltedItem
                    }
                }
            }
        end
        exports['qb-menu']:openMenu(pawnShop)
    end
end)

RegisterNetEvent('drugshop:client:openPawn', function(data)
    QBCore.Functions.TriggerCallback('drugshop:server:getInv', function(inventory)
        local PlyInv = inventory
        local pawnMenu = {
            {
                header = Lang:t('info.title'),
                isMenuHeader = true,
            }
        }
        for _, v in pairs(PlyInv) do
            for i = 1, #data.items do
                if v.name == data.items[i].item then
                    pawnMenu[#pawnMenu + 1] = {
                        header = QBCore.Shared.Items[v.name].label,
                        txt = Lang:t('info.sell_items', { value = data.items[i].price }),
                        params = {
                            event = 'drugshop:client:pawnitems',
                            args = {
                                label = QBCore.Shared.Items[v.name].label,
                                price = data.items[i].price,
                                name = v.name,
                                amount = v.amount
                            }
                        }
                    }
                end
            end
        end
        pawnMenu[#pawnMenu + 1] = {
            header = Lang:t('info.back'),
            params = {
                event = 'drugshop:client:openMenu'
            }
        }
        exports['qb-menu']:openMenu(pawnMenu)
    end)
end)

RegisterNetEvent('drugshop:client:pawnitems', function(item)
    local sellingItem = exports['qb-input']:ShowInput({
        header = Lang:t('info.title'),
        submitText = Lang:t('info.sell'),
        inputs = {
            {
                type = 'number',
                isRequired = false,
                name = 'amount',
                text = Lang:t('info.max', { value = item.amount })
            }
        }
    })
    if sellingItem then
        if not sellingItem.amount then
            return
        end

        if tonumber(sellingItem.amount) > 0 then
            TriggerServerEvent('drugshop:server:sellPawnItems', item.name, sellingItem.amount, item.price)
        else
            QBCore.Functions.Notify(Lang:t('error.negative'), 'error')
        end
    end
end)

RegisterNetEvent('drugshop:client:resetPickup', function()
    canTake = false
end)
