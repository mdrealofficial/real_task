<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'email',
        'password_hash',
    ];

    protected $hidden = [
        'password_hash',
    ];

    public function tasks()
    {
        return $this->hasMany(Task::class, 'user_id');
    }
}
