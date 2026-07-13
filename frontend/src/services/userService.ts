import { apiClient } from './api'
import type { UserProfile } from './authService'

/** All fields optional — send only what changed. Mirrors Spring's `UserUpdateRequest`. */
export interface ProfileUpdatePayload {
  nickname?: string
  bio?: string
  currentPassword?: string
  newPassword?: string
}

/** Wire shape of Spring's `UserProfileResponse` (PATCH /users/me, POST /users/me/profile-image). */
interface UserWireResponse {
  userId: number
  email: string
  nickname: string
  bio: string | null
  profileImageUrl: string | null
  level: number
  currentXp: number
  totalXp: number
}

function toUserProfile(body: UserWireResponse): UserProfile {
  return {
    userId: body.userId,
    email: body.email,
    nickname: body.nickname,
    bio: body.bio,
    profileImageUrl: body.profileImageUrl,
    level: body.level,
    currentXp: body.currentXp,
    totalXp: body.totalXp,
  }
}

export const userService = {
  async updateProfile(patch: ProfileUpdatePayload): Promise<UserProfile> {
    const { data } = await apiClient.patch<UserWireResponse>('/api/v1/users/me', patch)
    return toUserProfile(data)
  },

  async uploadProfileImage(file: File): Promise<UserProfile> {
    const formData = new FormData()
    formData.append('file', file)
    // The instance default `Content-Type: application/json` (see api.ts) must be
    // cleared here — otherwise axios's transformRequest sees a JSON content-type
    // and JSON.stringifies the FormData instead of sending it as multipart. Setting
    // it to `undefined` lets axios/the browser generate `multipart/form-data;
    // boundary=...` itself. Verified against the MSW mock in userService.test.ts.
    const { data } = await apiClient.post<UserWireResponse>('/api/v1/users/me/profile-image', formData, {
      headers: { 'Content-Type': undefined },
    })
    return toUserProfile(data)
  },
}
