package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.Chapter;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChapterRepository extends JpaRepository<Chapter, Integer> {

    List<Chapter> findAllByOrderByOrderIndexAsc();
}
