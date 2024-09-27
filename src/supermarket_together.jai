SUPERMARKET_EXE_NAME :: "Supermarket Together.exe";
SUPERMARKET_MODULE_NAME :: "UnityPlayer.dll";

Supermarket_Together :: struct 
{
    money: float32;
    money_addr: *u64;

    franchise_points: u32;
    franchise_points_addr: *u64;

    time: float32;
    time_addr: *u64;
}

init_supermarket_together_cheat :: (using cheat: *Supermarket_Together, game: Process_Attach)
{
    money_addr = get_dynamic_memory_allocation_addr(game, 0x01BC6228, u32.[0x950, 0x68, 0x6F8, 0x110, 0x50, 0x10, 0x168]);

    franchise_points_addr = xx (cast(*u8)money_addr + 0x8);
    time_addr = xx (cast(*u8)money_addr + 0x14);
}

money_input :: (using cheat: *Supermarket_Together, game: Process_Attach)
{
    read_value(game, money_addr, *money);
    ImGui.SetNextItemWidth(200);
    step: float32 = 100;
    step_fast: float32 = 500;
    if ImGui.InputScalar("Edit Money", ImGui.DataType.Float, *money, cast(*void)*step, cast(*void)*step_fast)
    {
        write_value(game, money_addr, *money);
    }
}

perk_input :: (using cheat: *Supermarket_Together, game: Process_Attach)
{
    read_value(game, franchise_points_addr, *franchise_points);
    ImGui.SetNextItemWidth(200);
    step: u32 = 1;
    step_fast: u32 = 5;
    if ImGui.InputScalar("Edit Franchise Points", ImGui.DataType.U32, *franchise_points, cast(*void)*step, cast(*void)*step_fast)
    {
        write_value(game, franchise_points_addr, *franchise_points);
    }
}

skip_day_button :: (using cheat: *Supermarket_Together, game: Process_Attach)
{
    if ImGui.Button("Skip day")
    {
        read_value(game, time_addr, *time);
        if time > 8.0 && time < 22.5 
        {
            time = 22.49;
            write_value(game, time_addr, *time);
        }
    }
}

supermarket_cheat_ui :: (using cheat: *Supermarket_Together, game: Process_Attach)
{
    money_input(cheat, game);
    perk_input(cheat, game);
    skip_day_button(cheat, game);
}