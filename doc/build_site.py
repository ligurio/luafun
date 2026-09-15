#!/usr/bin/env python3
"""Build the Lua Fun documentation site from reStructuredText with docutils.

The generated site contains the hand-written prose chapters.  The API
reference is built separately by emmylua_doc_cli into ``<output>/api``.
"""

from __future__ import annotations

import datetime
import html
import re
import shutil
import sys
from pathlib import Path

from docutils.core import publish_parts

DOC_DIR = Path(__file__).resolve().parent

SECTION_HEADING_RE = re.compile(
    r'(<section id="([^"]+)">\s*<h([1-6])>)(.*?)(</h\3>)',
    re.DOTALL,
)

SITE_NAME = "Lua Functional documentation"

MONTHS = (
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
)

PAGES = [
    ("index", "index.rst", "Lua Functional Library"),
    ("intro", "intro.rst", "Introduction"),
    ("getting_started", "getting_started.rst", "Getting Started"),
    ("under_the_hood", "under_the_hood.rst", "Under the Hood"),
    ("about", "about.rst", "About"),
]

NAV = [
    ("index", "index.html", "Contents"),
    ("intro", "intro.html", "Introduction"),
    ("getting_started", "getting_started.html", "Getting Started"),
    ("under_the_hood", "under_the_hood.html", "Under the Hood"),
    ("about", "about.html", "About"),
    ("api", "api/module/fun.html", "API Reference"),
]

NAV_SEPARATOR = "&#160;&#160;::&#160;&#160;"

LEGACY_PAGES = [
    "reference",
    "basic",
    "generators",
    "slicing",
    "indexing",
    "filtering",
    "reducing",
    "transformations",
    "compositions",
    "operators",
]

REDIRECT_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url={target}">
  <link rel="canonical" href="https://luafun.github.io/{target}">
  <title>Redirecting&#8230;</title>
</head>
<body>
  <p>This page has moved to <a href="{target}">{target}</a>.</p>
</body>
</html>
"""

TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title} &#8212; {site_name}</title>
  <link rel="icon" type="image/png" href="logo.png">
  <link rel="stylesheet" href="site.css">
</head>
<body>
  <div class="header" role="banner">
    <img class="rightlogo" src="logo.png" alt="Logo">
    <h1 class="heading"><a href="index.html">{site_name}</a></h1>
    <h2 class="heading">{page_title}</h2>
  </div>
  <div class="topnav" role="navigation" aria-label="top navigation">
    <p>{nav}</p>
  </div>
  <div class="content" role="main" id="top">
    <h1>{page_title}</h1>
{body}
  </div>
  <div class="bottomnav" role="navigation" aria-label="bottom navigation">
    <p>{nav}</p>
  </div>
  <div class="footer" role="contentinfo">
    <p>&#169; Copyright 2013-2021, Roman Tsisyk.</p>
  </div>
</body>
</html>
"""


def generation_date() -> str:
    today = datetime.date.today()
    return f"{MONTHS[today.month - 1]} {today.day}, {today.year}"


def build_nav(active: str) -> str:
    items = []
    for key, href, label in NAV:
        current = ' class="active" aria-current="page"' if key == active else ""
        items.append(f'<a href="{href}"{current}>{label}</a>')
    return NAV_SEPARATOR.join(items)


def add_headerlinks(body: str) -> str:
    """Add Sphinx-style permalink anchors to section headings."""

    def replace(match: re.Match[str]) -> str:
        section_id = html.escape(match.group(2), quote=True)
        return (
            f"{match.group(1)}{match.group(4)}"
            f'<a class="headerlink" href="#{section_id}" '
            f'title="Permalink to this headline">&#182;</a>'
            f"{match.group(5)}"
        )

    return SECTION_HEADING_RE.sub(replace, body)


def render(source: Path, page_title: str, active: str) -> str:
    text = source.read_text(encoding="utf-8")
    text = re.sub(
        r"^:Updated:.*$",
        f":Updated: {generation_date()}",
        text,
        count=1,
        flags=re.MULTILINE,
    )
    parts = publish_parts(
        source=text,
        source_path=str(source),
        writer_name="html5",
        settings_overrides={
            "input_encoding": "utf-8",
            "output_encoding": "utf-8",
            "report_level": 2,
            "halt_level": 3,
            "docinfo_xform": False,
            "sectnum_xform": False,
            "syntax_highlight": "short",
            "embed_stylesheet": False,
            "file_insertion_enabled": False,
            "raw_enabled": False,
        },
    )

    return TEMPLATE.format(
        title=html.escape(page_title),
        site_name=SITE_NAME,
        page_title=html.escape(page_title),
        nav=build_nav(active),
        body=add_headerlinks(parts["body"]),
    )


def main() -> None:
    output = Path(sys.argv[1] if len(sys.argv) > 1 else "site").resolve()
    output.mkdir(parents=True, exist_ok=True)

    for key, source_name, title in PAGES:
        source = DOC_DIR / source_name
        destination = output / f"{key}.html"
        destination.write_text(render(source, title, key), encoding="utf-8")
        print(f"wrote {destination}")

    for name in LEGACY_PAGES:
        destination = output / f"{name}.html"
        destination.write_text(
            REDIRECT_TEMPLATE.format(target="api/module/fun.html"),
            encoding="utf-8",
        )
        print(f"wrote {destination}")

    shutil.copyfile(DOC_DIR / "logo.png", output / "logo.png")
    shutil.copyfile(DOC_DIR / "site.css", output / "site.css")
    print(f"wrote {output / 'logo.png'}")
    print(f"wrote {output / 'site.css'}")


if __name__ == "__main__":
    main()
