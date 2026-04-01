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

$scriptDir = __DIR__;
loadEnv($scriptDir);

if (php_sapi_name() !== 'cli') {
    /**
     * Webhook request handler (runs inside the PHP built-in server).
     */
    
    // We use php://stderr to ensure logs appear in the terminal
    $log = fopen('php://stderr', 'w');
    
    $webhookSecret = getenv('WEBHOOK_SECRET');
    $signature = $_SERVER['HTTP_X_DOCLOOP_SIGNATURE'] ?? '';
    $rawBody = file_get_contents('php://input');

    fwrite($log, "\n=== New Request " . date('Y-m-d H:i:s') . " ===\n");
    fwrite($log, "Request: " . $_SERVER['REQUEST_METHOD'] . " " . $_SERVER['REQUEST_URI'] . "\n\n");
    fwrite($log, "--- Headers ---\n");
    foreach (getallheaders() as $name => $value) {
        fwrite($log, "$name: $value\n");
    }

    if ($rawBody) {
        fwrite($log, "\n--- Body ---\n");
        if ($webhookSecret) {
            // Signature Verification
            $cleanSignature = str_replace('sha256=', '', $signature);
            $computedSignature = hash_hmac('sha256', $rawBody, $webhookSecret);

            if (hash_equals($cleanSignature, $computedSignature)) {
                fwrite($log, "✅ Signature verified!\n");
            } else {
                fwrite($log, "❌ Invalid signature!\n");
                fwrite($log, "   Received: $signature\n");
                fwrite($log, "   Computed: $computedSignature\n");
            }
        } else {
            fwrite($log, "⚠️ WEBHOOK_SECRET not set, skipping signature verification.\n");
        }

        // Try to pretty print JSON body
        $decoded = json_decode($rawBody);
        if ($decoded) {
            fwrite($log, json_encode($decoded, JSON_PRETTY_PRINT) . "\n");
        } else {
            fwrite($log, $rawBody . "\n");
        }
    }
    fwrite($log, "================\n");
    fclose($log);

    header('Content-Type: application/json');
    echo json_encode(['status' => 'ok', 'message' => 'Request received']);
    exit;
}

/**
 * Main CLI entry point to start the server.
 */
$port = $argv[1] ?? getenv('WEBHOOK_PORT') ?: '5555';

echo "Starting PHP built-in server on port $port...\n";
echo "Use a tool like ngrok to expose this port to the internet.\n";
echo "Press Ctrl+C to stop.\n";

// Start the built-in server using THIS script as the router
$command = sprintf('php -S localhost:%d %s', $port, escapeshellarg(__FILE__));
passthru($command);
