import { Controller } from "@hotwired/stimulus"

// Give the leader time to look and think before the action clock begins.
// Story tracks get this lead-in; explicit intro tracks use absolute seconds.
const LEAD_IN = 3
const DURATION = 20000
const EASE = "cubic-bezier(0.45, 0, 0.25, 1)"
const REST = "translateY(0px) rotate(0deg) scale(1, 1)"
const CONTROL_ICONS = {
  playing: "M9 5 v14 M15 5 v14",
  paused: "M8 5 l11 7 -11 7 Z",
  finished: "M4 10 a8 8 0 1 1 1 7 M4 4 v6 h6"
}
// A quick ripple (75 ms per neighbour), followed by independent personalities.
const FRIENDS = [
  { type: "eager", waking: 2.65, cheering: 4.1, beat: 0.53, reaction: 8.87, applause: 9.12, clap: 0.31 },
  { type: "steady", waking: 2.725, cheering: 4.3, beat: 1.15, reaction: 8.98, applause: 9.25, clap: 0.4 },
  { type: "detached", waking: 2.8, reaction: 9.15, applause: 9.42, clap: 0.39 },
  { type: "eager", waking: 2.875, cheering: 4.18, beat: 0.66, reaction: 8.93, applause: 9.18, clap: 0.35 },
  { type: "steady", waking: 2.95, cheering: 4.4, beat: 1.3, reaction: 9.04, applause: 9.31, clap: 0.43 },
  { type: "detached", waking: 3.025, reaction: 9.28, applause: 9.55, clap: 0.36 }
]

export default class extends Controller {
  static targets = [
    "character", "body", "face", "eyes", "pupils", "gestures", "leftArm",
    "rightArm", "question", "surprise", "red", "boundary", "burst",
    "wordmark", "numericName", "reading", "determination", "idea", "mouth", "openMouth",
    "controls", "toggle", "icon", "skip", "status"
  ]

  connect() {
    this.animations = []
    this.inView = false
    this.userPaused = false
    this.motionPreference = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.onMotionChange = () => this.motionChanged()
    this.motionPreference.addEventListener("change", this.onMotionChange)
    this.controlsTarget.hidden = this.motionPreference.matches

    this.observer = new IntersectionObserver(([entry]) => {
      this.inView = entry.isIntersecting
      if (this.inView && !this.hasPlayed && !this.motionPreference.matches) {
        this.play()
      } else {
        this.syncPlayback()
      }
    }, { threshold: 0.15 })
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
    this.motionPreference.removeEventListener("change", this.onMotionChange)
    this.cancelAnimations()
  }

  motionChanged() {
    this.finish()
    this.controlsTarget.hidden = this.motionPreference.matches
  }

  play() {
    if (this.motionPreference.matches) return
    this.cancelAnimations()
    this.hasPlayed = true
    this.userPaused = false
    this.element.dataset.logoStoryState = "playing"
    this.skipTarget.hidden = false
    this.statusTarget.textContent = "ロゴのアニメーションを再生しています。"

    this.animateLeader()
    this.animateFriends()
    this.animateBoundary()
    this.track(this.redTarget, "opacity", [[0, 0], [8.8, 0], [9.25, 1], [14, 1]])
    this.track(this.redTarget, "transform", [[0, "scaleY(1)"], [8.8, "scaleY(1)"], [9.05, "scaleY(1.07)"], [9.45, "scaleY(1)"], [14, "scaleY(1)"]])
    this.appear(this.burstTarget, 8.7, 9.1, 9.55)
    this.track(this.burstTarget, "transform", [[0, "translateY(0px)"], [8.7, "translateY(0px)"], [9.55, "translateY(-12px)"], [14, "translateY(-12px)"]])
    this.track(this.wordmarkTarget, "opacity", [[0, 0], [11.9, 0], [12.8, 1], [14, 1]])
    // Let the seven blocks resolve into their written name before its reading.
    this.track(this.numericNameTarget, "opacity", [[0, 0], [15.3, 0], [15.85, 1], [17.6, 1], [18.05, 0], [20, 0]], { leadIn: 0 })
    this.track(this.readingTarget, "opacity", [[0, 0], [18.1, 0], [18.7, 1], [20, 1]], { leadIn: 0 })

    // Align start times after constructing all tracks, including delayed faces.
    this.syncPlayback()
    this.animations.at(-1).finished.then(() => this.finish()).catch(() => {})
  }

  animateLeader() {
    const body = [[0, "scale(1, 1)"], [1.7, "scale(1, 1)"]]
    const face = [[0, "translateY(0px)"], [1.7, "translateY(0px)"]]
    // Each attempt has anticipation, contact with the boundary, and a recoil.
    for (const [time, strength] of [[2, 0.18], [3.55, 0.3], [5.05, 0.46], [6.35, 0.36], [7.15, 0.52]]) {
      body.push(
        [time, "scale(1.08, 0.87)"],
        [time + 0.25, `scale(0.96, ${1 + strength})`],
        [time + 0.42, `scale(0.99, ${1 + strength * 0.85})`],
        [time + 0.65, "scale(1, 1)"]
      )
      face.push(
        [time, "translateY(5px)"],
        [time + 0.25, `translateY(${-56.257812 * strength}px)`],
        [time + 0.42, `translateY(${-56.257812 * strength * 0.85}px)`],
        [time + 0.65, "translateY(0px)"]
      )
    }
    body.push([8.25, "scale(1.13, 0.7)"], [8.82, "scale(0.97, 2.13)"], [9.15, "scale(1, 2)"], [9.65, "scale(1, 2)"], [10.35, "scale(1, 1)"], [14, "scale(1, 1)"])
    face.push([8.25, "translateY(12px)"], [8.82, "translateY(-64px)"], [9.15, "translateY(-56.257812px)"], [14, "translateY(-56.257812px)"])
    this.track(this.bodyTargets[0], "transform", body)
    this.track(this.faceTargets[0], "transform", face)
    this.animateIdea()
    this.appear(this.determinationTarget, 5.8, 8.7, 9.1)
  }

  animateIdea() {
    const absolute = { leadIn: 0 }
    this.track(this.faceTargets[0], "opacity", [[0, 0], [0.85, 0], [1.12, 1], [14.65, 1], [15.3, 0], [17, 0]], absolute)
    // A long, still upward gaze reads as a thought, before any physical effort.
    this.track(this.pupilsTargets[0], "transform", [
      [0, "translate(0px, 0px)"], [1.35, "translate(0px, 0px)"],
      [1.95, "translate(0px, -3.5px)"], [11.8, "translate(0px, -3.5px)"],
      [12.4, "translate(2px, 0px)"], [17, "translate(2px, 0px)"]
    ], absolute)
    this.track(this.eyesTargets[0], "transform", [
      [0, "scaleY(1)"], [2.65, "scaleY(1)"], [2.77, "scaleY(0.12)"],
      [2.97, "scaleY(1)"], [3.5, "scaleY(1)"], [3.72, "scaleY(1.23)"],
      [4.35, "scaleY(1)"], [13.5, "scaleY(1)"], [13.58, "scaleY(0.12)"],
      [13.7, "scaleY(1)"], [17, "scaleY(1)"]
    ], absolute)
    this.track(this.mouthTargets[0], "transform", [[0, "scaleY(0.12)"], [3.5, "scaleY(0.12)"], [4.05, "scaleY(1)"], [17, "scaleY(1)"]], absolute)
    this.track(this.ideaTarget, "opacity", [[0, 0], [3.5, 0], [3.7, 1], [4.3, 1], [4.7, 0], [17, 0]], absolute)
    this.track(this.ideaTarget, "transform", [[0, "translateY(3px) scale(0.92)"], [3.5, "translateY(3px) scale(0.92)"], [3.8, "translateY(0px) scale(1)"], [17, "translateY(0px) scale(1)"]], absolute)
  }

  animateFriends() {
    FRIENDS.forEach((friend, position) => {
      const index = position + 1
      this.characterTargets[index].dataset.personality = friend.type
      this.appear(this.faceTargets[index], friend.waking, 11.9 + index * 0.025, 12.45 + index * 0.025)
      this.animateFriendExpression(index, friend)
      this.track(this.characterTargets[index], "transform", this.friendBodyFrames(friend, index))
      this.appear(this.gesturesTargets[index], friend.cheering ?? friend.applause - 0.24, 11.85, 12.35)
      this.track(this.leftArmTargets[index], "transform", this.friendArmFrames(friend, "left"))
      this.track(this.rightArmTargets[index], "transform", this.friendArmFrames(friend, "right"))
    })

    this.questionTargets.forEach((element, index) => this.appear(element, 3.02 + index * 0.08, 4.05 + index * 0.08, 4.4 + index * 0.08))
    this.surpriseTargets.forEach((element, index) => this.appear(element, 5.65 + index * 0.15, 6.65, 7))
  }

  animateFriendExpression(index, friend) {
    const { type, waking, reaction, applause } = friend
    const detached = type === "detached"
    const restingEyes = detached ? (index === 6 ? 0.32 : 0.52) : 1
    const eyes = (scale) => `scaleY(${scale})`
    this.track(this.eyesTargets[index], "transform", [
      [0, eyes(1)], [waking + 0.28, eyes(1)], [waking + 0.4, eyes(0.12)],
      [waking + 0.65, eyes(restingEyes)], [reaction - 0.12, eyes(restingEyes)],
      [reaction + 0.14, eyes(detached ? 1.35 : 1.1)],
      [applause + 0.15, eyes(1)], [14, eyes(1)]
    ])
    this.track(this.pupilsTargets[index], "transform", [
      [0, "translate(0px, 0px)"], [waking + 0.35, "translate(0px, 0px)"],
      [waking + 0.85, detached ? "translate(3px, 1px)" : "translate(-3px, 0px)"],
      [reaction - 0.12, detached ? "translate(3px, 1px)" : "translate(-3px, 0px)"],
      [reaction + 0.2, "translate(-3px, -2px)"], [14, "translate(-3px, -2px)"]
    ])

    if (detached) {
      this.track(this.mouthTargets[index], "transform", [[0, "scaleY(0.1)"], [reaction, "scaleY(0.1)"], [applause, "scaleY(1)"], [14, "scaleY(1)"]])
      this.appear(this.openMouthTargets[index], reaction, reaction + 0.25, applause)
    } else if (type === "eager") {
      this.appear(this.openMouthTargets[index], friend.cheering + 0.1, 8.45, 8.7)
      this.track(this.mouthTargets[index], "opacity", [[0, 1], [friend.cheering, 1], [friend.cheering + 0.2, 0], [8.45, 0], [8.7, 1], [14, 1]])
    }
  }

  friendBodyFrames(friend, index) {
    const { type, waking, cheering, beat, reaction, applause } = friend
    const frames = [[0, REST], [waking, REST], [waking + 0.3, "translateY(3px) rotate(-3deg) scale(1, 0.94)"], [waking + 0.7, REST]]

    if (type === "detached") {
      const slouch = `translateY(4px) rotate(${index === 6 ? 6 : 3}deg) scale(1, 0.94)`
      frames.push([waking + 1.1, slouch], [reaction - 0.12, slouch])
    } else {
      frames.push([cheering - 0.08, REST])
      let cycle = 0
      for (let time = cheering; time + beat * 0.8 < 8.45; time += beat) {
        if (type === "eager") {
          frames.push(
            [time, `translateY(6px) rotate(${cycle % 2 ? 4 : -7}deg) scale(1.07, 0.86)`],
            [time + beat * 0.35, `translateY(1px) rotate(${cycle % 2 ? -5 : -2}deg) scale(0.98, 1)`],
            [time + beat * 0.8, REST]
          )
        } else {
          frames.push([time, "translateY(2px) rotate(-2deg) scale(1, 0.97)"], [time + beat * 0.7, REST])
        }
        cycle++
      }
      frames.push([8.65, REST], [reaction - 0.04, REST])
    }

    frames.push([reaction + 0.16, `translateY(2px) rotate(${type === "detached" ? -7 : -4}deg) scale(1, 0.94)`], [applause, REST], [14, REST])
    return frames
  }

  friendArmFrames(friend, side) {
    const { type, cheering, beat, reaction, applause, clap } = friend
    const left = side === "left"
    const angle = (degrees) => `rotate(${left ? degrees : -degrees}deg)`
    const relaxed = angle(-150)
    const frames = [[0, relaxed]]

    if (type === "eager") {
      frames.push([cheering, relaxed])
      for (let time = cheering + 0.16; time + beat * 0.7 < 8.5; time += beat) {
        frames.push([time, angle(left ? -12 : 36)], [time + beat * 0.35, angle(left ? 38 : -10)], [time + beat * 0.7, angle(12)])
      }
      frames.push([8.7, angle(20)])
    } else if (type === "steady" && left) {
      // A slow, one-handed wave, with the other arm resting by the body.
      frames.push([cheering, relaxed])
      for (let time = cheering + 0.2; time + beat * 0.65 < 8.5; time += beat) {
        frames.push([time, angle(8)], [time + beat * 0.35, angle(26)], [time + beat * 0.65, angle(8)])
      }
      frames.push([8.7, angle(8)])
    } else {
      frames.push([reaction, relaxed])
    }

    frames.push([applause - 0.08, angle(8)])
    // Every personality joins in. The late arrivals get a moment to register
    // the breakthrough, then their own clap rhythm within the same ending.
    for (let time = applause; time + clap * 0.52 < 11.82; time += clap) {
      frames.push([time, angle(56)], [time + clap * 0.52, angle(8)])
    }
    frames.push([12.15, angle(0)], [14, angle(0)])
    return frames
  }

  animateBoundary() {
    // Only this short SVG path repaints. All characters use transform/opacity.
    // Browsers without CSS path interpolation retain the straight boundary.
    if (!CSS.supports("d", 'path("M0 0 L1 1")')) return
    const boundary = (rise = 0) => `path("M2.728 57 C26 57 32 ${57 - rise} 41 ${57 - rise} C52 ${57 - rise} 86 ${57 - rise} 97 ${57 - rise} C106 ${57 - rise} 110 57 125 57 L679.273 57")`
    const frames = [[0, boundary()], [2, boundary()]]
    for (const [time, strength] of [[2, 0.18], [3.55, 0.3], [5.05, 0.46], [6.35, 0.36], [7.15, 0.52]]) {
      if (time !== 2) frames.push([time, boundary()])
      frames.push([time + 0.25, boundary(56.257812 * strength)], [time + 0.42, boundary(56.257812 * strength * 0.85)], [time + 0.65, boundary()])
    }
    frames.push([8.25, boundary()], [8.62, boundary(38)], [8.82, boundary(-6)], [9.05, boundary(3)], [9.4, boundary()], [14, boundary()])
    this.track(this.boundaryTarget, "d", frames)
  }

  appear(element, start, end, hiddenAt) {
    this.track(element, "opacity", [[0, 0], [start, 0], [start + 0.22, 1], [end, 1], [hiddenAt, 0], [14, 0]])
  }

  track(element, property, frames, { leadIn = LEAD_IN } = {}) {
    const animation = element.animate(frames.map(([seconds, value]) => ({
      offset: (seconds === 0 ? 0 : seconds + leadIn) * 1000 / DURATION,
      [property]: String(value),
      easing: EASE
    })), { duration: DURATION, fill: "both" })
    animation.pause()
    animation.currentTime = 0
    this.animations.push(animation)
  }

  toggle() {
    if (this.element.dataset.logoStoryState === "finished") {
      this.play()
    } else {
      this.userPaused = !this.userPaused
      this.syncPlayback()
      this.statusTarget.textContent = this.userPaused ? "アニメーションを一時停止しました。" : "アニメーションを再開しました。"
    }
  }

  syncPlayback() {
    if (!this.animations.length || this.element.dataset.logoStoryState === "finished") return
    const playing = this.inView && !document.hidden && !this.userPaused
    const currentTime = this.animations[0].currentTime || 0
    const startTime = document.timeline.currentTime - currentTime
    this.animations.forEach((animation) => {
      if (playing) {
        animation.play()
        animation.startTime = startTime
      } else {
        animation.pause()
        animation.currentTime = currentTime
      }
    })
    this.element.dataset.logoStoryState = playing ? "playing" : "paused"
    this.iconTarget.setAttribute("d", CONTROL_ICONS[playing ? "playing" : "paused"])
    this.toggleTarget.setAttribute("aria-label", playing ? "アニメーションを一時停止" : "アニメーションを再開")
  }

  skip() {
    this.finish()
    this.toggleTarget.focus({ preventScroll: true })
  }

  finish() {
    this.cancelAnimations()
    this.element.dataset.logoStoryState = "finished"
    this.iconTarget.setAttribute("d", CONTROL_ICONS.finished)
    this.toggleTarget.setAttribute("aria-label", "アニメーションをもう一度再生")
    this.skipTarget.hidden = true
    this.statusTarget.textContent = "8000000bit、ヤオヨロズビットのロゴになりました。"
  }

  cancelAnimations() {
    this.animations.forEach((animation) => animation.cancel())
    this.animations = []
  }
}
