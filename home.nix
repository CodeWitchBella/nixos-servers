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
  programs.nushell = {
    enable = true;
    extraConfig = ''
      $env.config.show_banner = false
    '';
    extraEnv = ''

    '';
  };
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = { };
  };
  home.stateVersion = "23.05";
}
