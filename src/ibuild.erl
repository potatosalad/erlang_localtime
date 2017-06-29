%% @author  Dmitry S. Melnikov (dmitryme@gmail.com)
%% @copyright 2010 Dmitry S. Melnikov

-module(ibuild).

-export([build_index/0, main/1]).

-include("tz_database.hrl").

build_tzlist(TzName, Name, Map) ->
    case maps:get(Name, Map, undefined) of
        undefined ->
            Map#{Name => [TzName]};
        TzNames ->
            Map#{Name => TzNames ++ [TzName]}
    end.

build_index() ->
    F = fun(TzName, {{Name,_},{DName,_},_,_,_,_,_,_}, Acc) ->
                NewMap = build_tzlist(TzName, Name, Acc),
                build_tzlist(TzName, DName, NewMap);
           (TzName, {{Name,_},undef,_,_,_,_,_,_}, Acc) ->
                build_tzlist(TzName, Name, Acc)
        end,
    I = maps:fold(F, #{}, ?tz_database),
    {ok, File} = file:open("tz_index.hrl", [write]),
    io:fwrite(File, "-define(tz_index,~n    ~100p).~n", [I]).

%% So this can be run from escript:
main(_Args) ->
    build_index().
