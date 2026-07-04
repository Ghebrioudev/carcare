<?php

namespace Database\Seeders;

use App\Models\MaintenanceType;
use Illuminate\Database\Seeder;

class MaintenanceTypeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $types = [
            'Vidange',
            'Changement du filtre à huile',
            'Changement du filtre à air',
            'Batterie',
            'Pneus',
            'Freins',
            'Climatisation',
            'Contrôle technique',
            'Assurance',
            'Autre',
        ];

        foreach ($types as $type) {
            MaintenanceType::firstOrCreate(['name' => $type]);
        }
    }
}
