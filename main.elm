module Main exposing (..)

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Http exposing (Error, request)

import Json.Decode exposing (int, string, float, Decoder, decodeString, field, list)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Platform exposing (Task)



type alias Tweet =
    { username : String
    , text : String
    }


type alias Model =
    { q : String
    , tweets : List Tweet
    }


tweetDecoder : Decoder Tweet
tweetDecoder =
    decode Tweet
        |> required "user" (field "name" string)
        |> required "text" string


tweetsDecoder : Decoder (List Tweet)
tweetsDecoder =
    (field "statuses" (list tweetDecoder))


init : ( Model, Cmd Msg )
init =
    ( { q = "cool"
    , tweets = [ Tweet "Michiel" "init tweet" ]
    }
    , Cmd.none
    )


view : Model -> Html Msg
view state =
    div []
        [ h2 [] [ text state.q ]
        , div [] [ input [ Attr.value state.q, Events.onInput SetHashtag ] [] ]
        , div [] [ button [ Events.onClick LoadTweets ] [ text "Load tweets" ] ]
        , tweets state.tweets
        ]


tweets : List Tweet -> Html Msg
tweets tweets =
    div []
        [ ul [] (List.map (\tweet -> li [] [ text ("@" ++ tweet.username ++ ": " ++ tweet.text) ]) tweets)
        ]


type Msg
    = SetHashtag String
    | LoadTweets
    | NewTweets (Result Http.Error (List Tweet))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg state =
    case msg of

        SetHashtag q ->
            ( { state | q = q }, Cmd.none )

        LoadTweets ->
            ( state, get state.q )

        NewTweets resultTweets ->
            case resultTweets of
                Ok tweets ->
                    ( { state | tweets = tweets }, Cmd.none )
                Err _ ->
                    ( state, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions state =
    Sub.none

get : String -> Cmd Msg
get q =
    let
        url =
            "http://localhost:3000/" ++ q
    in
        Http.send NewTweets (Http.get url tweetsDecoder)

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
