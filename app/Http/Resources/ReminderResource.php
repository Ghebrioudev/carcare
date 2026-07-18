<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReminderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'item_id' => $this->id,
            'maintenance_id' => $this->maintenance_id,
            'vehicle_id' => $this->maintenance->vehicle_id,
            'vehicle_name' => $this->maintenance->vehicle->brand . ' ' . $this->maintenance->vehicle->model,
            'license_plate' => $this->maintenance->vehicle->license_plate,
            'current_mileage' => $this->maintenance->vehicle->current_mileage,
            'maintenance_type_name' => $this->maintenanceType->name,
            'next_due_date' => $this->next_due_date?->toDateString(),
            'next_due_mileage' => $this->next_due_mileage,
        ];
    }
}
