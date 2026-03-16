{
  description = "A flake to build papyrus-compiler package for nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Get access to Nix packages.
    flake-utils.url = "github:numtide/flake-utils"; # Support package build on differen architectures.
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };
        tag = "2026.03.15"; # Use tags of stable releases, instead of using master branch as src, to avoid hash mismatch, which will change on each commit to master.
      in
      {
        packages.default = pkgs.stdenv.mkDerivation { # packages.default is used for build and install. E.g. nix build .#default is used for packages.default; nix build .#abc is used for packages.abc.
          pname = "papyrus-compiler"; # Package name.
          version = tag;
          # Source code from GitHub.
          src = pkgs.fetchFromGitHub {
            owner = "russo-2025";
            repo = "papyrus-compiler";
            rev = tag; # Downloads repo at the state of tag, instead of master branch, to avoid constant hash changes.
            hash = "sha256-0zWJdifY7XB8XbFP2ZPqiu5MKSHjcyFXXdadO/CWqew="; # Hash, if the tag was changed to new, this line will cause error, we will need to replace this hash. New hash will be in the error itself.
            # E.g. Expected - Old Hash, Got - New Hash. Use whatever hash is displayed inside of the Got message.
            fetchSubmodules = true;
          };
          buildPhase = ''
            # This will set home to /tmp directory rather than /homeless-shelter/
            # vlang seems to have issues with automating it
            # so we add this export.
            export HOME=$TMP

            # Extract the actual commit hash and patch @VMODHASH in sys_info.v. Required as Nix build occurs in isolated environment.
            echo "Patching sys_info.v with commit hash @VMODHASH"
            sed -i "s/@VMODHASH/\"$(git rev-parse HEAD)\"/" modules/papyrus/util/sys_info.v

            # Build papyrus-compiler.
            v -prod -g -gc none -o "bin/papyrus-compiler" compiler.v
          '';
          installPhase = ''
            # Make a package folder in Nix Store, and place our build output there.
            mkdir -p $out/bin/
            cp ./bin/papyrus-compiler $out/bin/
          '';
          nativeBuildInputs = with pkgs; [
            # All build dependencies should be listed here.
            vlang
            git
          ];
        };
        # Development shell with tools for manual building and tesing of the package.
        # Enter with `nix develop` command. Must be inside of the folder where flake.nix is located.
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ]; # Use same packages that listed in build dependencies.
          shellHook = ''
            export PS1="$PS1[nix develop]:" # Add a postfix, so we see that we are inside of a nix develop shell.
            echo "Welcome to the dev shell."
            echo "Build the package with: nix build .#default"
            echo "Use built package with: ./result/bin/papyrus-compiler"
          '';
        };
      });
}

/*
Bellow we can see a vague example of how one would install papyrus-compiler in NixOS with flakes. Please note that this is only a reference and not complete working flake.

{
  description = "Example papyrus-compiler flake.nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    papyrus-compiler.url = "github:DioKyrie-Git/papyrus-compiler";
  };

  outputs = { nixpkgs, papyrus-compiler, ... } @ inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations."UserName" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };
        modules = [
          #configuation.nix start
          ({ config, pkgs, unstable, inputs, ... }: {
            environment.systemPackages = with pkgs; [
              papyrus-compiler.packages.${system}.default
            ];
          };)
          #configuation.nix end
}
*/

