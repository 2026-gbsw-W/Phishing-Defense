package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.PhishingIndexEntry;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PhishingIndexRepository extends JpaRepository<PhishingIndexEntry, Long> {

    List<PhishingIndexEntry> findByUserId(Long userId);

    List<PhishingIndexEntry> findByUserIdAndChapterId(Long userId, Integer chapterId);

    boolean existsByUserIdAndScenarioId(Long userId, Long scenarioId);
}
