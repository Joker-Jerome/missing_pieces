Js.log {js|😁 嘻嘻 😁|js}
open Tea
open Tea.Html


type element
type dom
external document : dom = "" [@@bs.val]
external getElementById : string -> element option = ""
[@@bs.send.pipe:dom] [@@bs.return null_to_opt]
external getValue : element -> string = "value" [@@bs.get]

type clipboard
external createClipboard : string -> unit -> clipboard = "Clipboard" [@@bs.new]


type model = { html : string ; ocaml : string; csrfToken : string option}
type msg = | NoOp | InputHtml of string | InputOcaml of string | Convert | ConvertDone of string
let decodeConvert output = let open! Json.Decoder in
  let decoder = field "result" string in Json.Decoder.decodeString decoder output
let sectionInput model =
  let height = styles [("height", "300px")] in
  section [class' "section"] [ div [class' "container"] [
      div [class' "heading"] [h1 [class' "title"] [text "Missing Pieces"]
                             ; h2 [class' "subtitle"] [text "For the "
                                                      ; strong [] [text " Missing Pieces "]
                                                      ; text "we cherish the most"]]
    ; div [class' "field"] [div [class' "card"] [div [class' "card-image"] [Vdom.fullnode "" "figure" "" "" [class' "image is-4by3"] [img [src "http://bulma.io/images/placeholders/1280x960.png"; Vdom.prop "alt" "Image"] []]]
                                                ; div [class' "card-content"] [div [class' "media"] [div [class' "media-left"] [Vdom.fullnode "" "figure" "" "" [class' "image is-48x48"] [img [src "http://bulma.io/images/placeholders/96x96.png"; Vdom.prop "alt" "Image"] []]]
                                                                                                    ; div [class' "media-content"] [p [class' "title is-4"] [text "Jackal"]
                                                                                                                                   ; p [class' "subtitle is-6"] [text "@jackal"]]]
                                                                              ; div [class' "content"] [text "Elixir is a dynamic, functional language designed for building scalable and maintainable applications. Elixir leverages the Erlang VM, known for running low-latency, distributed and fault-tolerant systems, while also being successfully used in web development and the embedded software domain."
                                                                                                       ; a [] [text "@Jerome"]
                                                                                                       ; text "."
                                                                                                       ; a [] [text "#test"]
                                                                                                       ; br []
                                                                                                       ; Vdom.fullnode "" "small" "" "" [] [text "11:09 PM - 1 Jan 2016"]]]]
                           ]
    ; div [class' "field is-grouped"] [
        p [class' "control"] [a [class' "button is-primary is-outlined"; onClick Convert] [text "Previous"]]
      ; p [class' "control"] [a [class' "button is-primary is-outlined"; Vdom.prop "data-clipboard-target" "textarea#output"] [text "Next"]]
      ]
    ]
    ]
let view model = sectionInput model
let init () = { html = ""; ocaml = ""; csrfToken = None}, Cmd.none
let update model = function | NoOp -> model, Cmd.none
                            | InputHtml html -> {model with html = html}, Cmd.none
                            | InputOcaml ocaml -> {model with ocaml = ocaml}, Cmd.none
                            | Convert -> let cmd = let open! Http in
                                let elem = document |> getElementById "csrf_token" in match elem with | None -> Cmd.none | Some ui -> let csrfToken = getValue ui in
                                let stringBody = let encoded = let open! Json.Encoder in object_ ( List.concat [ [ ("html", string model.html) ] ] ) in Json.Encoder.encode 0 encoded in
                                Http.request { method' = "POST"; headers = [Http.Header ("Content-Type", "application/json"); Http.Header ("x-csrf-token", csrfToken)]; url = "/convert/html/ocaml";
                                               body = Web_xmlhttprequest.StringBody stringBody; expect = Http.expectString; timeout = None; withCredentials = false}
                                |> Http.send ( function | Result.Error _e -> NoOp | Result.Ok output -> ConvertDone output )
                              in model, cmd
                            | ConvertDone output ->
                              match decodeConvert output with | Tea.Result.Ok decoded  -> {model with ocaml = decoded}, Cmd.none | Tea.Result.Error _e -> model, Cmd.none

let subscriptions _model = Sub.none
let main =
  let open App in standardProgram { init; update; view; subscriptions; }