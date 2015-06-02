exception Missing_parameters of string


let rec index_of ?(index:int=0) (aray:string array) (elem:string) =
    if Array.length aray = index then None
    else if elem = Array.get aray index then Some index
    else index_of aray elem ~index:(index+1)


(* Parses CLI arguments into a set of filename
 * patterns and a command to run. *)
let rec get_args (vargs:string array) =
    match index_of vargs "-c" with
        | None   -> raise (Missing_parameters "no split of '-c' found in CLI arguments")
        | Some i ->
            let patterns = Array.sub vargs 1 (i-1) in
            let command = Array.sub vargs (i+1) (Array.length vargs -(i+1)) in
            (patterns, command)


(*
 * let check_
 * *)


let () =
    let patterns, command = get_args Sys.argv in
    ()


