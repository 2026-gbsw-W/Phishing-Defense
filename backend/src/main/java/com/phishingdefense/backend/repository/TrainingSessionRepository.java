package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.TrainingSession;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TrainingSessionRepository extends JpaRepository<TrainingSession, String> {

    List<TrainingSession> findByUserId(Long userId);

    Optional<TrainingSession> findByRecordId(Long recordId);
}
