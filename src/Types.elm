module Types exposing (Flags, Model, Msg(..), Res)

import Http


type alias Model =
    { gas : String
    , results : Maybe Pair
    , inProgress : Bool
    }


type alias Flags =
    {}


type Msg
    = GasUpdate String
    | GasSubmit
    | DataCb Int (Result Http.Error Res)


type alias Res =
    { price : Float
    , baseFee : Float
    , priority : Float
    }


type alias Pair =
    { res : Res
    , gasUsed : Int
    , total : String
    }
