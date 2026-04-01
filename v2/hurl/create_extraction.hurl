POST {{BASE_URL_API}}/extractions
Authorization: Bearer {{API_KEY}}
Content-Type: application/json
{
    "usecaseId": "{{usecase_id}}",
    "documentType": "{{document_type}}",
    "filename": "{{filename}}",
    "fileData": "{{file_data}}",
    "webhookUrl": "{{WEBHOOK_URL}}"
}

HTTP 202
[Asserts]
jsonpath "$.status" == "processing"
[Captures]
document_id: jsonpath "$.documentId"
job_id: jsonpath "$.jobId"
