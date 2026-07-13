-- scenarios.context는 어떤 코드에서도 읽히지 않고 AI 서버에도 전달되지 않는 죽은 컬럼이었다.
-- AI 서버(ai/app/domains/simulation/prompts.py)가 scenario_type별로 이미 완성된 페르소나 프롬프트를
-- 갖고 있어 이 컬럼이 대신하려던 역할을 전적으로 담당하므로 제거한다.
ALTER TABLE scenarios DROP COLUMN context;
