module Types.CurrentWeather exposing (..)

import Json.Decode exposing (Decoder, float, int, string)
import Json.Decode.Pipeline exposing (decode, required)


-- https://developer.weatherunlocked.com/documentation/localweather/resources#response-fields
--
--     Field	Type	Format	Description -- lat	decimal		weather station latitude
--
--     lon	decimal		weather station longitude
--     alt_m	decimal	meters	weather station altitude
--     alt_f	decimal	feet	weather station altitude
--     wx_desc	string	text	weather description
--     wx_code	integer	integer	weather code
--     wx_icon	string	.gif	weather icon file name
--     temp_c	1 decimal	Celcius	temperature
--     temp_f	1 decimal	Fahrenheit	temperature
--     feelslike_c	1 decimal	Celcius	feel like temperature
--     feelslike_f	1 decimal	fahrenheit	feel like temperature
--     windspd_mph	integer	miles per hour	maximum mean wind speed
--     windspd_kmh	integer	kilometers per hour	maximum mean wind speed
--     windspd_kts	integer	knots	maximum mean wind speed
--     windspd_ms	1 decimal	metres per second	maximum mean wind speed
--     winddir_deg	integer	degrees (0-360)	direction wind is coming from
--     winddir_compass	string	16 Point	direction wind is coming from
--     cloudtotal_pct	integer	percent	amount of total cloud
--     humid_pct	integer	percent	humidity level
--     dewpoint_c	1 decimal	Celcius	dewpoint
--     dewpoint_f	1 decimal	Fahrenheit	dewpoint
--     vis_km	1 decimal	kilometers	visibility
--     vis_mi	1 decimal	miles	visibility
--     slp_mb	integer	millibars	sea level pressure
--     slp_in	2 decimal	inches	sea level pressure


type alias CurrentWeather =
    { temp_c : Float
    , feelslike_c : Float
    , wx_desc : String
    , wx_icon : String
    , windspd_kmh : Int
    , cloudtotal_pct : Int
    }


decoder : Decoder CurrentWeather
decoder =
    decode CurrentWeather
        |> required "temp_c" float
        |> required "feelslike_c" float
        |> required "wx_desc" string
        |> required "wx_icon" string
        |> required "windspd_kmh" int
        |> required "cloudtotal_pct" int
