{ lib
, stdenv
, buildPythonPackage
, isPyPy
, fetchPypi
, pythonAtLeast
, pytestCheckHook
, libffi
, pkg-config
, pycparser
}:

if isPyPy then null else buildPythonPackage rec {
  pname = "cffi";
  version = "1.15.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-1AC/uaN7E1ElPLQCZxzqfom97MKU6AFqcH9tHYrJNPk=";
  };

  buildInputs = [ libffi ];

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [ pycparser ];

  postPatch = lib.optionalString stdenv.isDarwin ''
    # Remove setup.py impurities
    substituteInPlace setup.py \
      --replace "'-iwithsysroot/usr/include/ffi'" "" \
      --replace "'/usr/include/ffi'," "" \
      --replace '/usr/include/libffi' '${lib.getDev libffi}/include'
  '';

  # The tests use -Werror but with python3.6 clang detects some unreachable code.
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang
    "-Wno-unused-command-line-argument -Wno-unreachable-code -Wno-c++11-narrowing";

  # Lots of tests fail on aarch64-darwin due to "Cannot allocate write+execute memory":
  # * https://cffi.readthedocs.io/en/latest/using.html#callbacks
  doCheck = !stdenv.hostPlatform.isMusl && !(stdenv.isDarwin && stdenv.isAarch64);

  checkInputs = [ pytestCheckHook ];

  # test_callback_exception fails with python 3.11 because of change of exception format.
  # This will be solved in version 1.15.2
  # see
  # - https://foss.heptapod.net/pypy/cffi/-/merge_requests/113/diffs
  disabledTests = lib.optionals (pythonAtLeast "3.11") [
    "test_callback_exception"
  ];

  meta = with lib; {
    maintainers = with maintainers; [ domenkozar lnl7 ];
    homepage = "https://cffi.readthedocs.org/";
    license = licenses.mit;
    description = "Foreign Function Interface for Python calling C code";
  };
}
