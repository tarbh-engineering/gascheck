module Ticks exposing (Ticks, empty, flip, get, set, tick)

import Dict exposing (Dict)


type Ticks
    = Ticks (Dict Int Bool)


empty : Ticks
empty =
    Ticks Dict.empty


tick : Int -> Ticks -> Ticks
tick n =
    set n True


get : Int -> Ticks -> Bool
get n (Ticks xs) =
    Dict.get n xs
        |> Maybe.withDefault False


set : Int -> Bool -> Ticks -> Ticks
set n b (Ticks xs) =
    Dict.insert n b xs
        |> Ticks


flip : Int -> Ticks -> Ticks
flip n xs =
    set n (not (get n xs)) xs
