#load "abiotic_factor.jai";

Game_Name :: enum u32
{
    Abiotic_Factor;
    Corekeeper;
    Risk_of_Rain;
}

Cheat :: struct
{
    game: Process_Attach;
    current_game: Game_Name;
    exe_name_table: Table(Game_Name, string);

    abf: Abiotic_Factor;
}

init_cheat :: (cheat: *Cheat)
{
    table_add(*cheat.exe_name_table, .Abiotic_Factor, ABIOTIC_FACTOR_EXE_NAME);
}

