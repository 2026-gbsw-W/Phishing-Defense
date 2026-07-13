import { useEffect, useRef } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import './LandingPage.css'

/**
 * Ported from the repo-root static index.html marketing page (see that
 * file for the original vanilla-JS version). Scroll-driven effects below
 * mirror it 1:1, but scoped to this component's own refs instead of
 * global `document.querySelector` calls, and with listener cleanup on
 * unmount since this page can mount/unmount repeatedly in the SPA.
 */
export function LandingPage() {
  const navigate = useNavigate()
  const goToSignup = () => navigate('/signup')

  const heroThreadRef = useRef<HTMLDivElement>(null)
  const flowDiagramRef = useRef<HTMLDivElement>(null)
  const flowSvgRef = useRef<SVGSVGElement>(null)
  const flowPathBgRef = useRef<SVGPathElement>(null)
  const flowPathGlowRef = useRef<SVGPathElement>(null)
  const flowBadgeRefs = useRef<(HTMLDivElement | null)[]>([])
  const flowRowRefs = useRef<(HTMLDivElement | null)[]>([])
  const cardLightRefs = useRef<(HTMLDivElement | null)[]>([])
  const flowSummaryRef = useRef<HTMLDivElement>(null)
  const ctaBannerRef = useRef<HTMLDivElement>(null)
  const footerCtaRef = useRef<HTMLDivElement>(null)
  const spineBaseRefs = useRef<(HTMLDivElement | null)[]>([])
  const spineGlowRefs = useRef<(HTMLDivElement | null)[]>([])

  // The shared design system sets `html, body, #root { height: 100% }` so
  // the fixed-viewport screens (login/dashboard/game) can use
  // `min-height: 100%` to fill exactly one screen. That rule conflicts with
  // this page, which is meant to scroll naturally far past one viewport:
  // it turns <body> into its own fixed-height, independently-scrolling box
  // instead of letting the document itself grow and the window scroll,
  // which breaks position:sticky and the scroll-position math above.
  // Override it while this page is mounted; restore on unmount so the
  // other screens keep their intended fixed-viewport layout.
  useEffect(() => {
    const html = document.documentElement
    const body = document.body
    const prevHtmlHeight = html.style.height
    const prevBodyHeight = body.style.height
    const prevBodyOverflowY = body.style.overflowY
    html.style.height = 'auto'
    body.style.height = 'auto'
    body.style.overflowY = 'visible'
    return () => {
      html.style.height = prevHtmlHeight
      body.style.height = prevBodyHeight
      body.style.overflowY = prevBodyOverflowY
    }
  }, [])

  // Scroll-reveal: fades each card in the first time it enters the viewport.
  useEffect(() => {
    const revealEls = document.querySelectorAll<HTMLElement>(
      '.flow-row, .flow-summary, .msg-card, .msg-caption, .why-tile, .thesis-block, .type-card, .footer-cta-inner'
    )
    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

    if (reduceMotion || !('IntersectionObserver' in window)) {
      revealEls.forEach((el) => el.classList.add('is-visible'))
      return
    }

    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-visible')
            io.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.15 }
    )
    revealEls.forEach((el) => io.observe(el))

    return () => io.disconnect()
  }, [])

  // Flow diagram connector: draws a curved SVG path through the .flow-badge
  // centers and reveals it (stroke-dashoffset) as the user scrolls.
  useEffect(() => {
    const svg = flowSvgRef.current
    const diagram = flowDiagramRef.current
    const bg = flowPathBgRef.current
    const glow = flowPathGlowRef.current
    const badges = flowBadgeRefs.current.filter((b): b is HTMLDivElement => b !== null)
    if (!svg || !diagram || !bg || !glow || badges.length < 2) return

    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    let len = 0

    function build() {
      if (window.innerWidth <= 720) return
      const rect = diagram!.getBoundingClientRect()
      svg!.setAttribute('width', String(rect.width))
      svg!.setAttribute('height', String(rect.height))
      svg!.setAttribute('viewBox', `0 0 ${rect.width} ${rect.height}`)

      const pts = badges.map((b) => {
        const r = b.getBoundingClientRect()
        return { x: r.left + r.width / 2 - rect.left, y: r.top + r.height / 2 - rect.top }
      })
      let d = `M ${pts[0].x.toFixed(1)} ${pts[0].y.toFixed(1)}`
      for (let i = 1; i < pts.length; i++) {
        const p0 = pts[i - 1]
        const p1 = pts[i]
        const midY = (p0.y + p1.y) / 2
        d += ` C ${p0.x.toFixed(1)} ${midY.toFixed(1)}, ${p1.x.toFixed(1)} ${midY.toFixed(1)}, ${p1.x.toFixed(1)} ${p1.y.toFixed(1)}`
      }
      bg!.setAttribute('d', d)
      glow!.setAttribute('d', d)
      // getTotalLength isn't implemented by jsdom (test environment only —
      // real browsers always support it); skip the stroke animation setup
      // rather than crash when it's unavailable.
      len = typeof glow!.getTotalLength === 'function' ? glow!.getTotalLength() : 0
      glow!.style.strokeDasharray = String(len)
      updateProgress()
    }

    function updateProgress() {
      if (!len) return
      if (reduceMotion) {
        glow!.style.strokeDashoffset = '0'
        return
      }
      const rect = diagram!.getBoundingClientRect()
      const vh = window.innerHeight
      let progress = (vh * 0.85 - rect.top) / (rect.height + vh * 0.5)
      progress = Math.max(0, Math.min(1, progress))
      glow!.style.strokeDashoffset = String(len * (1 - progress))
    }

    let ticking = false
    function onScrollOrResize() {
      if (ticking) return
      ticking = true
      requestAnimationFrame(() => {
        updateProgress()
        ticking = false
      })
    }

    window.addEventListener('scroll', onScrollOrResize, { passive: true })
    window.addEventListener('resize', build)
    build()

    return () => {
      window.removeEventListener('scroll', onScrollOrResize)
      window.removeEventListener('resize', build)
    }
  }, [])

  // Page-wide "spine": three glowing line segments running from the hero
  // down to the footer, gapped around the solid-color CTA banner. Rendered
  // as real JSX siblings (not inserted into document.body like the
  // original) — they sit first in this page's own root element, so later
  // sections still paint over them via normal DOM stacking order.
  useEffect(() => {
    const heroThread = heroThreadRef.current
    const flowDiagram = flowDiagramRef.current
    const flowSummary = flowSummaryRef.current
    const ctaBanner = ctaBannerRef.current
    const footerCta = footerCtaRef.current
    const bases = spineBaseRefs.current
    const glows = spineGlowRefs.current
    if (!heroThread || !flowDiagram || !flowSummary || !ctaBanner || !footerCta) return
    if (bases.some((b) => !b) || glows.some((g) => !g)) return

    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    const GAP = 32
    const segments = [
      { top: 0, height: 0 },
      { top: 0, height: 0 },
      { top: 0, height: 0 },
    ]

    function edgeY(el: HTMLElement, edge: 'top' | 'bottom') {
      const r = el.getBoundingClientRect()
      return (edge === 'bottom' ? r.bottom : r.top) + window.scrollY
    }

    function build() {
      const hide = window.innerWidth <= 720
      bases.forEach((base, i) => {
        base!.style.display = hide ? 'none' : ''
        glows[i]!.style.display = hide ? 'none' : ''
      })
      if (hide) return

      const ranges: [number, number][] = [
        [edgeY(heroThread!, 'top'), edgeY(flowDiagram!, 'top')],
        [edgeY(flowSummary!, 'bottom'), edgeY(ctaBanner!, 'top') - GAP],
        [edgeY(ctaBanner!, 'bottom') + GAP, edgeY(footerCta!, 'top')],
      ]
      ranges.forEach(([start, end], i) => {
        const seg = segments[i]
        seg.top = start
        seg.height = Math.max(0, end - start)
        bases[i]!.style.top = `${seg.top}px`
        bases[i]!.style.height = `${seg.height}px`
        glows[i]!.style.top = `${seg.top}px`
        glows[i]!.style.height = `${seg.height}px`
      })
      updateProgress()
    }

    function updateProgress() {
      const viewportBottomDoc = window.scrollY + window.innerHeight * 0.85
      segments.forEach((seg, i) => {
        const glow = glows[i]!
        if (!seg.height) {
          glow.style.clipPath = 'inset(0 0 100% 0)'
          return
        }
        if (reduceMotion) {
          glow.style.clipPath = 'inset(0 0 0% 0)'
          return
        }
        let progress = (viewportBottomDoc - seg.top) / seg.height
        progress = Math.max(0, Math.min(1, progress))
        glow.style.clipPath = `inset(0 0 ${(1 - progress) * 100}% 0)`
      })
    }

    let ticking = false
    function onScrollOrResize() {
      if (ticking) return
      ticking = true
      requestAnimationFrame(() => {
        updateProgress()
        ticking = false
      })
    }

    window.addEventListener('scroll', onScrollOrResize, { passive: true })
    window.addEventListener('resize', build)
    build()

    return () => {
      window.removeEventListener('scroll', onScrollOrResize)
      window.removeEventListener('resize', build)
    }
  }, [])

  // Card spotlight: highlights each .flow-row card with a soft red wash as
  // the spine's glowing point passes it, based on scroll proximity.
  useEffect(() => {
    const rows = flowRowRefs.current.filter((r): r is HTMLDivElement => r !== null)
    const lights = cardLightRefs.current
    if (!rows.length) return
    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (reduceMotion) return

    function update() {
      const lightDocY = window.scrollY + window.innerHeight * 0.85
      rows.forEach((row, i) => {
        const light = lights[i]
        if (!light) return
        const rect = row.getBoundingClientRect()
        const cardTop = rect.top + window.scrollY
        const cardCenter = cardTop + rect.height / 2
        const range = rect.height / 2 + 240
        const dist = Math.abs(lightDocY - cardCenter)
        const proximity = 1 - Math.min(dist / range, 1)
        light.style.opacity = String(proximity)
      })
    }

    let ticking = false
    function onScrollOrResize() {
      if (ticking) return
      ticking = true
      requestAnimationFrame(() => {
        update()
        ticking = false
      })
    }

    window.addEventListener('scroll', onScrollOrResize, { passive: true })
    window.addEventListener('resize', onScrollOrResize)
    update()

    return () => {
      window.removeEventListener('scroll', onScrollOrResize)
      window.removeEventListener('resize', onScrollOrResize)
    }
  }, [])

  return (
    <div className="landing-page">
      <div className="spine-base" ref={(el) => { spineBaseRefs.current[0] = el }} />
      <div className="spine-glow" ref={(el) => { spineGlowRefs.current[0] = el }} />
      <div className="spine-base" ref={(el) => { spineBaseRefs.current[1] = el }} />
      <div className="spine-glow" ref={(el) => { spineGlowRefs.current[1] = el }} />
      <div className="spine-base" ref={(el) => { spineBaseRefs.current[2] = el }} />
      <div className="spine-glow" ref={(el) => { spineGlowRefs.current[2] = el }} />

      <nav>
        <div className="wrap">
          <div className="logo">
            <span className="logo-mark"></span>피싱 디펜스
          </div>
          <div className="nav-links">
            <a href="#types">사기 유형</a>
            <a href="#flow">이용 과정</a>
            <a href="#why">통계</a>
          </div>
          <button className="cta-btn" onClick={goToSignup}>
            시작하기
          </button>
        </div>
      </nav>

      <section className="hero">
        <div className="hero-stage">
          <div className="hero-thread" ref={heroThreadRef}></div>
          <div className="phone-glow-wrap">
            <div className="hex-halo">
              <div className="hex-layer layer-3 hex-bg"></div>
              <div className="hex-layer layer-2 hex-bg"></div>
              <div className="hex-layer layer-1 hex-bg"></div>
            </div>
            <div className="glow-blob"></div>
            <div className="phone-float">
              <div className="device-frame">
                <div className="device-volume-down"></div>
                <div className="device-power"></div>
                <div className="device-screen">
                  <div className="device-reflection"></div>
                  <div className="device-island"></div>
                  <div className="device-statusbar mono">9:41</div>
                  <div className="call-screen">
                    <div className="call-top">
                      <div className="incoming-tag mono">실전 훈련 시나리오 · 검찰 사칭</div>
                      <div className="call-avatar">검</div>
                      <div className="call-name">서울중앙지검 수사관</div>
                      <div className="call-sub">발신번호 확인 불가</div>
                    </div>
                    <div className="call-actions">
                      <div className="call-action">
                        <div className="call-btn decline">
                          <svg viewBox="0 0 24 24">
                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"></path>
                          </svg>
                        </div>
                        <span className="call-action-label">거절</span>
                      </div>
                      <div className="call-action">
                        <div className="call-btn accept">
                          <svg viewBox="0 0 24 24">
                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"></path>
                          </svg>
                        </div>
                        <span className="call-action-label">훈련 시작</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="wrap hero-text-center">
          <h1 className="reveal-in delay-3">
            전화를 받기 전에,
            <br />
            먼저 <span className="accent">연습</span>하세요
          </h1>
          <p className="hero-sub reveal-in delay-4">
            AI가 실제 사기꾼처럼 전화하고 채팅합니다. 경고 문자로는 배울 수 없는 대응 감각을, 안전한 훈련으로 몸에
            익히세요.
          </p>
          <div className="hero-actions reveal-in delay-5">
            <button className="btn-primary" onClick={goToSignup}>
              무료로 훈련 시작하기
            </button>
            <button className="btn-ghost">시뮬레이션 미리보기</button>
          </div>
        </div>
      </section>

      <section className="section" id="flow">
        <div className="wrap">
          <div className="section-head">
            <div className="section-eyebrow">HOW IT HAPPENS</div>
            <h2>공격은 이렇게 스며듭니다</h2>
          </div>
          <div className="flow-diagram" ref={flowDiagramRef}>
            <svg className="flow-svg" aria-hidden="true" ref={flowSvgRef}>
              <path className="flow-path-bg" ref={flowPathBgRef}></path>
              <path className="flow-path-glow" ref={flowPathGlowRef}></path>
            </svg>
            <div className="flow-list">
              <div className="flow-row align-left" ref={(el) => { flowRowRefs.current[0] = el }}>
                <div className="card-light" aria-hidden="true" ref={(el) => { cardLightRefs.current[0] = el }}></div>
                <div className="flow-card-head">
                  <div className="flow-badge" ref={(el) => { flowBadgeRefs.current[0] = el }}>
                    01
                  </div>
                  <h4>문자 한 통으로 시작됩니다</h4>
                </div>
                <p>결제 알림, 택배 도착, 자녀의 연락 — 일상적인 문자처럼 옵니다.</p>
              </div>
              <div className="flow-row align-right" ref={(el) => { flowRowRefs.current[1] = el }}>
                <div className="card-light" aria-hidden="true" ref={(el) => { cardLightRefs.current[1] = el }}></div>
                <div className="flow-card-head">
                  <div className="flow-badge" ref={(el) => { flowBadgeRefs.current[1] = el }}>
                    02
                  </div>
                  <h4>이름 하나로 신뢰를 얻습니다</h4>
                </div>
                <p>기관명과 직함, 그럴듯한 말투만으로 의심은 빠르게 무너집니다.</p>
              </div>
              <div className="flow-row align-left" ref={(el) => { flowRowRefs.current[2] = el }}>
                <div className="card-light" aria-hidden="true" ref={(el) => { cardLightRefs.current[2] = el }}></div>
                <div className="flow-card-head">
                  <div className="flow-badge" ref={(el) => { flowBadgeRefs.current[2] = el }}>
                    03
                  </div>
                  <h4>눈치채기도 전에 정보는 넘어갑니다</h4>
                </div>
                <p>80% 이상의 피해자가 "피싱인 줄 몰라서" 당합니다 — 판단이 늦으면 이미 늦습니다.</p>
              </div>
            </div>
          </div>
          <div className="flow-summary" ref={flowSummaryRef}>
            <div className="section-eyebrow">NO INSTALL, 3 MIN</div>
            <h2>
              지금 훈련하지 않으면,
              <br />
              다음은 당신 차례일 수 있습니다
            </h2>
            <p>설치도, 준비도 필요 없습니다. AI 사기범과의 실전 대화로 3분 만에 첫 훈련을 시작하세요.</p>
            <button className="btn-primary" onClick={goToSignup}>
              무료로 훈련 시작하기
            </button>
          </div>
        </div>
      </section>

      <section className="section msg-section">
        <div className="wrap msg-row-outer">
          <div className="msg-card">
            <div className="msg-row">
              <div className="msg-avatar">은</div>
              <div className="msg-meta">
                <div className="msg-sender">Web발신</div>
                <div className="msg-preview">[국민은행] 고객님의 계좌에서 500,000원이 결제되었습니다...</div>
              </div>
              <div className="msg-time">방금</div>
            </div>
          </div>
          <p className="msg-caption">
            피싱, 스미싱, 보이스피싱...
            <br />
            결국 누군가는 속아 넘어갑니다.
          </p>
        </div>
      </section>

      <section className="section" id="why">
        <div className="wrap">
          <div className="section-head">
            <div className="section-eyebrow">WHY 피싱 디펜스</div>
            <h2>숫자로 보는 피싱의 현실</h2>
          </div>
          <div className="why-grid">
            <div className="why-tile featured">
              <div className="hex-bg"></div>
              <div className="why-tile-inner">
                <div className="why-num mono">200억+</div>
                <div className="why-label">연간 보이스피싱 피해액 (경찰청, 2024)</div>
              </div>
            </div>
            <div className="why-tile">
              <div className="hex-bg"></div>
              <div className="why-tile-inner">
                <div className="why-num mono">80%</div>
                <div className="why-label">"피싱인 줄 몰라서" 피해를 입은 비율</div>
              </div>
            </div>
            <div className="why-tile">
              <div className="hex-bg"></div>
              <div className="why-tile-inner">
                <div className="why-num mono">50%+</div>
                <div className="why-label">스미싱 피해, 매년 증가하는 비율</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="section">
        <div className="wrap">
          <div className="impact-row">
            <div className="impact-block">
              <div className="impact-label">훈련 전 피싱 인지도</div>
              <div className="impact-num mono">45%</div>
            </div>
            <div className="impact-arrow mono">→</div>
            <div className="impact-block">
              <div className="impact-label">훈련 후 피싱 인지도 (목표)</div>
              <div className="impact-num mono accent">85%</div>
            </div>
          </div>
          <p className="impact-note">* 기획 단계의 목표 수치이며, 파일럿 운영을 통해 검증할 예정입니다.</p>
        </div>
      </section>

      <section className="section">
        <div className="wrap">
          <div className="thesis-block">
            <div className="thesis-eyebrow">우리가 만드는 것</div>
            <blockquote>"교육이 아닌, 게임처럼 느껴지는 실전 훈련."</blockquote>
            <p className="thesis-sub">
              포스터와 경고 문자로는 배울 수 없는 대응 감각을, 반복 가능한 실전 대화로 익힙니다.
            </p>
          </div>
        </div>
      </section>

      <div className="cta-banner-section">
        <div className="wrap">
          <div className="cta-banner" ref={ctaBannerRef}>
            <div className="headline mono">지금 바로 무료로 훈련 시작하기</div>
            <Link to="/signup">시작하기 →</Link>
          </div>
        </div>
      </div>

      <section className="section type-section" id="types">
        <div className="hex-bg"></div>
        <div className="wrap">
          <div className="section-head">
            <div className="section-eyebrow">SCENARIO TYPES</div>
            <h2>다양한 사기 유형을 훈련하세요</h2>
          </div>
          <div className="type-grid">
            <div className="type-card">
              <div className="type-chapter mono">CHAPTER 01</div>
              <h4>기초 스미싱</h4>
              <p>결제·택배 문자로 위장한 가장 흔한 유형</p>
            </div>
            <div className="type-card">
              <div className="type-chapter mono">CHAPTER 02</div>
              <h4>택배 사칭</h4>
              <p>배송 조회 링크로 개인정보를 유도</p>
            </div>
            <div className="type-card">
              <div className="type-chapter mono">CHAPTER 03</div>
              <h4>가족 사칭</h4>
              <p>자녀·부모를 사칭해 긴급 송금을 요구</p>
            </div>
            <div className="type-card">
              <div className="type-chapter mono">CHAPTER 04</div>
              <h4>금융기관 사칭</h4>
              <p>계좌 정지·대환대출을 빙자한 정보 탈취</p>
            </div>
            <div className="type-card">
              <div className="type-chapter mono">CHAPTER 05</div>
              <h4>검찰 사칭</h4>
              <p>수사 협조를 빙자한 가장 정교한 고난도 유형</p>
            </div>
          </div>
        </div>
      </section>

      <div className="wrap">
        <div className="footer-cta" ref={footerCtaRef}>
          <div className="footer-glow hex-bg"></div>
          <div className="footer-cta-inner">
            <h2>
              다음 전화가 오기 전에,
              <br />
              먼저 받아보세요
            </h2>
            <p>가입은 무료이고, 첫 훈련은 3분이면 충분합니다.</p>
            <button className="btn-primary" onClick={goToSignup}>
              무료로 훈련 시작하기
            </button>
          </div>
        </div>
      </div>

      <footer>
        <div className="wrap">
          <span>© 2026 피싱 디펜스</span>
          <span>실제 사례 기반 시나리오 · AI 시뮬레이션</span>
        </div>
      </footer>
    </div>
  )
}
