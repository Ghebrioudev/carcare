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

        $maintenances = $vehicle->maintenances()
            ->with(['items.maintenanceType'])
            ->latest('performed_at')
            ->get();

        return MaintenanceResource::collection($maintenances);
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
