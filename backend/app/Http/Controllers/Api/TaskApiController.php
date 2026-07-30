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
            $tagsVal = null;
            if (isset($taskData['tags'])) {
                $tagsVal = is_array($taskData['tags']) ? implode(',', $taskData['tags']) : $taskData['tags'];
            } elseif (isset($taskData['tags_json'])) {
                $tagsVal = $taskData['tags_json'];
            }

            Task::updateOrCreate(
                ['id' => $taskData['id']],
                [
                    'user_id' => $userId,
                    'title' => $taskData['title'],
                    'description' => $taskData['description'] ?? null,
                    'status' => $taskData['status'],
                    'priority' => $taskData['priority'],
                    'due_date' => $taskData['dueDate'] ?? $taskData['due_date'] ?? null,
                    'start_time' => $taskData['startTime'] ?? $taskData['start_time'] ?? null,
                    'end_time' => $taskData['endTime'] ?? $taskData['end_time'] ?? null,
                    'tags_json' => $tagsVal,
                    'checklist_json' => isset($taskData['checklist']) ? (is_string($taskData['checklist']) ? $taskData['checklist'] : json_encode($taskData['checklist'])) : ($taskData['checklist_json'] ?? null),
                    'recurrence_json' => isset($taskData['recurrence']) ? (is_string($taskData['recurrence']) ? $taskData['recurrence'] : json_encode($taskData['recurrence'])) : ($taskData['recurrence_json'] ?? null),
                    'reminders_json' => isset($taskData['reminders']) ? (is_string($taskData['reminders']) ? $taskData['reminders'] : json_encode($taskData['reminders'])) : ($taskData['reminders_json'] ?? null),
                    'version' => $taskData['version'] ?? 1,
                    'updated_at' => $taskData['updatedAt'] ?? $taskData['updated_at'] ?? now(),
                    'completed_at' => $taskData['completedAt'] ?? $taskData['completed_at'] ?? null,
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
