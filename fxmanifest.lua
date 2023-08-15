fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ZF Labo'
description 'QB Menu & Inputs Converter for OX_LIB'

client_script 'client/*.lua'
server_script 'versioncheck.lua'
shared_scripts {
    '@ox_lib/init.lua',
}

provide 'qb-menu'
provide 'qb-input'