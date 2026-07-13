import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { ProgressBar } from './ProgressBar'

describe('ProgressBar', () => {
  it('renders a fill width proportional to the ratio', () => {
    render(<ProgressBar ratio={0.75} label="80%" />)
    const fill = screen.getByTestId('progress-fill')
    expect(fill).toHaveStyle({ width: '75%' })
    expect(screen.getByText('80%')).toBeInTheDocument()
  })

  it('clamps ratio to [0, 1]', () => {
    render(<ProgressBar ratio={1.5} label="over" />)
    expect(screen.getByTestId('progress-fill')).toHaveStyle({ width: '100%' })
  })
})
