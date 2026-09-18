// Serves bootstrap.sh at init.jaxon.dev so `curl init.jaxon.dev | bash` works
// with no flags: no redirect to follow, correct content type, any path.
// Browsers get a page showing the command instead of a file download.

const RAW = "https://raw.githubusercontent.com/JaxonWright/dotfiles/master/bootstrap.sh";
const CMD = "curl init.jaxon.dev | bash";

// Mirrors the flags in bootstrap.sh's usage text.
const OPTS = [
  ["--minimal", "Dotfiles only. Skips apps and plugins."],
  ["--no-apps", "Skips install-apps.sh."],
  ["--no-plugins", "Skips install-plugins.sh."],
  ["--dir PATH", "Clones somewhere other than ~/dotfiles."],
];

export default {
  async fetch(request) {
    const wantsHtml = (request.headers.get("accept") || "").includes("text/html");

    if (wantsHtml) {
      return new Response(page(), {
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    }

    const upstream = await fetch(RAW, { cf: { cacheTtl: 60 } });
    if (!upstream.ok) {
      // Non-zero exit and nothing for bash to run.
      return new Response(`echo "bootstrap unavailable (upstream ${upstream.status})" >&2; exit 1\n`, {
        status: 502,
        headers: { "content-type": "text/plain; charset=utf-8" },
      });
    }

    return new Response(upstream.body, {
      headers: {
        "content-type": "text/plain; charset=utf-8",
        "cache-control": "no-cache",
      },
    });
  },
};

function page() {
  const opts = OPTS.map(
    ([flag, desc]) => `    <dt><code class="flag">${flag}</code></dt>
    <dd>${desc}</dd>`,
  ).join("\n");

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>init.jaxon.dev</title>
<style>
  :root { color-scheme: light dark; }
  body {
    margin: 0; min-height: 100vh; display: grid; place-items: center;
    font: 16px/1.5 ui-sans-serif, system-ui, sans-serif;
    background: #0f1115; color: #e6e8ee;
  }
  main { padding: 48px 16px; width: 100%; max-width: 640px; box-sizing: border-box; text-align: center; }
  h1 { font-size: 1rem; font-weight: 500; opacity: .7; margin: 0 0 12px; }
  h2 {
    font-size: .75rem; font-weight: 500; letter-spacing: .08em; text-transform: uppercase;
    opacity: .4; margin: 40px 0 14px; text-align: left;
  }
  main > code { margin-top: 16px; }
  code {
    display: block; padding: 16px 20px; border-radius: 10px;
    background: #191c24; border: 1px solid #2a2f3a;
    font: 15px/1.4 ui-monospace, SFMono-Regular, Menlo, monospace;
    overflow-x: auto; white-space: nowrap;
  }
  dl {
    margin: 0; text-align: left;
    display: grid; grid-template-columns: max-content 1fr; gap: 10px 18px; align-items: baseline;
  }
  dd { margin: 0; opacity: .6; font-size: .9rem; }
  code.flag {
    display: inline-block; padding: 4px 9px; border-radius: 6px;
    font-size: 13.5px; white-space: nowrap;
  }
  .usage { margin-top: 16px; font-size: .85rem; opacity: .45; text-align: left; }
  .usage code { display: inline; padding: 0; border: 0; background: none; font-size: 13.5px; opacity: .8; }
  p { opacity: .55; font-size: .85rem; margin: 12px 0 0; }
  a { color: inherit; }
  @media (max-width: 480px) {
    dl { grid-template-columns: 1fr; gap: 4px; }
    dd { margin-bottom: 10px; }
  }
</style>
</head>
<body>
<main>
  <h1>Omarchy, Jaxon's Version</h1>
  <p>In one command, take a fresh Omarchy machine and make it be just how Jaxon likes it.</p>
  <code>${CMD}</code>

  <h2>Options</h2>
  <dl>
${opts}
  </dl>
  <p class="usage">Pass them after <code>-s --</code>, like <code>${CMD} -s -- --minimal</code></p>

  <p><a href="https://github.com/JaxonWright/dotfiles">JaxonWright/dotfiles</a></p>
</main>
</body>
</html>`;
}
