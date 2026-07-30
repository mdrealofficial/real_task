<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'app' => 'TaskFlow REST API Backend',
        'status' => 'online',
        'version' => '1.0.0',
        'domain' => 'https://tasks.mdrealofficial.com'
    ]);
});
