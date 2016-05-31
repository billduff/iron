module Stable = struct

  open Import_stable

  module Action = struct
    module V1 = Unit

    module Model = V1
  end

  module Reaction = struct
    let map ~f =
      let open! Core.Std in
      let open! Import in
      Map.map ~f:(List.map ~f:(fun occurrence ->
        match f occurrence with
        | Ok occurrence -> occurrence
        | Error err ->
          raise_s
            [%sexp
              "Unsupported occurrence type with an old fe client.  \
               Consider upgrading your binary"
            , (err : Error.t)
            ]))
    ;;

    module V3 = struct
      type t = User_name_occurrence.V3.t list User_name.V1.Map.t
      [@@deriving bin_io, sexp]
      let of_model m = m
    end

    module V2 = struct
      type t = User_name_occurrence.V2.t list User_name.V1.Map.t
      [@@deriving bin_io, sexp]

      let of_model = map ~f:User_name_occurrence.V2.of_model
    end

    module V1 = struct
      type t = User_name_occurrence.V1.t list User_name.V1.Map.t
      [@@deriving bin_io]

      let of_model = map ~f:User_name_occurrence.V1.of_model
    end

    module Model = V3
  end
end

include Iron_versioned_rpc.Make
    (struct let name = "get-invalid-users" end)
    (struct let version = 3 end)
    (Stable.Action.V1)
    (Stable.Reaction.V3)

include Register_old_rpc
    (struct let version = 2 end)
    (Stable.Action.V1)
    (Stable.Reaction.V2)

include Register_old_rpc
    (struct let version = 1 end)
    (Stable.Action.V1)
    (Stable.Reaction.V1)

module Action       = Stable.Action.  Model
module Reaction     = Stable.Reaction.Model