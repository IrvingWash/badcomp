#import "Basic";
#load "config.jai";

main :: () {
    error, config := make_config();
    if error {
        print(error, to_standard_error = true);
        exit(1);
    }

    print("%\n", config);
}
