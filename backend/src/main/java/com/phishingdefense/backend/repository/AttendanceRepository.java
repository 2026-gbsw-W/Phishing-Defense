package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.Attendance;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    List<Attendance> findByUserIdOrderByCheckedInAtDesc(Long userId);

    Optional<Attendance> findByUserIdAndCheckedInAt(Long userId, LocalDate checkedInAt);
}
