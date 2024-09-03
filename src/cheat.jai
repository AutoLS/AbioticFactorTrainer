Cheat :: struct
{
    game: Process_Attach;
    item_count: u32;
    unlimited_stamina: bool;
    mem_addr: Table(string, *u64);

    location_name_text: [128] u8;
    saved_location_names: [..] string;
    saved_location: Table(string, Vector3);
    selected_location_index: s32;
    custom_coordinate_tp: [3] float; 
}

init_cheat :: (executable_name: string, cheat: *Cheat)
{
    cheat.game = attach_process(executable_name);

    hotbar_slot1_addr := get_dynamic_memory_allocation_addr(cheat.game, 0x074CCE00, u32.[0x140, 0x2A0, 0x310, 0x278, 0x88, 0xA8, 0x30]);

    stamina_addr := get_dynamic_memory_allocation_addr(cheat.game, 0x074AEF68, u32.[0, 0x20, 0x278, 0x1C8, 0xB0, 0x90, 0x8A4]);

    zaxis_addr := get_dynamic_memory_allocation_addr(cheat.game, 0x074F6710, u32.[0x110, 0x50, 0x180, 0xC0, 0x48, 0xB0, 0x270]);

    table_add(*cheat.mem_addr, "hotbar_slot1", hotbar_slot1_addr);
    table_add(*cheat.mem_addr, "stamina", stamina_addr);
    table_add(*cheat.mem_addr, "zpos", zaxis_addr);
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
        ImGui.Text("Hotbar Slot 1 Settings");
        ImGui.PushItemWidth(100);
        if ImGui.InputScalar("Item Count", ImGui.DataType.U32, *new_hotbar_slot1_count, cast(*void)*step, cast(*void)*step)
        {
            write_value(cheat.game, addr, *new_hotbar_slot1_count);
        }
        ImGui.PopItemWidth();
        if ImGui.Button("Max Durability/Decay")
        {
            durability_decay_addr := cast(*u8)addr - 0x10;
            max_dura_decay_addr := cast(*u8)addr - 0x8;
            max_value: float64; 
            read_value(cheat.game, xx max_dura_decay_addr, *max_value);
            write_value(cheat.game, xx durability_decay_addr, *max_value);
        }
        if ImGui.Button("Max battery")
        {
            max_value_addr := cast(*u8)addr + 0x58BB6C40; //Don't know if this is static
            battery_addr := cast(*u8)addr + 0x8;
            max_battery: u32;
            read_value(cheat.game, xx max_value_addr, *max_battery);
            write_value(cheat.game, xx battery_addr, *max_battery);
        }
    }
}
checkbox_cheat :: (using cheat: Cheat)
{
    max_stamina: float64 = 412325249024;
    addr, found := table_find(*cheat.mem_addr, "stamina");
    if found 
    {
        ImGui.Text("Player");
        ImGui.Checkbox("Unlimited Stamina", *unlimited_stamina);
        if unlimited_stamina
        {
            write_value(game, addr, *max_stamina);
        }
    }
}

get_player_position :: (using cheat: Cheat) -> Vector3
{
    position: Vector3;
    addr, found := table_find(*mem_addr, "zpos");
    if found
    {
        pos_z: float64;
        pos_x: float64;
        pos_y: float64;

        x_addr := cast(*u8)addr-16;
        y_addr := cast(*u8)addr-8;

        read_value(game, cast(*u64)addr, *pos_z);
        read_value(game, cast(*u64)x_addr, *pos_x);
        read_value(game, cast(*u64)y_addr, *pos_y);

        position = Vector3.{xx pos_x, xx pos_y, xx pos_z};
    }

    return position;
}

teleport_menu :: (using cheat: Cheat)
{
    player_position := get_player_position(cheat);
    ImGui.Text("Teleport");
    ImGui.Text("(%, %, %)", cast(int)player_position.x, cast(int)player_position.y, cast(int)player_position.z);
    ImGui.SetNextItemWidth(200);
    ImGui.InputText("Name", location_name_text.data, location_name_text.count);
    if ImGui.Button("Add")
    {
        name := copy_string(cast(string)location_name_text);
        array_add(*saved_location_names, name);
        
        table_add(*saved_location, name, player_position);

        for location_name_text
        {
            location_name_text[it_index] = xx "";
        }
    }

    ImGui.SetNextItemWidth(150);
    ImGui.InputFloat3("Custom Coordinate", *custom_coordinate_tp);
    if ImGui.Button("Teleport##0")
    {
        addr, addr_found := table_find(*mem_addr, "zpos");
        if addr_found
        {
            print("Teleporting to position: %\n", custom_coordinate_tp);
            pos_x: float64 = xx custom_coordinate_tp[0];
            pos_y: float64 = xx custom_coordinate_tp[1]; 
            pos_z: float64 = xx custom_coordinate_tp[2];

            x_addr := cast(*u8)addr-16;
            y_addr := cast(*u8)addr-8;

            write_value(game, addr, *pos_z);
            write_value(game, cast(*u64)x_addr, *pos_x);
            write_value(game, cast(*u64)y_addr, *pos_y);
        }
    }

    location_names: [..] *u8;
    location_names.allocator = temp;

    for saved_location_names array_add(*location_names, to_c_string(it));

    ImGui.SetNextItemWidth(200);
    if location_names.count > 0
    {
        combo_box("Locations", location_names, *selected_location_index);
        if ImGui.Button("Teleport##1")
        {
            pos, found := table_find(*saved_location, saved_location_names[selected_location_index]);
            if found
            {
                addr, addr_found := table_find(*mem_addr, "zpos");
                if addr_found
                {
                    print("Teleporting to position: %\n", pos);
                    pos_z: float64 = xx (pos.z + 1.0);
                    pos_x: float64 = xx pos.x;
                    pos_y: float64 = xx pos.y; 

                    x_addr := cast(*u8)addr-16;
                    y_addr := cast(*u8)addr-8;

                    write_value(game, addr, *pos_z);
                    write_value(game, cast(*u64)x_addr, *pos_x);
                    write_value(game, cast(*u64)y_addr, *pos_y);
                }
            }
        }
    }
}