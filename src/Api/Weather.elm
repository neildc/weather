module Api.Weather exposing (..)

-- https://developer.weatherunlocked.com/documentation/localweather

import Types.Location as Location exposing (Location)


type LocalWeatherType
    = Current
    | Forecast


baseUrl : Location -> LocalWeatherType -> String
baseUrl location localWeatherType =
    let
        app_id =
            "930fc96a"

        api_key =
            "bd8f96bc469b5f3a186a7b87da0f8ddd"
    in
    String.concat
        [ "http://api.weatherunlocked.com/api/"
        , (localWeatherType |> toString |> String.toLower) ++ "/"
        , Location.toCoordinatesString location
        , "?app_id=" ++ app_id
        , "&app_key=" ++ api_key
        ]
