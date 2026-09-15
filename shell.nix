{ pkgs ? import <nixpkgs> {} }:

let
  # Commit of emmylua-analyzer-rust with the documentation generator fixes
  # required by the annotations in fun.lua (see HACKING.md).
  rev = "d56a03b08f2c25b44d7828fb70c072bd4b3cb5c7";

  src = pkgs.fetchFromGitHub {
    owner = "EmmyLuaLs";
    repo = "emmylua-analyzer-rust";
    inherit rev;
    hash = "sha256-xvv8AugXMZbJdZZIatgR6yPP611qSeCMprymjfyxyAw=";
  };

  # Build each tool from the same pinned revision, the way nixpkgs does.
  tool = { pname, dir }: pkgs.rustPlatform.buildRustPackage {
    inherit pname;
    version = "0.30.0";
    inherit src;
    buildAndTestSubdir = "crates/${dir}";
    cargoHash = "sha256-UIwCuHpAr1tAo94X0fp3nDMxYL2ZJ3tlKsnsWS7rsHs=";
    doCheck = false;
  };
in
pkgs.mkShell {
  name = "luafun";

  buildInputs = with pkgs; [
    (tool { pname = "emmylua-check"; dir = "emmylua_check"; })
    (tool { pname = "emmylua-doc-cli"; dir = "emmylua_doc_cli"; })
    git
    gnumake
    sphinx
    luajitPackages.luacheck
    mkdocs
    python312Packages.myst-parser
    sphinx-autobuild
  ];
}
