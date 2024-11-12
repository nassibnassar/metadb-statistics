CREATE TABLE ldp_statistics (
    schema_name text,
    table_name text,
    PRIMARY KEY (schema_name, table_name),
    last_update timestamptz,
    seq_scan bigint,
    idx_scan bigint
);

CREATE FUNCTION update_ldp_statistics()
RETURNS void
AS $$
INSERT INTO ldp_statistics
    SELECT schemaname AS schema_name,
           relname AS table_name,
           now() AS last_update,
           COALESCE(seq_scan, 0) AS seq_scan,
           COALESCE(idx_scan, 0) AS idx_scan
        FROM pg_stat_user_tables 
        WHERE schemaname IN ('folio_reporting', 'public')
    ON CONFLICT (schema_name, table_name) DO UPDATE
        SET last_update = now(),
            seq_scan = ldp_statistics.seq_scan + COALESCE(EXCLUDED.seq_scan, 0),
            idx_scan = ldp_statistics.idx_scan + COALESCE(EXCLUDED.idx_scan, 0)
$$
LANGUAGE SQL;
