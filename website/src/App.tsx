import './App.css'
const features = [
  { icon: '📊', title: 'Smart Dashboard', desc: "See today's classes, pending assignments, upcoming exams, and AI-highlighted priorities — all at a glance.", color: 'violet' },
  { icon: '📅', title: 'Timetable Manager', desc: 'Add, edit, and organize your weekly class schedule by day with faculty names, rooms, and time slots.', color: 'pink' },
  { icon: '📝', title: 'Assignment Tracker', desc: 'Track every assignment with due dates, priority levels, and completion status. Filter by pending or done.', color: 'yellow' },
  { icon: '🎓', title: 'Exam Planner', desc: 'Schedule exams with date, time, venue, and custom reminder alerts. Never be caught off guard again.', color: 'green' },
  { icon: '🤖', title: 'Pulse AI Agent', desc: 'An on-device AI engine analyzes all your tasks and generates smart priority rankings — no internet needed.', color: 'violet' },
  { icon: '🌙', title: 'Dark Mode & Settings', desc: 'Customize theme, notification preferences, and reminder timing. Your app, your rules.', color: 'pink' },
]

const aiFeatures = [
  { icon: '✓', color: 'violet', text: 'Weighted urgency scoring (deadlines × priority × task type)' },
  { icon: '✓', color: 'pink', text: 'Automatic overdue detection with exponential penalty boosts' },
  { icon: '✓', color: 'yellow', text: 'Human-readable action suggestions for every task' },
  { icon: '✓', color: 'green', text: '100% on-device — no API keys, no internet required' },
]

export default function App() {
  return (
    <div className="app">
      {/* ── Decorative Background Shapes ── */}
      <div className="bg-shapes" aria-hidden="true">
        <div className="shape shape-circle shape-1" />
        <div className="shape shape-circle shape-2" />
        <div className="shape shape-circle shape-3" />
        <div className="shape shape-square shape-4" />
        <div className="shape shape-triangle shape-5" />
        <div className="shape shape-circle shape-6" />
      </div>

      {/* ── Navbar ── */}
      <nav className="navbar">
        <div className="container navbar-inner">
          <a href="#" className="logo">
            <span className="logo-icon">📚</span>
            <span className="logo-text">Campus<span className="logo-highlight">Pulse</span></span>
          </a>
          <ul className="nav-links">
            <li><a href="#features">Features</a></li>
            <li><a href="#ai-agent">AI Agent</a></li>
            <li><a href="#preview">Preview</a></li>
          </ul>
          <a href="#download" className="btn btn-primary btn-sm">
            Download APK <span className="btn-pill">↓</span>
          </a>
        </div>
      </nav>

      {/* ── Hero ── */}
      <header className="hero section" id="hero">
        <div className="container hero-grid">
          <div className="hero-text">
            <div className="hero-badge">
              <span className="badge-dot" /> Free & Open Source — Android App
            </div>
            <h1 className="hero-heading">
              Your Academic Life,{' '}
              <span className="highlight highlight--violet">Organized</span>{' '}
              &amp;{' '}
              <span className="highlight highlight--pink">Prioritized</span>
            </h1>
            <p className="hero-sub">
              CampusPulse Planner combines smart timetable management with an AI-powered priority engine to keep you on top of classes, assignments, and exams — effortlessly.
            </p>
            <div className="hero-actions">
              <a href="#download" className="btn btn-primary btn-lg">
                Download for Android <span className="btn-pill">↓</span>
              </a>
              <a href="#features" className="btn btn-secondary btn-lg">See Features</a>
            </div>
            <div className="hero-stats">
              <div className="stat">
                <span className="stat-num">5</span>
                <span className="stat-label">Core Modules</span>
              </div>
              <div className="stat-divider" />
              <div className="stat">
                <span className="stat-num">AI</span>
                <span className="stat-label">Priority Engine</span>
              </div>
              <div className="stat-divider" />
              <div className="stat">
                <span className="stat-num">0</span>
                <span className="stat-label">Ads or Tracking</span>
              </div>
            </div>
          </div>

          <div className="hero-visual">
            <div className="phone-wrap">
              <div className="phone">
                <div className="phone-status">
                  <span className="phone-dot" /> CampusPulse
                </div>
                <div className="phone-stats">
                  <div className="pstat pstat--violet"><div className="pstat-num">3</div><div className="pstat-lbl">Classes</div></div>
                  <div className="pstat pstat--pink"><div className="pstat-num">5</div><div className="pstat-lbl">Pending</div></div>
                  <div className="pstat pstat--yellow"><div className="pstat-num">1</div><div className="pstat-lbl">Exams</div></div>
                </div>
                <div className="pmock-card">
                  <span className="pmock-icon">⚡</span>
                  <div><div className="pmock-title">Top Priority</div><div className="pmock-sub">Math Assignment — Due Tomorrow</div></div>
                </div>
                <div className="pmock-card">
                  <span className="pmock-icon">📖</span>
                  <div><div className="pmock-title">Data Structures</div><div className="pmock-sub">9:00 AM — Room 301</div></div>
                </div>
                <div className="pmock-card">
                  <span className="pmock-icon">📝</span>
                  <div><div className="pmock-title">Physics Lab Report</div><div className="pmock-sub">3 days left • High Priority</div></div>
                </div>
                <div className="phone-nav">
                  {['🏠','📅','📋','🎓','✨'].map((ic, i) => (
                    <span key={i} className={`pnav-item${i === 0 ? ' pnav-active' : ''}`}>{ic}</span>
                  ))}
                </div>
              </div>
              <div className="phone-deco phone-deco--circle" aria-hidden="true" />
              <div className="phone-deco phone-deco--dots" aria-hidden="true" />
              <div className="phone-deco phone-deco--tri" aria-hidden="true" />
            </div>
          </div>
        </div>

        <div className="squiggle-divider" aria-hidden="true">
          <svg viewBox="0 0 1200 60" fill="none" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
            <path d="M0 30 Q 50 0, 100 30 T 200 30 T 300 30 T 400 30 T 500 30 T 600 30 T 700 30 T 800 30 T 900 30 T 1000 30 T 1100 30 T 1200 30" stroke="#8B5CF6" strokeWidth="3" fill="none"/>
          </svg>
        </div>
      </header>

      {/* ── Features ── */}
      <section className="section features-section" id="features">
        <div className="container">
          <div className="section-header">
            <span className="eyebrow">✦ What's Inside</span>
            <h2 className="section-title">
              Everything You Need to <span className="highlight highlight--yellow">Ace</span> College
            </h2>
            <p className="section-sub">One app. Five powerful modules. Zero excuses.</p>
          </div>
          <div className="features-grid">
            {features.map((f) => (
              <div key={f.title} className={`fcard fcard--${f.color}`}>
                <div className={`fcard-icon fcard-icon--${f.color}`}>{f.icon}</div>
                <h3 className="fcard-title">{f.title}</h3>
                <p className="fcard-desc">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── AI Agent ── */}
      <section className="section ai-section" id="ai-agent">
        <div className="container ai-grid">
          <div className="ai-visual">
            <div className="ai-card">
              <div className="ai-card-header">
                <span>✨</span>
                <span className="ai-card-title">Pulse AI</span>
              </div>
              <div className="ai-summary">
                <div className="ai-summary-label">Workload Summary</div>
                <p className="ai-summary-text">A few urgent items require your immediate attention. Get them out of the way!</p>
                <div className="ai-badges">
                  <span className="ai-badge ai-badge--red">2 Critical</span>
                  <span className="ai-badge ai-badge--green">1 Exam</span>
                  <span className="ai-badge ai-badge--yellow">4 Pending</span>
                </div>
              </div>
              <div className="ai-item ai-item--critical">
                <span className="ai-item-icon">⚠️</span>
                <div>
                  <div className="ai-item-title">Math Assignment</div>
                  <div className="ai-item-sub">Overdue by 1 day — Complete immediately!</div>
                </div>
                <span className="ai-tag ai-tag--red">CRITICAL</span>
              </div>
              <div className="ai-item ai-item--urgent">
                <span className="ai-item-icon">🔥</span>
                <div>
                  <div className="ai-item-title">Physics Exam</div>
                  <div className="ai-item-sub">In 2 days — Focus on revision today</div>
                </div>
                <span className="ai-tag ai-tag--orange">URGENT</span>
              </div>
            </div>
          </div>

          <div className="ai-text">
            <span className="eyebrow">✦ Built-In Intelligence</span>
            <h2 className="section-title">
              Meet <span className="highlight highlight--violet">Pulse AI</span>
            </h2>
            <p className="ai-desc">
              Pulse AI is your personal academic advisor. It scans your timetable, assignments, and exam dates — then tells you <strong>exactly what to focus on right now</strong>.
            </p>
            <ul className="ai-list">
              {aiFeatures.map((f) => (
                <li key={f.text}>
                  <span className={`ai-check ai-check--${f.color}`}>{f.icon}</span>
                  <span>{f.text}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* ── Preview ── */}
      <section className="section preview-section" id="preview">
        <div className="container">
          <div className="section-header">
            <span className="eyebrow">✦ See It In Action</span>
            <h2 className="section-title">
              A Premium <span className="highlight highlight--pink">Experience</span>
            </h2>
            <p className="section-sub">Glassmorphism cards, gradient accents, smooth animations — this isn't your average student app.</p>
          </div>
          <div className="preview-grid">
            {[
              { emoji: '📊', label: 'Dashboard', desc: "Stat cards, today's schedule, and AI insights in one scroll.", cls: 'preview-card--violet' },
              { emoji: '📅', label: 'Timetable', desc: 'Day-by-day class switching with faculty & room details.', cls: 'preview-card--pink' },
              { emoji: '✨', label: 'Pulse AI', desc: 'Smart priority ranking with actionable suggestions.', cls: 'preview-card--yellow' },
            ].map((p) => (
              <div key={p.label} className={`preview-card ${p.cls}`}>
                <span className="preview-emoji">{p.emoji}</span>
                <span className="preview-label">{p.label}</span>
                <p className="preview-desc">{p.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Download ── */}
      <section className="section download-section" id="download">
        <div className="container">
          <div className="download-card">
            <div className="download-blob download-blob--1" aria-hidden="true" />
            <div className="download-blob download-blob--2" aria-hidden="true" />
            <div className="download-badge">🎉 FREE DOWNLOAD</div>
            <h2 className="download-title">
              Ready to Take Control of Your{' '}
              <span className="highlight highlight--yellow">Semester</span>?
            </h2>
            <p className="download-sub">
              Download CampusPulse Planner now and let Pulse AI handle the prioritization while you focus on what matters.
            </p>
            <a
              href="/CampusPulse-Planner.apk"
              download="CampusPulse-Planner.apk"
              className="btn btn-primary btn-xl"
            >
              <span>📱</span>
              Download Android APK
              <span className="btn-pill">↓</span>
            </a>
            <p className="download-note">Android 5.0+ required · ~15 MB · No sign-up needed</p>
          </div>
        </div>
      </section>

      {/* ── Footer ── */}
      <footer className="footer">
        <div className="container footer-inner">
          <div className="logo">
            <span className="logo-icon">📚</span>
            <span className="logo-text">Campus<span className="logo-highlight">Pulse</span> Planner</span>
          </div>
          <p className="footer-tagline">Built with ❤️ for students who want to stay ahead.</p>
          <div className="footer-links">
            <a href="#features">Features</a>
            <a href="#ai-agent">AI Agent</a>
            <a href="#download">Download</a>
            <a href="https://github.com/NavDevs/CampusPulse-Planner" target="_blank" rel="noopener noreferrer">GitHub</a>
          </div>
          <p className="footer-copy">© 2026 NavDevs. All rights reserved.</p>
        </div>
      </footer>
    </div>
  )
}
