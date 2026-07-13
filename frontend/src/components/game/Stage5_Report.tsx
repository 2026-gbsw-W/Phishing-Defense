interface Stage5ReportProps {
  onComplete: () => void
}

// The real backend has no separate "report to police" chat endpoint — the
// scenario goes straight from evidence confirmation (Stage 4) to the report
// (Stage 6). This stage stays as a short transitional screen so the game's
// pacing/narrative still acknowledges "신고 접수" before showing results.
export function Stage5_Report({ onComplete }: Stage5ReportProps) {
  return (
    <div className="stage5-report-container stage5-report-transition">
      <p className="stage5-report-header">경찰 신고 접수</p>
      <p className="stage5-report-transition-text">
        수집한 증거와 대화 내용이 경찰에 접수되었습니다. 잠시 후 결과를 확인하세요.
      </p>
      <div className="stage5-report-actions">
        <button type="button" className="btn-primary" onClick={onComplete}>
          결과 확인하기
        </button>
      </div>
    </div>
  )
}
