#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);
String :: #import "String";
File   :: #import "File";
U :: #import,file "unshittifier.jai";

Config :: struct {
    source:               string;
    destination:          string;
    should_remove_source: bool;
    should_help:          bool;
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
        help_people();

        return;
    }

    error = U.unshittify(config.source, config.destination);
    if error {
        print("%\n", error, to_standard_error = true);
        exit(1);
    }

    if config.should_remove_source {
        error = remove_source_interactively(config.source);
        if error {
            print("%\n", error, to_standard_error = true);
            exit(1);
        }
    }
}

remove_source_interactively :: (source_path: string) -> error: string {
    agreed_for_deletion: bool;
    while true {
        print("Going to delete '%' (the source directory you passed), you sure? y/n\n", source_path);

        reply: string;

        #if OS_IS_UNIX {
            POSIX  :: #import "POSIX";

            buffer: [4096]u8;
            bytes_read := POSIX.read(POSIX.STDIN_FILENO, buffer.data, buffer.count - 1);

            reply = to_string(buffer.data, bytes_read,, temp);
        } else {
            return "We don't support your OS, delete the source directory yourself and think about your life choices while doing it";
        }

        if String.trim(reply) == {
            case "y";
                agreed_for_deletion = true;
                break;
            case "n";
                agreed_for_deletion = false;
                break;
        }
    }

    if agreed_for_deletion {
        ok := File.delete_directory(source_path);
        if !ok {
            return tprint("Failed to delete the source directory %\n", source_path);
        }
    }

    return "";
}

help_people :: () {
HELP :: #string DONE
Bandcamp album structure fixer

Usage: badcomp --source <SOURCE> --desintation <DESTINATION>

Flags:
-s, --source <SOURCE>           - Path to the directory with the album
-d, --destination <DESTINATION> - Path to the the destination directory
-r, --remove-source             - Delete the source directory
-h, --help                      - Show this help
DONE;

    print(HELP);
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

    if !config.source && !config.should_help {
        return "Source directory was not provided, what were you thinking?", config;
    }

    if !config.destination && !config.should_help {
        return "Destination directory was not provided. Sorry, we don't know what to do in such a case", config;
    }

    return "", config;
}
