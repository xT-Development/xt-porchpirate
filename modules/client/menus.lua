local UTILS = lib.load('modules.client.utils')

local menus = {}

-- view all packages
function menus.viewAllPackages()
    if GetInvokingResource() then return end

    local options = {}
    if GlobalState.porchPackages and next(GlobalState.porchPackages) then
        for x = 1, #GlobalState.porchPackages do
            options[x] = {
                title = ('Package %s'):format(x),
                description = ('Coords: %s'):format(GlobalState.porchPackages[x].coords),
                icon = 'fas fa-box-archive',
                onSelect = function()
                    menus.viewPackage(x, GlobalState.porchPackages[x])
                end
            }
        end
    end

    if not options or not next(options) then
        options[1] = {
            title = 'No packages found',
            description = 'There are no packages to view'
        }
    end

    lib.registerContext({
        id = 'xt_porchpirate_menu',
        title = 'Porch Pirate: All Packages',
        options = options
    })
    lib.showContext('xt_porchpirate_menu')
end

-- view package
function menus.viewPackage(id, info)
    local options = {
        {
            title = 'Go To Package',
            description = 'Teleport to the package',
            icon = 'fas fa-map-pin',
            onSelect = function()
                local coords = info.coords
                SetEntityCoords(cache.ped, coords.x, coords.y, coords.z)
            end
        },
        {
            title = 'Delete Package',
            description = 'Delete the package. This removes it for all players, but instantly re-spawns another to replace it.',
            icon = 'fas fa-trash',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Delete Package',
                    content = 'Are you sure you want to delete this package?  \nOnce deleted, a new package will randomly generate and replace it.',
                    centered = true,
                    cancel = true
                }) if confirm == 'cancel' then return end

                local deleted = lib.callback.await('xt-porchpirate:server:deletePackage', false, {
                    id = id,
                    coords = info.coords
                })

                if deleted then
                    lib.notify({
                        title = 'Porch Pirate',
                        description = 'Successfully deleted package',
                        type = 'success'
                    })
                    menus.viewAllPackages()
                end
            end
        }
    }

    lib.registerContext({
        id = 'xt_porchpirate_view_package',
        title = 'Porch Pirate: All Packages',
        options = options
    })
    lib.showContext('xt_porchpirate_view_package')
end


return menus