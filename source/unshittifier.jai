unshittify :: (source_path: string, destination_path: string) -> error: string {
    file_paths := FU.file_list(source_path,, temp);

    mp3_file_path: string;
    for file_path: file_paths {
        if String.path_extension(file_path) == "mp3" {
            mp3_file_path = file_path;
            break;
        }
    }
    if !mp3_file_path {
        return "Source directory doesn't contain any mp3 files";
    }

    error, album_info := get_album_info(mp3_file_path);
    if error {
        return error;
    }

    // @Todo: this doesn't work with UTF16
    new_path := tprint("%/%/% - %", destination_path, album_info.artist, album_info.year, album_info.album);
    ok := File.make_directory_if_it_does_not_exist(
        new_path,
        recursive = true,
    );
    if !ok {
        return tprint("Failed to create directory at: %", new_path);
    }

    return "";
}



#scope_file

Album_Info :: struct {
    artist: string;
    album:  string;
    year:   string;
}

get_album_info :: (mp3_path: string) -> error: string, Album_Info {
    album_info: Album_Info;

    error, tag := ID3.read_tag(mp3_path);
    defer ID3.destroy_tag(tag);
    if error {
        return tprint("Something went wrong when we tried to parse the id3 tag: %", error), album_info;
    }

    for frame: tag.frames {
        if frame.body.kind == {
            case .TPE1;
                if !album_info.artist {
                    album_info.artist = copy_string(frame.body.tpe1.information,, temp);
                }
            case .TPE2;
                if !album_info.artist {
                    album_info.artist = copy_string(frame.body.tpe2.information,, temp);
                }
            case .TALB;
                album_info.album = copy_string(frame.body.talb.information,, temp);
            case .TYER;
                if !album_info.year {
                    album_info.year = copy_string(frame.body.tyer.information,, temp);
                }
            case .TDRC;
                if !album_info.year {
                    album_info.year = copy_string(frame.body.tdrc.information,, temp);
                }
            case .TDRL;
                album_info.year = copy_string(frame.body.tdrl.information,, temp);
        }
    }

    return "", album_info;
}

#import "Basic";
FU     :: #import "File_Utilities";
String :: #import "String";
ID3    :: #import "jaid3";
File   :: #import "File";
