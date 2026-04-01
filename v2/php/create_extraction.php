<?php

/**
 * Simple .env file loader.
 */
function loadEnv($dir) {
    $path = $dir . '/.env';
    if (!file_exists($path)) return;
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            list($name, $value) = explode('=', $line, 2);
            putenv(trim($name) . '=' . trim($value));
        }
    }
}

loadEnv(__DIR__);

// Parameter validation
if ($argc < 4) {
    die("Usage: php create_extraction.php <usecaseid> <documenttype> <filepath>\n");
}

list(, $usecaseId, $documentType, $filePath) = $argv;

if (!file_exists($filePath)) {
    die("Error: File not found: $filePath\n");
}

$apiKey = getenv('API_KEY');
$baseUrl = getenv('BASE_URL_API');
$webhookUrl = getenv('WEBHOOK_URL');

// Validate environment
if (!$apiKey || !$baseUrl) {
    die("Error: API_KEY or BASE_URL_API not set in environment.\n");
}

$url = $baseUrl . '/extractions';

// Prepare payload: API v2 expects base64 encoded string for fileData
$fileName = basename($filePath);
$fileData = base64_encode(file_get_contents($filePath));

$payload = [
    'usecaseId' => $usecaseId,
    'documentType' => $documentType,
    'filename' => $fileName,
    'fileData' => $fileData,
    'webhookUrl' => $webhookUrl
];

$ch = curl_init($url);

// Configure cURL for POST request with JSON payload
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $apiKey, // API v2 uses Bearer Token
    'Content-Type: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if (curl_errno($ch)) {
    echo 'Error: ' . curl_error($ch) . "\n";
} else {
    if ($httpCode >= 200 && $httpCode < 300) {
        echo "Extraction created successfully!\n";
    } else {
        echo "Error: HTTP $httpCode\n";
    }
    
    // Output response
    $decoded = json_decode($response);
    echo json_encode($decoded, JSON_PRETTY_PRINT) . "\n";
}

curl_close($ch);
