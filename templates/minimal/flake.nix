{
  description = "λ well-tailored and configureable NixOS system!";

  inputs = { dotfiles.url = "github:eelcovv/snowflake"; };

  outputs = inputs@{ dotfiles, ... }: {
    nixosConfigurations = dotfiles.lib.mapHosts ./hosts {
      imports = [
        # If this is a linode machine
        # "${snowflake}/hosts/linode.nix"
      ];
    };
  };
}
