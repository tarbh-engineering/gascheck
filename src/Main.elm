module Main exposing (main)

import Browser
import Ticks
import Types exposing (Flags, Model, Msg)
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { gas = ""
      , results = Nothing
      , inProgress = False
      , ticks = Ticks.empty
      , small = flags.width < 768
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
