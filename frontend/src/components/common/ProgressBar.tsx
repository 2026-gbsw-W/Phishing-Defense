interface ProgressBarProps {
  ratio: number
  label?: string
}

export function ProgressBar({ ratio, label }: ProgressBarProps) {
  const clamped = Math.min(1, Math.max(0, ratio))
  return (
    <div className="progress-bar-container">
      <div className="progress-bar-track">
        <div
          data-testid="progress-fill"
          className="progress-bar-fill"
          style={{ width: `${clamped * 100}%` }}
        />
      </div>
      {label && <span className="progress-bar-label">{label}</span>}
    </div>
  )
}
