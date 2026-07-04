<?php

namespace App\Enums;

enum FuelType: string
{
    case Gasoline = 'gasoline';
    case Diesel = 'diesel';
    case Electric = 'electric';
    case Hybrid = 'hybrid';
    case Lpg = 'lpg';
}
