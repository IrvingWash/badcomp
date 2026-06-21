do_gui :: () {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";

        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    window := WC.create_window(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE);
    Simp.set_render_target(window);
    GR.ui_init();

    theme := GR.default_theme_procs[GR.Default_Themes.Default]();
    current_time := seconds_since_init();
    quit: bool;

    while !quit {
        Input.update_window_events();

        for event: Input.events_this_frame {
            if event.type == .QUIT {
                quit = true;
            }

            GR.getrect_handle_event(event);
        }

        draw_frame(window, theme, current_time);

        // reset_temporary_storage();

        sleep_milliseconds(16);
    }
}

#scope_file

WINDOW_WIDTH  :: 800;
WINDOW_HEIGHT :: 600;
WINDOW_TITLE  :: "badcomp";

draw_frame :: (window: WC.Window_Type, theme: GR.Overall_Theme, current_time: float64) {
    Simp.clear_render_target(0.3, 0.3, 0.3, 1);

    x, y, width, height := WC.get_dimensions(window, true);
    GR.ui_per_frame_update(window, width, height, current_time);

    // Toys
    r := GR.get_rect(
        width - (width - width * 0.8),
        height - height * 0.9,
        100,
        50,
    );
    pressed := GR.button(r, "Fix");

    r = GR.get_rect(
        width - (width - width * 0.5),
        height - height * 0.2,
        400,
        50,
    );
    GR.text_input(
        r,
        "Source path",
        *theme.text_input_theme,
    );

    Simp.swap_buffers(window);
}

#import "Basic";
GR    :: #import "GetRect";
WC    :: #import "Window_Creation";
Simp  :: #import "Simp";
Input :: #import "Input";
