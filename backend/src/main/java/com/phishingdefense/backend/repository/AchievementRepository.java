package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.Achievement;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AchievementRepository extends JpaRepository<Achievement, Integer> {

    List<Achievement> findAllByCategory(String category);

    List<Achievement> findAllByOrderByAchievementIdAsc();
}
