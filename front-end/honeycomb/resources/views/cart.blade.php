@extends('layouts.base')

<!-- Title-->
@section('title')
    Webshop
@endsection
<!-- End title -->
<!-- Content-->
@section('content')
    @if(Session::has('cart'))
        <div class="container">
            <div class="row">
                <div class="col-sm-4 col-md-4 offset-3 offset-sm-3">
                    <ul class="list-group">
                        @foreach($products as $product)
                            <li class="list-group-item d-flex justify-content-around">
                                <span class="badge">{{ $product['qty'] }}</span>
                                <strong>{{ $product['item']['title'] }}</strong>
                                <span class="label label-success">{{$product['price']}}</span>

                                <div class="btn-group">
                                    <button type="button" class="btn btn-primary dropdown-toggle">
                                        Action
                                        <ul class="dropdown-menu">
                                            <li><a href="">Reduce by 1</a></li>
                                            <li><a href="">Remove all</a></li>
                                        </ul>
                                    </button>
                                </div>
                            </li>
                        @endforeach
                    </ul>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-12 col-md-6 ">
                <strong>Total: {{ $totalPrice }}</strong>
                @if($totalPrice > 0)
                    <form>
                        <div class="form-group">
                            <label for="exampleFormControlSelect1">Start date</label>
                            <select class="form-control" id="exampleFormControlSelect1">
                                <option>80</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="exampleFormControlSelect1">End date</label>
                            <select class="form-control" id="exampleFormControlSelect1">
                                <option>90</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="exampleFormControlSelect1">Minimum wind speed</label>
                            <select class="form-control" id="exampleFormControlSelect1">
                                <option>5</option>
                                <option>7</option>
                                <option>9</option>
                            </select>
                        </div>
                    </form>
                <button class="btn btn-danger">Checkout</button>
                @endif
            </div>
        </div>

    @else

    @endif
@endsection
<!-- End content -->
