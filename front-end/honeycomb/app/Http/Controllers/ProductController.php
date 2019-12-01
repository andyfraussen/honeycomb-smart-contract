<?php

namespace App\Http\Controllers;

use App\Product;
use App\Cart;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::all();

        return view('index', ['products' => $products]);
    }

    public function AddToCart(Request $request, $id)
    {
        $product = Product::find($id);
        $oldCart = Session::has('cart') ? Session::get('cart') : null;
        $cart = new Cart($oldCart);
        $cart->add($product, $product->id);

        $request->session()->put('cart', $cart);

        return redirect()->back();
    }

    public function ShowCart()
    {
        if(!Session::has('cart')){
            return view('cart');
        }
        $oldCart = Session::get('cart');
        $cart = new Cart($oldCart);

        return view('cart',  ['products' => $cart->items, 'totalPrice' => $cart->totalPrice]);
    }
}
