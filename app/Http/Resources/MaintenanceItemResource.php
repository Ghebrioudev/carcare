<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MaintenanceItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'maintenance_type_id' => $this->maintenance_type_id,
            'maintenance_type' => new MaintenanceTypeResource($this->whenLoaded('maintenanceType')),
            'next_due_date' => $this->next_due_date?->toDateString(),
            'next_due_mileage' => $this->next_due_mileage,
            'notes' => $this->notes,
            'cost' => $this->cost,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
