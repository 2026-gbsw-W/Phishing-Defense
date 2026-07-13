package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.game.AttendanceStatusResponse;
import com.phishingdefense.backend.dto.game.NextRewardResponse;
import com.phishingdefense.backend.entity.Attendance;
import com.phishingdefense.backend.repository.AttendanceRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AttendanceService {

    private static final List<Integer> MILESTONE_DAYS = List.of(7, 14, 30);
    private static final Map<Integer, String> MILESTONE_REWARDS = Map.of(
            7, "hint_and_coins",
            14, "double_xp_1day",
            30, "special_badge_and_coins"
    );

    private final AttendanceRepository attendanceRepository;

    @Transactional
    public AttendanceStatusResponse getStatus(Long userId) {
        LocalDate today = LocalDate.now();
        Attendance todayAttendance = attendanceRepository.findByUserIdAndCheckedInAt(userId, today)
                .orElseGet(() -> checkIn(userId, today));

        List<LocalDate> calendar = attendanceRepository.findByUserIdOrderByCheckedInAtDesc(userId).stream()
                .map(Attendance::getCheckedInAt)
                .toList();

        NextRewardResponse nextReward = MILESTONE_DAYS.stream()
                .filter(day -> day > todayAttendance.getConsecutiveDays())
                .findFirst()
                .map(day -> new NextRewardResponse(day, MILESTONE_REWARDS.get(day)))
                .orElse(null);

        return new AttendanceStatusResponse(todayAttendance.getConsecutiveDays(), true, nextReward, calendar);
    }

    private Attendance checkIn(Long userId, LocalDate today) {
        int consecutiveDays = attendanceRepository.findByUserIdAndCheckedInAt(userId, today.minusDays(1))
                .map(yesterday -> yesterday.getConsecutiveDays() + 1)
                .orElse(1);

        return attendanceRepository.save(Attendance.checkIn(userId, today, consecutiveDays));
    }
}
