
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependency 'cnrobbers'

client_scripts {
  "cl_chat.lua"
}

server_scripts {
  "sv_chat.lua"
}

server_exports {
  'DiscordMessage'
}

exports {
}
