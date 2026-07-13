import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import { LandingPage } from './LandingPage'

function renderLanding() {
  return render(
    <MemoryRouter initialEntries={['/']}>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/signup" element={<p>signup page</p>} />
      </Routes>
    </MemoryRouter>,
  )
}

describe('LandingPage', () => {
  it('renders the hero content and mounts without throwing', async () => {
    renderLanding()
    expect(await screen.findByText(/AI가 실제 사기꾼처럼/)).toBeInTheDocument()
  })

  it('navigates to /signup when the nav CTA is clicked', async () => {
    renderLanding()
    await userEvent.click(screen.getByRole('button', { name: '시작하기' }))
    expect(await screen.findByText('signup page')).toBeInTheDocument()
  })

  it('navigates to /signup when a "무료로 훈련 시작하기" CTA is clicked', async () => {
    renderLanding()
    const ctas = screen.getAllByRole('button', { name: '무료로 훈련 시작하기' })
    expect(ctas.length).toBeGreaterThan(0)
    await userEvent.click(ctas[0])
    expect(await screen.findByText('signup page')).toBeInTheDocument()
  })

  it('navigates to /signup when the footer banner link is clicked', async () => {
    renderLanding()
    await userEvent.click(screen.getByRole('link', { name: '시작하기 →' }))
    expect(await screen.findByText('signup page')).toBeInTheDocument()
  })
})
