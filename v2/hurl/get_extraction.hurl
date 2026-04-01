GET {{BASE_URL_API}}/extractions/{{job_id}}
Authorization: Bearer {{API_KEY}}
Content-Type: application/json
[Options]
retry: 20
retry-interval: 4000

HTTP 200
[Asserts]
jsonpath "$.status" == "completed"
