Cheat :: struct
{
    game: Process_Attach;
    item_count: u32;
    unlimited_stamina: bool;
    mem_addr: Table(string, *u64);
}

init_cheat :: (executable_name: string, cheat: *Cheat)
{
    cheat.game = attach_process(executable_name);

    hotbar_slot1_addr := get_dynamic_memory_allocation_addr(cheat.game, 0x074CCE00, u32.[0x140, 0x2A0, 0x310, 0x278, 0x88, 0xA8, 0x30]);

    stamina_addr := get_dynamic_memory_allocation_addr(cheat.game, 0x074AEF68, u32.[0, 0x20, 0x278, 0x1C8, 0xB0, 0x90, 0x8A4]);

    table_add(*cheat.mem_addr, "hotbar_slot1", hotbar_slot1_addr);
    table_add(*cheat.mem_addr, "stamina", stamina_addr);
}

hotbar_slot1_input :: (cheat: Cheat)
{
    using cheat.game;
    addr, found := table_find(*cheat.mem_addr, "hotbar_slot1");
    if found
    {
        hotbar_slot_item_count: u32;
        ReadProcessMemory(process, cast(*void)addr, *hotbar_slot_item_count, size_of(u32), null);
        //ImGui.Text("Item Count: %", hotbar_slot_item_count);
        new_hotbar_slot1_count: u32 = hotbar_slot_item_count;
        step: u32 = 1;
        ImGui.PushItemWidth(100);
        if ImGui.InputScalar("Hotbar slot 1", ImGui.DataType.U32, *new_hotbar_slot1_count, cast(*void)*step, cast(*void)*step)
        {
            write_value(cheat.game, addr, *new_hotbar_slot1_count);
        }
        ImGui.PopItemWidth();
    }
}

unlimited_stamina_checkbox :: (using cheat: Cheat)
{
    max_stamina: float64 = 549755813888;
    addr, found := table_find(*cheat.mem_addr, "stamina");
    if found 
    {
        ImGui.Checkbox("Unlimited Stamina", *unlimited_stamina);
        if unlimited_stamina
        {
            write_value(game, addr, *max_stamina);
        }
    }
}