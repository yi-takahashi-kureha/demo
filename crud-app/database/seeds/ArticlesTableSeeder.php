<?php
 
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
 
class ArticlesTableSeeder extends Seeder
{
   /**
    * Run the database seeds.
    *
    * @return void
    */
   public function run()
   {
       $titles = ['abc', 'edf', 'ghi'];
 
       foreach ($titles as $title) {
           DB::table('articles')->insert([
               'title' => $title,
               'body' => "test",
               'imagePath' => '/uploads/noimage.png',
               'created_at' => Carbon::now(),
               'updated_at' => Carbon::now(),
           ]);
       }
   }
}
