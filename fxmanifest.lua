fx_version 'cerulean'
game 'gta5'

author 'AngelicXS'
version '1.5.1'

client_script 'client.lua'

server_script {
	'server.lua',
    '@mysql-async/lib/MySQL.lua'
}

dependencies {
    'ps-ui',
}

shared_script 'config.lua'
