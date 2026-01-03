{
    pkgs,
    config,
    ...
}:
let
    strings = pkgs.lib.strings;
    lists = pkgs.lib.lists;

    text = builtins.readFile ./Dockerfile;
    parseLine = line: let
        parts = strings.splitString " " line;
        image = lists.elemAt parts 1;
        repository = lists.elemAt (strings.splitString ":" image) 0;
        imageVersion = strings.removePrefix "${repository}:" image;
    in
    {
        inherit repository;
        name = lists.elemAt parts 3;
        tag = lists.elemAt (strings.splitString "@" imageVersion) 0;
        digest = lists.elemAt (strings.splitString "@" imageVersion) 1;
    };
    filterLine = line:
        (strings.trim line) != ""
        && !(strings.hasPrefix "#" line);

    lines = builtins.filter filterLine (strings.splitString "\n" text);
    list = builtins.map (line: parseLine line) lines;
    attrs = builtins.listToAttrs (builtins.map (line: { name = line.name; value = line; }) list);
in
{
    inherit list attrs;
}
