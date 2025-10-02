{
  pkgs,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  bleak,
  pycayennelpp,
  pyserial-asyncio,
  ...
}:

buildPythonPackage rec {
  pname = "meshcore";
  version = "2.1.7";
  format = "pyproject";
  propagatedBuildInputs = [
    hatchling
    bleak
    pycayennelpp
    pyserial-asyncio
  ];
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-VEkpS6FTs7mCjhqFRL6+AisR0IKYrOWbx6irGfsucEc=";
  };
}
