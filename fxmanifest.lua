fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ZF Labo'
description 'QB Menu & Inputs Converter for OX_LIB'
version '1.0.0'

client_script 'client/*.lua'
server_script 'versioncheck.lua'
shared_scripts {
    '@ox_lib/init.lua',
}

provide 'qb-menu'
provide 'qb-input'
