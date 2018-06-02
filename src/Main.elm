module Main exposing (..)

import Api.Weather
import EveryDict exposing (EveryDict)
import Html exposing (Html, button, div, h1, img, text)
import Html.Attributes exposing (src)
import Html.Events exposing (..)
import Http
import Types.CurrentForecastResponse as CurrentForecastResponse exposing (CurrentForecastResponse)
import Types.Location as Location exposing (Location)


---- MODEL ----


type WeatherData a
    = NotFetched
    | Fetching
    | Fetched a
    | Error Http.Error


type alias Model =
    { currentForecastsDict : EveryDict Location (WeatherData CurrentForecastResponse)
    }


init : ( Model, Cmd Msg )
init =
    let
        allLocations =
            [ Location.Brisbane
            , Location.Sydney
            , Location.Melbourne
            ]

        emptyLocations =
            List.map (\l -> ( l, NotFetched )) allLocations

        model =
            { currentForecastsDict = EveryDict.fromList emptyLocations
            }
    in
    ( model
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = GetForecast Location
    | ForecastResponse Location (Result Http.Error CurrentForecastResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetForecast location ->
            let
                modelWithLocationFetching =
                    { model
                        | currentForecastsDict =
                            model.currentForecastsDict
                                |> EveryDict.insert location Fetching
                    }
            in
            ( modelWithLocationFetching
            , Api.Weather.getCurrentForecast (ForecastResponse location) location
            )

        ForecastResponse location result ->
            let
                insertIntoForecastsDict : WeatherData CurrentForecastResponse -> Model
                insertIntoForecastsDict data =
                    { model
                        | currentForecastsDict =
                            model.currentForecastsDict
                                |> EveryDict.insert location data
                    }

                updatedModel =
                    case result of
                        Result.Ok resp ->
                            Fetched resp |> insertIntoForecastsDict

                        Result.Err e ->
                            Error e |> insertIntoForecastsDict
            in
            ( updatedModel, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ text <| toString model.currentForecastsDict
        , button [ onClick <| GetForecast Location.Sydney ] [ text "Sydney" ]
        , button [ onClick <| GetForecast Location.Brisbane ] [ text "Brisbane" ]
        , button [ onClick <| GetForecast Location.Melbourne ] [ text "Melbourne" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
