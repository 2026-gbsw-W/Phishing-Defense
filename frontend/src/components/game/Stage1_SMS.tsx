interface Stage1SMSProps {
  message: string
  onContinue: () => void
}

export function Stage1_SMS({ message, onContinue }: Stage1SMSProps) {
  return (
    <div className="stage1-sms-container">
      <p className="stage1-sms-intro-text">문자 메시지가 도착했습니다</p>
      <div className="stage1-sms-bubble">
        <p className="stage1-sms-bubble-text">{message}</p>
      </div>
      <button onClick={onContinue} className="btn-primary stage1-sms-button">
        확인
      </button>
    </div>
  )
}
