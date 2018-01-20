Config                            = {}
Config.DrawDistance               = 100.0
Config.MarkerColor                = { r = 102, g = 0, b = 102 }
Config.NPCJobEarnings             = {min = 200, max = 300}
Config.EnablePlayerManagement     = true
local second = 1000
local minute = 60 * second
-- How much time before auto respawn at hospital
Config.RespawnDelayAfterRPDeath   = 5 * minute
-- How much time before a menu opens to ask the player if he wants to respawn at hospital now
-- The player is not obliged to select YES, but he will be auto respawn
-- at the end of RespawnDelayAfterRPDeath just above.
Config.RespawnToHospitalMenuTimer   = true
Config.MenuRespawnToHospitalDelay   = 5 * minute
Config.EnableSocietyOwnedVehicles = false
Config.RemoveWeaponsAfterRPDeath  = true
Config.RemoveCashAfterRPDeath     = true
Config.RemoveItemsAfterRPDeath    = true

-- Will display a timer that shows RespawnDelayAfterRPDeath time remaining
Config.ShowDeathTimer             = true
-- Will allow to respawn at any time, don't use RespawnToHospitalMenuTimer at the same time !
Config.EarlyRespawn               = false
-- The player can have a fine (on bank account)
Config.EarlyRespawnFine           = false
Config.EarlyRespawnFineAmount     = 100
Config.Locale                     = 'en'

Config.JobLocations = {
	{x = 295.44149780273,y = -1439.6423339844,z = 28.803928375244 },
	{x = 1165.1629638672,y = -1536.8948974609,z = 38.400791168213 },
	{x = 1827.8881835938,y = 3693.8835449219,z = 33.224269866943 },
}

Config.Blip = {
  Pos     = { x = 1151.447, y = -1529.491, z = 34.375 },
  Sprite  = 61,
  Display = 4,
  Scale   = 1.2,
  Colour  = 2,
}

Config.HelicopterSpawner = {
  SpawnPoint  = { x = 1151.447, y = -1529.491, z = 34.375 },
  Heading     = 0.0
}


Config.Zones = {


  HospitalInteriorEntering1 = {
    Pos  = { x = 1151.447, y = -1529.491, z = 34.375 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = 1
  },

  HospitalInteriorInside1 = {
    Pos  = { x = 251.464, y = -1369.770, z = 28.648 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = -1
  },

  HospitalInteriorOutside1 = {
    Pos  = { x = 1153.364, y = -1525.731, z = 33.843 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = -1
  },

  HospitalInteriorExit1 = {
    Pos  = { x = 253.612, y = -1371.66, z = 28.647 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = 1
  },

  HospitalInteriorEntering2 = {
    Pos  = { x = 1137.181, y = -1597.504, z = 33.692 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = 1
  },

  HospitalInteriorInside2 = {
    Pos  = { x = 240.508,  y = -1360.565, z = 28.647 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = -1
  },

  HospitalInteriorOutside2 = {
    Pos  = { x = 1137.922, y = -1601.434, z = 33.692 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = -1
  },

  HospitalInteriorExit2 = {
    Pos  = { x = 238.587,  y = -1359.113, z = 28.647 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = 1
  },

  AmbulanceActions = {
    Pos  = { x = 244.048, y = -1366.330, z = 28.647 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = 1
  },

  VehicleSpawner = {
    Pos  = { x = 1128.290, y = -1601.451, z = 33.893 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = 1
  },

  VehicleSpawnPoint = {
    Pos  = { x = 1138.061, y = -1607.882, z = 34.692 },
    Size = { x = 1.5, y = 1.5, z = 1.0 },
    Type = -1
  },

  VehicleDeleter = {
    Pos  = { x = 1146.143, y = -1617.472, z = 34.694 },
    Size = { x = 3.0, y = 3.0, z = 2.0 },
    Type = 1
  },
  
  Pharmacy = {
    Pos  = {x = 230.38511657715,y = -1366.3583984375,z = 38.534370422363 },
    Size = { x = 1.5, y = 1.5, z = 0.4 },
    Type = 1
  },
  
  AuthorizedVehicles = {
	{ name = 'polgs350',  label = 'ambulance1' },
  }

}
