GET {{BASE_URL_API}}/usecases/{{usecase_id}}
Authorization: Bearer {{API_KEY}}
Content-Type: application/json

HTTP 200
[Asserts]
jsonpath "$.id" isString
jsonpath "$.name" isString
jsonpath "$.documentTypes" isCollection
