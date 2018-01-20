description 'ESX Trucker By AlphaKush, Thanks to Marcio for the original script'

server_scripts {
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/fr.lua',
	'config.lua',
	'client/main.lua'
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/bankgothic.ttf',
	'html/pdown.ttf',
	'html/css/app.css',
	'html/scripts/mustache.min.js',
	'html/scripts/app.js',
	'html/img/keys/enter.png',
	'html/img/keys/return.png'
}