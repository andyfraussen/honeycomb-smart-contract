<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', 'ProductController@index');

Route::get('/payment', 'paymentController@test');

Auth::routes();

Route::get('/home', 'HomeController@index')->name('home');



// ADMIN

Route::get('admin/home', 'HomeController@adminHome')->name('admin.home')->middleware('is_admin');
