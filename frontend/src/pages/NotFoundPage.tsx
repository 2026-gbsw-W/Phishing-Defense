import { Link } from 'react-router-dom'

export function NotFoundPage() {
  return (
    <div className="not-found-page hex-bg">
      <p className="not-found-message">페이지를 찾을 수 없습니다.</p>
      <Link to="/" className="accent">
        홈으로 돌아가기
      </Link>
    </div>
  )
}
