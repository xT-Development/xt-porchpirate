fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

description 'Porch Pirates for QB, QBX, OX, ND, & ESX | xT Development'
author 'xT Development'

dependencies = {
    '/onesync',
    'ox_lib',
    'ox_inventory',
    'Renewed-Lib'
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/sv_main.lua',
    'server/sv_hooks.lua',
}

files {
    'configs/*.lua',
}
