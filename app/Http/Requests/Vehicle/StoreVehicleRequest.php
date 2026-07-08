<?php

namespace App\Http\Requests\Vehicle;

use App\Enums\FuelType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreVehicleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'brand' => ['required', 'string', 'max:100'],
            'model' => ['required', 'string', 'max:100'],
            'year' => ['required', 'integer', 'min:1900', 'max:'.(date('Y') + 1)],
            'license_plate' => [
                'required',
                'string',
                'max:20',
                Rule::unique('vehicles')->where('user_id', $this->user()->id),
            ],
            'current_mileage' => ['required', 'integer', 'min:0'],
            'fuel_type' => ['required', Rule::enum(FuelType::class)],
            'photo_path' => ['nullable', 'string', 'max:255'],
        ];
    }
}
