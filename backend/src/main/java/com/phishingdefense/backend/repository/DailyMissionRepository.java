package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.DailyMission;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DailyMissionRepository extends JpaRepository<DailyMission, Long> {

    List<DailyMission> findByUserIdAndCreatedDate(Long userId, LocalDate createdDate);
}
