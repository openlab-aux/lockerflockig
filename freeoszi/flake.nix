{
  description = "Flake for FreeOszi, a Qt-based oscilloscope software";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.default = pkgs.stdenv.mkDerivation {
      name = "freeoszi";
      version = "0.1.0";

      buildInputs = [ 
        pkgs.libsForQt5.qt5.qtbase
        pkgs.libsForQt5.qt5.qtcharts
        pkgs.libusb1
        pkgs.fftw

        pkgs.qt5.qtbase.dev
        pkgs.qt5.qmake
        pkgs.qt5.qtx11extras
        pkgs.qt5.qtwebsockets
        pkgs.qt5.qtdeclarative
        pkgs.qt5.qtsvg
        pkgs.xorg.libX11
        pkgs.xorg.libX11.dev
        pkgs.xorg.libxcb.dev
      ];

      nativeBuildInputs = [ pkgs.qt5.wrapQtAppsHook ];

      src = pkgs.fetchFromGitLab {
        owner = "kayNick";
        repo = "FreeOszi";
        sha256 = "sha256-jxMZh7DZdaACfBwS3VrKj3tdB8OsxH8mATRxDu3epIA=";
        rev = "3cc3c4f147956362bb87a202ecb940d1d61269f1";
      };

      buildPhase = ''
        runHook preBuild
        sed -i -e 's/target.path = .*/target.path = $PREFIX/g' FreeOszi.pro
        qmake PREFIX=$out FreeOszi.pro
        make
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp -r FreeOszi $out/bin/
        runHook postInstall
      '';
    };
  });
}
