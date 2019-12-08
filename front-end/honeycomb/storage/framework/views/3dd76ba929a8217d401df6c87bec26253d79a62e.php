<!-- Title-->
<?php $__env->startSection('title'); ?>
    Webshop
<?php $__env->stopSection(); ?>
<!-- End title -->
<!-- Content-->
<?php $__env->startSection('content'); ?>
    <div class="container">
        <?php $__currentLoopData = $products->chunk(3); $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $chunk): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
            <div class="row mt-3">
                <?php $__currentLoopData = $chunk; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $product): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                    <div class="col-sm-6 col-md-4">
                        <div class="card" style="width: 17rem;">
                            <img src="<?php echo e($product->imagePath === null ? 'https://desenio.be/bilder/artiklar/zoom/12643_2.jpg' : $product->imagePath); ?>" class="card-img-top" alt="...">
                            <div class="card-body">
                                <h5 class="card-title"><?php echo e($product->title); ?></h5>
                                <p class="card-text"><?php echo e($product->description); ?></p>
                                <div class="d-flex justify-content-between">
                                    <p class="card-text"><?php echo e($product->price); ?></p>
                                    <a href="<?php echo e(route('add-to-cart', ['id' => $product->id])); ?>" class="btn btn btn-primary">Buy</a>
                                </div>
                            </div>
                        </div>
                    </div>
                <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
    </div>
<?php $__env->stopSection(); ?>
<!-- End content -->

<?php echo $__env->make('layouts.base', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH /Users/fraussen/Projects/honeycomb-smart-contract/front-end/honeycomb/resources/views/index.blade.php ENDPATH**/ ?>