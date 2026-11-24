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

          coreblow = pkgs.stdenv.mkDerivation rec {
            pname = "coreblow";
            version = "2.1.4";

            src = pkgs.fetchurl {
              url = "https://registry.npmjs.org/coreblow/-/coreblow-${version}.tgz";
              sha256 = "793ccb921892740ca942e04be8f754f6cc1207c3d1be3a39936ac25c20dccfc5";
            };

            nativeBuildInputs = [ pkgs.makeWrapper ];
            buildInputs = [ pkgs.nodejs_22 ];

            dontBuild = true;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/lib/node_modules/coreblow $out/bin
              cp -r . $out/lib/node_modules/coreblow
              makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/coreblow \
                --add-flags "$out/lib/node_modules/coreblow/dist/entry.js"
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "CoreBlow Sovereign Autonomous Agent-OS & Enterprise AI Gateway CLI";
              homepage = "https://coreblow.com";
              license = licenses.mit;
              platforms = platforms.all;
              mainProgram = "coreblow";
            };
          };

          coreblow-studio = if isDarwin then pkgs.stdenv.mkDerivation {
            pname = "coreblow-studio";
            version = "2.1.2";
            src = ./.;
            dontBuild = true;
            installPhase = ''
              runHook preInstall
              mkdir -p $out/Applications
              if [ -d "dist/CoreBlow.app" ]; then
                cp -R dist/CoreBlow.app $out/Applications/
              elif [ -d "CoreBlow.app" ]; then
                cp -R CoreBlow.app $out/Applications/
              else
                echo "Notice: CoreBlow.app not found in source tree. Pre-built binaries are distributed via official DMG packages."
              fi
              runHook postInstall
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
