exception Missing_parameters of string
module StringMap = Map.Make(String)

(* index_of finds the index of a given value in an array of that type *)
let rec index_of ?(index : int=0) (aray : 'a array) (elem : 'a) : int option =
    if Array.length aray = index then None
    else if elem = Array.get aray index then Some index
    else index_of aray elem ~index:(index+1)


(* get_args parses CLI arguments into a set of filename
 * patterns and a command to run. *)
let get_args (vargs : string array) : (Str.regexp array * string) =
    match index_of vargs "-c" with
        | None   -> raise (Missing_parameters "no comand found after '-c' found in CLI arguments")
        | Some i ->
            let patterns = Array.sub vargs 1 (i-1) in
            let patterns = Array.map Str.regexp patterns in
            let command = Array.sub vargs (i+1) (Array.length vargs -(i+1)) in
            let command = String.concat " " (Array.to_list command) in
            patterns, command


(* walk calls a provided function on every regular file in directories
 * nested under the provided initial directory.
 * The search for files is performed in a DFS style. *)
let walk (dir : string) (fn : string -> Unix.stats -> 'a -> 'a) (x : 'a) =
    let rec walkdir (dir_name : string) (dir : Unix.dir_handle) (y : 'b) : 'b =
        try
            let filename = Unix.readdir dir in
            let fullpath = if dir_name <> "." then Filename.concat dir_name filename else filename in
            let s = Unix.stat fullpath in
            match (s.Unix.st_kind) with
                | Unix.S_REG -> walkdir dir_name dir (fn fullpath s y)     (* call 'fn' on regular files*)
                | Unix.S_DIR when String.sub filename 0 1 <> "." ->
                    walkdir fullpath (Unix.opendir fullpath) y             (* Start the DFS *)
                | _ -> walkdir dir_name dir y                              (* ignore other filetypes *)
        with End_of_file ->
            Unix.closedir dir; y
    in
    walkdir dir (Unix.opendir dir) x


(* get_filemap walks through the filesystem and returns a map with all
 * matching files and their last modified times. *)
let get_filemap (filenames : Str.regexp array) : float StringMap.t =
    let get_times (filename : string) (s : Unix.stats) (data : float StringMap.t) =
        if List.exists (fun p -> Str.string_match p filename 0) (Array.to_list filenames)
            then StringMap.add filename s.Unix.st_mtime data
            else data
    in
    walk "." get_times (StringMap.empty)


let () =
    let patterns, command = get_args Sys.argv in
    let init_map = get_filemap patterns in
    let rec checking_loop old_mod_times =
        let () = Unix.sleep 1 in
        let new_map = get_filemap patterns in
        if StringMap.equal (=) old_mod_times new_map
            then checking_loop new_map
            else
                print_endline (match Sys.command command with
                    | 0 -> "No error" |> Output.green_text
                    | i -> Format.sprintf "ERROR: exit status %d" i |> Output.red_text);
                checking_loop new_map
    in
    checking_loop init_map

