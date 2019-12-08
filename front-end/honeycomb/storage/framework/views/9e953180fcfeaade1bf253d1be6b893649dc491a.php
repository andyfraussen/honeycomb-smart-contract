<!-- Title-->
<?php $__env->startSection('title'); ?>
    Test Payment
<?php $__env->stopSection(); ?>
<!-- End title -->
<?php $__env->startSection('content'); ?>
<div class="container">
    <div class="col-12 d-flex justify-content-center">
        <div class="container-fluid d-flex justify-content-center">
            <div class="col-4 d-flex flex-column justify-content-center text-centergi" id="testbox">
                <h1>get wallet address</h1>
                <input id="testbtn" type='button' class="btn btn-danger" onclick="click" value="click">
            </div>
        </div>
    </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.base', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?><?php /**PATH /Users/fraussen/Projects/honeycomb-smart-contract/front-end/honeycomb/resources/views/payment.blade.php ENDPATH**/ ?>