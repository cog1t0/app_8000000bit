import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reveal", "menu"]

  connect() {
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches

    if (this.reducedMotion) {
      this.revealTargets.forEach((element) => element.classList.add("is-visible"))
      return
    }

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return

          entry.target.classList.add("is-visible")
          this.observer.unobserve(entry.target)
        })
      },
      { rootMargin: "0px 0px -12% 0px", threshold: 0.12 }
    )

    this.revealTargets.forEach((element) => this.observer.observe(element))
  }

  disconnect() {
    this.observer?.disconnect()
  }

  closeMenu(event) {
    if (!event.target.closest("a") || !this.hasMenuTarget) return

    this.menuTarget.removeAttribute("open")
  }
}
