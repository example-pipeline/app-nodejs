{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    npmlock2nix = {
      url = "github:nix-community/npmlock2nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, npmlock2nix }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      nl2nix = import npmlock2nix {inherit pkgs;};
      app = nl2nix.v2.build {
        src = ./.;
        nodejs = pkgs.nodejs-18_x;
        buildCommands = [ "npm run build" ];
        installPhase = ''
          mkdir -p $out
          cp -r .next/standalone $out/app
          cp -r public $out/app/public
          mkdir -p $out/app/.next
          cp -r .next/static $out/app/.next/static
        '';
      };
      dockerImage = pkgs.dockerTools.buildImage {
        name = "app";
        tag = "latest";

        runAsRoot = ''
          #!${pkgs.runtimeShell}
          ${pkgs.dockerTools.shadowSetup}
          groupadd -r nextjs
          useradd -r -g nextjs nextjs
        '';
        copyToRoot = [
          # Uncomment the coreutils and bash if you want to be able to use a shell environment
          # inside the container.
          #pkgs.coreutils
          #pkgs.bash
          pkgs.nodejs-18_x
          app
        ];
        config = {
          Cmd = [ "node" "server.js" ];
          User = "nextjs:nextjs";
          Env = [ "NEXT_TELEMETRY_DISABLED=1" ];
          ExposedPorts = {
              "3000/tcp" = {};
          };
          WorkingDir = "/app";
        };
      };
    in
    {
      packages."x86_64-linux".default = app;
      packages."x86_64-linux".docker = dockerImage;
    };
}

