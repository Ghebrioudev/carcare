<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MaintenanceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'vehicle_id' => $this->vehicle_id,
            'performed_at' => $this->performed_at->toDateString(),
            'mileage' => $this->mileage,
            'garage_name' => $this->garage_name,
            'total_cost' => $this->total_cost,
            'notes' => $this->notes,
            'items' => MaintenanceItemResource::collection($this->whenLoaded('items')),
            'vehicle' => new VehicleResource($this->whenLoaded('vehicle')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
