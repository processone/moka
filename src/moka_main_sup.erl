%%% @copyright 2012 Samuel Rivas
%%% @doc Main supervisor for the Moka application
%%%
%%% You should not need to use this module directly, use {@link moka:start/1} to
%%% start new mokas
-module(moka_main_sup).
-behaviour(supervisor).

%%%_* Exports ==========================================================
-export([start_link/0, start_moka/2, stop_moka/1]).

%% Supervisor callbacks
-export([init/1]).

%%%_* API ==============================================================

%% @doc Starts The moka main supervisor
%%
%% Normally, this function must be called from {@link moka_app}
-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @doc Starts a new moka process tree
-spec start_moka(atom(), module()) -> ok.
start_moka(MokaName, MokedModule) ->
    SupName = sup_name(MokaName),
    crashfy:untuple(
      supervisor:start_child(
        ?MODULE, moka_sup_spec(SupName, MokaName, MokedModule))).

%% @doc Stops a moka process tree
-spec stop_moka(atom()) -> ok.
stop_moka(MokaName) ->
    SupName = sup_name(MokaName),
    crashfy:untuple(supervisor:terminate_child(?MODULE, SupName)).

%%%_* Exported Internals ================================================

%% @private
init([]) -> {ok, {supervisor_spec(), []}}.

%%%_* Private Functions ================================================

supervisor_spec() ->
    MaxRestarts = 1,
    MaxSecondsBetweenRestarts = 1,
    {one_for_one, MaxRestarts, MaxSecondsBetweenRestarts}.

moka_sup_spec(SupName, MokaName, MokedModule) ->
    Restart = temporary,
    Shutdown = 2000,
    MFA = {moka_sup, start_link, [SupName, MokaName, MokedModule]},
    {SupName, MFA, Restart, Shutdown, supervisor, [moka_sup]}.

sup_name(MokaName) ->
    moka_utils:atom_append(atom_to_list(MokaName), "_sup").

%%%_* Emacs ============================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 4
%%% End:
