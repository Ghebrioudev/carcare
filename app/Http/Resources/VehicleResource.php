<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VehicleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'brand' => $this->brand,
            'model' => $this->model,
            'year' => $this->year,
            'license_plate' => $this->license_plate,
            'current_mileage' => $this->current_mileage,
            'fuel_type' => $this->fuel_type->value,
            'photo_path' => $this->photo_path,
            'maintenances_count' => $this->whenCounted('maintenances'),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
