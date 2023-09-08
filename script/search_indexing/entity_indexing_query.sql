SELECT
	e.id,
	e.name,
	e.kind,
	e.address_line_1,
	e.address_line_2,
	e.city,
	e.state,
	e.zip,
	e.country_code,
	e.phone,
	e.email,
	e.url,
	e.user_id,
	e.created_at at time zone 'utc' AS created_at,
	e.updated_at at time zone 'utc' AS updated_at,
    e.full_notice_only_researchers,
    e.address_line_1_original,
    e.address_line_2_original,
    e.city_original,
    e.state_original,
    e.country_code_original,
    e.zip_original,
    e.url_original,
	e.name_description
FROM entities AS e
	WHERE e.updated_at > :sql_last_value
	ORDER BY e.updated_at ASC
	LIMIT :size 
	OFFSET :offset
