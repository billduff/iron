module Stable = struct

  open Import_stable

  (* [for_] is for testing mainly. Catch_up on behalf of someone else will be rejected
     later on during the [catch_up_diffs] query *)
  module Action = struct
    module V1 = struct
      type t =
        { feature_path : Feature_path.V1.t
        ; for_         : User_name.V1.t
        }
      [@@deriving bin_io, fields, sexp]

      let to_model t = t
    end
    module Model = V1
  end

  module Catch_up_session = struct
    module V4 = struct
      type t =
        { catch_up_session_id              : Session_id.V1.t
        ; catch_up_session_tip             : Rev.V1.t
        ; creation_time                    : Time.V1_round_trippable.t
        ; reviewer_in_session              : Reviewer.V2.t
        ; diff4s_to_catch_up               : Diff4_to_catch_up.V3.t list
        ; line_count_remaining_to_catch_up : Line_count.Catch_up.V1.t
        ; remote_rev_zero                  : Rev.V1.t
        ; remote_repo_path                 : Remote_repo_path.V1.t
        ; feature_path                     : Feature_path.V1.t
        ; feature_id                       : Feature_id.V1.t
        ; whole_feature_reviewers          : User_name.V1.Set.t
        ; owners                           : User_name.V1.t list
        ; base                             : Rev.V1.t
        ; tip                              : Rev.V1.t
        ; description                      : string
        ; is_permanent                     : bool
        ; is_archived                      : bool
        ; seconder                         : User_name.V1.t option
        }
      [@@deriving bin_io, sexp]
    end

    module V3 = struct
      type t =
        { catch_up_session_id             : Session_id.V1.t
        ; catch_up_session_tip            : Rev.V1.t
        ; creation_time                   : Time.V1_round_trippable.t
        ; reviewer_in_session             : Reviewer.V2.t
        ; diff4s_to_catch_up              : Diff4_to_catch_up.V3.t list
        ; num_lines_remaining_to_catch_up : int
        ; remote_rev_zero                 : Rev.V1.t
        ; remote_repo_path                : Remote_repo_path.V1.t
        ; feature_path                    : Feature_path.V1.t
        ; feature_id                      : Feature_id.V1.t
        ; whole_feature_reviewers         : User_name.V1.Set.t
        ; owners                          : User_name.V1.t list
        ; base                            : Rev.V1.t
        ; tip                             : Rev.V1.t
        ; description                     : string
        ; is_permanent                    : bool
        ; is_archived                     : bool
        ; seconder                        : User_name.V1.t option
        }
      [@@deriving bin_io]

      open! Core.Std
      open! Import

      let of_v4
            { V4.
              catch_up_session_id
            ; catch_up_session_tip
            ; creation_time
            ; reviewer_in_session
            ; diff4s_to_catch_up
            ; line_count_remaining_to_catch_up
            ; remote_rev_zero
            ; remote_repo_path
            ; feature_path
            ; feature_id
            ; whole_feature_reviewers
            ; owners
            ; base
            ; tip
            ; description
            ; is_permanent
            ; is_archived
            ; seconder
            } =
        { catch_up_session_id
        ; catch_up_session_tip
        ; creation_time
        ; reviewer_in_session
        ; diff4s_to_catch_up
        ; num_lines_remaining_to_catch_up
          = Line_count.Catch_up.total line_count_remaining_to_catch_up
        ; remote_rev_zero
        ; remote_repo_path
        ; feature_path
        ; feature_id
        ; whole_feature_reviewers
        ; owners
        ; base
        ; tip
        ; description
        ; is_permanent
        ; is_archived
        ; seconder
        }
      ;;
    end

    module V2 = struct
      type t =
        { catch_up_session_id             : Session_id.V1.t
        ; catch_up_session_tip            : Rev.V1.t
        ; creation_time                   : Time.V1_round_trippable.t
        ; diff4s_to_catch_up              : Diff4_to_catch_up.V2.t list
        ; num_lines_remaining_to_catch_up : int
        ; remote_rev_zero                 : Rev.V1.t
        ; remote_repo_path                : Remote_repo_path.V1.t
        ; feature_path                    : Feature_path.V1.t
        ; feature_id                      : Feature_id.V1.t
        ; whole_feature_reviewers         : User_name.V1.Set.t
        ; owners                          : User_name.V1.t list
        ; base                            : Rev.V1.t
        ; tip                             : Rev.V1.t
        ; description                     : string
        ; is_permanent                    : bool
        ; is_archived                     : bool
        ; seconder                        : User_name.V1.t option
        }
      [@@deriving bin_io]

      open! Core.Std
      open! Import

      let of_v3
            { V3.
              catch_up_session_id
            ; catch_up_session_tip
            ; creation_time
            ; diff4s_to_catch_up
            ; num_lines_remaining_to_catch_up
            ; remote_rev_zero
            ; remote_repo_path
            ; feature_path
            ; feature_id
            ; whole_feature_reviewers
            ; owners
            ; base
            ; tip
            ; description
            ; is_permanent
            ; is_archived
            ; seconder
            ; _
            } =
        { catch_up_session_id
        ; catch_up_session_tip
        ; creation_time
        ; diff4s_to_catch_up
          = List.map diff4s_to_catch_up ~f:Diff4_to_catch_up.Stable.V2.of_v3
        ; num_lines_remaining_to_catch_up
        ; remote_rev_zero
        ; remote_repo_path
        ; feature_path
        ; feature_id
        ; whole_feature_reviewers
        ; owners
        ; base
        ; tip
        ; description
        ; is_permanent
        ; is_archived
        ; seconder
        }
      ;;
    end

    module Model = V4
  end

  module Reaction = struct
    module V4 = struct
      type t =
        [ `Up_to_date
        | `Catch_up_session of Catch_up_session.V4.t
        ]
      [@@deriving bin_io, sexp]

      let of_model m = m
    end

    module V3 = struct
      type t =
        { status : [ `Up_to_date
                   | `Catch_up_session of Catch_up_session.V3.t
                   ]
        }
      [@@deriving bin_io]

      let of_model m =
        { status
          = match V4.of_model m with
            | `Up_to_date as t -> t
            | `Catch_up_session v4 -> `Catch_up_session (Catch_up_session.V3.of_v4 v4)
        }
      ;;
    end

    module V2 = struct
      type t =
        { status : [ `Up_to_date
                   | `Catch_up_session of Catch_up_session.V2.t
                   ]
        }
      [@@deriving bin_io]

      let of_model m =
        let { V3. status } = V3.of_model m in
        { status
          = match status with
            | `Up_to_date as t -> t
            | `Catch_up_session v3 -> `Catch_up_session (Catch_up_session.V2.of_v3 v3)
        }
      ;;
    end

    module Model = V4
  end
end

include Iron_versioned_rpc.Make
    (struct let name = "get-catch-up-session" end)
    (struct let version = 4 end)
    (Stable.Action.V1)
    (Stable.Reaction.V4)

include Register_old_rpc
    (struct let version = 3 end)
    (Stable.Action.V1)
    (Stable.Reaction.V3)

include Register_old_rpc
    (struct let version = 2 end)
    (Stable.Action.V1)
    (Stable.Reaction.V2)

module Action           = Stable.Action.           Model
module Reaction         = Stable.Reaction.         Model
module Catch_up_session = Stable.Catch_up_session. Model