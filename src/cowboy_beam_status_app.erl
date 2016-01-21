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

-module(cowboy_beam_status_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", beam_status_handler, []}
		]}
	]),
    {ok, _} = cowboy:start_http(http, 100, 
        [{ip, {0,0,0,0,0,0,0,0}}, {port, 9000}],
        [{env, [{dispatch, Dispatch}]}
	]),
	cowboy_beam_status_sup:start_link().

stop(_State) ->
	ok.
