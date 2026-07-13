package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.ChapterProgress;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChapterProgressRepository extends JpaRepository<ChapterProgress, Long> {

    List<ChapterProgress> findByUserId(Long userId);

    Optional<ChapterProgress> findByUserIdAndChapterId(Long userId, Integer chapterId);
}
