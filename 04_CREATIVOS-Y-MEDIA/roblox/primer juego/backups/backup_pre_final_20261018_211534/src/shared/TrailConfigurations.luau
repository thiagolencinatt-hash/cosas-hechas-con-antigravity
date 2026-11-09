--!strict
local TrailConfigurations = {}

export type TrailInfo = {
	ID: string,
	Name: string,
	SpeedBoost: number,
	SpeedMultiplier: number,
	GainMultiplier: number,
	MoneyCost: number,
	ProductId: number,
	Color: ColorSequence,
	Image: string,
	Biome: string,
}

TrailConfigurations.Trails = {
	{
		ID = "Trail_BrisaVerde",
		Name = "Rastro Brisa Verde",
		SpeedBoost = 2,
		SpeedMultiplier = 1.2,
		GainMultiplier = 1.2,
		MoneyCost = 1000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(80, 240, 100), Color3.fromRGB(40, 180, 70)),
		Image = "rbxassetid://89306781652186",
		Biome = "Pradera Verde",
	},
	{
		ID = "Trail_TormentaArena",
		Name = "Rastro Tormenta de Arena",
		SpeedBoost = 4,
		SpeedMultiplier = 1.5,
		GainMultiplier = 1.5,
		MoneyCost = 3500,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(240, 190, 80), Color3.fromRGB(180, 130, 40)),
		Image = "rbxassetid://106953796028431",
		Biome = "Desierto de Piedra",
	},
	{
		ID = "Trail_CeroAbsoluto",
		Name = "Rastro Cero Absoluto",
		SpeedBoost = 6,
		SpeedMultiplier = 2.0,
		GainMultiplier = 2.0,
		MoneyCost = 10000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(120, 225, 255), Color3.fromRGB(40, 160, 240)),
		Image = "rbxassetid://80823398251140",
		Biome = "Zona de Hielo",
	},
	{
		ID = "Trail_FiebreAzucar",
		Name = "Rastro Fiebre de Azúcar",
		SpeedBoost = 9,
		SpeedMultiplier = 2.8,
		GainMultiplier = 2.8,
		MoneyCost = 25000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 180, 220)),
		Image = "rbxassetid://74735631371205",
		Biome = "Reino de Caramelo",
	},
	{
		ID = "Trail_VaporToxico",
		Name = "Rastro Vapor Tóxico",
		SpeedBoost = 12,
		SpeedMultiplier = 3.8,
		GainMultiplier = 3.8,
		MoneyCost = 65000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(130, 255, 50), Color3.fromRGB(90, 40, 160)),
		Image = "rbxassetid://89306781652186",
		Biome = "Pantano Rocoso",
	},
	{
		ID = "Trail_CorrienteAbisal",
		Name = "Rastro Corriente Abisal",
		SpeedBoost = 16,
		SpeedMultiplier = 5.0,
		GainMultiplier = 5.0,
		MoneyCost = 150000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(0, 190, 255), Color3.fromRGB(0, 50, 140)),
		Image = "rbxassetid://80823398251140",
		Biome = "Zona de Agua",
	},
	{
		ID = "Trail_CometaMagma",
		Name = "Rastro Cometa de Magma",
		SpeedBoost = 22,
		SpeedMultiplier = 7.0,
		GainMultiplier = 7.0,
		MoneyCost = 400000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(255, 90, 20), Color3.fromRGB(200, 20, 20)),
		Image = "rbxassetid://106953796028431",
		Biome = "Zona Volcánica",
	},
	{
		ID = "Trail_PetalosSolares",
		Name = "Rastro Pétalos Solares",
		SpeedBoost = 30,
		SpeedMultiplier = 10.0,
		GainMultiplier = 10.0,
		MoneyCost = 1000000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(255, 230, 80), Color3.fromRGB(255, 140, 180)),
		Image = "rbxassetid://74735631371205",
		Biome = "Valle de Flores",
	},
	{
		ID = "Trail_NebulosaCosmica",
		Name = "Rastro Nebulosa Cósmica",
		SpeedBoost = 42,
		SpeedMultiplier = 15.0,
		GainMultiplier = 15.0,
		MoneyCost = 2500000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(160, 60, 255), Color3.fromRGB(60, 20, 180)),
		Image = "rbxassetid://80823398251140",
		Biome = "Espacio Galáctico",
	},
	{
		ID = "Trail_PropulsorOVNI",
		Name = "Rastro Propulsor OVNI",
		SpeedBoost = 60,
		SpeedMultiplier = 25.0,
		GainMultiplier = 25.0,
		MoneyCost = 7000000,
		ProductId = 0,
		Color = ColorSequence.new(Color3.fromRGB(50, 255, 210), Color3.fromRGB(20, 255, 80)),
		Image = "rbxassetid://89306781652186",
		Biome = "Planeta Alienígena",
	},
}

function TrailConfigurations.GetTrailById(id: string): TrailInfo?
	for _, trail in ipairs(TrailConfigurations.Trails) do
		if trail.ID == id then
			return trail
		end
	end
	return nil
end

return TrailConfigurations
