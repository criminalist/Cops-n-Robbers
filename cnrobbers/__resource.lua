
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

client_scripts {
  "shared.lua", 
  "client.lua"
}
server_scripts {
  "shared.lua",
  "server.lua"
}

server_exports {
  'CurrentZone'
}

exports {
  'GetActiveZone',
  'WantedPoints',
  'ChatNotification'
}
