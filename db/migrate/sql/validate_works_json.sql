CREATE OR REPLACE FUNCTION validate_works_json(works_json jsonb)
    RETURNS bool LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE
    AS $$
DECLARE
    work_json jsonb;
    url_json jsonb;
BEGIN
    IF jsonb_typeof(works_json) <> 'array' THEN
        RETURN false;
    END IF;

    FOR work_json IN (SELECT j FROM jsonb_array_elements(works_json) j) LOOP
        IF jsonb_typeof(work_json) <> 'object' THEN
            RETURN false;
        END IF;

        IF jsonb_typeof(work_json->'kind') NOT IN ('null', 'string') THEN
            RETURN false;
        END IF;

        IF jsonb_typeof(work_json->'description_original') NOT IN ('null', 'string') THEN
            RETURN false;
        END IF;

        IF jsonb_typeof(work_json->'description') NOT IN ('null', 'string') THEN
            RETURN false;
        END IF;

        IF jsonb_typeof(work_json->'infringing_urls') <> 'array' THEN
            RETURN false;
        END IF;

        IF jsonb_typeof(work_json->'copyrighted_urls') <> 'array' THEN
            RETURN false;
        END IF;

        FOR url_json IN (SELECT j FROM jsonb_array_elements(works_json->'infringing_urls') j) LOOP
            IF jsonb_typeof(url_json) <> 'object' THEN
                RETURN false;
            END IF;

            IF jsonb_typeof(url_json->'url_original') <> 'string' THEN
                RETURN false;
            END IF;

            IF jsonb_typeof(url_json->'url') NOT IN ('null', 'string') THEN
                RETURN false;
            END IF;
        END LOOP;

        FOR url_json IN (SELECT j FROM jsonb_array_elements(works_json->'copyrighted_urls') j) LOOP
            IF jsonb_typeof(url_json) <> 'object' THEN
                RETURN false;
            END IF;

            IF jsonb_typeof(url_json->'url_original') <> 'string' THEN
                RETURN false;
            END IF;

            IF jsonb_typeof(url_json->'url') NOT IN ('null', 'string') THEN
                RETURN false;
            END IF;
        END LOOP;
    END LOOP;

    RETURN true;
END
$$;
