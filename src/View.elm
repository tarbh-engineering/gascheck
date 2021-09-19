module View exposing (view)

import Element exposing (Attribute, Color, Element, centerX, centerY, column, el, fill, height, padding, paragraph, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Helpers.View exposing (cappedWidth, style, when, whenJust)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as JD
import Types exposing (Model, Msg)


view : Model -> Html Msg
view model =
    [ text "Gascheck"
        |> el
            [ Font.bold
            , Font.size 40
            , centerX
            ]
    , [ Input.text
            [ onEnter Types.GasSubmit
            , spinner
                |> el [ Element.alignRight, Element.centerY, Element.paddingXY 5 0 ]
                |> when model.inProgress
                |> Element.inFront
            , cappedWidth 250
            , centerX
            , Html.Attributes.maxlength 10
                |> Element.htmlAttribute
            , Html.Attributes.disabled model.inProgress
                |> Element.htmlAttribute
            ]
            { onChange = Types.GasUpdate
            , placeholder =
                text "21000"
                    |> Input.placeholder []
                    |> Just
            , text = model.gas
            , label = Input.labelHidden ""
            }
      , Input.button [ padding 10, Border.width 1, hover ]
            { onPress = Just Types.GasSubmit
            , label = text "Submit"
            }
      ]
        |> row [ spacing 10, centerX ]
    , model.results
        |> whenJust
            (\pair ->
                [ [ show "Estimated Fee" pair.total
                  , [ text "This is an optimistic prediction that your transaction is accepted with the following values." ]
                        |> paragraph []
                  ]
                    |> column [ spacing 10 ]
                , pair.res.price
                    |> FormatNumber.format usLocale
                    |> (++) "$"
                    |> show "Ethereum price"
                , pair.res.baseFee
                    |> FormatNumber.format usLocale
                    |> show "Base Fee"
                , pair.res.priority
                    |> FormatNumber.format usLocale
                    |> show "Priority"
                ]
                    |> column [ spacing 20, width fill, fadeIn ]
            )
    ]
        |> column [ centerX, spacing 20, padding 30, cappedWidth 500 ]
        |> Element.layoutWith
            { options =
                [ Element.focusStyle
                    { borderColor = Nothing
                    , backgroundColor = Nothing
                    , shadow = Nothing
                    }
                ]
            }
            [ width fill
            , height fill
            , Background.color bg
            ]


show : String -> String -> Element msg
show a b =
    [ text a
        |> el [ Font.bold ]

    --, text "|"
    , text b
    ]
        |> row [ width fill, Element.spaceEvenly ]


onEnter : msg -> Attribute msg
onEnter msg =
    JD.field "key" JD.string
        |> JD.andThen
            (\key ->
                if key == "Enter" then
                    JD.succeed msg

                else
                    JD.fail ""
            )
        |> Html.Events.on "keydown"
        |> Element.htmlAttribute


bg : Color
bg =
    rgb255 246 246 246


rotate : Attribute msg
rotate =
    style "animation" "rotation 0.7s infinite linear"


spinner : Element msg
spinner =
    '✷'
        |> String.fromChar
        |> text
        |> el
            [ rotate
            , Font.size 25
            ]


fadeIn : Attribute msg
fadeIn =
    style "animation" "fadeIn 1s"


hover : Attribute msg
hover =
    Element.mouseOver [ fade ]


fade : Element.Attr a b
fade =
    Element.alpha 0.7
