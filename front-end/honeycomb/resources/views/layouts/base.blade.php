<!doctype html>
<html lang="en">
<head>
    <!-- Meta description, Meta tags -->
    @include('layouts.meta')

    <!-- Base Css -->
    @include('layouts.css')

    <!-- Base Headscripts -->
    @include('layouts.headScripts')

    <!-- Custom page css -->
    @yield('css')

    <!-- Custom head scripts -->
    @yield('headScripts')
</head>
<body>

<div id="app">
    @include('components.header')
    <div class="container">
        @yield('content')
    </div>
    @include('components.footer')
</div>
<!-- base scripts -->
@include('layouts.scripts')
<!-- custom scripts -->
@yield('scripts')
</body>

</html>
