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

Route::get('/home', 'HomeController@index')->name('home');

// USER
Auth::routes();

// ADMIN
Route::get('admin/home', 'HomeController@adminHome')->name('admin.home')->middleware('is_admin');

// CART

Route::get('add-to-cart/{id}', 'ProductController@AddToCart')->name('add-to-cart');
Route::get('shopping-cart', 'ProductController@ShowCart')->name('cart');
