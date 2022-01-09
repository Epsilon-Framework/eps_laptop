fx_version 'bodacious'
game 'gta5'

author 'MrFusiion'
version '1.0.0'

shared_scripts {
    '@qb-core/import.lua',
    'shared/sh_*.lua',
    'config.lua',
}

client_scripts {
    'client/cl_funcs.lua',

    'client/cl_*.lua',
    'client/apps/cl_*.lua',
    'client/apps/**/cl_*.lua'
}

server_scripts {
    'server/sv_funcs.lua',

    'server/sv_*.lua',
    'server/apps/sv_*.lua',
    'server/apps/**/sv_*.lua'
}

ui_page 'ui/index.html'

files {
    'ui/**'
}

dependencies {
    'qb-core'
}