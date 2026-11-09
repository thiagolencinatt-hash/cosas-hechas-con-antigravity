--!strict
export type WeaponInfo = {
	Id: string,
	Name: string,
	Description: string,
	Price: number,
	BreakPower: number,
	Biome: string,
	Color: Color3,
	ModelColor: Color3,
	Material: Enum.Material,
}

local OpeningToolsConfig = {}

OpeningToolsConfig.Tools = {
	{
		Id = "MazoMadera",
		Name = "Mazo de Madera",
		Description = "Herramienta rústica de golpe contundente. Ideal para principiantes en la Pradera Verde.",
		Price = 0,
		BreakPower = 1,
		Biome = "Pradera Verde",
		Color = Color3.fromRGB(160, 110, 60),
		ModelColor = Color3.fromRGB(120, 80, 45),
		Material = Enum.Material.Wood,
	},
	{
		Id = "PicoRomperrocas",
		Name = "Pico Romperrocas",
		Description = "Pico de piedra afilada y cuarzo. Diseñado para quebrar conchas endurecidas por el sol del Desierto.",
		Price = 2500,
		BreakPower = 3,
		Biome = "Desierto de Piedra",
		Color = Color3.fromRGB(240, 180, 60),
		ModelColor = Color3.fromRGB(190, 140, 50),
		Material = Enum.Material.Sandstone,
	},
	{
		Id = "MartilloEscarcha",
		Name = "Martillo de Escarcha",
		Description = "Forjado en hielo perenne. Aplica frío glacial que vuelve quebradizas las corazas de la Cumbre.",
		Price = 8000,
		BreakPower = 7,
		Biome = "Zona de Hielo",
		Color = Color3.fromRGB(100, 220, 255),
		ModelColor = Color3.fromRGB(150, 235, 255),
		Material = Enum.Material.Ice,
	},
	{
		Id = "MazoChicle",
		Name = "Mazo de Chicle Macizo",
		Description = "Hecho de azúcar condensada y caramelo reforzado. Destroza cápsulas dulces sin pegarse.",
		Price = 20000,
		BreakPower = 15,
		Biome = "Reino de Caramelo",
		Color = Color3.fromRGB(255, 100, 180),
		ModelColor = Color3.fromRGB(255, 140, 200),
		Material = Enum.Material.SmoothPlastic,
	},
	{
		Id = "HachaAcida",
		Name = "Hacha Ácida",
		Description = "Hoja bañada en savia cáustica del pantano. Disuelve al instante la protección de cáscaras tóxicas.",
		Price = 50000,
		BreakPower = 35,
		Biome = "Pantano Rocoso",
		Color = Color3.fromRGB(120, 255, 50),
		ModelColor = Color3.fromRGB(80, 180, 40),
		Material = Enum.Material.Cobblestone,
	},
	{
		Id = "TridenteAbisal",
		Name = "Tridente Abisal",
		Description = "Canaliza la presión de las fosas marinas. Perfora con precisión las corazas sumergidas.",
		Price = 125000,
		BreakPower = 80,
		Biome = "Zona de Agua",
		Color = Color3.fromRGB(30, 180, 255),
		ModelColor = Color3.fromRGB(10, 100, 200),
		Material = Enum.Material.Glass,
	},
	{
		Id = "EspadonMagma",
		Name = "Espadón de Magma",
		Description = "Filo incandescente bañado en lava viva. Funde las corazas basálticas del Núcleo Volcánico.",
		Price = 300000,
		BreakPower = 180,
		Biome = "Zona Volcánica",
		Color = Color3.fromRGB(255, 80, 20),
		ModelColor = Color3.fromRGB(220, 40, 10),
		Material = Enum.Material.Neon,
	},
	{
		Id = "GuadanaFloral",
		Name = "Guadaña Floral",
		Description = "Hoja de espinas colosales y polen denso. Siega las cápsulas vivas del Valle de Flores.",
		Price = 750000,
		BreakPower = 400,
		Biome = "Valle de Flores",
		Color = Color3.fromRGB(255, 215, 60),
		ModelColor = Color3.fromRGB(230, 80, 160),
		Material = Enum.Material.Grass,
	},
	{
		Id = "EspadaLaserGalactica",
		Name = "Espada Láser Galáctica",
		Description = "Haz de plasma cósmico estabilizado por cristales astrales. Corta cualquier aleación planetaria.",
		Price = 2000000,
		BreakPower = 1000,
		Biome = "Espacio Galáctico",
		Color = Color3.fromRGB(180, 60, 255),
		ModelColor = Color3.fromRGB(220, 100, 255),
		Material = Enum.Material.Neon,
	},
	{
		Id = "CanonDesintegradorAlien",
		Name = "Cañón Desintegrador Alien",
		Description = "Tecnología extraterrestre hiper-avanzada. Desintegra corazas biológicas en un parpadeo.",
		Price = 5500000,
		BreakPower = 2500,
		Biome = "Planeta Alienígena",
		Color = Color3.fromRGB(40, 255, 180),
		ModelColor = Color3.fromRGB(20, 220, 140),
		Material = Enum.Material.Neon,
	},
}

function OpeningToolsConfig.GetToolById(id: string): WeaponInfo?
	for _, tool in ipairs(OpeningToolsConfig.Tools) do
		if tool.Id == id then return tool end
	end
	return nil
end

return OpeningToolsConfig
