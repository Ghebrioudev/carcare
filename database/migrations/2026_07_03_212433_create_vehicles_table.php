<?php

use App\Enums\FuelType;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('brand', 100);
            $table->string('model', 100);
            $table->unsignedSmallInteger('year');
            $table->string('license_plate', 20);
            $table->unsignedInteger('current_mileage');
            $table->enum('fuel_type', array_column(FuelType::cases(), 'value'));
            $table->string('photo_path')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'license_plate']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vehicles');
    }
};
