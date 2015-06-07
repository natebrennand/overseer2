exception Missing_parameters of string
module StringMap = Map.Make(String)
type watched_file = {
    last_modified: float;
    modified: bool;
}


(* index_of finds the index of a given value in an array of that type *)
let rec index_of ?(index:int=0) (aray:'a array) (elem:'a) : int option =
    if Array.length aray = index then None
    else if elem = Array.get aray index then Some index
    else index_of aray elem ~index:(index+1)


(* get_args parses CLI arguments into a set of filename
 * patterns and a command to run. *)
let get_args (vargs:string array) : (string array * string array) =
    match index_of vargs "-c" with
        | None   -> raise (Missing_parameters "no comand found after '-c' found in CLI arguments")
        | Some i ->
            let patterns = Array.sub vargs 1 (i-1) in
            let command = Array.sub vargs (i+1) (Array.length vargs -(i+1)) in
            patterns, command


(* walk calls a provided function on every regular file in directories
 * nested under the provided initial directory.
 * The search for files is performed in a DFS style. *)
let rec walk (dir : string) (fn : Unix.stats -> 'a -> 'a) (x : 'a) =
    let rec walkdir (dir : Unix.dir_handle) (y : 'b) : 'b =
        try
            let filename =  Unix.readdir dir in
            let s = Unix.stat filename in
            match s.st_kind with
                | Unix.S_REG -> walkdir dir (fn s y)
                | Unix.S_DIR -> (* Start the DFS *)
                    let new_dir = Unix.opendir filename in
                    walkdir new_dir y
                | _ -> walkdir dir y
        with End_of_file -> Unix.closedir dir; y
    in
    let dir = Unix.opendir "." in
    walkdir dir x


let get_filemap (filenames:string array) : float StringMap.t =
    let filemap = StringMap.empty in
    (*
    let init_watched_file filename =
        let stats = Unix.lstat filename in
            ()
    *)
    StringMap.add "test" 3.0 filemap



let tester () =
    let dir = Unix.opendir "." in
    let rec foo (x : Unix.dir_handle) =
        try let () = print_endline (Unix.readdir x) in foo x
        with End_of_file -> ()
    in
    let () = print_endline "DIR:" in
    let () = foo dir in
    let () = print_endline "END DIR" in
    let x = StringMap.empty in
    let x = StringMap.add "a" 1.0 x in
    let x = StringMap.add "b" 2.0 x in
    let x = StringMap.add "c" 3.0 x in
    let x = StringMap.add "d" 4.0 x in
    let now = 2.5 in
    let update_filemap _ _ = true in
    let modified, unmodified = StringMap.partition update_filemap x in
    print_endline "modified";
    StringMap.iter (fun k v -> print_endline (k ^ " " ^ (string_of_float v))) modified;
    print_endline "unmodified";
    StringMap.iter (fun k v -> print_endline (k ^ " " ^ (string_of_float v))) unmodified;
    let x = Unix.lstat "Makefile" in
    let y = x.st_mtime in
    y |> string_of_float |> print_endline



let () =
    let () = print_endline "ARGS:" in
    let () = Array.iter print_endline Sys.argv in
    let () = print_endline "END ARGS" in
    let patterns, command = get_args Sys.argv in
    let filemap = StringMap.empty in
    (* let modified, unmodified = walk_fs filemap in *)
    tester ()

