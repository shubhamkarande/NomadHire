import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

gsap.registerPlugin(ScrollTrigger)

export function fadeInUp(element: HTMLElement, delay = 0) {
  gsap.fromTo(element, 
    { 
      y: 30, 
      opacity: 0 
    },
    { 
      y: 0, 
      opacity: 1, 
      duration: 0.8, 
      delay,
      ease: "power2.out"
    }
  )
}

export function staggerFadeIn(elements: NodeListOf<HTMLElement> | HTMLElement[], delay = 0.1) {
  gsap.fromTo(elements,
    {
      y: 20,
      opacity: 0
    },
    {
      y: 0,
      opacity: 1,
      duration: 0.6,
      stagger: delay,
      ease: "power2.out"
    }
  )
}

export function scaleOnHover(element: HTMLElement) {
  element.addEventListener('mouseenter', () => {
    gsap.to(element, { scale: 1.05, duration: 0.3, ease: "power2.out" })
  })
  
  element.addEventListener('mouseleave', () => {
    gsap.to(element, { scale: 1, duration: 0.3, ease: "power2.out" })
  })
}

export function parallaxScroll(element: HTMLElement, speed = 0.5) {
  gsap.to(element, {
    yPercent: -50 * speed,
    ease: "none",
    scrollTrigger: {
      trigger: element,
      start: "top bottom",
      end: "bottom top",
      scrub: true
    }
  })
}

export function slideInFromLeft(element: HTMLElement, delay = 0) {
  gsap.fromTo(element,
    {
      x: -100,
      opacity: 0
    },
    {
      x: 0,
      opacity: 1,
      duration: 0.8,
      delay,
      ease: "power2.out"
    }
  )
}

export function slideInFromRight(element: HTMLElement, delay = 0) {
  gsap.fromTo(element,
    {
      x: 100,
      opacity: 0
    },
    {
      x: 0,
      opacity: 1,
      duration: 0.8,
      delay,
      ease: "power2.out"
    }
  )
}

export function countUp(element: HTMLElement, start: number, end: number, duration = 2) {
  const obj = { val: start }
  gsap.to(obj, {
    val: end,
    duration,
    onUpdate: () => {
      element.textContent = Math.round(obj.val).toString()
    },
    ease: "power2.out"
  })
}