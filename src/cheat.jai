#load "abiotic_factor.jai";
#load "ale_and_tale.jai";

Game_Name :: enum u32
{
    Abiotic_Factor;
    Ale_and_Tale;
}

Cheat :: struct
{
    game: Process_Attach;
    current_game: Game_Name;
    exe_name_table: Table(Game_Name, string);

    abf: Abiotic_Factor;
    ale_and_tale: Ale_and_Tale;
}

init_cheat :: (cheat: *Cheat)
{
    table_add(*cheat.exe_name_table, .Abiotic_Factor, ABIOTIC_FACTOR_EXE_NAME);
    table_add(*cheat.exe_name_table, .Ale_and_Tale, ALE_AND_TALE_EXE_NAME);
}

