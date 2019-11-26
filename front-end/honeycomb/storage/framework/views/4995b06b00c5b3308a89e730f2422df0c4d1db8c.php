<!doctype html>
<html lang="en">
<head>
    <!-- Meta description, Meta tags -->
    <?php echo $__env->make('layouts.meta', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?>

    <!-- Base Css -->
    <?php echo $__env->make('layouts.css', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?>

    <!-- Custom page css -->
    <?php echo $__env->yieldContent('css'); ?>

    <!-- Custom head scripts -->
    <?php echo $__env->yieldContent('headScripts'); ?>
</head>
<body>

<div id="app">
    <?php echo $__env->make('components.header', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?>
    <?php echo $__env->yieldContent('content'); ?>
    <?php echo $__env->make('components.footer', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?>
</div>
<!-- base scripts -->
<?php echo $__env->make('layouts.scripts', \Illuminate\Support\Arr::except(get_defined_vars(), ['__data', '__path']))->render(); ?>
<!-- custom scripts -->
<?php echo $__env->yieldContent('scripts'); ?>
</body>

</html>
<?php /**PATH /Users/andy/Projects/honeycomb-smart-contract/front-end/honeycomb/resources/views/layouts/base.blade.php ENDPATH**/ ?>