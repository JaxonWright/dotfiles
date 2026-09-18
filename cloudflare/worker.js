// Serves bootstrap.sh at init.jaxon.dev so `curl init.jaxon.dev | bash` works
// with no flags: no redirect to follow, correct content type, any path.
// Browsers get a page showing the command instead of a file download.

const RAW = "https://raw.githubusercontent.com/JaxonWright/dotfiles/master/bootstrap.sh";
const CMD = "curl init.jaxon.dev | bash";

// The Omarchy icon, traced off the 15x15 pixel grid of /usr/share/omarchy/icon.png.
const LOGO = `<svg class="logo" viewBox="0 0 15 15" width="60" height="60"
  fill="currentColor" shape-rendering="crispEdges" role="img" aria-label="Omarchy">
  <path d="M0 0h15v1h-15zM0 1h1v14h-1zM7 1h1v2h-1zM14 1h1v14h-1zM2 2h5v1h-5zM11 2h2v1h-2zM2 3h1v10h-1zM12 3h1v10h-1zM1 7h1v1h-1zM3 12h9v1h-9zM7 13h1v2h-1zM1 14h6v1h-6zM9 14h5v1h-5z"/>
</svg>`;

// The JW mark, from jaxon.dev/assets/img/branding/favicon.svg.
const JW = `<svg class="logo jw" viewBox="0 0 1185 538" height="34"
  fill="currentColor" role="img" aria-label="Jaxon Wright">
  <path d="M359.5 358.5V538H180V358.5zm179 0V538H359V358.5zm0-179V359H359V179.5zm0-179V180H359V.5zM358 179.2h179.5v179.5H358zm0 179h179.5v179.5H358zm-179 0h179.5v179.5H179zm-179 0h179.5v179.5H0zm932.5.3V538H753V358.5zm-179 0V538H574V358.5zm0-179V359H574V179.5zm0-179V180H574V.5zm36 358V538H610V358.5zm179 0V538H789V358.5zm0-179V359H789V179.5zm0-179V180H789V.5zm37 358V538H826V358.5zm179 0V538H1005V358.5zm0-179V359H1005V179.5zm0-179V180H1005V.5z"/>
</svg>`;

// Mirrors the flags in bootstrap.sh's usage text.
const OPTS = [
  ["--minimal", "Dotfiles only. Skips apps and plugins."],
  ["--no-apps", "Skips install-apps.sh."],
  ["--no-plugins", "Skips install-plugins.sh."],
  ["--dir PATH", "Clones somewhere other than ~/git/dotfiles."],
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
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&display=swap">
<style>
  :root {
    color-scheme: dark;
    /* JetBrains Mono is what Omarchy's terminals ship with. The fallbacks are
       the locally installed terminal fonts, then the system default. */
    --mono: "JetBrains Mono", "JetBrainsMono Nerd Font", "CaskaydiaMono Nerd Font",
            ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    --text: #c9c9c9;
  }
  body {
    margin: 0; min-height: 100vh; display: grid; place-items: center;
    font: 15px/1.6 var(--mono);
    background: #000; color: var(--text);
  }
  main { padding: 48px 16px; width: 100%; max-width: 640px; box-sizing: border-box; text-align: center; }
  .logos {
    display: flex; align-items: center; justify-content: center;
    gap: 18px; margin-bottom: 22px;
  }
  .logo { color: #fff; display: block; }
  .logo.jw { width: auto; }
  .times { font-size: 20px; opacity: .45; line-height: 1; }
  h1 { font: inherit; opacity: .85; margin: 0 0 12px; }
  h2 {
    font: inherit; font-size: .8rem; letter-spacing: .1em; text-transform: uppercase;
    opacity: .35; margin: 40px 0 14px; text-align: left;
  }
  .cmd {
    position: relative; display: block; width: 100%; box-sizing: border-box;
    margin-top: 16px; padding: 16px 20px; border-radius: 8px;
    background: #0a0a0a; border: 1px solid #1f1f1f; color: #e0e0e0;
    font: 15px/1.4 var(--mono); text-align: center; cursor: pointer;
    -webkit-appearance: none; appearance: none;
    transition: border-color .15s, background-color .15s;
  }
  .cmd:hover { background: #0e0e0e; border-color: #333; }
  .cmd:focus-visible { outline: 1px solid #555; outline-offset: 2px; }
  .cmd code {
    display: inline; padding: 0; border: 0; background: none;
    font: inherit; color: inherit;
  }
  .state {
    position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
    font-size: 10px; letter-spacing: .1em; text-transform: uppercase; opacity: .3;
  }
  .cmd.copied .state { opacity: .75; color: #fff; }
  code {
    display: block; padding: 16px 20px; border-radius: 8px;
    background: #0a0a0a; border: 1px solid #1f1f1f;
    font: 15px/1.4 var(--mono); color: #e0e0e0;
    overflow-x: auto; white-space: nowrap;
  }
  dl {
    margin: 0; text-align: left;
    display: grid; grid-template-columns: max-content 1fr; gap: 10px 18px; align-items: baseline;
  }
  dd { margin: 0; opacity: .5; font-size: .85rem; }
  code.flag {
    display: inline-block; padding: 4px 9px; border-radius: 5px;
    font-size: 13px; white-space: nowrap;
    /* The base code rule sets overflow-x, which would make this inline-block
       baseline on its bottom edge and drop the description below the flag. */
    overflow: visible;
  }
  .usage { margin-top: 16px; font-size: .8rem; opacity: .35; text-align: left; }
  .usage code { display: inline; padding: 0; border: 0; background: none; color: inherit; font-size: 13px; }
  p { opacity: .5; font-size: .85rem; margin: 12px 0 0; }
  a { color: inherit; }
  @media (max-width: 520px) { .state { display: none; } }
  @media (max-width: 480px) {
    dl { grid-template-columns: 1fr; gap: 4px; }
    dd { margin-bottom: 10px; }
  }
</style>
</head>
<body>
<main>
  <div class="logos">${LOGO}<span class="times">&times;</span>${JW}</div>
  <h1>Omarchy, Jaxon's Version</h1>
  <p>In one command, take a fresh Omarchy machine and make it be just how Jaxon likes it.</p>
  <button type="button" class="cmd" id="cmd" data-cmd="${CMD}"
          aria-label="Copy command to clipboard"><code>${CMD}</code><span class="state" id="state">copy</span></button>

  <h2>Options</h2>
  <dl>
${opts}
  </dl>
  <p class="usage">Pass them after <code>-s --</code>, like <code>${CMD} -s -- --minimal</code></p>

  <p><a href="https://github.com/JaxonWright/dotfiles">JaxonWright/dotfiles</a></p>
</main>
<script>
(function () {
  var btn = document.getElementById("cmd");
  var state = document.getElementById("state");
  var text = btn.getAttribute("data-cmd");
  var timer;

  btn.addEventListener("click", function () {
    write(text).then(function (ok) {
      state.textContent = ok ? "copied" : "copy failed";
      btn.classList.add("copied");
      clearTimeout(timer);
      timer = setTimeout(function () {
        state.textContent = "copy";
        btn.classList.remove("copied");
      }, 1600);
    });
  });

  function write(s) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(s).then(
        function () { return true; },
        function () { return legacy(s); }
      );
    }
    return Promise.resolve(legacy(s));
  }

  // http:// and older browsers never get the async clipboard API.
  function legacy(s) {
    try {
      var ta = document.createElement("textarea");
      ta.value = s;
      ta.setAttribute("readonly", "");
      ta.style.position = "fixed";
      ta.style.top = "-1000px";
      document.body.appendChild(ta);
      ta.select();
      var ok = document.execCommand("copy");
      document.body.removeChild(ta);
      return ok;
    } catch (e) {
      return false;
    }
  }
})();
</script>
</body>
</html>`;
}
