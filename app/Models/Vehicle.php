<?php

namespace App\Models;

use App\Enums\FuelType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Storage;

class Vehicle extends Model
{
    protected $fillable = [
        'user_id',
        'brand',
        'model',
        'year',
        'license_plate',
        'current_mileage',
        'fuel_type',
        'photo_path',
    ];

    protected function casts(): array
    {
        return [
            'year' => 'integer',
            'current_mileage' => 'integer',
            'fuel_type' => FuelType::class,
        ];
    }

    public function getPhotoUrlAttribute(): ?string
    {
        return $this->photo_path ? url(Storage::url($this->photo_path)) : null;
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function maintenances(): HasMany
    {
        return $this->hasMany(Maintenance::class);
    }
}
