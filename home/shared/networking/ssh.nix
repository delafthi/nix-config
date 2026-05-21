{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "clt-dsk-t-6006" = {
        hostname = "clt-dsk-t-6006";
        user = "deaa";
        identityFile = "~/.ssh/id_clt-dsk-t-6006.pub";
        identitiesOnly = true;
      };
      "codeberg.org" = {
        hostname = "codeberg.org";
        user = "git";
        identityFile = "~/.ssh/id_codeberg.org.pub";
        identitiesOnly = true;
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_github.com.pub";
        identitiesOnly = true;
      };
      "github.zhaw.ch" = {
        hostname = "github.zhaw.ch";
        user = "git";
        identityFile = "~/.ssh/id_github.zhaw.ch.pub";
        identitiesOnly = true;
      };
      "git.krampf.ch" = {
        hostname = "git.krampf.ch";
        user = "_gitea";
        identityFile = "~/.ssh/id_git.krampf.ch.pub";
        identitiesOnly = true;
      };
      "*" = {
        addKeysToAgent = "no";
        compression = false;
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        forwardAgent = false;
        hashKnownHosts = false;
        serverAliveInterval = 30;
        serverAliveCountMax = 6;
        userKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };
}
