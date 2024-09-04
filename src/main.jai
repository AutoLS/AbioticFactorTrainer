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
#load "cheat.jai";
window: *SDL_Window;

main :: ()
{
	SDL_Init(SDL_INIT_VIDEO);

	window = SDL_CreateWindow
	(
		"AutoCheat", 
		SDL_WINDOWPOS_CENTERED,
		SDL_WINDOWPOS_CENTERED, 
		400, 400,
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

	cheat: Cheat;
	init_cheat(*cheat);

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

		exe_name, found := table_find(*cheat.exe_name_table, cheat.current_game);
		if found 
		{
			id := get_process_id(exe_name);
			if id == 0 then cheat.game.attached = false;
		}
		else
		{
			cheat.game.attached = false;
		}

		if !cheat.game.attached
		{
			if cheat.current_game == 
			{
				case .Abiotic_Factor;
				{
					cheat.game = attach_process(ABIOTIC_FACTOR_EXE_NAME);
					init_abf_cheat(*cheat.abf, cheat.game);
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
			}
			if ImGui.BeginMenu("Menu")
			{
				defer ImGui.EndMenu();
				if ImGui.MenuItem("Abiotic Factor", null) cheat.current_game = .Abiotic_Factor;
				if ImGui.MenuItem("Corekeeper", null) cheat.current_game = .Corekeeper;
				if ImGui.MenuItem("Risk of Rain 2", null) cheat.current_game = .Risk_of_Rain;
			}
		}

		if cheat.game.attached
		{
			if cheat.current_game == 
			{
				case .Abiotic_Factor; abf_cheat_ui(*cheat.abf, cheat.game);
			}
		}
		else
		{
			ImGui.Text("Game not found! Please launch the game first!");
		}
		ImGui.End();

		ImGui.Render();
        glViewport(0, 0, xx io.DisplaySize.x, xx io.DisplaySize.y);
        glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        SDL_GL_SwapWindow(window);
	} 
}