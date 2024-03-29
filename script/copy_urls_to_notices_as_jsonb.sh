#!/bin/sh

set -e

beg=0
inc=1000
max=20000000

while getopts b:i:m: flag
do
    case "${flag}" in
        b) beg=${OPTARG};;
        i) inc=${OPTARG};;
        m) max=${OPTARG};;
    esac
done

for i in $(seq $beg $inc $max); do
    j=$(expr $i + $inc)

    cat << EOM
PROCESSING $i UNTIL $j ($(expr 100 '*' $i / $max)%)
EOM

    psql -v ON_ERROR_STOP=1 << EOM
SET enable_hashjoin = false;
SET enable_mergejoin = false;
WITH
    a AS (
        SELECT
            nw.notice_id,
            w.kind,
            w.description_original,
            min(w.description) AS description,
            min(w.id) AS work_id,
            array_agg(w.id) AS work_ids
        FROM works w
        JOIN notices_works nw ON nw.work_id = w.id
        WHERE nw.notice_id >= $i AND nw.notice_id < $j
        GROUP BY nw.notice_id, w.kind, w.description_original
    ),
    i AS (
        SELECT
            a.work_id,
            array_agg((SELECT x FROM (SELECT
                u.url_original,
                CASE u.url WHEN u.url_original THEN null
                ELSE u.url END AS url
            ) x)) AS urls
       FROM a
       JOIN infringing_urls_works uw ON uw.work_id = ANY (a.work_ids)
       JOIN infringing_urls u ON uw.infringing_url_id = u.id
       GROUP BY a.work_id
    ),
    c AS (
        SELECT
            a.work_id,
            array_agg((SELECT x FROM (SELECT
                u.url_original,
                CASE u.url WHEN u.url_original THEN null
                ELSE u.url END AS url
            ) x)) AS urls
        FROM a
        JOIN copyrighted_urls_works uw ON uw.work_id = ANY (a.work_ids)
        JOIN copyrighted_urls u ON uw.copyrighted_url_id = u.id
        GROUP BY a.work_id
    ),
    f AS (
        SELECT
            a.notice_id,
            jsonb_strip_nulls(jsonb_agg((SELECT x FROM (SELECT
                a.kind,
                a.description_original,
                CASE a.description WHEN a.description_original THEN null
                ELSE a.description END AS description,
                COALESCE(i.urls, '{}') AS infringing_urls,
                COALESCE(c.urls, '{}') AS copyrighted_urls
            ) x))) AS json
        FROM a
        LEFT JOIN i USING (work_id)
        LEFT JOIN c USING (work_id)
        GROUP BY a.notice_id
    )
UPDATE notices n
SET works_json = COALESCE((SELECT f.json FROM f WHERE f.notice_id = n.id), '[]')
WHERE n.id >= $i AND n.id < $j;
VACUUM notices;
EOM

done
