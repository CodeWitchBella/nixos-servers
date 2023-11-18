{ pkgs, lib, config, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Isabella Skořepová";
    userEmail = "isabella@skorepova.info";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      submodule.recurse = "true";
      alias.frp = "!bash -c \"git fetch --prune ; git rebase `git symbolic-ref refs/remotes/origin/HEAD --short`; git push --force\"";
      alias.fr = "!bash -c \"git fetch --prune ; git rebase `git symbolic-ref refs/remotes/origin/HEAD --short`\"";
      rebase.autostash = true;
      pull.rebase = true;
    };
  };
  home.stateVersion = "23.05";
}
