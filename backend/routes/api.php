<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthApiController;
use App\Http\Controllers\Api\TaskApiController;

/*
|--------------------------------------------------------------------------
| TaskFlow API Routes
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {
    // Auth Routes
    Route::post('/auth/login', [AuthApiController::class, 'login']);
    Route::post('/auth/change-password', [AuthApiController::class, 'changePassword']);

    // Task Sync Routes
    Route::get('/tasks', [TaskApiController::class, 'index']);
    Route::post('/tasks/sync', [TaskApiController::class, 'sync']);
});
