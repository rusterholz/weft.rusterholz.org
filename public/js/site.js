// The site's one script, for its chrome only: the examples run on htmx alone.
// Registered on ApplicationPage; docs/development.md, "The Site's One Script",
// says what it does and why it is a script at all.
//
// It is here because weft does not fit this need yet. Weft 0.2 has no hook for
// what served a request, so the site works that out itself (SiteData::HandledBy,
// in the Weft-Site-Handled header) and shows it from here. Weft is growing one:
// request ids are planned for v0.3, and middleware around renders and actions
// is on its roadmap. Revisit this file when they land.
//
// Everything it drives is rendered hidden and marked data-reveal, so without the
// script nothing on the page promises what only the script can do.
(function () {
  "use strict";

  var HANDLED = "Weft-Site-Handled";
  var started = new WeakMap();

  document.querySelectorAll("[data-reveal]").forEach(function (element) {
    element.hidden = false;
  });

  document.addEventListener("htmx:beforeRequest", function (event) {
    started.set(event.detail.xhr, performance.now());
  });

  document.addEventListener("htmx:afterRequest", function (event) {
    var xhr = event.detail.xhr;
    showRequest(event.detail, Math.round(performance.now() - started.get(xhr)));
    light(xhr.getResponseHeader(HANDLED));
  });

  // The bench's line: the last request, as the browser sent it.
  function showRequest(detail, ms) {
    var line = document.querySelector(".bench-request");
    if (!line) return;

    var status = detail.xhr.status || "no response";
    var text = detail.requestConfig.verb.toUpperCase() + " " + detail.pathInfo.finalRequestPath +
      " · " + status + " · " + ms + " ms";
    line.textContent = text;
    line.title = text;
  }

  // The margin's light: the declaration of the action that answered, or the
  // block of the component that rendered. It stays until the next request.
  function light(handled) {
    document.querySelectorAll(".declarations .lit").forEach(function (element) {
      element.classList.remove("lit");
    });
    if (!handled) return;

    var name = CSS.escape(handled);
    var target = document.querySelector('.declarations [data-handles="' + name + '"]') ||
      document.querySelector('.declarations [data-component="' + name + '"]');
    if (target) target.classList.add("lit");
  }
})();
