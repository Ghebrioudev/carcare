<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\MaintenanceController;
use App\Http\Controllers\MaintenanceTypeController;
use App\Http\Controllers\VehicleController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);

    Route::apiResource('vehicles', VehicleController::class);

    Route::get('/maintenance-types', [MaintenanceTypeController::class, 'index']);

    Route::get('/vehicles/{vehicle}/maintenances', [MaintenanceController::class, 'index']);
    Route::post('/vehicles/{vehicle}/maintenances', [MaintenanceController::class, 'store']);
    Route::get('/maintenances/{maintenance}', [MaintenanceController::class, 'show']);
    Route::put('/maintenances/{maintenance}', [MaintenanceController::class, 'update']);
    Route::delete('/maintenances/{maintenance}', [MaintenanceController::class, 'destroy']);

    Route::get('/dashboard', [DashboardController::class, 'index']);
});
