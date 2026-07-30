<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes — Personal Task Management App ("Task Flow")
|--------------------------------------------------------------------------
*/

Route::get('/', function () {
    return view('app');
});

Route::get('/api-status', function () {
    return response()->json([
        'app' => 'TaskFlow REST API Backend',
        'status' => 'online',
        'version' => '1.0.14',
        'domain' => 'https://tasks.mdrealofficial.com'
    ]);
});
