package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.Stage;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StageRepository extends JpaRepository<Stage, Long> {

    List<Stage> findByChapterIdOrderByStageIdAsc(Integer chapterId);
}
