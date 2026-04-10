WAVE_SETTINGS = {
    initial_delay = 0,
    default_interval = 120,
    repeat_last_wave = true,
    spawn_point_name = "wave_spawn",
    waypoint_prefix = "wave_path_",
    waypoint_count_max = 64,
    target_scan_radius = 700,
    fort_override_radius = 1200,
    spawn_scatter_radius = 120,
    waves = {
        {
            creeps = {
                {name = "npc_dota_creep_badguys_melee", count = 6}
            }
        },
        {
            creeps = {
                {name = "npc_dota_creep_badguys_melee", count = 4},
                {name = "npc_dota_creep_badguys_ranged", count = 2}
            }
        },
        {
            creeps = {
                {name = "npc_dota_creep_badguys_melee", count = 6},
                {name = "npc_dota_creep_badguys_ranged", count = 3}
            }
        }
    }
}