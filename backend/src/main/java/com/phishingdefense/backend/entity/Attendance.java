package com.phishingdefense.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "attendance")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Attendance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "attendance_id")
    private Long attendanceId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "checked_in_at", nullable = false)
    private LocalDate checkedInAt;

    @Column(name = "consecutive_days")
    private Integer consecutiveDays;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    private Attendance(Long userId, LocalDate checkedInAt, Integer consecutiveDays) {
        this.userId = userId;
        this.checkedInAt = checkedInAt;
        this.consecutiveDays = consecutiveDays;
    }

    public static Attendance checkIn(Long userId, LocalDate checkedInAt, Integer consecutiveDays) {
        return Attendance.builder()
                .userId(userId)
                .checkedInAt(checkedInAt)
                .consecutiveDays(consecutiveDays)
                .build();
    }
}
