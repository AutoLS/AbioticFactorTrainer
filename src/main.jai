#import "Basic";
#import "String";
#import "Windows";
#import "System";
#import "Deep_Copy";
#import "Hash_Table";
#import "Math";
#load "ui.jai";
#load "input.jai";
#load "util.jai";
#load "proc.jai";
window: *SDL_Window;

main :: ()
{
	SDL_Init(SDL_INIT_VIDEO);

	window = SDL_CreateWindow
	(
		"Abf Trainer", 
		SDL_WINDOWPOS_CENTERED,
		SDL_WINDOWPOS_CENTERED, 
		300, 300,
		SDL_WINDOW_OPENGL
	);

	if window == null 
	{
		print("Could not create window: %\n", to_string(SDL_GetError()));
		return;
	}

	print("%\n", to_string(ImGui.GetVersion()));
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);
	gl_context := SDL_GL_CreateContext(window);
    if !gl_context 
	{
        print( "Could not create OpenGL context: %\n", to_string(SDL_GetError()));
        return;
    }

	gl_load(*gl, SDL_GL_GetProcAddress);

    imgui_context := ImGui.CreateContext();

    // Setup ImGui binding
    ImGui_ImplSdl_Init(window);

	ImGui.StyleColorsClassic();

	io := ImGui.GetIO();

	running := true;
	is_quit: bool;
	clear_color := Vector4.{0, 0, 0, 1.00};
	main_tool_active: bool;

	abf := attach_process("AbioticFactor-Win64-Shipping.exe");
	print("Process Attachment: %\n", abf);

	test_addr := abf.base_addr + 1;
	print("test_base_addr: %\n", test_addr);

	hotbar_slot1_addr := get_dynamic_memory_allocation_addr(abf, 0x074CCE00, u32.[0x2A8, 0x310, 0x320, 0xC0, 0x198, 0xA8, 0x30]);
	//print("hotbar_slot1_addr: %\n", cast(u64)hotbar_slot1_addr);

	while running
	{
		reset_temporary_storage();
		reset_controller_input(*global_input.keyboard);

		event: SDL_Event;
        while SDL_PollEvent(*event) 
		{
            ImGui_ImplSdl_ProcessEvent(*event);
            if event.type == SDL_QUIT   is_quit = true;
            if event.type == SDL_WINDOWEVENT && 
			   event.window.event == SDL_WINDOWEVENT_CLOSE && 
			   event.window.windowID == SDL_GetWindowID(window) 
			{
				running = false;
            }

			if event.type ==
			{
				case SDL_KEYDOWN; #through;
				case SDL_KEYUP;
				{
					is_down: bool = event.key.state == SDL_PRESSED;
					was_down: bool;
					
					if event.key.state == SDL_RELEASED
					{
						was_down = true;
					}
					else if event.key.repeat != 0
					{
						was_down = true;
					}
					
					if event.key.repeat == 0
					{
						key := event.key.keysym.scancode;
						
						button_state := table_find_pointer(*global_input.keyboard.keys, key);
						if button_state 
						{
							process_keypress(button_state, is_down, was_down);
						}
						else
						{
							new_state: Button_State;
							process_keypress(*new_state, is_down, was_down);
							table_add(*global_input.keyboard.keys, key, new_state);
						}
					}
				}
			}
        }

		ImGui_ImplSdl_NewFrame(window);
		ImGui.NewFrame();

		is_new_file := false;
		is_open_file := false;
		is_save_file := false;
		
		ImGui.Begin("Template", *main_tool_active, 
					IMGUI_WINDOW_FLAGS.NoTitleBar | 
					IMGUI_WINDOW_FLAGS.MenuBar |
					IMGUI_WINDOW_FLAGS.NoMove |
					IMGUI_WINDOW_FLAGS.NoResize |
					IMGUI_WINDOW_FLAGS.NoBackground);
		if ImGui.BeginMenuBar()
		{
			defer ImGui.EndMenuBar();
			if ImGui.BeginMenu("File")
			{
				defer ImGui.EndMenu();
				is_new_file = ImGui.MenuItem("New", "Ctrl+N");

				is_open_file = ImGui.MenuItem("Open..", "Ctrl+O");

				is_save_file = ImGui.MenuItem("Save", "Ctrl+S");

				if ImGui.MenuItem("Save as..") 
				{
					
				}
			}
		}

		hotbar_slot_item_count: u32;
		ReadProcessMemory(abf.process, cast(*void)hotbar_slot1_addr, *hotbar_slot_item_count, size_of(u32), null);
		ImGui.Text("Item Count: %", hotbar_slot_item_count);
		// new_hotbar_slot1_count: u32 = hotbar_slot_item_count;
		// ImGui.PushItemWidth(100);
		// ImGui.InputScalar("Hotbar slot", ImGui.DataType.U32, *new_hotbar_slot1_count);
		// ImGui.PopItemWidth();
		
		ImGui.End();

		ImGui.Render();
        glViewport(0, 0, xx io.DisplaySize.x, xx io.DisplaySize.y);
        glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        SDL_GL_SwapWindow(window);
	} 
}