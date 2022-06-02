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
    notice_tags AS (
        SELECT
            tg.name AS tag_name,
            tgg.context AS context,
            tgg.taggable_id
        FROM taggings tgg
        JOIN tags tg ON tg.id = tgg.tag_id
        WHERE tgg.taggable_id >= $i AND tgg.taggable_id < $j
    ),
    f AS (
        SELECT
            notice_tags.taggable_id AS notice_id,
            jsonb_agg(tag_name) FILTER (WHERE context = 'tags' AND tag_name IS NOT NULL) AS tags,
            jsonb_agg(tag_name) FILTER (WHERE context = 'jurisdictions' AND tag_name IS NOT NULL) AS jurisdictions,
            jsonb_agg(tag_name) FILTER (WHERE context = 'regulations' AND tag_name IS NOT NULL) AS regulations
        FROM notice_tags
        GROUP BY notice_tags.taggable_id
    )

UPDATE notices n
SET tags_json = COALESCE((SELECT f.tags FROM f WHERE f.notice_id = n.id), '[]'),
    jurisdictions_json = COALESCE((SELECT f.jurisdictions FROM f WHERE f.notice_id = n.id), '[]'),
    regulations_json = COALESCE((SELECT f.regulations FROM f WHERE f.notice_id = n.id), '[]')
WHERE n.id >= $i AND n.id < $j;

VACUUM notices;
EOM

done
