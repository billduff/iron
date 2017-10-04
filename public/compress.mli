open! Core
open! Import

module Action : sig
  type t =
    { feature_path   : Export.Iron.Feature_path.t
    ; for_           : Export.Iron.User_name.t
    }
  [@@deriving fields, sexp_of]
end

module Reaction : Unit

include Iron_command_rpc.S
  with type action   = Action.t
  with type reaction = Reaction.t
