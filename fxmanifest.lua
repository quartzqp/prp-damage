fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'
description 'Blue Sky Limb Damage'
client_script "@prp-base/components/cl_error.lua"
client_script "@prp-pwnzor/client/check.lua"

version '2.0.0'

shared_scripts {
	'@ox_lib/init.lua',
	'sh_config.lua',
	'sh_definitions.lua',
	'sh_strings.lua',
}

client_scripts {
	'client/**/*.lua',
}

server_scripts {
	'server/**/*.lua',
}

files {
	"locales/*.json"
}