<?php

namespace App\Http\Requests\Maintenance;

use Illuminate\Foundation\Http\FormRequest;

class StoreMaintenanceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'performed_at' => ['required', 'date', 'before_or_equal:today'],
            'mileage' => ['required', 'integer', 'min:0'],
            'garage_name' => ['nullable', 'string', 'max:150'],
            'total_cost' => ['required', 'numeric', 'min:0', 'decimal:0,2'],
            'notes' => ['nullable', 'string', 'max:1000'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.maintenance_type_id' => ['required', 'integer', 'exists:maintenance_types,id'],
            'items.*.next_due_date' => ['nullable', 'date', 'after:today'],
            'items.*.next_due_mileage' => ['nullable', 'integer', 'min:0'],
            'items.*.notes' => ['nullable', 'string', 'max:1000'],
            'items.*.cost' => ['nullable', 'numeric', 'min:0', 'decimal:0,2'],
        ];
    }
}
