package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.TrainingEvidence;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TrainingEvidenceRepository extends JpaRepository<TrainingEvidence, String> {

    List<TrainingEvidence> findBySessionIdOrderByCreatedAtAsc(String sessionId);
}
