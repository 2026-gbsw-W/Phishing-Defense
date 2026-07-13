ALTER TABLE scenario_records
  ADD COLUMN current_stage INT DEFAULT 1 AFTER scenario_id,
  ADD COLUMN current_turn INT DEFAULT 0 AFTER current_stage;
