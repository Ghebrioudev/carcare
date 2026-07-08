<?php

namespace App\Http\Controllers;

use App\Http\Requests\Vehicle\StoreVehicleRequest;
use App\Http\Requests\Vehicle\UpdateVehicleRequest;
use App\Http\Resources\VehicleResource;
use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class VehicleController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $vehicles = $request->user()
            ->vehicles()
            ->withCount('maintenances')
            ->latest()
            ->get();

        return VehicleResource::collection($vehicles);
    }

    public function store(StoreVehicleRequest $request): JsonResponse
    {
        $vehicle = $request->user()->vehicles()->create($request->validated());

        return response()->json([
            'data' => new VehicleResource($vehicle),
        ], 201);
    }

    public function show(Request $request, Vehicle $vehicle): VehicleResource
    {
        $this->authorizeVehicle($request, $vehicle);

        $vehicle->loadCount('maintenances');

        return new VehicleResource($vehicle);
    }

    public function update(UpdateVehicleRequest $request, Vehicle $vehicle): VehicleResource
    {
        $this->authorizeVehicle($request, $vehicle);

        $vehicle->update($request->validated());

        return new VehicleResource($vehicle->fresh());
    }

    public function destroy(Request $request, Vehicle $vehicle): JsonResponse
    {
        $this->authorizeVehicle($request, $vehicle);

        $vehicle->delete();

        return response()->json([
            'message' => 'Vehicle deleted successfully.',
        ]);
    }

    private function authorizeVehicle(Request $request, Vehicle $vehicle): void
    {
        abort_unless($vehicle->user_id === $request->user()->id, 403);
    }
}
