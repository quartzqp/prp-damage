Config = Config or {}

--[[
    HealthDamage : How Much Damage To Direct HP Must Be Applied Before Checks For Damage Happens
    ArmorDamage : How Much Damage To Armor Must Be Applied Before Checks For Damage Happens | NOTE: This will in turn make stagger effect with armor happen only after that damage occurs
]]
Config.HealthDamage = 6
Config.ArmorDamage = 10

--[[
    MaxInjuryChanceMulti : How many times the HealthDamage value above can divide into damage taken before damage is forced to be applied
    ForceInjury : Maximum amount of damage a player can take before limb damage & effects are forced to occur
]]
Config.MaxInjuryChanceMulti = 3
Config.ForceInjury = 19
Config.AlwaysBleedChance = 35

--[[ 
    BleedTickRate : How much time, in seconds, between bleed ticks
]]
Config.BleedTickRate = 30

--[[ 
    BleedEvidenceRate : How much time, in seconds, between blood falling to the floor as evidence (it is divided by bleed level 1-4)
]]

Config.BleedEvidenceRate = 4

--[[
    BleedMovementTick : How many seconds is taken away from the bleed tick rate if the player is walking, jogging, or sprinting
    BleedMovementAdvance : How Much Time Moving While Bleeding Adds (This Adds This Value To The Tick Count, Meaing The Above BleedTickRate Will Be Reached Faster)
]]
Config.BleedMovementTick = 10
Config.BleedMovementAdvance = 3

--[[
    The Base Damage That Is Multiplied By Bleed Level Every Time A Bleed Tick Occurs
]]
Config.BleedTickDamage = 2

--[[
    AdvanceBleedTimer : How many bleed ticks occur before bleed level increases
]]
Config.AdvanceBleedTimer = 10

--[[
    HeadInjuryTimer : How much time, in seconds, do head injury effects chance occur
    ArmInjuryTimer : How much time, in seconds, do arm injury effects chance occur
    LegInjuryTimer : How much time, in seconds, do leg injury effects chance occur
]]
Config.HeadInjuryTimer = 30
Config.ArmInjuryTimer = 30
Config.LegInjuryTimer = 15

--[[
    The Chance, In Percent, That Certain Injury Side-Effects Get Applied
]]
Config.HeadInjuryChance = 25
Config.ArmInjuryChance = 25
Config.LegInjuryChance = {
	Running = 50,
	Walking = 15,
}

--[[
    MajorArmoredBleedChance : The % Chance Someone Gets A Bleed Effect Applied When Taking Major Damage With Armor
    MajorDoubleBleed : % Chance You Have To Receive Double Bleed Effect From Major Damage, This % is halved if the player has armor
]]
Config.MajorArmoredBleedChance = 30

--[[
    DamgeMinorToMajor : How much damage would have to be applied for a minor weapon to be considered a major damage event. Put this at 100 if you want to disable it
]]
Config.DamageMinorToMajor = 25

--[[
    These following lists uses tables defined in definitions.lua, you can technically use the hardcoded values but for sake
    of ensuring future updates doesn't break it I'd highly suggest you check that file for the index you're wanting to use.

    MinorInjurWeapons : Damage From These Weapons Will Apply Only Minor Injuries
    MajorInjurWeapons : Damage From These Weapons Will Apply Only Major Injuries
    AlwaysBleedChanceWeapons : Weapons that're in the included weapon classes will roll for a chance to apply a bleed effect if the damage wasn't enough to trigger an injury chance
    CriticalAreas : 
    StaggerAreas : These are the body areas that would cause a stagger is hit by firearms,
        Table Values: Armored = Can This Cause Stagger If Wearing Armor, Major = % Chance You Get Staggered By Major Damage, Minor = % Chance You Get Staggered By Minor Damage
]]

Config.MinorInjurWeapons = {
	[Config.WeaponClasses["SMALL_CALIBER"]] = true,
	[Config.WeaponClasses["MEDIUM_CALIBER"]] = true,
	[Config.WeaponClasses["CUTTING"]] = true,
	[Config.WeaponClasses["WILDLIFE"]] = true,
	[Config.WeaponClasses["OTHER"]] = true,
	[Config.WeaponClasses["LIGHT_IMPACT"]] = true,
}

Config.MajorInjurWeapons = {
	[Config.WeaponClasses["HIGH_CALIBER"]] = true,
	[Config.WeaponClasses["HEAVY_IMPACT"]] = true,
	[Config.WeaponClasses["SHOTGUN"]] = true,
	[Config.WeaponClasses["EXPLOSIVE"]] = true,
}

Config.AlwaysBleedChanceWeapons = {
	[Config.WeaponClasses["SMALL_CALIBER"]] = true,
	[Config.WeaponClasses["MEDIUM_CALIBER"]] = true,
	[Config.WeaponClasses["CUTTING"]] = true,
	[Config.WeaponClasses["WILDLIFE"]] = true,
}

Config.ForceInjuryWeapons = {
	[Config.WeaponClasses["HIGH_CALIBER"]] = true,
	[Config.WeaponClasses["HEAVY_IMPACT"]] = true,
	[Config.WeaponClasses["EXPLOSIVE"]] = true,
}

Config.CriticalAreas = {
	["UPPER_BODY"] = { armored = false },
	["LOWER_BODY"] = { armored = true },
	["SPINE"] = { armored = true },
	["HEAD"] = { armored = false },
}

Config.StaggerAreas = {
	["SPINE"] = { armored = true, major = 60, minor = 30 },
	["UPPER_BODY"] = { armored = false, major = 60, minor = 30 },
	["LLEG"] = { armored = true, major = 100, minor = 85 },
	["RLEG"] = { armored = true, major = 100, minor = 85 },
	["LFOOT"] = { armored = true, major = 100, minor = 100 },
	["RFOOT"] = { armored = true, major = 100, minor = 100 },
}

Config.ICUBeds = {
	vector4(-309.096039, -569.146423, 37.197, 35.673),
	vector4(-297.522736, -570.301697, 37.197, 307.200),
	vector4(-292.680145, -577.657104, 37.197, 301.083),
	vector4(-298.943329, -588.053833, 37.195, 212.668),
	--[[ MOUNT ZONAH
	vector4(-484.631, -329.334, 69.523, 352.380),
	vector4(-483.648, -341.486, 69.523, 178.489),
	vector4(-477.289, -330.050, 69.523, 1.676),
	vector4(-476.180, -342.179, 69.523, 179.781),
	vector4(-469.840, -331.163, 69.523, 1.152),
	vector4(-468.668, -343.538, 69.523, 181.606),
	vector4(-462.200, -332.150, 69.521, 4.846),
	vector4(-461.303, -344.223, 69.523, 174.951),
	vector4(-445.279, -346.800, 69.523, 176.390),
	vector4(-435.775, -336.701, 69.523, 274.043),]]
}

