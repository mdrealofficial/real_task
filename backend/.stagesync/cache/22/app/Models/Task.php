<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'user_id',
        'title',
        'description',
        'status',
        'priority',
        'due_date',
        'start_time',
        'end_time',
        'tags_json',
        'checklist_json',
        'recurrence_json',
        'reminders_json',
        'version',
        'updated_at',
        'completed_at',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
