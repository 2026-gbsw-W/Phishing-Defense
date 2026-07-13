package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.ChatHistory;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChatHistoryRepository extends JpaRepository<ChatHistory, Long> {

    List<ChatHistory> findByRecordIdOrderByTurnAsc(Long recordId);
}
