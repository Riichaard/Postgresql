SELECT pid, usename, application_name, client_addr, state, query
FROM pg_stat_activity
WHERE state = 'active';


select * from aluno

update aluno set nome = 'Diogoo' where nome = 'Diogo'



CREATE TABLE update_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB,
    client_ip inet
);


CREATE OR REPLACE FUNCTION log_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO update_log(table_name, old_data, new_data, client_ip)
    VALUES (
        TG_TABLE_NAME,
        row_to_json(OLD),
        row_to_json(NEW),
        inet_client_addr()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER update_monitor
AFTER UPDATE ON aluno
FOR EACH ROW
WHEN (OLD.nome IS DISTINCT FROM NEW.nome)
EXECUTE FUNCTION log_update();


SELECT * FROM update_log ORDER BY operation_time DESC;

SELECT trigger_name, event_manipulation AS event, event_object_table AS table_name, action_statement
FROM information_schema.triggers
ORDER BY event_object_table, trigger_name;

DROP TRIGGER update_monitor ON aluno CASCADE;

