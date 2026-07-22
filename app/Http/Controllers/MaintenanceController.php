<?php

namespace App\Http\Controllers;

use App\Http\Requests\Maintenance\StoreMaintenanceRequest;
use App\Http\Requests\Maintenance\UpdateMaintenanceRequest;
use App\Http\Resources\MaintenanceResource;
use App\Models\Maintenance;
use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;

class MaintenanceController extends Controller
{
    public function index(Request $request, Vehicle $vehicle): AnonymousResourceCollection
    {
        $this->authorizeVehicle($request, $vehicle);

        $query = $vehicle->maintenances()->with(['items.maintenanceType']);

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('notes', 'like', "%{$search}%")
                  ->orWhere('garage_name', 'like', "%{$search}%")
                  ->orWhereHas('items', function ($itemQuery) use ($search) {
                      $itemQuery->whereHas('maintenanceType', function ($typeQuery) use ($search) {
                          $typeQuery->where('name', 'like', "%{$search}%");
                      });
                  });
            });
        }

        if ($type = $request->query('type')) {
            $query->whereHas('items', function ($itemQuery) use ($type) {
                $itemQuery->where('maintenance_type_id', $type);
            });
        }

        $sort = $request->query('sort', 'date_desc');
        switch ($sort) {
            case 'date_asc':
                $query->orderBy('performed_at', 'asc');
                break;
            case 'cost_asc':
                $query->orderBy('total_cost', 'asc');
                break;
            case 'cost_desc':
                $query->orderBy('total_cost', 'desc');
                break;
            case 'mileage_asc':
                $query->orderBy('mileage', 'asc');
                break;
            case 'mileage_desc':
                $query->orderBy('mileage', 'desc');
                break;
            case 'date_desc':
            default:
                $query->orderBy('performed_at', 'desc');
                break;
        }

        return MaintenanceResource::collection($query->get());
    }

    public function store(StoreMaintenanceRequest $request, Vehicle $vehicle): JsonResponse
    {
        $this->authorizeVehicle($request, $vehicle);

        $maintenance = DB::transaction(function () use ($request, $vehicle) {
            $data = $request->validated();
            $items = $data['items'];
            unset($data['items']);

            $maintenance = $vehicle->maintenances()->create($data);
            $maintenance->items()->createMany($items);

            return $maintenance;
        });

        $maintenance->load(['items.maintenanceType']);

        return response()->json([
            'data' => new MaintenanceResource($maintenance),
        ], 201);
    }

    public function show(Request $request, Maintenance $maintenance): MaintenanceResource
    {
        $this->authorizeMaintenance($request, $maintenance);

        $maintenance->load(['items.maintenanceType', 'vehicle']);

        return new MaintenanceResource($maintenance);
    }

    public function update(UpdateMaintenanceRequest $request, Maintenance $maintenance): MaintenanceResource
    {
        $this->authorizeMaintenance($request, $maintenance);

        DB::transaction(function () use ($request, $maintenance) {
            $data = $request->validated();

            if (array_key_exists('items', $data)) {
                $items = $data['items'];
                unset($data['items']);

                $maintenance->items()->delete();
                $maintenance->items()->createMany($items);
            }

            $maintenance->update($data);
        });

        $maintenance->load(['items.maintenanceType']);

        return new MaintenanceResource($maintenance->fresh());
    }

    public function destroy(Request $request, Maintenance $maintenance): JsonResponse
    {
        $this->authorizeMaintenance($request, $maintenance);

        $maintenance->delete();

        return response()->json([
            'message' => 'Maintenance deleted successfully.',
        ]);
    }

    private function authorizeVehicle(Request $request, Vehicle $vehicle): void
    {
        abort_unless($vehicle->user_id === $request->user()->id, 403);
    }

    private function authorizeMaintenance(Request $request, Maintenance $maintenance): void
    {
        abort_unless($maintenance->vehicle->user_id === $request->user()->id, 403);
    }
}
