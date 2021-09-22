module Update exposing (update)

import BigInt exposing (BigInt)
import Eth.Units
import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Http
import Json.Decode as JD exposing (Decoder)
import Maybe.Extra exposing (unwrap)
import Result.Extra exposing (unpack)
import Ticks
import Types exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick n ->
            ( { model | ticks = Ticks.flip n model.ticks }, Cmd.none )

        GasUpdate val ->
            ( { model | gas = val }, Cmd.none )

        GasSubmit ->
            (if String.isEmpty model.gas then
                Just 21000

             else
                String.toInt model.gas
            )
                |> unwrap
                    ( model, Cmd.none )
                    (\n ->
                        ( { model
                            | inProgress = True
                            , results = Nothing
                            , ticks = Ticks.empty
                          }
                        , Http.get
                            { url = "/ping"
                            , expect = Http.expectJson (DataCb n) decodeData
                            }
                        )
                    )

        DataCb gasUsed res ->
            res
                |> unpack
                    (\_ ->
                        ( { model | inProgress = False }
                        , Cmd.none
                        )
                    )
                    (\data ->
                        let
                            ethUsed =
                                Eth.Units.gwei
                                    (round
                                        (toFloat gasUsed
                                            * (data.baseFee + data.priority)
                                        )
                                    )
                        in
                        ( { model
                            | inProgress = False
                            , results =
                                BigInt.div ethUsed
                                    (weiPerDollar data.price)
                                    |> BigInt.toString
                                    |> String.toFloat
                                    |> Maybe.map
                                        (\f ->
                                            { res = data
                                            , gasUsed = gasUsed
                                            , ethUsed = ethUsed
                                            , total =
                                                (f / 100)
                                                    |> FormatNumber.format usLocale
                                                    |> (++) "$"
                                            }
                                        )
                          }
                        , Cmd.none
                        )
                    )


decodeData : Decoder Types.Res
decodeData =
    JD.map3 Types.Res
        (JD.field "price" JD.float)
        (JD.field "base_fee" JD.float)
        (JD.field "priority" JD.float)


weiPerDollar : Float -> BigInt
weiPerDollar f =
    (10 ^ 18)
        / (f * 100)
        |> round
        |> BigInt.fromInt
