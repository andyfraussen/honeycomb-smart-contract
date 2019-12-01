<!-- Title-->
<?php $__env->startSection('title'); ?>
    Webshop
<?php $__env->stopSection(); ?>
<!-- End title -->
<!-- Content-->
<?php $__env->startSection('content'); ?>
    <?php if(Session::has('cart')): ?>
        <div class="container">
            <div class="row">
                <div class="col-sm-4 col-md-4 offset-3 offset-sm-3">
                    <ul class="list-group">
                        <?php $__currentLoopData = $products; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $product): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                            <li class="list-group-item d-flex justify-content-around">
                                <span class="badge"><?php echo e($product['qty']); ?></span>
                                <strong><?php echo e($product['item']['title']); ?></strong>
                                <span class="label label-success"><?php echo e($product['price']); ?></span>

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
                        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                    </ul>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-12 col-md-6 ">
                <strong>Total: <?php echo e($totalPrice); ?></strong>
                <?php if($totalPrice > 0): ?>
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
                <?php endif; ?>
            </div>
        </div>

    <?php else: ?>

    <?php endif; ?>
<?php $__env->stopSection(); ?>
<!-- End content -->

<?php echo $__env->make('layouts.base', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH C:\laragon\www\honeycomb-smart-contract\front-end\honeycomb\resources\views/cart.blade.php ENDPATH**/ ?>