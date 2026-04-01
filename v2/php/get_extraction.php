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
if ($argc < 2) {
    die("Usage: php get_extraction.php <jobId>\n");
}

$jobId = $argv[1];

$apiKey = getenv('API_KEY');
$baseUrl = getenv('BASE_URL_API');

// Validate environment
if (!$apiKey || !$baseUrl) {
    die("Error: API_KEY or BASE_URL_API not set in environment.\n");
}

$url = $baseUrl . '/extractions/' . $jobId;

$ch = curl_init($url);

// Configure cURL for GET request
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $apiKey // API v2 uses Bearer Token
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if (curl_errno($ch)) {
    echo 'Error: ' . curl_error($ch) . "\n";
} else {
    if ($httpCode >= 200 && $httpCode < 300) {
        echo "Extraction retrieved successfully!\n";
    } else {
        echo "Error: HTTP $httpCode\n";
    }
    
    // Output response
    $decoded = json_decode($response);
    echo json_encode($decoded, JSON_PRETTY_PRINT) . "\n";
}

curl_close($ch);
