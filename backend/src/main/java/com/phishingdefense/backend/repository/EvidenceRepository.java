package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.Evidence;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EvidenceRepository extends JpaRepository<Evidence, Long> {

    List<Evidence> findByRecordId(Long recordId);
}
