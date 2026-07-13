package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.ScenarioRecord;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ScenarioRecordRepository extends JpaRepository<ScenarioRecord, Long> {

    List<ScenarioRecord> findByUserIdOrderByCreatedAtDesc(Long userId);

    List<ScenarioRecord> findByUserIdAndScenarioId(Long userId, Long scenarioId);
}
