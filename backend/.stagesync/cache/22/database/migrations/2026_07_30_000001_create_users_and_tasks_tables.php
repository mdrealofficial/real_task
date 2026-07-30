<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->string('id', 64)->primary();
            $table->string('email', 191)->unique();
            $table->string('password_hash');
            $table->timestamps();
        });

        Schema::create('tasks', function (Blueprint $table) {
            $table->string('id', 64)->primary();
            $table->string('user_id', 64);
            $table->text('title');
            $table->text('description')->nullable();
            $table->string('status', 32);
            $table->string('priority', 16);
            $table->string('due_date', 64)->nullable();
            $table->string('start_time', 16)->nullable();
            $table->string('end_time', 16)->nullable();
            $table->text('tags_json')->nullable();
            $table->text('checklist_json')->nullable();
            $table->text('recurrence_json')->nullable();
            $table->text('reminders_json')->nullable();
            $table->integer('version')->default(1);
            $table->string('updated_at', 64)->nullable();
            $table->string('completed_at', 64)->nullable();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });

        // Seed Default Admin User
        DB::table('users')->insert([
            'id' => 'user-admin-1',
            'email' => 'mdreal.official@gmail.com',
            'password_hash' => Hash::make('Staritlab77'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
        Schema::dropIfExists('users');
    }
};
