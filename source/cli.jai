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
            #if OS == {
                case .WINDOWS;
                    Win :: #import "Windows";

                    kernel32 :: #system_library "kernel32";

                    ReadConsoleA  :: (
                        hConsoleInput:        Win.HANDLE,
                        lpBuffer:             *u8,
                        nNumberOfCharsToRead: Win.DWORD,
                        lpNumberOfCharsRead:  *s32,
                        lpInputControl :=     *void,
                    ) -> bool #foreign kernel32;

                    stdin := Win.GetStdHandle(Win.STD_INPUT_HANDLE);

                    buffer: [1024]u8;
                    bytes_read: s32;
                    ok := ReadConsoleA(stdin, buffer.data, buffer.count, *bytes_read);

                    reply = to_string(buffer.data, bytes_read,, temp);
                case;
                    return "We don't support your OS, delete the source directory yourself and think about your life choices while doing it";
            }
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



#scope_file

#import "Basic";
String :: #import "String";
File   :: #import      "File";
