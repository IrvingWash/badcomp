unshittify :: (source_path: string, destination_path: string) -> error: string {
    mp3_paths: [..]string;
    mp3_paths.allocator = temp;

    other_file_paths: [..]string;
    other_file_paths.allocator = temp;

    {
        file_paths := FU.file_list(source_path, recursive = true,, temp);

        for file_path: file_paths {
            if String.path_extension(file_path) == "mp3" {
                array_add(*mp3_paths, file_path);
            } else {
                array_add(*other_file_paths, file_path);
            }
        }

        if mp3_paths.count < 1 {
            return "Source directory doesn't contain any mp3 files";
        }
    }

    track_infos: [..]Track_Info;
    track_infos.allocator = temp;
    for mp3_file_path: mp3_paths {
        error, track_info := get_track_info(mp3_file_path);
        if error {
            return error;
        }
        array_add(*track_infos, track_info);
    }

    new_album_path := tprint("%/%/% - %", destination_path, track_infos[0].artist, track_infos[0].year, track_infos[0].album);
    {
        ok := File.make_directory_if_it_does_not_exist(
            new_album_path,
            recursive = true,
        );
        if !ok {
            return tprint("Failed to create directory at: %", new_album_path);
        }
    }

    for track_info: track_infos {
        new_file_path := tprint("%/%. %.mp3", new_album_path, track_info.nubmer, track_info.name);
        ok := FU.copy_file(
            track_info.filepath,
            new_file_path,
        );
        if !ok {
            return tprint("Failed to copy % into %", track_info.filepath, new_file_path);
        }
    }

    for other_file_path: other_file_paths {
        new_file_path := tprint("%/%", new_album_path, String.path_filename(other_file_path));

        ok := FU.copy_file(
            other_file_path,
            new_file_path,
        );
        if !ok {
            return tprint("Failed to copy % into %", other_file_path, new_file_path);
        }
    }

    return "";
}



#scope_file

Track_Info :: struct {
    name:     string;
    nubmer:   string;
    artist:   string;
    album:    string;
    year:     string;
    filepath: string;
}

get_track_info :: (mp3_path: string) -> error: string, Track_Info {
    track_info: Track_Info = {
        filepath = copy_string(mp3_path,, temp),
    };

    error, tag := ID3.read_tag(track_info.filepath);
    defer ID3.destroy_tag(tag);
    if error {
        return tprint("Something went wrong when we tried to parse the id3 tag: %", error), track_info;
    }

    for frame: tag.frames {
        if frame.body.kind == {
            case .TPE1;
                if !track_info.artist {
                    track_info.artist = copy_string(frame.body.tpe1.information,, temp);
                }
            case .TPE2;
                if !track_info.artist {
                    track_info.artist = copy_string(frame.body.tpe2.information,, temp);
                }
            case .TALB;
                track_info.album = copy_string(frame.body.talb.information,, temp);
            case .TYER;
                if !track_info.year {
                    track_info.year = copy_string(frame.body.tyer.information,, temp);
                }
            case .TDRC;
                if !track_info.year {
                    track_info.year = copy_string(frame.body.tdrc.information,, temp);
                }
            case .TDRL;
                track_info.year = copy_string(frame.body.tdrl.information,, temp);
            case .TRCK;
                track_info.nubmer = copy_string(frame.body.trck.information,, temp);
            case .TIT2;
                track_info.name = copy_string(frame.body.tit2.information,, temp);
        }
    }

    return "", track_info;
}

#import "Basic";
FU     :: #import "File_Utilities";
String :: #import "String";
ID3    :: #import "jaid3";
File   :: #import "File";
