fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ZF Labo'
description 'QB Interfaces Compatibility for OverExtended\'s Resources' 
version '1.3.1'

client_script 'client/*.lua'
server_script 'versioncheck.lua'
shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

provide 'qb-menu'
provide 'qb-input'