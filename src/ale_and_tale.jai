ALE_AND_TALE_EXE_NAME :: "Ale and Tale Tavern.exe";
ALE_AND_TALE_MODULE_NAME :: "UnityPlayer.dll";

Ale_and_Tale :: struct
{
    money: u32;
    money_addr: *u64;
    
    god_mode: bool;
    hp_addr: *u64;
} 

init_ale_and_tale_cheat :: (using cheat: *Ale_and_Tale, game: Process_Attach)
{
    money_addr = get_dynamic_memory_allocation_addr(game, 0x01C70A48, u32.[0x688, 0x150, 0x28, 0x1F0, 0xD8]);
    hp_addr = get_dynamic_memory_allocation_addr(game, 0x01C773A0, u32.[0x0, 0xE0, 0x60, 0x120, 0x38]);
}

money_input :: (using cheat: *Ale_and_Tale, game: Process_Attach)
{
    read_value(game, money_addr, *money);
    ImGui.SetNextItemWidth(200);
    step: u32 = 100;
    step_fast: u32 = 500;
    if ImGui.InputScalar("Edit Money", ImGui.DataType.U32, *money, cast(*void)*step, cast(*void)*step_fast)
    {
        write_value(game, money_addr, *money);
    }
}

god_mode_check_box :: (using cheat: *Ale_and_Tale, game: Process_Attach)
{
    ImGui.Checkbox("God Mode", *god_mode);
    if god_mode
    {
        max_hp: s16 = 100;
        write_value(game, hp_addr, *max_hp);
    }
}

ale_and_tale_cheat_ui :: (using cheat: *Ale_and_Tale, game: Process_Attach)
{
    money_input(cheat, game);
    god_mode_check_box(cheat, game);
}