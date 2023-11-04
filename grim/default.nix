{ lib
, stdenv
, fetchFromSourcehut
, pixman
, libpng
, libjpeg
, meson
, ninja
, pkg-config
, scdoc
, wayland
, wayland-protocols
, wayland-scanner
}:

stdenv.mkDerivation rec {
  pname = "grim";
  version = "1.4.1";

  src = ./.;

  mesonFlags = [
    "-Dwerror=false"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    pixman
    libpng
    libjpeg
    wayland
    wayland-protocols
  ];

  meta = with lib; {
    description = "Grab images from a Wayland compositor";
    homepage = "https://github.com/emersion/grim";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ buffet eclairevoyant ];
    mainProgram = "grim";
  };
}

