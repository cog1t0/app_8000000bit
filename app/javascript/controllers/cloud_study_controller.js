import { Controller } from "@hotwired/stimulus"

// A scroll-position study, independent of the approved, once-only logo story.
// No continuous loop, scroll interception, timers, or layout animation.
export default class extends Controller {
  static targets = ["cloud", "thread"]
  static values = { side: String }

  connect() {
    this.motionPreference = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.schedule = () => {
      if (this.frame || !this.nearViewport || this.motionPreference.matches) return
      this.frame = requestAnimationFrame(() => {
        this.frame = null
        this.update()
      })
    }
    this.motionChanged = () => {
      cancelAnimationFrame(this.frame)
      this.frame = null
      this.update()
    }
    this.observer = new IntersectionObserver(([entry]) => {
      this.nearViewport = entry.isIntersecting
      this.schedule()
    }, { rootMargin: "200px 0px" })
    this.observer.observe(this.element)
    window.addEventListener("scroll", this.schedule, { passive: true })
    window.addEventListener("resize", this.schedule, { passive: true })
    this.motionPreference.addEventListener("change", this.motionChanged)
    this.update()
  }

  disconnect() {
    cancelAnimationFrame(this.frame)
    this.observer.disconnect()
    window.removeEventListener("scroll", this.schedule)
    window.removeEventListener("resize", this.schedule)
    this.motionPreference.removeEventListener("change", this.motionChanged)
  }

  update() {
    const progress = this.motionPreference.matches ? 1 : Math.max(0, Math.min(1,
      (window.innerHeight * 0.92 - this.element.getBoundingClientRect().top) / (window.innerHeight * 0.5)
    ))
    // Accelerate the first appearance, then let it come to rest without bounce.
    const eased = 1 - Math.pow(1 - progress, 3)
    const direction = this.sideValue === "right" ? 1 : -1
    this.cloudTarget.style.transform = `translateX(${direction * (104 - eased * 86)}%)`
    this.cloudTarget.style.opacity = Math.min(1, progress * 5)
    this.threadTarget.style.transform = `scaleX(${Math.max(0.001, eased)})`
    this.threadTarget.style.opacity = Math.min(0.65, progress * 1.3)
  }
}
