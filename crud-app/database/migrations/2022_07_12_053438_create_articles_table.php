<?php
 
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
 
class CreateArticlesTable extends Migration
{
   /**
    * Run the migrations.
    *
    * @return void
    */
   public function up()
   {
	/*** 内容 ***/
       Schema::create('articles', function (Blueprint $table) {
           $table->increments('id');
           $table->string('title');
           $table->string('body');
           $table->string('imagePath');
           $table->timestamps();
       });
   }
 
   /**
    * Reverse the migrations.
    *
    * @return void
    */
   public function down()
   {
       Schema::dropIfExists('articles');
   }
}
