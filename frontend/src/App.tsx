import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Toaster } from 'react-hot-toast'
import { ProtectedRoute } from '@components/common/ProtectedRoute'
import { useAuth } from '@hooks/useAuth'
import { LandingPage } from '@pages/LandingPage'
import { LoginPage } from '@pages/LoginPage'
import { SignupPage } from '@pages/SignupPage'
import { HomePage } from '@pages/HomePage'
import { ProfilePage } from '@pages/ProfilePage'
import { GamePage } from '@pages/GamePage'
import { NotFoundPage } from '@pages/NotFoundPage'

const queryClient = new QueryClient()

function RootRoute() {
  const { isAuthenticated } = useAuth()
  return isAuthenticated ? <Navigate to="/home" replace /> : <LandingPage />
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Toaster position="top-center" />
        <Routes>
          <Route path="/" element={<RootRoute />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />
          <Route element={<ProtectedRoute />}>
            <Route path="/home" element={<HomePage />} />
            <Route path="/profile" element={<ProfilePage />} />
            <Route path="/game/:recordId" element={<GamePage />} />
          </Route>
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  )
}
