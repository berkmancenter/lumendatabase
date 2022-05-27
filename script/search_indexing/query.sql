WITH
	a AS MATERIALIZED (
		SELECT
			r.notice_id,
			min(e.name) FILTER (WHERE r.name = 'sender') AS sender_name,
			min(e.name) FILTER (WHERE r.name = 'recipient') AS recipient_name,
			min(e.name) FILTER (WHERE r.name = 'submitter') AS submitter_name,
			min(e.country_code) FILTER (WHERE r.name = 'submitter') AS submitter_country_code,
			min(e.name) FILTER (WHERE r.name = 'principal') AS principal_name,
			array_agg(DISTINCT(e.country_code)) AS entities_country_codes
		FROM entity_notice_roles r
			JOIN entities e ON r.entity_id = e.id
		GROUP BY r.notice_id
	),
	b AS MATERIALIZED (
		SELECT
			g.taggable_id AS notice_id,
			array_agg(t.name) FILTER (WHERE g.context = 'tags') AS tag_list,
			array_agg(t.name) FILTER (WHERE g.context = 'jurisdictions') AS jurisdictions_list,
			array_agg(t.name) FILTER (WHERE g.context = 'regulations') AS regulations_list
		FROM taggings g
			JOIN tags t ON g.tag_id = t.id
		WHERE g.taggable_type = 'Notice'
		GROUP BY g.taggable_id
	),
    c AS MATERIALIZED (
        SELECT
            a.notice_id,
            json_agg(json_build_object('id', t.id, 'name', t.name)) AS topics
        FROM topic_assignments a
            JOIN topics t ON a.topic_id = t.id
        GROUP BY a.notice_id
    )
SELECT
	n.id,
	n.title,
	n.body,
	n.date_received,
	n.created_at,
	n.updated_at,
	n.type as class_name,
	n.source,
	n.subject,
	n.body_original,
	n.date_sent,
	n.language,
	n.rescinded,
	n.action_taken,
	n.original_notice_id,
	n.spam,
	n.hidden,
	n.request_type,
	n.submission_id,
	n.mark_registration_number,
	n.published,
	n.counternotice_for_id,
	n.counternotice_for_sid,
	n.local_jurisdiction_laws,
	n.case_id_number,
	(
		SELECT json_agg(w - ARRAY['kind', 'description_original'])::text
		FROM jsonb_array_elements(n.works_json) x(w)
	) AS works,
	a.sender_name,
	a.recipient_name,
	a.submitter_name,
	a.principal_name,
	a.submitter_country_code,
	a.entities_country_codes,
	b.tag_list,
	b.jurisdictions_list,
	b.regulations_list,
	c.topics::text
FROM notices n
	LEFT JOIN a ON a.notice_id = n.id
	LEFT JOIN b ON b.notice_id = n.id
	LEFT JOIN c ON c.notice_id = n.id
ORDER BY n.id ASC
