<?php

namespace App\Http\Requests\Vehicle;

use App\Enums\FuelType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateVehicleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'remove_photo' => match (true) {
                is_bool($this->remove_photo) => $this->remove_photo,
                is_null($this->remove_photo) => null,
                default => filter_var($this->remove_photo, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE),
            },
        ]);
    }

    public function rules(): array
    {
        $vehicle = $this->route('vehicle');

        return [
            'brand' => ['sometimes', 'required', 'string', 'max:100'],
            'model' => ['sometimes', 'required', 'string', 'max:100'],
            'year' => ['sometimes', 'required', 'integer', 'min:1900', 'max:'.(date('Y') + 1)],
            'license_plate' => [
                'sometimes',
                'required',
                'string',
                'max:20',
                Rule::unique('vehicles')
                    ->where('user_id', $this->user()->id)
                    ->ignore($vehicle->id),
            ],
            'current_mileage' => ['sometimes', 'required', 'integer', 'min:0'],
            'fuel_type' => ['sometimes', 'required', Rule::enum(FuelType::class)],
            'photo' => ['nullable', 'image', 'max:4096'], // Max 4MB
            'remove_photo' => ['nullable', 'boolean'],
        ];
    }
}
