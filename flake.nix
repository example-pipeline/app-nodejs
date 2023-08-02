{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
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
        buildCommands = [ "HOME=$PWD" "npm run build" ];
        installPhase = ''
          mkdir -p $out
          cp -r .next/standalone $out/app
          cp -r public $out/app/public
          mkdir -p $out/app/.next
          cp -r .next/static $out/app/.next/static
        '';
      };
      nextUser = pkgs.runCommand "user" {} ''
        mkdir -p $out/etc
        echo "nextjs:x:1000:1000:nextjs:/home/nextjs:/bin/false" > $out/etc/passwd
        echo "nextjs:x:1000:" > $out/etc/group
        echo "nextjs:!:1::::::" > $out/etc/shadow
      '';
      dockerImage = pkgs.dockerTools.buildImage {
        name = "app";
        tag = "latest";

        copyToRoot = [
          # Uncomment the coreutils and bash if you want to be able to use a shell environment
          # inside the container.
          #pkgs.coreutils
          #pkgs.bash
          nextUser
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

