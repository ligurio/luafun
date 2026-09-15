{ pkgs ? import <nixpkgs> {} }:

let
  # Commit of emmylua-analyzer-rust with the documentation
  # generator fixes required by the annotations in fun.lua,
  # including Rust-like intra-doc links (see HACKING.md and
  # https://github.com/EmmyLuaLs/emmylua-analyzer-rust/issues/1430).
  rev = "9ab790824ca8bd15c9f612016dee3de42f83b896";

  src = pkgs.fetchFromGitHub {
    owner = "EmmyLuaLs";
    repo = "emmylua-analyzer-rust";
    inherit rev;
    hash = "sha256-xHImJEwfop4Dm5rim2doza266MSH5Ivn6XUpKP/YHnU=";
  };

  # Build each tool from the same pinned revision, the way nixpkgs
  # does.
  tool = { pname, dir }: pkgs.rustPlatform.buildRustPackage {
    inherit pname;
    version = "0.30.0";
    inherit src;
    buildAndTestSubdir = "crates/${dir}";
    cargoHash = "sha256-97Xu+wvs/6FlS94jDmP20+TR5G/mBzGDy5Drcmkjino=";
    nativeBuildInputs = [ pkgs.cmake ];
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
    luajitPackages.luacheck
    python3
    python3Packages.docutils
    python3Packages.pygments
  ];
}
