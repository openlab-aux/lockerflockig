{
  pkgs,
  lib,
  buildPythonPackage,
  setuptools,
  paho-mqtt,
  click,
  pydantic,
  pyyaml,
  meshcore,
  ...
}:
buildPythonPackage rec {
  pname = "meshcore-mqtt";
  version = "0.1.1";
  format = "pyproject";
  nativeBuildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    paho-mqtt
    click
    pydantic
    pyyaml
    meshcore
  ];

  src = pkgs.fetchFromGitHub {
    owner = "ipnet-mesh";
    repo = "meshcore-mqtt";
    rev = "main";
    sha256 = "sha256-MEm7GK6WqVtZQGRAKab2CAgydBCs2u4ec1Bfs+1214c=";
  };
}
