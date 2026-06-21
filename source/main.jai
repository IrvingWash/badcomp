#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);
String :: #import      "String";
U      :: #import,file "unshittifier.jai";
CLI    :: #import,file "cli.jai";

Config :: struct {
    source:               string;
    destination:          string;
    should_remove_source: bool;
    should_help:          bool;
    use_gui:              bool;
}

main :: () {
    #if DEBUG {
        defer report_memory_leaks();
    }

    defer reset_temporary_storage();

    error, config := make_config();
    if error {
        print("%\n", error, to_standard_error = true);
        exit(1);
    }

    if config.should_help {
        CLI.help_people();

        return;
    }

    if !config.use_gui {
        error = U.unshittify(config.source, config.destination);
        if error {
            print("%\n", error, to_standard_error = true);
            exit(1);
        }

        if config.should_remove_source {
            error = CLI.remove_source_interactively(config.source);
            if error {
                print("%\n", error, to_standard_error = true);
                exit(1);
            }
        }

        return;
    }

    if config.use_gui {
    }
}

make_config :: () -> error: string, Config {
    config: Config;

    arguments := get_command_line_arguments(,, temp);

    unknown_arguments: [..]string;
    unknown_arguments.allocator = temp;

    for argument: arguments {
        if it_index == 0 {
            continue; // We want to skip the first argument which is the path to the app
        }

        if argument == {
            case "--help";
                #through;
            case "-h";
                config.should_help = true;

            case "--gui";
                #through;
            case "-g";
                config.use_gui = true;

            case "--source";
                #through;
            case "-s";
                expected_path_index := it_index + 1;

                if (
                    arguments.count >= expected_path_index + 1
                    && !String.starts_with(arguments[expected_path_index], "-")
                ) {
                    config.source = arguments[expected_path_index];

                    it_index += 1;

                    continue;
                }

                return "A directory path must follow the --source flag", config;

            case "--destination";
                #through;
            case "-d";
                expected_path_index := it_index + 1;

                if (
                    arguments.count >= expected_path_index + 1
                    && !String.starts_with(arguments[expected_path_index], "-")
                ) {
                    config.destination = arguments[expected_path_index];

                    it_index += 1;

                    continue;
                }

                return "A directory path must follow the --destination flag", config;

            case "--remove-source";
                #through;
            case "-r";
                config.should_remove_source = true;

            case;
                array_add(*unknown_arguments, argument);
        }
    }

    if unknown_arguments.count > 0 {
        return tprint("Encountered some unknown arguments: %, stop fatfingering", unknown_arguments), config;
    }

    if !config.source && !config.should_help && !config.use_gui {
        return "Source directory was not provided, what were you thinking?", config;
    }

    if !config.destination && !config.should_help && !config.use_gui {
        return "Destination directory was not provided. Sorry, we don't know what to do in such a case", config;
    }

    return "", config;
}
