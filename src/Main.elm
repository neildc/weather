module Main exposing (..)

import Api.Weather
import EveryDict exposing (EveryDict)
import Html exposing (Html, button, div, h1, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (..)
import Http
import Types.CurrentForecastResponse as CurrentForecastResponse exposing (CurrentForecastResponse)
import Types.Location as Location exposing (Location)


---- MODEL ----


type WeatherData a
    = Fetching
    | Fetched a
    | Error Http.Error


type alias Model =
    { currentForecastsDict : EveryDict Location (WeatherData CurrentForecastResponse)
    , selectedState : Maybe Location
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { currentForecastsDict = EveryDict.empty
            , selectedState = Nothing
            }
    in
    ( model
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = TabSelected Location
    | ForecastResponse Location (Result Http.Error CurrentForecastResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabSelected location ->
            let
                modelWithLocationFetching =
                    { model
                        | currentForecastsDict =
                            model.currentForecastsDict
                                |> EveryDict.insert location Fetching
                        , selectedState = Just location
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
    div [ class "app" ]
        [ viewTabs model.selectedState
        , viewMainPane model
        ]


viewTabs : Maybe Location -> Html Msg
viewTabs currentlySelectedLocation =
    let
        baseTabAttributes location =
            [ src <| Location.imagePath location
            , onClick <| TabSelected location
            ]

        tabAttributes location =
            case currentlySelectedLocation of
                Just selected ->
                    if location == selected then
                        baseTabAttributes location ++ [ class "selected" ]
                    else
                        baseTabAttributes location

                Nothing ->
                    baseTabAttributes location

        tab location =
            img (tabAttributes location) []
    in
    div [ class "tabs" ] <|
        List.map tab Location.all


viewMainPane : Model -> Html Msg
viewMainPane { selectedState, currentForecastsDict } =
    let
        mainPane =
            case selectedState of
                Nothing ->
                    text "Please select a state to begin."

                Just state ->
                    case EveryDict.get state currentForecastsDict of
                        Just data ->
                            viewWeatherDetails data

                        Nothing ->
                            -- This should never happen.
                            -- TODO: Possibly prevent this??
                            text "Invalid state was selected."
    in
    div [ class "main-pane" ] [ mainPane ]


viewWeatherDetails : WeatherData CurrentForecastResponse -> Html Msg
viewWeatherDetails weatherData =
    case weatherData of
        Fetching ->
            text "Loading..."

        Error err ->
            text <| toString err

        Fetched data ->
            div [ class "weather-details-success" ]
                [ text <| toString data.temp_c ++ "°C"
                , text <| data.wx_desc
                , img [ src <| "http://www.weatherunlocked.com/Images/icons/1/" ++ data.wx_icon ] []
                , text <| "Wind : " ++ toString data.windspd_kmh ++ "km/h"
                , text <| "Clouds: " ++ toString data.cloudtotal_pct ++ "%"
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
