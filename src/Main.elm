module Main exposing (..)

import Api.Weather
import EveryDict exposing (EveryDict)
import Html exposing (..)
import Html.Attributes exposing (class, classList, src)
import Html.Events exposing (..)
import Http
import Types.CurrentWeather as CurrentWeather exposing (CurrentWeather)
import Types.Location as Location exposing (Location)


---- MODEL ----


type WeatherData a
    = Fetching
    | Fetched a
    | Error Http.Error


type alias Model =
    { currentWeatherDict : EveryDict Location (WeatherData CurrentWeather)
    , selectedState : Maybe Location
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { currentWeatherDict = EveryDict.empty
            , selectedState = Nothing
            }
    in
    ( model
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = TabSelected Location
    | ForecastResponse Location (Result Http.Error CurrentWeather)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabSelected location ->
            let
                modelWithLocationFetching =
                    { model
                        | currentWeatherDict =
                            model.currentWeatherDict
                                |> EveryDict.insert location Fetching
                        , selectedState = Just location
                    }
            in
            ( modelWithLocationFetching
            , Api.Weather.getCurrentForecast (ForecastResponse location) location
            )

        ForecastResponse location result ->
            let
                insertIntoForecastsDict : WeatherData CurrentWeather -> Model
                insertIntoForecastsDict data =
                    { model
                        | currentWeatherDict =
                            model.currentWeatherDict
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
        tabAttributes location =
            let
                isSelected =
                    case currentlySelectedLocation of
                        Nothing ->
                            False

                        Just l ->
                            l == location
            in
            [ src <| Location.imagePath location
            , onClick <| TabSelected location
            , classList
                [ ( "tab-item", True )
                , ( "selected-" ++ toString location, isSelected )
                ]
            ]

        tab location =
            img (tabAttributes location) []
    in
    div [ class "tabs" ] <|
        List.map tab Location.all


viewMainPane : Model -> Html Msg
viewMainPane { selectedState, currentWeatherDict } =
    let
        viewNothingSelected =
            h1 [] [ text "Please select a state to retrieve the weather for its capital city." ]

        mainPane =
            case selectedState of
                Nothing ->
                    viewNothingSelected

                Just state ->
                    case EveryDict.get state currentWeatherDict of
                        Just data ->
                            div []
                                [ h1 [] [ text <| String.toUpper <| toString state ]
                                , br [] []
                                , viewWeatherDetails data
                                ]

                        Nothing ->
                            -- This should never happen, but just in case...
                            Debug.log "Invalid state was selected" <|
                                viewNothingSelected
    in
    div [ class "main-pane" ] [ mainPane ]


viewWeatherDetails : WeatherData CurrentWeather -> Html Msg
viewWeatherDetails weatherData =
    case weatherData of
        Fetching ->
            text "Loading..."

        Error err ->
            Debug.log (toString err) <|
                text "An error has occurred."

        Fetched data ->
            div [ class "weather-details-container" ]
                [ h2 [ class "temperature" ]
                    [ text <| toString data.temp_c ++ "°C"
                    ]
                , div [ class "icon" ] [ img [ src <| "http://www.weatherunlocked.com/Images/icons/1/" ++ data.wx_icon ] [] ]
                , h4 [ class "description" ] [ text <| data.wx_desc ]
                , div [ class "other" ] <|
                    [ text <| "Wind : " ++ toString data.windspd_kmh ++ "km/h"
                    , br [] []
                    , text <| "Clouds: " ++ toString data.cloudtotal_pct ++ "%"
                    ]
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
