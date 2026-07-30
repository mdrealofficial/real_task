<?php

return [
    'name' => env('APP_NAME', 'TaskFlowAPI'),
    'env' => env('APP_ENV', 'production'),
    'debug' => (bool) env('APP_DEBUG', false),
    'url' => env('APP_URL', 'https://tasks.mdrealofficial.com'),
    'timezone' => 'UTC',
    'locale' => 'en',
    'fallback_locale' => 'en',
    'faker_locale' => 'en_US',
    'key' => env('APP_KEY', 'base64:X8v5nK9q7M3L1P4R6T0V2W4Y6Z8A0B2C4D6E8F0G2H4='),
    'cipher' => 'AES-256-CBC',
];
