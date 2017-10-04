open! Core
open! Import

module Action : sig
  type t =
    { feature_path                : Export.Iron.Feature_path.t
    ; base                        : Export.Iron.Raw_rev.t option
    ; tip                         : Export.Iron.Raw_rev.t option
    ; description                 : string option
    ; owners                      : Export.Iron.User_name.t list
    ; is_permanent                : bool
    ; remote_repo_path            : Export.Iron.Remote_repo_path.t option
    ; no_bookmark                 : bool
    ; add_whole_feature_reviewers : Export.Iron.User_name.Set.t option
    ; allow_non_cr_clean_base     : bool
    ; properties                  : Export.Iron.Properties.t option
    }
  [@@deriving sexp_of]
end

module Reaction : Unit

include Iron_command_rpc.S
  with type action   = Action.t
  with type reaction = Reaction.t
