<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Web\TaskWebController;

/*
|--------------------------------------------------------------------------
| Web Routes — Personal Task Management App ("Task Flow")
|--------------------------------------------------------------------------
*/

Route::get('/', [TaskWebController::class, 'index'])->name('dashboard');
Route::get('/login', [TaskWebController::class, 'showLogin'])->name('login');
Route::post('/login', [TaskWebController::class, 'login'])->name('login.post');
Route::get('/logout', [TaskWebController::class, 'logout'])->name('logout');

Route::post('/tasks', [TaskWebController::class, 'store'])->name('tasks.store');
Route::post('/tasks/{id}/toggle', [TaskWebController::class, 'toggleStatus'])->name('tasks.toggle');
Route::post('/tasks/{id}/status', [TaskWebController::class, 'updateStatus'])->name('tasks.updateStatus');
Route::post('/tasks/{id}/update', [TaskWebController::class, 'update'])->name('tasks.update');
Route::delete('/tasks/{id}', [TaskWebController::class, 'destroy'])->name('tasks.destroy');

Route::get('/api-status', function () {
    return response()->json([
        'app' => 'TaskFlow REST API Backend',
        'status' => 'online',
        'version' => '1.0.18',
        'domain' => 'https://tasks.mdrealofficial.com'
    ]);
});
