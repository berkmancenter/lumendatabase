WITH
    n AS NOT MATERIALIZED (
    	SELECT * FROM notices
		ORDER BY notices.id ASC
		LIMIT :size
		OFFSET :offset
	),
    roles AS NOT MATERIALIZED (
        SELECT
            enr.notice_id,
            min(e.name) FILTER (WHERE enr.name = 'sender') AS sender_name,
            min(e.name) FILTER (WHERE enr.name = 'recipient') AS recipient_name,
            min(e.country_code) FILTER (WHERE enr.name = 'recipient') AS country_code,
            min(e.name) FILTER (WHERE enr.name = 'submitter') AS submitter_name,
            min(e.country_code) FILTER (WHERE enr.name = 'submitter') AS submitter_country_code,
            min(e.name) FILTER (WHERE enr.name = 'principal') AS principal_name,
            array_agg(DISTINCT(e.country_code)) AS entities_country_codes
        FROM entity_notice_roles AS enr
            JOIN entities AS e ON enr.entity_id = e.id
            JOIN n ON n.id = enr.notice_id
        GROUP BY enr.notice_id
    ),
    topics AS NOT MATERIALIZED (
        SELECT
            ta.notice_id,
            json_agg(json_build_object('name', t.name)) AS topics,
            json_agg(t.name) AS topic_list
        FROM topic_assignments AS ta
            JOIN topics t ON ta.topic_id = t.id
            JOIN n ON n.id = ta.notice_id
        GROUP BY ta.notice_id
    )
SELECT
    n.id,
    n.title,
    n.body,
    n.date_received at time zone 'utc' AS date_received,
	n.created_at at time zone 'utc' AS created_at,
    n.type as class_name,
    n.subject,
    n.language,
    n.rescinded,
    n.action_taken,
    n.spam,
    n.hidden,
    n.request_type,
    n.mark_registration_number,
    n.published,
    n.counternotice_for_id,
    n.counternotice_for_sid,
    (
		SELECT json_agg( 
            json_build_object( 
                'description', w -> 'description', 
                'infringing_urls', ( 
                    SELECT json_agg(json_build_object('url', y -> 'url')) 
                    FROM jsonb_array_elements(w -> 'infringing_urls') x(y) 
                ), 
                'copyrighted_urls', ( 
                    SELECT json_agg(json_build_object('url', y -> 'url')) 
                    FROM jsonb_array_elements(w -> 'copyrighted_urls') x(y) 
                )
            ) 
        )::text
        FROM jsonb_array_elements(n.works_json) x(w) 
    ) AS works,
    roles.sender_name,
    roles.recipient_name,
    roles.submitter_name,
    roles.principal_name,
    roles.submitter_country_code,
    roles.entities_country_codes,
    roles.country_code,
    n.tag_list::text,
    n.jurisdiction_list::text,
    topics.topics::text,
    topics.topic_list::text
FROM n
    LEFT JOIN roles ON roles.notice_id = n.id
    LEFT JOIN topics ON topics.notice_id = n.id;
