module ImgIX exposing
    ( ImgIX
    , fromUrl, fromString
    , size, sizes
    , rotation, rotations
    , adjust, adjustments
    , automatic, automatics
    , stylize, stylizations
    , toUrl, toHtml, toHtmlWithAttributes
    )

{-| Create and apply options to images hosted on [ImgIX](https://www.imgix.com/).


# ImgIX

@docs ImgIX


# Creation

@docs fromUrl, fromString


# Size

@docs size, sizes


# Rotation

@docs rotation, rotations


# Adjustment

@docs adjust, adjustments


# Automatic Optimization

@docs automatic, automatics


# Stylize

@docs stylize, stylizations


# Render

@docs toUrl, toHtml, toHtmlWithAttributes

-}

import Html as Html exposing (Attribute, img)
import Html.Attributes as HtmlAttr exposing (src)
import ImgIX.Adjustment exposing (Adjustment, toQueryParameters)
import ImgIX.Automatic exposing (Automatic, toQueryParameter)
import ImgIX.Rotation exposing (Rotation, toQueryParameters)
import ImgIX.Size exposing (Size, toQueryParameters)
import ImgIX.Stylize exposing (Stylize, toQueryParameters)
import Url as Url exposing (Url, fromString, toString)
import Url.Builder as UrlBuilder exposing (toQuery)


{-| The type of an ImgIX image
-}
type ImgIX
    = ImgIX Url ImgIXOptions


{-| Create a new ImgIX from an Url
-}
fromUrl : Url.Url -> ImgIX
fromUrl url =
    ImgIX (stripUrlQuery url) emptyImgIXOptions


{-| Create a new ImgIX from a string representing an Url
-}
fromString : String -> Maybe ImgIX
fromString =
    Maybe.map fromUrl << Url.fromString



-- Size


{-| Control the size of an ImgIX
Check the ImgIX.Size module for all the available options.
-}
size : Size -> ImgIX -> ImgIX
size x (ImgIX url imgIXOptions) =
    ImgIX url
        { imgIXOptions
            | size = x :: imgIXOptions.size
        }


{-| Apply a list of Sizes
-}
sizes : List Size -> ImgIX -> ImgIX
sizes =
    fold size



-- Rotation


{-| Adjust an ImgIX using Rotations
Check the ImgIX.Rotation module for all the rotations available.
-}
rotation : Rotation -> ImgIX -> ImgIX
rotation x (ImgIX url imgIXOptions) =
    ImgIX url
        { imgIXOptions
            | rotation = x :: imgIXOptions.rotation
        }


{-| Apply a list of Rotations
-}
rotations : List Rotation -> ImgIX -> ImgIX
rotations =
    fold rotation



-- Adjustment


{-| Adjust an ImgIX using Adjustments
Check the ImgIX.Adjustments module for all the adjustments available.
-}
adjust : Adjustment -> ImgIX -> ImgIX
adjust x (ImgIX url imgIXOptions) =
    ImgIX url
        { imgIXOptions
            | adjustment = x :: imgIXOptions.adjustment
        }


{-| Apply a list of Adjustments
-}
adjustments : List Adjustment -> ImgIX -> ImgIX
adjustments =
    fold adjust



-- Automatic


{-| Apply an automatic optimization
Check the ImgIX.Automatic module for all the automatic optimizations available.
-}
automatic : Automatic -> ImgIX -> ImgIX
automatic x (ImgIX url imgIXOptions) =
    ImgIX url
        { imgIXOptions
            | automatic = x :: imgIXOptions.automatic
        }


{-| Apply a list of automatic optimizations
-}
automatics : List Automatic -> ImgIX -> ImgIX
automatics =
    fold automatic



-- Stylize


{-| Adjust an ImgIX using Stylizations
Check the ImgIX.Stylize module for all the stylizations available.
-}
stylize : Stylize -> ImgIX -> ImgIX
stylize x (ImgIX url imgIXOptions) =
    ImgIX url
        { imgIXOptions
            | stylize = x :: imgIXOptions.stylize
        }


{-| Apply a list of Stylizations
-}
stylizations : List Stylize -> ImgIX -> ImgIX
stylizations =
    fold stylize



-- Render


{-| Create a valid ImgIX url from an ImgIX type
-}
toUrl : ImgIX -> Url.Url
toUrl (ImgIX url imgIXOptions) =
    let
        sizeQueryParameters =
            ImgIX.Size.toQueryParameters imgIXOptions.size

        rotationQueryParameters =
            ImgIX.Rotation.toQueryParameters imgIXOptions.rotation

        automaticQueryParameter =
            ImgIX.Automatic.toQueryParameter imgIXOptions.automatic

        adjustmentQueryParameters =
            ImgIX.Adjustment.toQueryParameters imgIXOptions.adjustment

        stylizeQueryParameters =
            ImgIX.Stylize.toQueryParameters imgIXOptions.stylize

        query =
            UrlBuilder.toQuery
                (sizeQueryParameters
                    ++ rotationQueryParameters
                    ++ adjustmentQueryParameters
                    ++ [ automaticQueryParameter ]
                    ++ stylizeQueryParameters
                )
                |> String.dropLeft 1
                |> Just
    in
    { url | query = query }


{-| Render ImgIx as a Html img node
-}
toHtml : ImgIX -> Html.Html msg
toHtml =
    toHtmlWithAttributes []


{-| Render ImgIx as a Html img node with a given list of [Html.Attributes](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes)
-}
toHtmlWithAttributes : List (Html.Attribute msg) -> ImgIX -> Html.Html msg
toHtmlWithAttributes listOfAttributes imgix =
    Html.img
        ((toUrl imgix
            |> Url.toString
            |> HtmlAttr.src
         )
            :: listOfAttributes
        )
        []



-- Types


type alias ImgIXOptions =
    { size : List Size
    , adjustment : List Adjustment
    , automatic : List Automatic
    , rotation : List Rotation
    , stylize : List Stylize
    }



-- Helpers


{-| Convenient function to create an empty record of ImgIXOptions
-}
emptyImgIXOptions : ImgIXOptions
emptyImgIXOptions =
    { size = []
    , adjustment = []
    , automatic = []
    , rotation = []
    , stylize = []
    }


{-| Remove all queries previous set on a given Url
-}
stripUrlQuery : Url.Url -> Url.Url
stripUrlQuery url =
    { url
        | query = Nothing
        , fragment = Nothing
    }


{-| Fold over an ImgIX
-}
fold : (a -> ImgIX -> ImgIX) -> List a -> ImgIX -> ImgIX
fold f list_a imgix =
    List.foldl f imgix list_a
