# Hacking

## Build documentation

The documentation consists of two parts:

* the hand-written prose chapters in `doc/*.rst`, converted to HTML with
  [docutils](https://docutils.sourceforge.io/) and published at the site root;
* the API reference generated from the EmmyLua annotations in `fun.lua` with
  [emmylua_doc_cli](https://github.com/EmmyLuaLs/emmylua-analyzer-rust) and
  published under `site/api/`.

Prerequisites:

* Python 3 with `docutils` and `Pygments`:

  ```sh
  $ pip install docutils pygments
  ```

  Alternatively, use the provided nix shell, which includes them.
* `emmylua_doc_cli` built from the
  [emmylua-analyzer-rust](https://github.com/EmmyLuaLs/emmylua-analyzer-rust)
  commit `9ab7908` (it contains the documentation generator fixes used
  by the annotations in `fun.lua`, including Rust-like intra-doc links
  such as ``[`fun.range`]``):

  ```sh
  $ cargo install --locked \
      --git https://github.com/EmmyLuaLs/emmylua-analyzer-rust \
      --rev 9ab790824ca8bd15c9f612016dee3de42f83b896 \
      emmylua_doc_cli
  ```

  If an older `emmylua_doc_cli` is already installed, remove it first
  (`cargo uninstall emmylua_doc_cli`) or pass `--force`.

Build both parts into `site/`:

```sh
$ make docs
$ xdg-open site/index.html
```

Serve the documentation locally:

```sh
$ make serve
```

Edit the prose chapters in `doc/*.rst`. The generation script is
`doc/build_site.py`, the shared stylesheet is `doc/site.css`, and the navigation
links to the API subsite at `api/module/fun.html`.

Cleanup generated artifacts (`build/` and `site/`):

```sh
$ make clean
```

## Run static analysis

```sh
$ make check
```

The target runs `luacheck` and `emmylua_check`.

## Run tests

```sh
$ make test
```
