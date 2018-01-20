----------------------------------------------------------------------
----------------------- Developped by AlphaKush ----------------------
----------------------------------------------------------------------

Config = {}

Config.Price = 3500

Config.DrawDistance = 100.0
Config.MarkerSize   = {x = 2, y = 2, z = 1}
Config.MarkerColor  = {r = 102, g = 102, b = 204}
Config.MarkerType   = 1

Config.Zones = {}

Config.garage = {
  --{x=-327.12713623047, y=-144.54234313965, z=38.059986114502},
  {x=1182.6057128906, y=2638.2951660156, z=36.795085906982},
  {x=103.66405487061, y=6622.677734375, z=30.828517913818},
  {x=735.73376464844, y=-1072.3411865234, z=21.23295211792},
}

for i=1, #Config.garage, 1 do

	Config.Zones['Garage_' .. i] = {
	 	Pos   = Config.garage[i],
	 	Size  = Config.MarkerSize,
	 	Color = Config.MarkerColor,
	 	Type  = Config.MarkerType
  }

end
