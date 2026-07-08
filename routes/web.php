<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('test');
});

Route::get('/ningas', function () {
    $ninjas = [
        ['name' => 'Naruto', 'id' => 1],
        ['name' => 'Sasuke', 'id' => 2],
        ['name' => 'Sakura', 'id' => 3],
    ];
    return view('khiro.index', ["greting" => "Hello", "ninjas" => $ninjas ]);
});

Route::get('/ningas', function () {
    return view('khiro.index2');
});
