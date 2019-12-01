<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <a class="navbar-brand" href="#">Navbar</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarSupportedContent">
        <ul class="navbar-nav mr-auto">
        </ul>
        <form class="form-inline my-2 my-lg-0">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                        <a class="nav-link" href="<?php echo e(route('cart')); ?>">
                            <i class="fas fa-shopping-cart mr-1"></i>
                            <span class="badge"><?php echo e(Session::has('cart') ? Session::get('cart')->totalQty :  ''); ?></span>
                            Shopping Cart
                        </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i class="fas fa-user mr-1"></i>Account
                    </a>
                    <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                        <a class="dropdown-item" href="#">Action</a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item" href="#">Logout</a>
                    </div>
                </li>
            </ul>
        </form>
    </div>
</nav>
<?php /**PATH C:\laragon\www\honeycomb-smart-contract\front-end\honeycomb\resources\views/components/header.blade.php ENDPATH**/ ?>