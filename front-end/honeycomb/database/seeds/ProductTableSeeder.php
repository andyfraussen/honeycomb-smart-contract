<?php

use Illuminate\Database\Seeder;

class ProductTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $product = new \App\Product([

            'title' => 'Surfboard',
            'description' => "A well made board",
            'price' => 0.5
        ]);
        $product->save();

        $product = new \App\Product([

            'title' => 'Surfboard',
            'description' => "A well made board",
            'price' => 0.5
        ]);
        $product->save();

        $product = new \App\Product([

            'title' => 'Surfboard',
            'description' => "A well made board",
            'price' => 0.5
        ]);
        $product->save();

        $product = new \App\Product([

            'title' => 'Surfboard',
            'description' => "A well made board",
            'price' => 0.5
        ]);

        $product = new \App\Product([

            'title' => 'Surfboard',
            'description' => "A well made board",
            'price' => 0.5
        ]);
        $product->save();
    }
}
