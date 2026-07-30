@extends('layouts.app')

@section('title', "Today's Tasks — Task Flow")

@section('content')
<div class="app-wrapper">
  <!-- Sidebar -->
  <aside class="sidebar" id="appSidebar">
    <div class="sidebar-header">
      <div class="brand">
        <div class="brand-icon"><i class="fa-solid fa-square-check"></i></div>
        <span class="brand-title">Task Flow</span>
      </div>
      <button class="btn btn-outline" onclick="toggleSidebar()" style="padding: 4px 8px; font-size: 11px;"><i class="fa-solid fa-chevron-left" id="sidebarToggleIcon"></i></button>
    </div>

    <div class="sidebar-menu">
      <a href="{{ route('dashboard', ['category' => 'today']) }}" class="nav-item {{ $category === 'today' ? 'active' : '' }}">
        <i class="fa-regular fa-calendar-check"></i> <span class="nav-text">Today</span> <span class="nav-badge">{{ $totalCount }}</span>
      </a>
      <a href="{{ route('dashboard', ['category' => 'upcoming']) }}" class="nav-item {{ $category === 'upcoming' ? 'active' : '' }}">
        <i class="fa-regular fa-calendar"></i> <span class="nav-text">Upcoming</span>
      </a>
      <a href="{{ route('dashboard', ['category' => 'inbox']) }}" class="nav-item {{ $category === 'inbox' ? 'active' : '' }}">
        <i class="fa-solid fa-inbox"></i> <span class="nav-text">Inbox & Backlog</span>
      </a>
      <a href="{{ route('dashboard', ['category' => 'recurring']) }}" class="nav-item {{ $category === 'recurring' ? 'active' : '' }}">
        <i class="fa-solid fa-arrows-rotate"></i> <span class="nav-text">Recurring Tasks</span>
      </a>

      <div class="nav-section-title" style="font-size: 11px; font-weight: 700; color: var(--text-muted); margin: 16px 8px 8px;">PROJECTS & TAGS</div>
      <a href="{{ route('dashboard', ['category' => 'work']) }}" class="nav-item {{ $category === 'work' ? 'active' : '' }}"><i class="fa-solid fa-folder" style="color: var(--accent-amber);"></i> <span class="nav-text">Work & Dev</span></a>
      <a href="{{ route('dashboard', ['category' => 'personal']) }}" class="nav-item {{ $category === 'personal' ? 'active' : '' }}"><i class="fa-solid fa-user" style="color: var(--accent-cyan);"></i> <span class="nav-text">Personal</span></a>
      <a href="{{ route('dashboard', ['category' => 'health']) }}" class="nav-item {{ $category === 'health' ? 'active' : '' }}"><i class="fa-solid fa-heart" style="color: var(--accent-rose);"></i> <span class="nav-text">Health & Wellness</span></a>
    </div>

    <div class="sidebar-footer">
      <div class="user-info">
        <div class="avatar">{{ strtoupper(substr(session('user_email', 'admin'), 0, 1)) }}</div>
        <div class="user-email-text" style="flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">{{ session('user_email', 'mdreal.official@gmail.com') }}</div>
      </div>
      <div style="display:flex; justify-content:space-between; gap:6px;">
        <button class="btn btn-outline" onclick="toggleTheme()" style="flex:1;"><i class="fa-solid fa-moon"></i></button>
        <a href="{{ route('logout') }}" class="btn btn-outline" style="flex:1; color: var(--accent-rose);"><i class="fa-solid fa-right-from-bracket"></i></a>
      </div>
      <div class="version-text" style="text-align:center; font-size:10px; color:var(--text-muted); margin-top:8px;">Backend v1.1.0</div>
    </div>
  </aside>

  <!-- Main Content Canvas -->
  <main class="main-canvas">
    <!-- Top Navigation Header -->
    <header class="top-header">
      <button class="btn btn-outline mobile-menu-btn" onclick="toggleSidebar()" style="padding: 6px 10px;"><i class="fa-solid fa-bars"></i></button>
      <h1 class="category-title">{{ ucfirst($category) }} Tasks</h1>

      <form action="{{ route('dashboard') }}" method="GET" class="search-box">
        <input type="hidden" name="category" value="{{ $category }}">
        <input type="hidden" name="view" value="{{ $viewMode }}">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" name="search" class="form-control" placeholder="Search tasks..." value="{{ $search }}" onchange="this.form.submit()">
      </form>

      <div class="view-toggle">
        <a href="{{ route('dashboard', ['category' => $category, 'view' => 'kanban', 'search' => $search]) }}" class="view-btn {{ $viewMode === 'kanban' ? 'active' : '' }}"><i class="fa-solid fa-table-columns"></i> Kanban</a>
        <a href="{{ route('dashboard', ['category' => $category, 'view' => 'list', 'search' => $search]) }}" class="view-btn {{ $viewMode === 'list' ? 'active' : '' }}"><i class="fa-solid fa-list"></i> List</a>
      </div>

      <button class="btn btn-primary" onclick="openCreateModal()"><i class="fa-solid fa-plus"></i> New Task</button>
    </header>

    <!-- Top Progress Bar -->
    <div class="progress-bar-container">
      <div class="progress-stats">
        <div class="stat-pill">{{ $percentage }}% Completed</div>
        <span style="color: var(--text-muted);">({{ $completedCount }} of {{ $totalCount }} tasks done)</span>
      </div>
      <div class="progress-line-track">
        <div class="progress-line-fill" style="width: {{ $percentage }}%;"></div>
      </div>
    </div>

    <!-- Main Content Viewport -->
    <div class="content-viewport">
      @if($viewMode === 'kanban')
        <div class="kanban-board">
          @php
            $statuses = [
              'backlog' => 'Backlog',
              'todo' => 'To Do',
              'inProgress' => 'In Progress',
              'done' => 'Done'
            ];
          @endphp

          @foreach($statuses as $statusKey => $statusTitle)
            @php
              $colTasks = $tasks->filter(fn($t) => ($t->status ?? 'todo') === $statusKey);
            @endphp
            <div class="kanban-col">
              <div class="kanban-header">
                <span>{{ $statusTitle }}</span>
                <span class="kanban-count">{{ $colTasks->count() }}</span>
              </div>
              <div class="kanban-cards">
                @foreach($colTasks as $t)
                  <div class="task-card" onclick="document.getElementById('toggle-form-{{ $t->id }}').submit();">
                    <form id="toggle-form-{{ $t->id }}" action="{{ route('tasks.toggle', $t->id) }}" method="POST" style="display:none;">
                      @csrf
                    </form>
                    <span class="card-badge badge-{{ $t->priority ?? 'p3' }}">{{ strtoupper($t->priority ?? 'P3') }}</span>
                    <div class="card-title" style="{{ $t->status === 'done' ? 'text-decoration: line-through; color: var(--text-muted);' : '' }}">{{ $t->title }}</div>
                    @if($t->description)
                      <div class="card-desc">{{ $t->description }}</div>
                    @endif
                    <div class="card-meta">
                      <span><i class="fa-regular fa-clock"></i> {{ $t->due_date ? date('M d', strtotime($t->due_date)) : 'No Date' }}</span>
                      <form action="{{ route('tasks.destroy', $t->id) }}" method="POST" onclick="event.stopPropagation();">
                        @csrf
                        @method('DELETE')
                        <button type="submit" style="background:none; border:none; color:var(--accent-rose); cursor:pointer;"><i class="fa-solid fa-trash"></i></button>
                      </form>
                    </div>
                  </div>
                @endforeach
              </div>
            </div>
          @endforeach
        </div>
      @else
        <div class="task-list">
          @foreach($tasks as $t)
            <div class="list-item" onclick="document.getElementById('toggle-list-{{ $t->id }}').submit();">
              <form id="toggle-list-{{ $t->id }}" action="{{ route('tasks.toggle', $t->id) }}" method="POST" style="display:none;">
                @csrf
              </form>
              <div class="checkbox {{ $t->status === 'done' ? 'checked' : '' }}"><i class="fa-solid fa-check" style="font-size: 10px;"></i></div>
              <div style="flex:1;">
                <div style="font-weight: 600; {{ $t->status === 'done' ? 'text-decoration: line-through; color: var(--text-muted);' : '' }}">{{ $t->title }}</div>
                <div style="font-size:11px; color:var(--text-muted);">{{ $t->due_date ? date('M d, Y', strtotime($t->due_date)) : 'No Date' }}</div>
              </div>
              <span class="card-badge badge-{{ $t->priority ?? 'p3' }}">{{ strtoupper($t->priority ?? 'P3') }}</span>
              <form action="{{ route('tasks.destroy', $t->id) }}" method="POST" onclick="event.stopPropagation();">
                @csrf
                @method('DELETE')
                <button type="submit" style="background:none; border:none; color:var(--accent-rose); cursor:pointer;"><i class="fa-solid fa-trash"></i></button>
              </form>
            </div>
          @endforeach
        </div>
      @endif
    </div>
  </main>
</div>

<!-- Create Task Modal Dialog -->
<div class="modal-backdrop" id="createModal">
  <div class="modal-box">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
      <h3 style="font-size:18px; font-weight:700;"><i class="fa-solid fa-circle-plus" style="color:var(--primary);"></i> Create New Task</h3>
      <button class="btn btn-outline" onclick="closeCreateModal()" style="padding:4px 8px;"><i class="fa-solid fa-xmark"></i></button>
    </div>
    <form action="{{ route('tasks.store') }}" method="POST">
      @csrf
      <div class="form-group">
        <label>Task Title *</label>
        <input type="text" name="title" class="form-control" placeholder="What needs to be done?" required>
      </div>
      <div class="form-group">
        <label>Description / Notes</label>
        <textarea name="description" class="form-control" rows="2" placeholder="Optional notes..."></textarea>
      </div>
      <div style="display:flex; gap:10px; margin-bottom:16px;">
        <div class="form-group" style="flex:1;">
          <label>Due Date</label>
          <input type="date" name="due_date" class="form-control">
        </div>
        <div class="form-group" style="flex:1;">
          <label>Priority</label>
          <select name="priority" class="form-control">
            <option value="p1">P1 (Urgent)</option>
            <option value="p2">P2 (High)</option>
            <option value="p3" selected>P3 (Medium)</option>
            <option value="p4">P4 (Low)</option>
          </select>
        </div>
      </div>
      <div style="display:flex; gap:10px; margin-bottom:16px;">
        <div class="form-group" style="flex:1;">
          <label>Start Time</label>
          <input type="time" name="start_time" class="form-control">
        </div>
        <div class="form-group" style="flex:1;">
          <label>End Time</label>
          <input type="time" name="end_time" class="form-control">
        </div>
      </div>
      <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px;">
        <button type="button" class="btn btn-outline" onclick="closeCreateModal()">Cancel</button>
        <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check"></i> Create Task</button>
      </div>
    </form>
  </div>
</div>
@endsection
