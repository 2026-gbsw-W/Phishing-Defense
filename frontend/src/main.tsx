import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { useAuthStore } from '@/stores/authStore'

async function bootstrap() {
  if (import.meta.env.VITE_ENABLE_MOCKS === 'true') {
    const { worker } = await import('@mocks/browser')
    await worker.start({ onUnhandledRequest: 'bypass' })
  }

  await useAuthStore.getState().hydrate()

  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
}

bootstrap().catch((err) => {
  console.error('Failed to bootstrap app:', err)
})
