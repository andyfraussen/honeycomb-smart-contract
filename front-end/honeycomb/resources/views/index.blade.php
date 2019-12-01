@extends('layouts.base')

<!-- Title-->
@section('title')
    Webshop
@endsection
<!-- End title -->
<!-- Content-->
@section('content')
    <div class="container">
        @foreach($products->chunk(3) as $chunk)
            <div class="row mt-3">
                @foreach($chunk as $product)
                    <div class="col-sm-6 col-md-4">
                        <div class="card" style="width: 17rem;">
                            <img src="{{$product->imagePath === null ? 'https://desenio.be/bilder/artiklar/zoom/12643_2.jpg' : $product->imagePath}}" class="card-img-top" alt="...">
                            <div class="card-body">
                                <h5 class="card-title">{{$product->title}}</h5>
                                <p class="card-text">{{$product->description}}</p>
                                <div class="d-flex justify-content-between">
                                    <p class="card-text">{{$product->price}}</p>
                                    <a href="{{route('add-to-cart', ['id' => $product->id])}}" class="btn btn btn-primary">Buy</a>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
        @endforeach
    </div>
@endsection
<!-- End content -->
