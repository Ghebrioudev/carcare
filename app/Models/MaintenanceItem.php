<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MaintenanceItem extends Model
{
    protected $fillable = [
        'maintenance_id',
        'maintenance_type_id',
        'next_due_date',
        'next_due_mileage',
        'notes',
        'cost',
    ];

    protected function casts(): array
    {
        return [
            'next_due_date' => 'date',
            'next_due_mileage' => 'integer',
            'cost' => 'decimal:2',
        ];
    }

    public function maintenance(): BelongsTo
    {
        return $this->belongsTo(Maintenance::class);
    }

    public function maintenanceType(): BelongsTo
    {
        return $this->belongsTo(MaintenanceType::class);
    }
}
