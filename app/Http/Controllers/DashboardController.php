<?php

namespace App\Http\Controllers;

use App\Http\Resources\MaintenanceResource;
use App\Models\Maintenance;
use App\Models\MaintenanceItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $vehicleIds = $user->vehicles()->pluck('id');

        $totalCost = Maintenance::query()
            ->whereIn('vehicle_id', $vehicleIds)
            ->sum('total_cost');

        $nextReminder = MaintenanceItem::query()
            ->whereHas('maintenance', fn ($query) => $query->whereIn('vehicle_id', $vehicleIds))
            ->whereNotNull('next_due_date')
            ->where('next_due_date', '>=', now()->toDateString())
            ->orderBy('next_due_date')
            ->with(['maintenance.vehicle', 'maintenanceType'])
            ->first();

        $recentMaintenances = Maintenance::query()
            ->whereIn('vehicle_id', $vehicleIds)
            ->with(['items.maintenanceType', 'vehicle'])
            ->latest('performed_at')
            ->limit(5)
            ->get();

        $monthlyCosts = [];
        for ($i = 5; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $monthName = $date->format('M');
            $cost = Maintenance::query()
                ->whereIn('vehicle_id', $vehicleIds)
                ->whereYear('performed_at', $date->year)
                ->whereMonth('performed_at', $date->month)
                ->sum('total_cost');

            $monthlyCosts[] = [
                'month' => $monthName,
                'cost' => (float) number_format((float) $cost, 2, '.', ''),
            ];
        }

        $categoryCostsRaw = MaintenanceItem::query()
            ->whereHas('maintenance', fn ($query) => $query->whereIn('vehicle_id', $vehicleIds))
            ->selectRaw('maintenance_type_id, SUM(cost) as total')
            ->groupBy('maintenance_type_id')
            ->with('maintenanceType')
            ->get();

        $categoryCosts = [];
        foreach ($categoryCostsRaw as $item) {
            if ($item->maintenanceType) {
                $categoryCosts[] = [
                    'category' => $item->maintenanceType->name,
                    'cost' => (float) number_format((float) $item->total, 2, '.', ''),
                ];
            }
        }

        return response()->json([
            'data' => [
                'vehicles_count' => $vehicleIds->count(),
                'total_cost' => number_format((float) $totalCost, 2, '.', ''),
                'next_reminder' => $nextReminder ? [
                    'maintenance_type' => $nextReminder->maintenanceType->name,
                    'next_due_date' => $nextReminder->next_due_date?->toDateString(),
                    'next_due_mileage' => $nextReminder->next_due_mileage,
                    'vehicle' => $nextReminder->maintenance->vehicle->only(['id', 'brand', 'model', 'license_plate']),
                ] : null,
                'recent_maintenances' => MaintenanceResource::collection($recentMaintenances),
                'monthly_costs' => $monthlyCosts,
                'category_costs' => $categoryCosts,
            ],
        ]);
    }
}
