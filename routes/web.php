<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('test');
});

Route::get('/1', function () {
    return view('khiro.index');
});
