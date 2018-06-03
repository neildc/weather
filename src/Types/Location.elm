module Types.Location
    exposing
        ( Location
        , all
        , imagePath
        , toCoordinatesString
        )

-- Disclaimer: The ordering of these are by no mean a reflection of my personal ranking of these cities


type Location
    = Brisbane
    | Sydney
    | Melbourne


all : List Location
all =
    [ Brisbane, Sydney, Melbourne ]


type alias Coordinates =
    ( Float, Float )


toCoordinates : Location -> Coordinates
toCoordinates location =
    case location of
        Brisbane ->
            ( -27.46, 153.02 )

        Sydney ->
            ( -33.86, 151.2 )

        Melbourne ->
            ( -37.81, 144.96 )


toCoordinatesString : Location -> String
toCoordinatesString location =
    let
        ( long, lat ) =
            location |> toCoordinates
    in
    toString long ++ "," ++ toString lat


imagePath : Location -> String
imagePath location =
    let
        filename =
            case location of
                Brisbane ->
                    "qld"

                Sydney ->
                    "nsw"

                Melbourne ->
                    "vic"
    in
    "%PUBLIC_URL%/" ++ filename ++ ".svg"
