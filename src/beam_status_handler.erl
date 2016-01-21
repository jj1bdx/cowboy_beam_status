%%% License document: MIT license
%%% 
%%% Copyright (c) 2016 Kenji Rikitake.
%%% 
%%% Permission is hereby granted, free of charge, to any person obtaining a
%%% copy of this software and associated documentation files (the
%%% "Software"), to deal in the Software without restriction, including
%%% without limitation the rights to use, copy, modify, merge, publish,
%%% distribute, sublicense, and/or sell copies of the Software, and to
%%% permit persons to whom the Software is furnished to do so, subject to
%%% the following conditions:
%%% 
%%% The above copyright notice and this permission notice shall be included
%%% in all copies or substantial portions of the Software.
%%% 
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
%%% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
%%% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%%% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
%%% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
%%% OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
%%% WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-module(beam_status_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-record(state, {}).

init(_, Req, _Opts) ->
	{ok, Req, #state{}}.

f(F, X) -> io_lib:format(F, X).

static1() ->
    << "<!DOCTYPE html>" "<html>" "<head>"
    "<meta charset=\"utf-8\">"
    "<title>Cowboy server status</title>"
    "<style> .num { text-align: right; } </style>"
    "</head>" "<body>" "<h1>Cowboy server status</h1>"
    >>.

static2() ->
    <<"<h2>Process status</h2>">>.

static3() ->
    <<"</body>" "</html>" >>.

pinfo(P, Item) ->
        element(2, process_info(P, Item)).

pinfo_table() ->
    PL = processes(),
    [
        f("<p>Number of processes: ~.10B</p>", [length(PL)]),
        "<table border=\"1\">",
        "<thead><tr><td>Pid<td>name<td>memory<td>reductions</tr></thead>",
        "<tbody>",
        [["<tr>",
          f("<td>~w", [P]),
          "<td>",
          case process_info(P, registered_name) of
              {registered_name, Name} -> f("~s", [Name]);
              [] -> ""
          end,
          "<td class=\"num\">",
          f("~.10B", [pinfo(P, memory)]),
          "<td class=\"num\">",
          f("~.10B", [pinfo(P, reductions)])]
          || P <- PL ],
        "</table>"
    ].

handle(Req, State=#state{}) ->
    {{Addr, Port}, Req2} = cowboy_req:peer(Req),

	{ok, Req3} = cowboy_req:reply(200, [
            {<<"content-type">>, <<"text/html">>},
            {<<"cache-control">>, <<"private, max-age=0, no-cache">>}
        ],
        [static1(),
         io_lib:format("<p>You are from IP ~s Port ~.10B</p>",
                     [string:to_lower(inet:ntoa(Addr)), Port]),
         static2(),
         pinfo_table(),
         static3()
        ], 
        Req2),
	{ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
	ok.
