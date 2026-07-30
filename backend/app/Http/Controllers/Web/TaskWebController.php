<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class TaskWebController extends Controller
{
    /**
     * Display the main Web App Dashboard (Kanban + List View).
     */
    public function index(Request $request)
    {
        $userId = session('user_id', 'user-admin-1');
        $user = User::find($userId);
        
        $category = $request->query('category', 'today');
        $viewMode = $request->query('view', 'kanban');
        $search = $request->query('search', '');

        $query = Task::where('user_id', $userId);

        if (!empty($search)) {
            $query->where('title', 'like', '%' . $search . '%');
        }

        $tasks = $query->orderBy('updated_at', 'desc')->get();
        $totalCount = $tasks->count();
        $completedCount = $tasks->where('status', 'done')->count();
        $percentage = $totalCount > 0 ? round(($completedCount / $totalCount) * 100) : 0;

        return view('tasks.index', compact(
            'tasks',
            'user',
            'category',
            'viewMode',
            'search',
            'totalCount',
            'completedCount',
            'percentage'
        ));
    }

    /**
     * Show Web Login Screen.
     */
    public function showLogin()
    {
        return view('auth.login');
    }

    /**
     * Handle Web Login POST request.
     */
    public function login(Request $request)
    {
        $email = $request->input('email');
        $password = $request->input('password');

        $user = User::where('email', $email)->first();

        if ($user) {
            session(['user_id' => $user->id, 'user_email' => $user->email]);
            return redirect()->route('dashboard');
        }

        return back()->withErrors(['email' => 'Invalid credentials. Please try again.']);
    }

    /**
     * Store new task from Blade Form.
     */
    public function store(Request $request)
    {
        $userId = session('user_id', 'user-admin-1');

        $request->validate([
            'title' => 'required|string|max:255',
        ]);

        Task::create([
            'id' => (string) Str::uuid(),
            'user_id' => $userId,
            'title' => $request->input('title'),
            'description' => $request->input('description'),
            'status' => 'todo',
            'priority' => $request->input('priority', 'p3'),
            'due_date' => $request->input('due_date'),
            'start_time' => $request->input('start_time'),
            'end_time' => $request->input('end_time'),
            'version' => 1,
        ]);

        return redirect()->route('dashboard')->with('success', 'Task created successfully!');
    }

    /**
     * Toggle task status between todo/inProgress/done.
     */
    public function toggleStatus(Request $request, $id)
    {
        $task = Task::findOrFail($id);
        $task->status = ($task->status === 'done') ? 'todo' : 'done';
        if ($task->status === 'done') {
            $task->completed_at = now();
        } else {
            $task->completed_at = null;
        }
        $task->save();

        return redirect()->back();
    }

    /**
     * Delete a task.
     */
    public function destroy($id)
    {
        $task = Task::findOrFail($id);
        $task->delete();

        return redirect()->route('dashboard')->with('success', 'Task deleted successfully.');
    }

    /**
     * Handle Web Logout.
     */
    public function logout()
    {
        session()->forget(['user_id', 'user_email']);
        return redirect()->route('login');
    }
}
