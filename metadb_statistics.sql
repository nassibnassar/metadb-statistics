CREATE TABLE metadb_statistics (
    schema_name text,
    table_name text,
    PRIMARY KEY (schema_name, table_name),
    last_update timestamptz,
    seq_scan bigint,
    idx_scan bigint
);

CREATE OR REPLACE FUNCTION update_metadb_statistics()
RETURNS void
AS $$
INSERT INTO metadb_statistics
    SELECT schemaname AS schema_name,
           relname AS table_name,
           now() AS last_update,
           COALESCE(seq_scan, 0) AS seq_scan,
           COALESCE(idx_scan, 0) AS idx_scan
        FROM pg_stat_user_tables 
        WHERE schemaname = 'folio_derived'
    ON CONFLICT (schema_name, table_name) DO UPDATE
        SET last_update = now(),
            seq_scan = metadb_statistics.seq_scan + COALESCE(EXCLUDED.seq_scan, 0),
            idx_scan = metadb_statistics.idx_scan + COALESCE(EXCLUDED.idx_scan, 0)
$$
LANGUAGE SQL;
