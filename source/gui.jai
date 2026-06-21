State :: struct {
    source:       string;
    destination:  string;
    should_clear: bool;
    should_fix:   bool;
    output:       string;
}

do_gui :: () {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";

        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    window := WC.create_window(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE);
    Simp.set_render_target(window);
    GR.ui_init();

    #if OS == {
        case .WINDOWS;
            Windows.DragAcceptFiles(window, cast(Windows.BOOL) true);
        case .LINUX;
            X11 :: #import "X11";
            typelist := string.["url/url", "text/uri-list", "text/plain", "application/octet-stream"];
            X11.enable_drag_and_drop(window, typelist);
        case .MACOS;
            #import "Objective_C";
            #import "Objective_C/AppKit";
            types := NSArray(NSPasteboardType).arrayWithObject(NSPasteboardTypeFileURL);
            NSView.registerForDraggedTypes(window, types);
    }

    theme := GR.default_theme_procs[GR.Default_Themes.Default]();
    current_time := seconds_since_init();
    quit: bool;

    state: State;

    while !quit {
        Input.update_window_events();

        for event: Input.events_this_frame {
            if event.type == .QUIT {
                quit = true;
            }

            GR.getrect_handle_event(event);
        }

        draw_frame(window, theme, current_time, *state);

        if state.should_fix {
            state.output = U.unshittify(state.source, state.destination);

            if !state.output {
                update_string(*state.output, to_string("Done!"));
                update_string(*state.source, to_string("Source"));
                update_string(*state.destination, to_string("Destination"));
            }
        }

        sleep_milliseconds(16);
    }
}

#scope_file

WINDOW_WIDTH  :: 800;
WINDOW_HEIGHT :: 600;
WINDOW_TITLE  :: "badcomp";

draw_frame :: (
    window: WC.Window_Type,
    theme: GR.Overall_Theme,
    current_time: float64,
    state: *State,
) {
    Simp.clear_render_target(
        theme.background_color.x,
        theme.background_color.y,
        theme.background_color.z,
        theme.background_color.w,
    );

    x, y, width, height := WC.get_dimensions(window, true);
    GR.ui_per_frame_update(window, width, height, current_time);

    r := GR.get_rect(
        width - (width - width * 0.5) - 50,
        height - height * 0.7,
        100,
        50,
    );
    state.should_fix = GR.button(r, "Fix");

    r = GR.get_rect(
        width - (width - width * 0.5) - 300,
        height - height * 0.2,
        600,
        50,
    );
    new_source_action, new_source := GR.text_input(
        r,
        state.source,
        *theme.text_input_theme,
    );
    if new_source_action & .ENTERED {
        update_string(*state.source, new_source);
    }

    r = GR.get_rect(
        width - (width - width * 0.5) - 300,
        height - height * 0.4,
        600,
        50,
    );
    new_destination_action, new_destination := GR.text_input(
        r,
        state.destination,
        *theme.text_input_theme,
    );
    if new_destination_action & .ENTERED {
        update_string(*state.destination, new_destination);
    }

    r = GR.get_rect(
        width - (width - width * 0.5) - 50,
        height - height * 0.5,
        100,
        50,
    );
    state.should_clear ^= GR.base_checkbox(
        r,
        "X?",
        state.should_clear,
    );

    r = GR.get_rect(
        width - (width - width * 0.5) - 200,
        height - height * 0.7,
        400,
        100,
    );
    if state.output {
        GR.text_input(
            r,
            state.output,
            *theme.text_input_theme,
            input_action = .DEACTIVATE,
        );
    }

    Simp.swap_buffers(window);
}

update_string :: (original: *string, new: string) {
    free(original.*);
    original.* = copy_string(new);
}

#import "Basic";
GR    :: #import "GetRect";
WC    :: #import "Window_Creation";
Simp  :: #import "Simp";
Input :: #import "Input";
U     :: #import,file "unshittifier.jai";
