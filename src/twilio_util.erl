-module(twilio_util).

-export([escape_uri/1]).

escape_uri([C | Cs]) when C >= $a, C =< $z ->
    [C | escape_uri(Cs)];
escape_uri([C | Cs]) when C >= $A, C =< $Z ->
    [C | escape_uri(Cs)];
escape_uri([C | Cs]) when C >= $0, C =< $9 ->
    [C | escape_uri(Cs)];
escape_uri([C = $. | Cs]) ->
    [C | escape_uri(Cs)];
escape_uri([C = $- | Cs]) ->
    [C | escape_uri(Cs)];
escape_uri([C = $_ | Cs]) ->
    [C | escape_uri(Cs)];
escape_uri([C | Cs]) when C > 16#7f ->
    %% This assumes that characters are at most 16 bits wide.
    escape_byte(((C band 16#c0) bsr 6) + 16#c0)
    ++ escape_byte(C band 16#3f + 16#80)
    ++ escape_uri(Cs);
escape_uri([C | Cs]) -> escape_byte(C) ++ escape_uri(Cs);
escape_uri([]) -> [].
 
escape_byte(C) ->
    H = hex_octet(C),
    % io:fwrite("~p - ~p~n", [C, H]),
    normalize(H).
 
%% Append 0 if length == 1
normalize(H) when length(H) == 1 -> "%0" ++ H;
normalize(H) -> "%" ++ H.