module Stable = struct
  open! Import_stable

  module Action = struct
    module V3 = struct
      type t =
        { from           : Feature_path.V1.t
        ; to_            : Feature_path.V1.t
        ; rev_zero       : Rev.V1.t
        }
      [@@deriving bin_io, fields, sexp]

      let to_model t = t
    end

    module V2 = struct
      type t =
        { from           : Feature_path.V1.t
        ; to_            : Feature_path.V1.t
        ; even_if_locked : bool
        ; rev_zero       : Rev.V1.t
        }
      [@@deriving bin_io]

      let to_model { from
                   ; to_
                   ; even_if_locked = _
                   ; rev_zero
                   } =
        V3.to_model
          { V3.
            from
          ; to_
          ; rev_zero
          }
      ;;
    end

    module V1 = struct
      type t =
        { from     : Feature_path.V1.t
        ; to_      : Feature_path.V1.t
        ; rev_zero : Rev.V1.t
        }
      [@@deriving bin_io]

      let to_model { from
                   ; to_
                   ; rev_zero
                   } =
        V3.to_model
          { V3.
            from
          ; to_
          ; rev_zero
          }
      ;;
    end

    module Model = V3
  end

  module Reaction = struct
    module V2 = struct
      type t =
        { from_feature_path      : Feature_path.V1.t
        ; from_base              : Rev.V1.t
        ; from_tip               : Rev.V1.t
        ; to_parent_feature_path : Feature_path.V1.t
        ; to_parent_tip          : Rev.V1.t
        ; renames                : Rename.V2.t list
        ; remote_repo_path       : Remote_repo_path.V1.t
        }
      [@@deriving bin_io, sexp]

      let of_model (t : t) = t
    end

    module V1 = struct
      type t =
        { from_feature_path      : Feature_path.V1.t
        ; from_base              : Rev.V1.t
        ; from_tip               : Rev.V1.t
        ; to_parent_feature_path : Feature_path.V1.t
        ; to_parent_tip          : Rev.V1.t
        ; renames                : Rename.V1.t list
        ; remote_repo_path       : Remote_repo_path.V1.t
        }
      [@@deriving bin_io]

      open! Core.Std
      open! Import

      let of_model m =
        let { V2.
              from_feature_path
            ; from_base
            ; from_tip
            ; to_parent_feature_path
            ; to_parent_tip
            ; renames
            ; remote_repo_path
            } = V2.of_model m in
        { from_feature_path
        ; from_base
        ; from_tip
        ; to_parent_feature_path
        ; to_parent_tip
        ; renames                = List.map renames ~f:Rename.Stable.V1.of_v2
        ; remote_repo_path
        }
      ;;
    end

    module Model = V2
  end

end

include Iron_versioned_rpc.Make
    (struct let name = "prepare-to-rename" end)
    (struct let version = 4 end)
    (Stable.Action.V3)
    (Stable.Reaction.V2)

include Register_old_rpc
    (struct let version = 3 end)
    (Stable.Action.V3)
    (Stable.Reaction.V1)

include Register_old_rpc
    (struct let version = 2 end)
    (Stable.Action.V2)
    (Stable.Reaction.V1)

include Register_old_rpc
    (struct let version = 1 end)
    (Stable.Action.V1)
    (Stable.Reaction.V1)

module Action   = Stable.Action.   Model
module Reaction = Stable.Reaction. Model
