INSERT INTO storage.buckets
    (id, name, file_size_limit)
VALUES
    ('documents', 'documents', 500 * 1024 * 1024) -- 500 MB
ON CONFLICT (id) DO UPDATE
    SET file_size_limit = EXCLUDED.file_size_limit;
