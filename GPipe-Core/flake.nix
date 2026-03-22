{
  description = "A basic development shell";

  # 📥 Inputs: Where we get our packages
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };


outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # 1. Tell flake-parts which systems to support
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      # 2. Import your new Neovim file
      imports = [ ./dev-config/nvim.nix ];

      # 3. Define your shell (which now just references the package)
      # TODO: try to do one-time hoogle generate at the start
      perSystem = { config, pkgs, ... }: 
      let
          glSource = pkgs.fetchFromGitHub {
            owner = "ekmett";
            repo = "gl";
            rev = "5aad20d0af9fa803e7d0e96700d2a90604b2cf4e";
            sha256 = "sha256-Ro0muoAtDSq2UqqspBH4HuMwg45hyje4CZ0rHQ+A9fM=";
          };
          haskellPackages = pkgs.haskellPackages.override {
            overrides = hfinal: hprev: {
              # 1. Simple package (no subdir)
              PSQueue = hprev.callCabal2nix "PSQueue" (pkgs.fetchFromGitHub {
                owner = "MaciekFlis";
                repo = "PSQueue";
                rev = "20441a98c4f77e5d45bc72c780a42829330f556b";
                sha256 = "sha256-UjEP1JEWDzJenuJCtS1fQzpb7JNzKB1DouIWm3fNOnA=";
              }) {};
      
              # 2. Packages with subdirs (use the /path suffix)
              apecs = hprev.callCabal2nix "apecs" "${pkgs.fetchFromGitHub {
                owner = "MaciekFlis";
                repo = "apecs";
                rev = "c7b75736fd4d71a0e59be4b32a3b8a2fcca72842";
                sha256 = "sha256-aTbZRqQtNSwuW2R8jhmlCJSaEhesXjZWmIKzdKzhj+0=";
              }}/apecs" {};
      
              GPipe-Core = hprev.callCabal2nix "GPipe-Core" "${pkgs.fetchFromGitHub {
                owner = "MaciekFlis";
                repo = "GPipe-Core";
                rev = "68af27674ea03b36788274354a363fc24b645857";
                sha256 = pkgs.lib.fakeSha256;
              }}/GPipe-Core" {};
      
              GPipe-GLFW = hprev.callCabal2nix "GPipe-GLFW" "${pkgs.fetchFromGitHub {
                owner = "MaciekFlis";
                repo = "GPipe-GLFW";
                rev = "ec39c76d5401426588d79fc2a4bb05547cb8e97a";
                sha256 = "sha256-h6MSrdfbGxgbaQlpxcQTBai0DWO100d6mTNXBTXCLXs=";
              }}/GPipe-GLFW" {};

              };
          };
      
          haskellApp = haskellPackages.callCabal2nix "craft" ./. {};
        in {
	packages.default = haskellApp;
        devShells.default = pkgs.mkShell {
	  inputsFrom = [ haskellApp.env ];
          packages = [ 
            pkgs.git
            pkgs.ghc
            pkgs.cabal-install
            pkgs.haskellPackages.haskell-language-server
            pkgs.haskellPackages.haskell-debug-adapter
            pkgs.haskellPackages.ghci-dap
            pkgs.haskellPackages.fast-tags
            pkgs.haskellPackages.hoogle
            pkgs.tree-sitter
            pkgs.ripgrep
            pkgs.fd
            # Reference the package defined in neovim.nix
            config.packages.myNeovim
          ];

          shellHook = ''
            if [ -d .git ]; then
	      echo "Configuring local Git settings..."
	      git config --local user.name "maciek flis"
	      git config --local user.email "maciek.flis@gmail.com"
	      git config --local core.autocrlf input
	      git config --local alias.s status
	      git config --local alias.l log
	      git config --local alias.sw switch -
	      git config --local alias.sm switch master
            fi
          '';
        };
      };
    };
}
