# Create Extraction
POST {{BASE_URL_API}}/extractions
Authorization: Bearer {{API_KEY}}
Content-Type: application/json
{
    "usecaseId": "{{usecase_id}}",
    "documentType": "{{document_type}}",
    "filename": "{{filename}}",
    "fileData": "{{file_data}}"
}

HTTP 202
[Asserts]
jsonpath "$.status" == "processing"
[Captures]
document_id: jsonpath "$.documentId"
job_id: jsonpath "$.jobId"

# Get Extraction (with retry loop)
GET {{BASE_URL_API}}/extractions/{{job_id}}
Authorization: Bearer {{API_KEY}}
Content-Type: application/json
[Options]
retry: 20
retry-interval: 4000

HTTP 200
[Asserts]
jsonpath "$.documentId" == "{{document_id}}"
jsonpath "$.status" == "completed"
