package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.Attendance;
import java.time.LocalDate;

public record AttendanceResponse(
        Long attendanceId,
        LocalDate checkedInAt,
        Integer consecutiveDays
) {
    public static AttendanceResponse from(Attendance attendance) {
        return new AttendanceResponse(
                attendance.getAttendanceId(),
                attendance.getCheckedInAt(),
                attendance.getConsecutiveDays()
        );
    }
}
