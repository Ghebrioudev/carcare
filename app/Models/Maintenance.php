<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Maintenance extends Model
{
    protected $fillable = [
        'vehicle_id',
        'performed_at',
        'mileage',
        'garage_name',
        'total_cost',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'performed_at' => 'date',
            'mileage' => 'integer',
            'total_cost' => 'decimal:2',
        ];
    }

    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(Vehicle::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(MaintenanceItem::class);
    }
}
