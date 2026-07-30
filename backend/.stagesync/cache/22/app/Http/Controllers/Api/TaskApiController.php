<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Task;

class TaskApiController extends Controller
{
    /**
     * Get all tasks for user
     */
    public function index(Request $request)
    {
        $userId = $request->query('user_id');
        if (!$userId) {
            return response()->json(['success' => false, 'message' => 'User ID is required.'], 400);
        }

        $tasks = Task::where('user_id', $userId)->get();

        return response()->json([
            'success' => true,
            'tasks' => $tasks,
        ]);
    }

    /**
     * Upsert and sync task batch
     */
    public function sync(Request $request)
    {
        $userId = $request->input('user_id');
        $tasksData = $request->input('tasks', []);

        if (!$userId) {
            return response()->json(['success' => false, 'message' => 'User ID is required.'], 400);
        }

        foreach ($tasksData as $taskData) {
            Task::updateOrCreate(
                ['id' => $taskData['id']],
                [
                    'user_id' => $userId,
                    'title' => $taskData['title'],
                    'description' => $taskData['description'] ?? null,
                    'status' => $taskData['status'],
                    'priority' => $taskData['priority'],
                    'due_date' => $taskData['dueDate'] ?? null,
                    'start_time' => $taskData['startTime'] ?? null,
                    'end_time' => $taskData['endTime'] ?? null,
                    'tags_json' => isset($taskData['tags']) ? implode(',', $taskData['tags']) : null,
                    'checklist_json' => isset($taskData['checklist']) ? json_encode($taskData['checklist']) : null,
                    'recurrence_json' => isset($taskData['recurrence']) ? json_encode($taskData['recurrence']) : null,
                    'reminders_json' => isset($taskData['reminders']) ? json_encode($taskData['reminders']) : null,
                    'version' => $taskData['version'] ?? 1,
                    'updated_at' => $taskData['updatedAt'] ?? now(),
                    'completed_at' => $taskData['completedAt'] ?? null,
                ]
            );
        }

        $allTasks = Task::where('user_id', $userId)->get();

        return response()->json([
            'success' => true,
            'tasks' => $allTasks,
        ]);
    }
}
