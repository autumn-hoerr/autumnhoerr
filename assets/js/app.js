// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", ({detail}) => {
  topbar.show(300)
  rememberFocus(detail.kind)
})
window.addEventListener("phx:page-loading-stop", ({detail}) => {
  topbar.hide()
  manageNavigationFocus(detail.kind)
})

// LiveView swaps content without a page load, so screen readers and keyboard
// users get no cue that anything changed. Mimic a page load when navigating
// to a new view, and announce in-place updates (pagination, newer/older).
let focusAfterMount = false
let focusedIdBeforePatch = null

function rememberFocus(kind) {
  if (kind === "patch") focusedIdBeforePatch = document.activeElement?.id || null
}

function manageNavigationFocus(kind) {
  if (kind === "redirect") {
    // the old view is gone at this point; the new one fires "initial" once mounted
    focusAfterMount = true
    return
  }

  const main = document.getElementById("main")
  if (!main) return

  if (kind === "initial" && focusAfterMount) {
    focusAfterMount = false
    main.focus({preventScroll: true})
  } else if (kind === "patch") {
    restoreFocus(main)
    // the title may not have updated yet, so views can supply the message:
    // data-route-announce="message", or an empty attribute to read the element's text
    const el = main.querySelector("[data-route-announce]")
    announce(el?.dataset.routeAnnounce || el?.textContent.trim() || document.title)
  }
}

// keep focus on e.g. the "Older" link so it can be pressed again; if the
// update replaced it, refocus it by id, or fall back to the main content
function restoreFocus(main) {
  if (document.activeElement && document.activeElement !== document.body) return
  const previous = focusedIdBeforePatch && document.getElementById(focusedIdBeforePatch)
  ;(previous || main).focus({preventScroll: true})
}

function announce(message) {
  const region = document.getElementById("route-announcer")
  if (!region) return
  region.textContent = ""
  // a separate frame so identical consecutive messages are re-announced
  requestAnimationFrame(() => { region.textContent = message })
}

liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

