{
  description = "A flake for papyrus-compiler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };
        tag = "2026.03.15"; # Use tags to avoid hash mismatch after each commit to master.
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "papyrus-compiler";
          version = tag;
          # Local source code (no external files needed)
          src = pkgs.fetchFromGitHub {
            owner = "russo-2025";
            repo = "papyrus-compiler";
            rev = tag;
            hash = "sha256-0zWJdifY7XB8XbFP2ZPqiu5MKSHjcyFXXdadO/CWqew=";
            fetchSubmodules = true;
            #leaveDotGit = true; # Preserve .git/ upon unpacking to satisfy @VMODHASH
          };
          buildPhase = ''
            # This will set home to /tmp directory rather than /homeless-shelter/
            # vlang seems to have issues with automating it
            # so we add this export.
            export HOME=$TMP

            # Extract the actual commit hash and patch @VMODHASH in sys_info.v
            echo "Patching sys_info.v with commit hash @VMODHASH"
            sed -i "s/@VMODHASH/\"$(git rev-parse HEAD)\"/" modules/papyrus/util/sys_info.v

            # Build papyrus-compiler
            v -prod -g -gc none -o "bin/papyrus-compiler" compiler.v
          '';
          installPhase = ''
            mkdir -p $out/bin/
            cp ./bin/papyrus-compiler $out/bin/
          '';
          nativeBuildInputs = with pkgs; [
            vlang
            git
          ];
        };
        # Development shell with tools for hacking on the package
        # Enter with `nix develop`
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];
          shellHook = ''
            export PS1="$PS1[nix develop]:"
            echo "Welcome to the dev shell."
            echo "Build the package with: nix build"
            echo "Use built package ./result/bin/papyrus-compiler"
          '';
        };
      });
}
