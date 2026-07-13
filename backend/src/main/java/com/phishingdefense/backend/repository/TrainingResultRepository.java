package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.TrainingResult;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TrainingResultRepository extends JpaRepository<TrainingResult, String> {
}
