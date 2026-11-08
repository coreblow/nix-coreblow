{
  description = "Nix packaging for CoreBlow Sovereign Agent-OS & Desktop Studio";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          isDarwin = pkgs.stdenv.isDarwin;
        in
        rec {
          default = coreblow;

          coreblow = pkgs.writeShellApplication {
            name = "coreblow";
            runtimeInputs = [ pkgs.nodejs_22 pkgs.pnpm pkgs.git ];
            text = ''
              if command -v coreblow >/dev/null 2>&1; then
                exec coreblow "$@"
              else
                exec npx -y coreblow@latest "$@"
              fi
            '';
          };

          coreblow-studio = if isDarwin then pkgs.stdenv.mkDerivation {
            pname = "coreblow-studio";
            version = "2.0.0";
            src = ./.;
            installPhase = ''
              mkdir -p $out/Applications
              if [ -d "dist/CoreBlow.app" ]; then
                cp -R dist/CoreBlow.app $out/Applications/
              elif [ -d "CoreBlow.app" ]; then
                cp -R CoreBlow.app $out/Applications/
              fi
            '';
            meta = with pkgs.lib; {
              description = "CoreBlow Sovereign Autonomous Agent-OS Desktop Studio";
              homepage = "https://coreblow.com";
              license = licenses.mit;
              platforms = platforms.darwin;
            };
          } else null;
        });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.nodejs_22 pkgs.pnpm pkgs.git ];
          };
        });
    };
}
