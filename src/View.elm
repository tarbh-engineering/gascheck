module View exposing (view)

import Element exposing (Attribute, Color, Element, centerX, centerY, column, el, fill, height, padding, paddingXY, paragraph, px, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Eth.Units
import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Helpers.View exposing (cappedWidth, style, when, whenAttr, whenJust)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Img
import Json.Decode as JD
import Ticks
import Types exposing (Model, Msg)


view : Model -> Html Msg
view model =
    [ [ Element.image
            [ height <|
                px
                    (if model.small then
                        70

                     else
                        100
                    )
            , style "animation" "bob 4s infinite ease"
            , Html.Attributes.class "shake"
                |> Element.htmlAttribute
            , Element.alignTop
            , paddingXY 20 0
            ]
            { src = Img.astro, description = "" }
      , [ text "Gascheck"
            |> el
                [ Font.color white
                , Font.size
                    (if model.small then
                        55

                     else
                        65
                    )
                , fjalla
                , centerX
                ]
        , [ text "Smart contract cost estimation" ]
            |> paragraph [ Font.center ]
            |> box
        ]
            |> column [ spacing 10, centerX ]
            |> el [ width fill, spacing 20 ]
      ]
        |> row [ width fill ]
    , [ [ [ Input.button
                [ hover ]
                { onPress = Just <| Types.Tick 0
                , label =
                    [ el [ Font.bold ] <| text "Gas Limit"
                    , String.fromChar '�'
                        |> text
                        |> el [ Font.size 25, padding 5 ]
                    ]
                        |> row [ spacing 10 ]
                }
          , [ [ text "This is the amount of Gwei you expect the transaction execution to require." ]
                |> paragraph []
            , Element.newTabLink
                [ hover
                , Font.underline
                ]
                { url = "https://academy.binance.com/en/glossary/gas-limit"
                , label = text "Learn more"
                }
            ]
                |> column [ width fill, padding 10, fadeIn, Background.color white, Font.color black, spacing 10, Font.size 17 ]
                |> when (Ticks.get 0 model.ticks)
          ]
            |> column [ spacing 5 ]
        , [ Input.text
                [ onEnter Types.GasSubmit
                , spinner
                    |> el [ Element.alignRight, Element.centerY, paddingXY 5 0 ]
                    |> when model.inProgress
                    |> Element.inFront
                , width fill
                , Font.color black
                , Border.rounded 0
                , Border.width 0
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
          , Input.button
                [ padding 10
                , hover
                    |> whenAttr (not model.inProgress)
                , height fill
                , Font.color black
                , Background.color white
                , style "cursor" "wait"
                    |> whenAttr model.inProgress
                ]
                { onPress = Just Types.GasSubmit
                , label = text "Submit"
                }
          ]
            |> row [ spacing 1, width fill ]
        ]
            |> column [ spacing 10, width fill ]
      , model.results
            |> whenJust
                (\pair ->
                    [ [ Input.button
                            [ hover ]
                            { onPress = Just <| Types.Tick 1
                            , label =
                                [ el [ Font.bold ] <| text "Estimated Cost"
                                , String.fromChar '�'
                                    |> text
                                    |> el [ Font.size 25, padding 5 ]
                                ]
                                    |> row [ spacing 10 ]
                            }
                      , [ [ text "(Base Fee + Priority Fee) * Gas Limit" ]
                            |> paragraph []
                        , Element.newTabLink
                            [ hover
                            , Font.underline
                            ]
                            { url = "https://www.blocknative.com/blog/eip-1559-fees"
                            , label = text "Learn more"
                            }
                        ]
                            |> column [ width fill, padding 10, fadeIn, Background.color white, Font.color black, spacing 10, Font.size 17 ]
                            |> when (Ticks.get 1 model.ticks)
                      , text (Eth.Units.fromWei Eth.Units.Ether pair.ethUsed ++ " ETH")
                            |> el [ Element.alignRight ]
                      , pair.total
                            |> text
                            |> el [ Font.italic, Element.alignRight, Font.size 17 ]
                      ]
                        |> column [ spacing 10, width fill ]
                    , el
                        [ width fill
                        , height <| px 1
                        , Background.color white
                        ]
                        Element.none
                    , pair.res.baseFee
                        |> FormatNumber.format usLocale
                        |> (\v -> v ++ " GWEI")
                        |> show "Base Fee"
                    , pair.res.priority
                        |> FormatNumber.format usLocale
                        |> (\v -> v ++ " GWEI")
                        |> show "Priority Fee"
                    , pair.res.price
                        |> FormatNumber.format usLocale
                        |> (++) "$"
                        |> show "ETH-USD"
                    ]
                        |> column [ spacing 20, width fill, fadeIn ]
                )
      ]
        |> column [ spacing 30, width fill ]
        |> box
    , Element.newTabLink
        [ centerX
        , Element.alignBottom
        , Element.mouseOver [ Border.glow white 2 ]
        , style "cursor" "crosshair"
        ]
        { url = "https://terraloot.dev/"
        , label =
            [ text "Sponsored by"
                |> el [ centerX ]
            , text "TERRALOOT"
                |> el
                    [ Font.bold
                    , centerX
                    , Font.family [ Font.typeface "Mars" ]
                    ]
            ]
                |> (if model.small then
                        row [ spacing 10, Font.size 17 ]

                    else
                        column [ spacing 20, Font.size 20 ]
                   )
                |> box
        }
    , [ text "This website is "
      , Element.newTabLink [ hover, Font.underline ]
            { url = "https://github.com/tarbh-engineering/gascheck"
            , label = text "open-source"
            }
      , text "."
      ]
        |> paragraph
            [ Font.color white
            , Font.size 16
            , Font.center
            , centerX
            ]
    ]
        |> column
            [ spacing 30
            , width fill
            , height fill
            , paddingXY 0
                (if model.small then
                    20

                 else
                    50
                )
            ]
        |> el
            [ centerX
            , cappedWidth 420
            , height fill
            ]
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
            , paddingXY 20 0
                |> whenAttr model.small
            , height fill
            , Element.scrollbarY
            , style "min-height" "auto"
            , style "scrollbar-width" "none"
            , Html.Attributes.class "scroll"
                |> Element.htmlAttribute
            , Background.image Img.bg
            , Font.family
                [ Font.typeface "Open Sans"
                ]
            ]


show : String -> String -> Element msg
show a b =
    [ text a
        |> el [ Font.bold ]
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


rotate : Attribute msg
rotate =
    style "animation" "rotation 0.7s infinite linear"


spinner : Element msg
spinner =
    Element.image
        [ height <| px 25
        , rotate
        ]
        { src = Img.sun, description = "" }


box : Element msg -> Element msg
box =
    el [ padding 20, Background.color blu, Font.color white, width fill ]


fadeIn : Attribute msg
fadeIn =
    style "animation" "fadeIn 1s"


hover : Attribute msg
hover =
    Element.mouseOver [ fade ]


fjalla : Attribute msg
fjalla =
    Font.family [ Font.typeface "Fjalla" ]


fade : Element.Attr a b
fade =
    Element.alpha 0.7


white : Color
white =
    rgb255 255 255 255


black : Color
black =
    rgb255 0 0 0


blu : Color
blu =
    rgb255 5 3 23
