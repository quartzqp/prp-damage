-- init locales
lib.locale()

Config = Config or {}
Config.Debug = false

Config.NotifStyle = {
	alert = {
		background = "#760036",
	},
	progress = {
		background = "#ffffff",
	},
}

Config.BedModels = {
	1847650607,
	1729039189,
	`wx_hospital_bed`,
	`v_med_bed1`,
	`v_med_bed2`,
	`v_med_emptybed`,
	`v_med_cor_emblmtable`,
	`v_med_cor_autopsytbl`,
	`wx_hospital_bed`,
	`id1_h_oper_bad`, --These May Need to be Polyzoned?
	`id1_h_oper_bad002`,
	`id1_h_oper_bad003`,
	`gn_med_bed_prop`,
	`gn_med_ope_table_prop`,
	`gn_medic_diagtable`,
	`gn_med_xray_3_prop`,
	`bkr_prop_biker_campbed_01`
}


Config.BedOffsets = {
	[`bkr_prop_biker_campbed_01`] = {
		rotationOffset = 90,
	}
}

Config.HospitalZones = {
	{
		name = "safezone_los_santos",
		coords = vector3(33.947, -2674.302, 6.009),
		size = vec3(30.0, 30.0, 5.0),
		rotation = 0.0,
	},
}

Config.MilitaryZones = {
	{
		name = "military_base",
		coords = vector3(1634.295, 1295.873, 92.015),
		size = vec3(50.0, 50.0, 10.0),
		rotation = 0.0,
	}
}

Config.DynamicHospitalZones = {}

Config.PrisonHospitalZones = {}

Config.Clinics = {
	{
		location = vector4(35.090, -2687.622, 5.014, 177.039),
		model = `alvar_doc`,
		door = {}
	}
}

Config.DynamicClinics = {}

---Each check-in zone can check the amount of employees in a specific zone, the name of this zone is set in `prp-businesses-v2/shared/actionzones.lua`.
---We are primarily using this to change the check-in price based on how many (on-duty) employees are in the zone.
Config.CheckInZones = {
	["checking-safezone_los_santos"] = {
		coords = vector3(34.872, -2688.128, 6.014),
		length = 5.0,
		width = 5.6,
		minZ = 2.58,
		maxZ = 8.18,
		rotation = 0.0
	},
}

Config.DynamicCheckInZones = {}

Config.Beds = {
	{ x = 28.778, y = -2664.974, z = 6.660, h = 0.965 },
	{ x = 31.353, y = -2664.975, z = 6.658, h = 0.966 },
	{ x = 36.750, y = -2664.975, z = 6.652, h = 0.966 },
	{ x = 39.536, y = -2664.975, z = 6.652, h = 0.966 },
	{ x = 28.778, y = -2672.813, z = 6.659, h = 0.965 },
	{ x = 31.354, y = -2672.814, z = 6.657, h = 0.965 },
	{ x = 36.750, y = -2672.813, z = 6.652, h = 0.966 },
	{ x = 39.536, y = -2672.814, z = 6.652, h = 0.966 },

	-- MILITARY BASE
	{ x = 1640.837, y = 1297.232, z = 92.734, h = 167.730 },
	{ x = 1638.024, y = 1297.721, z = 92.734, h = 169.357 },
	{ x = 1635.894, y = 1298.129, z = 92.733, h = 168.480 },
	{ x = 1634.020, y = 1298.555, z = 92.734, h = 168.023 },
	{ x = 1631.811, y = 1298.871, z = 92.734, h = 167.964 },
	{ x = 1630.857, y = 1293.917, z = 92.734, h = 353.909 + 180.0 },
	{ x = 1632.950, y = 1293.448, z = 92.734, h = 351.953 + 180.0 },
	{ x = 1635.286, y = 1293.100, z = 92.734, h = 351.743 + 180.0 },
	{ x = 1637.480, y = 1292.745, z = 92.734, h = 351.954 + 180.0 },
	{ x = 1639.839, y = 1292.312, z = 92.733, h = 352.662 + 180.0 },
}

Config.DynamicBeds = {}

--[[
    GENERAL SETTINGS | THESE WILL AFFECT YOUR ENTIRE SERVER SO BE SURE TO SET THESE CORRECTLY
    MaxHp : Maximum HP Allowed, set to -1 if you want to disable mythic_hospital from setting this
        NOTE: Anything under 100 and you are dead
    RegenRate :
]]
Config.MaxHp = 200
Config.RegenRate = 0.0
Config.HealTimer = GetConvarInt("sv_nancyHealTimerOff", 60)
Config.RespawnTimer = 300

--[[
    AlertShowInfo :
]]
Config.AlertShowInfo = 2
