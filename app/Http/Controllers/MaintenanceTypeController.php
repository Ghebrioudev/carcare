<?php

namespace App\Http\Controllers;

use App\Http\Resources\MaintenanceTypeResource;
use App\Models\MaintenanceType;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class MaintenanceTypeController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return MaintenanceTypeResource::collection(
            MaintenanceType::orderBy('name')->get()
        );
    }
}
