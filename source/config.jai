Config :: struct {
    source:        string;
    destination:   string;
    should_remove_source: bool;
}

make_config :: () -> error: string, Config {
    config: Config;

    arguments := get_command_line_arguments();

    unknown_arguments: [..]string;
    unknown_arguments.allocator = temp;

    for argument: arguments {
        if it_index == 0 {
            continue; // We want to skip the first argument which is the path to the app
        }

        if argument == {
            case "--source"; #through;
            case "-s";
                expected_path_index := it_index + 1;

                if (
                    arguments.count >= expected_path_index + 1
                    && !starts_with(arguments[expected_path_index], "-")
                ) {
                    config.source = arguments[expected_path_index];

                    it_index += 1;

                    continue;
                }
                
                return "A directory path must follow the --source flag", config;
            case "--destination"; #through;
            case "-d";
                expected_path_index := it_index + 1;

                if (
                    arguments.count >= expected_path_index + 1
                    && !starts_with(arguments[expected_path_index], "-")
                ) {
                    config.destination = arguments[expected_path_index];

                    it_index += 1;

                    continue;
                }
                
                return "A directory path must follow the --destination flag", config;
            case "--remove-source"; #through;
            case "-r";
                config.should_remove_source = true;
            case;
                array_add(*unknown_arguments, argument);
        }
    }

    if unknown_arguments.count > 0 {
        return tprint("Encountered some unknown arguments: %, stop fatfingering", unknown_arguments), config;
    }

    if !config.source {
        return "Source directory was not provided, what were you thinking?", config;
    }

    if !config.destination {
        return "Destination directory was not provided. Sorry, we don't know what to do in such a case", config;
    }

    return "", config;
}



#scope_file

#import "String";
