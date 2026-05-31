GET {{BASE_URL_API}}/usecases
Authorization: Bearer {{API_KEY}}
Content-Type: application/json

HTTP 200
[Asserts]
jsonpath "$" isCollection
