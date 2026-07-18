<?php

namespace App\Http\Controllers;

use App\Http\Resources\ReminderResource;
use App\Models\MaintenanceItem;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ReminderController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $user = $request->user();
        $vehicleIds = $user->vehicles()->pluck('id');

        $reminders = MaintenanceItem::query()
            ->whereHas('maintenance', function ($query) use ($vehicleIds) {
                $query->whereIn('vehicle_id', $vehicleIds);
            })
            ->where(function ($query) {
                $query->whereNotNull('next_due_date')
                      ->orWhereNotNull('next_due_mileage');
            })
            ->with(['maintenance.vehicle', 'maintenanceType'])
            ->get();

        return ReminderResource::collection($reminders);
    }
}
