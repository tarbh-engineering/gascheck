module Types exposing (Flags, Model, Msg(..), Res)

import BigInt exposing (BigInt)
import Http
import Ticks exposing (Ticks)


type alias Model =
    { gas : String
    , results : Maybe Pair
    , inProgress : Bool
    , ticks : Ticks
    , small : Bool
    }


type alias Flags =
    { width : Int
    }


type Msg
    = GasUpdate String
    | GasSubmit
    | DataCb Int (Result Http.Error Res)
    | Tick Int


type alias Res =
    { price : Float
    , baseFee : Float
    , priority : Float
    }


type alias Pair =
    { res : Res
    , gasUsed : Int
    , total : String
    , ethUsed : BigInt
    }
