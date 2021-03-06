%%% @author Tristan Sloughter <t@crashfast.com>
%%% @copyright (C) 2015, Tristan Sloughter
-module(rlx_test_utils).

-compile(export_all).

create_app(Dir, Name, Vsn, Deps, LibDeps) ->
    AppDir = filename:join([Dir, Name ++ "-" ++ Vsn]),
    write_app_file(AppDir, Name, Vsn, Deps, LibDeps),
    write_beam_file(AppDir, Name),
    rlx_app_info:new(erlang:list_to_atom(Name), Vsn, AppDir,
                     Deps, []).

create_empty_app(Dir, Name, Vsn, Deps, LibDeps) ->
    AppDir = filename:join([Dir, Name ++ "-" ++ Vsn]),
    write_app_file(AppDir, Name, Vsn, Deps, LibDeps),
    rlx_app_info:new(erlang:list_to_atom(Name), Vsn, AppDir,
                     Deps, []).

write_beam_file(Dir, Name) ->
    Beam = filename:join([Dir, "ebin", "not_a_real_beam" ++ Name ++ ".beam"]),
    ok = filelib:ensure_dir(Beam),
    ok = ec_file:write_term(Beam, testing_purposes_only).

write_appup_file(AppInfo, DownVsn) ->
    Dir = rlx_app_info:dir(AppInfo),
    Name = rlx_util:to_string(rlx_app_info:name(AppInfo)),
    Vsn = rlx_app_info:vsn_as_string(AppInfo),
    Filename = filename:join([Dir, "ebin", Name ++ ".appup"]),
    ok = filelib:ensure_dir(Filename),
    ok = ec_file:write_term(Filename, {Vsn, [{DownVsn, []}], [{DownVsn, []}]}).

write_app_file(Dir, Name, Version, Deps, LibDeps) ->
    Filename = filename:join([Dir, "ebin", Name ++ ".app"]),
    ok = filelib:ensure_dir(Filename),
    ok = ec_file:write_term(Filename, get_app_metadata(Name, Version, Deps, LibDeps)).

get_app_metadata(Name, Vsn, Deps, LibDeps) ->
    {application, erlang:list_to_atom(Name),
     [{description, ""},
      {vsn, Vsn},
      {modules, []},
      {included_applications, LibDeps},
      {registered, []},
      {applications, Deps}]}.

create_random_name(Name) ->
    random:seed(erlang:now()),
    Name ++ erlang:integer_to_list(random:uniform(1000000)).

create_random_vsn() ->
    random:seed(erlang:now()),
    lists:flatten([erlang:integer_to_list(random:uniform(100)),
                   ".", erlang:integer_to_list(random:uniform(100)),
                   ".", erlang:integer_to_list(random:uniform(100))]).

write_config(Filename, Values) ->
    ok = filelib:ensure_dir(Filename),
    ok = ec_file:write(Filename,
                       [io_lib:format("~p.\n", [Val]) || Val <- Values]).

test_template_contents() ->
    "{erts_vsn, \"{{erts_vsn}}\"}.\n"
     "{release_erts_version, \"{{release_erts_version}}\"}.\n"
        "{release_name, {{release_name}}}.\n"
        "{rel_vsn, \"{{release_version}}\"}.\n"
        "{release_version, \"{{release_version}}\"}.\n"
        "{release_applications, [{{ release_applications|join:\", \" }}]}.\n"
        "{std_version, \"{{release.stdlib.version}}\"}.\n"
        "{kernel_version, \"{{release.kernel.version}}\"}.\n"
        "{non_goal_1_version, \"{{release.non_goal_1.version}}\"}.\n"
        "{non_goal_2_version, \"{{release.non_goal_2.version}}\"}.\n"
        "{goal_app_1_version, \"{{release.goal_app_1.version}}\"}.\n"
        "{goal_app_2_version, \"{{release.goal_app_2.version}}\"}.\n"
        "{lib_dep_1, \"{{release.lib_dep_1.version}}\"}.\n"
        "{lib_dep_1_dir, \"{{release.lib_dep_1.dir}}\"}.\n"
        "{lib_dep_1_active, [{{ release.lib_dep_1.active_dependencies|join:\", \" }}]}.\n"
        "{lib_dep_1_library, [{{ release.lib_dep_1.library_dependencies|join:\", \" }}]}.\n"
        "{lib_dep_1_link, \"{{release.lib_dep_1.link}}\"}.\n"
        "{log, \"{{log}}\"}.\n"
        "{output_dir, \"{{output_dir}}\"}.\n"
        "{target_dir, \"{{target_dir}}\"}.\n"
        "{overridden, [{{ overridden|join:\", \" }}]}.\n"
        "{goals, [\"{{ goals|join:\", \" }}\"]}.\n"
        "{lib_dirs, [\"{{ lib_dirs|join:\", \" }}\"]}.\n"
        "{config_file, \"{{ config_file }}\"}.\n"
        "{providers, [{{ providers|join:\", \" }}]}.\n"
        "{sys_config, \"{{sys_config}}\"}.\n"
        "{root_dir, \"{{root_dir}}\"}.\n"
        "{default_release_name, {{default_release_name}}}.\n"
        "{default_release_version, \"{{default_release_version}}\"}.\n"
        "{default_release, \"{{default_release}}\"}.\n"
        "{yahoo, \"{{yahoo}}\"}.\n"
        "{yahoo2_foo, \"{{yahoo2.foo}}\"}.\n"
        "{foo_dir, \"{{foo_dir}}\"}.\n"
        "{yahoo3, \"{{yahoo3.bar}}\"}.\n"
        "{yahoo4, \"{{yahoo4.foo}}\"}.\n"
        "{google, \"{{google}}\"}.\n".
