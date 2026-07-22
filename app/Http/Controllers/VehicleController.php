<?php

namespace App\Http\Controllers;

use App\Http\Requests\Vehicle\StoreVehicleRequest;
use App\Http\Requests\Vehicle\UpdateVehicleRequest;
use App\Http\Resources\VehicleResource;
use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Storage;

class VehicleController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = $request->user()
            ->vehicles()
            ->withCount('maintenances');

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('brand', 'like', "%{$search}%")
                  ->orWhere('model', 'like', "%{$search}%")
                  ->orWhere('license_plate', 'like', "%{$search}%");
            });
        }

        $sort = $request->query('sort', 'latest');
        switch ($sort) {
            case 'brand_asc':
                $query->orderBy('brand', 'asc');
                break;
            case 'brand_desc':
                $query->orderBy('brand', 'desc');
                break;
            case 'year_asc':
                $query->orderBy('year', 'asc');
                break;
            case 'year_desc':
                $query->orderBy('year', 'desc');
                break;
            case 'mileage_asc':
                $query->orderBy('current_mileage', 'asc');
                break;
            case 'mileage_desc':
                $query->orderBy('current_mileage', 'desc');
                break;
            case 'latest':
            default:
                $query->latest();
                break;
        }

        return VehicleResource::collection($query->get());
    }

    public function store(StoreVehicleRequest $request): JsonResponse
    {
        $data = $request->validated();

        if ($request->hasFile('photo')) {
            $data['photo_path'] = $request->file('photo')->store('vehicles', 'public');
        }

        $vehicle = $request->user()->vehicles()->create($data);

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

        $data = $request->validated();

        // Handle photo replacement
        if ($request->hasFile('photo')) {
            // Delete old photo if exists
            if ($vehicle->photo_path) {
                Storage::disk('public')->delete($vehicle->photo_path);
            }
            $data['photo_path'] = $request->file('photo')->store('vehicles', 'public');
        } elseif ($request->has('remove_photo') && $request->remove_photo) {
            // Remove photo if requested
            if ($vehicle->photo_path) {
                Storage::disk('public')->delete($vehicle->photo_path);
            }
            $data['photo_path'] = null;
        }

        $vehicle->update($data);

        return new VehicleResource($vehicle->fresh());
    }

    public function destroy(Request $request, Vehicle $vehicle): JsonResponse
    {
        $this->authorizeVehicle($request, $vehicle);

        // Delete photo if exists
        if ($vehicle->photo_path) {
            Storage::disk('public')->delete($vehicle->photo_path);
        }

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
