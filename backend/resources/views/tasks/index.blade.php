@extends('layouts.app')

@section('content')
<div class="app-layout">
  <!-- Sidebar Navigation -->
  <aside class="sidebar" id="appSidebar">
    <div class="sidebar-header">
      <div class="brand">
        <img src="{{ asset('favicon.png') }}" style="width: 28px; height: 28px; border-radius: 8px;" alt="Task Flow Logo">
        <span class="brand-title">Task Flow</span>
      </div>
      <button class="btn btn-outline" onclick="toggleSidebar()" style="padding: 4px 8px; font-size: 11px;"><i class="fa-solid fa-chevron-left" id="sidebarToggleIcon"></i></button>
    </div>

    <div class="sidebar-menu">
      <a href="{{ route('dashboard', ['category' => 'today']) }}" class="nav-item {{ ($category ?? 'today') === 'today' ? 'active' : '' }}">
        <i class="fa-regular fa-calendar-check" style="color: var(--primary);"></i>
        <span>Today</span>
        <span class="nav-badge">{{ $tasks->where('status', '!=', 'done')->count() }}</span>
      </a>

      <a href="{{ route('dashboard', ['category' => 'inbox']) }}" class="nav-item {{ ($category ?? '') === 'inbox' ? 'active' : '' }}">
        <i class="fa-solid fa-inbox" style="color: #64748b;"></i>
        <span>Inbox</span>
      </a>

      <a href="{{ route('dashboard', ['category' => 'upcoming']) }}" class="nav-item {{ ($category ?? '') === 'upcoming' ? 'active' : '' }}">
        <i class="fa-regular fa-calendar-days" style="color: var(--accent-cyan);"></i>
        <span>Upcoming</span>
      </a>

      <a href="{{ route('dashboard', ['category' => 'recurring']) }}" class="nav-item {{ ($category ?? '') === 'recurring' ? 'active' : '' }}">
        <i class="fa-solid fa-rotate" style="color: #a855f7;"></i>
        <span>Recurring Tasks</span>
      </a>

      <div style="margin: 16px 12px 6px; font-size: 10px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px;">Projects & Tags</div>

      <a href="{{ route('dashboard', ['category' => 'work']) }}" class="nav-item {{ ($category ?? '') === 'work' ? 'active' : '' }}">
        <i class="fa-solid fa-folder" style="color: #f59e0b;"></i>
        <span>Work & Dev</span>
      </a>

      <a href="{{ route('dashboard', ['category' => 'personal']) }}" class="nav-item {{ ($category ?? '') === 'personal' ? 'active' : '' }}">
        <i class="fa-solid fa-user" style="color: #3b82f6;"></i>
        <span>Personal</span>
      </a>

      <a href="{{ route('dashboard', ['category' => 'health']) }}" class="nav-item {{ ($category ?? '') === 'health' ? 'active' : '' }}">
        <i class="fa-solid fa-heart" style="color: #ec4899;"></i>
        <span>Health & Wellness</span>
      </a>
    </div>

    <div class="sidebar-footer">
      <div class="user-info">
        <div class="avatar"><i class="fa-solid fa-user"></i></div>
        <div style="flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: 600;">
          {{ session('user_email', 'mdreal.official@gmail.com') }}
        </div>
      </div>
      <div style="display: flex; gap: 8px;">
        <button class="btn btn-outline" onclick="toggleTheme()" style="flex:1;"><i class="fa-solid fa-moon"></i></button>
        <a href="{{ route('logout') }}" class="btn btn-outline" style="flex:1; color: var(--accent-rose);"><i class="fa-solid fa-right-from-bracket"></i></a>
      </div>
      <div class="version-text" style="text-align:center; font-size:10px; color:var(--text-muted); margin-top:8px;">Backend v1.1.11</div>
    </div>
  </aside>

  <!-- Main Work Area -->
  <main class="main-canvas">
    <!-- Top Header -->
    <header class="top-header">
      <div style="display: flex; align-items: center; gap: 12px;">
        <button class="btn btn-outline" onclick="toggleSidebar()" style="padding: 6px 10px;"><i class="fa-solid fa-bars"></i></button>
        <div class="category-title">{{ ucfirst($category ?? 'Today') }}'s Tasks</div>
      </div>

      <div style="display: flex; align-items: center; gap: 10px;">
        <form action="{{ route('dashboard') }}" method="GET" class="search-box">
          <input type="hidden" name="category" value="{{ $category }}">
          <input type="hidden" name="view" value="{{ $viewMode }}">
          <i class="fa-solid fa-magnifying-glass"></i>
          <input type="text" name="search" class="form-control" placeholder="Search tasks..." value="{{ $search }}">
        </form>

        <div style="display: flex; background: var(--bg-color); border: 1px solid var(--border-color); border-radius: 8px; padding: 2px;">
          <a href="{{ route('dashboard', ['category' => $category, 'view' => 'list', 'search' => $search]) }}" class="btn {{ $viewMode === 'list' ? 'btn-primary' : 'btn-outline' }}" style="padding: 4px 10px; border:none;"><i class="fa-solid fa-list"></i></a>
          <a href="{{ route('dashboard', ['category' => $category, 'view' => 'kanban', 'search' => $search]) }}" class="btn {{ $viewMode === 'kanban' ? 'btn-primary' : 'btn-outline' }}" style="padding: 4px 10px; border:none;"><i class="fa-solid fa-table-columns"></i></a>
        </div>

        <button class="btn btn-primary" onclick="openCreateModal()"><i class="fa-solid fa-plus"></i> New</button>
      </div>
    </header>

    <!-- Content Workspace (Kanban vs List) -->
    <div class="content-viewport">
      @if(($viewMode ?? 'kanban') === 'kanban')
        <div class="kanban-grid">
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
            <div class="kanban-col" ondragover="handleDragOver(event)" ondrop="handleDrop(event, '{{ $statusKey }}')">
              <div class="kanban-header">
                <span>{{ $statusTitle }}</span>
                <span class="kanban-count">{{ $colTasks->count() }}</span>
              </div>
              <div class="kanban-cards">
                @foreach($colTasks as $t)
                  <div class="task-card" 
                       draggable="true" 
                       ondragstart="handleDragStart(event, '{{ $t->id }}')"
                       onclick="openDetailModal('{{ $t->id }}', '{{ addslashes($t->title) }}', '{{ addslashes($t->description ?? '') }}', '{{ $t->priority }}', '{{ $t->status }}', '{{ $t->due_date }}', '{{ $t->start_time }}', '{{ $t->end_time }}')">
                    
                    <form id="toggle-form-{{ $t->id }}" action="{{ route('tasks.toggle', $t->id) }}" method="POST" style="display:none;">
                      @csrf
                    </form>

                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                      <span class="card-badge badge-{{ $t->priority ?? 'p3' }}">{{ strtoupper($t->priority ?? 'P3') }}</span>
                      <button type="button" 
                              onclick="event.stopPropagation(); document.getElementById('toggle-form-{{ $t->id }}').submit();" 
                              style="background:none; border:none; cursor:pointer; color: {{ $t->status === 'done' ? 'var(--accent-emerald)' : 'var(--text-muted)' }};">
                        <i class="{{ $t->status === 'done' ? 'fa-solid fa-circle-check' : 'fa-regular fa-circle' }}"></i>
                      </button>
                    </div>

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
            <div class="list-item" onclick="openDetailModal('{{ $t->id }}', '{{ addslashes($t->title) }}', '{{ addslashes($t->description ?? '') }}', '{{ $t->priority }}', '{{ $t->status }}', '{{ $t->due_date }}', '{{ $t->start_time }}', '{{ $t->end_time }}')">
              <form id="toggle-list-{{ $t->id }}" action="{{ route('tasks.toggle', $t->id) }}" method="POST" style="display:none;">
                @csrf
              </form>
              <div class="checkbox {{ $t->status === 'done' ? 'checked' : '' }}" onclick="event.stopPropagation(); document.getElementById('toggle-list-{{ $t->id }}').submit();">
                <i class="fa-solid fa-check" style="font-size: 10px;"></i>
              </div>
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

<!-- Task Details Modal Dialog (View-Only Mode by Default + Edit Toggle Button) -->
<div class="modal-backdrop" id="detailModal">
  <div class="modal-box">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
      <h3 style="font-size:18px; font-weight:700;"><i class="fa-solid fa-file-lines" style="color:var(--primary);"></i> Task Details</h3>
      <div style="display:flex; gap:8px;">
        <button type="button" class="btn btn-outline" id="editModalBtn" onclick="toggleWebEditMode()" style="padding:4px 10px; font-size:12px;">
          <i class="fa-solid fa-pen-to-square"></i> Edit Task
        </button>
        <button class="btn btn-outline" onclick="closeDetailModal()" style="padding:4px 8px;"><i class="fa-solid fa-xmark"></i></button>
      </div>
    </div>
    
    <form id="detailForm" action="" method="POST">
      @csrf
      <div class="form-group">
        <label>Task Title</label>
        <input type="text" id="detailTitle" name="title" class="form-control" readonly required>
      </div>
      
      <div style="display:flex; gap:10px; margin-bottom:16px;">
        <div class="form-group" style="flex:1;">
          <label>Status</label>
          <select id="detailStatus" name="status" class="form-control" disabled>
            <option value="backlog">Backlog</option>
            <option value="todo">To Do</option>
            <option value="inProgress">In Progress</option>
            <option value="done">Done</option>
          </select>
        </div>
        <div class="form-group" style="flex:1;">
          <label>Priority</label>
          <select id="detailPriority" name="priority" class="form-control" disabled>
            <option value="p1">P1 (Urgent)</option>
            <option value="p2">P2 (High)</option>
            <option value="p3">P3 (Medium)</option>
            <option value="p4">P4 (Low)</option>
          </select>
        </div>
      </div>

      <div class="form-group">
        <label>Description / Notes</label>
        <textarea id="detailDescription" name="description" class="form-control" rows="3" readonly></textarea>
      </div>

      <div style="display:flex; gap:10px; margin-bottom:16px;">
        <div class="form-group" style="flex:1;">
          <label>Due Date</label>
          <input type="date" id="detailDueDate" name="due_date" class="form-control" readonly>
        </div>
        <div class="form-group" style="flex:1;">
          <label>Start Time</label>
          <input type="time" id="detailStartTime" name="start_time" class="form-control" readonly>
        </div>
        <div class="form-group" style="flex:1;">
          <label>End Time</label>
          <input type="time" id="detailEndTime" name="end_time" class="form-control" readonly>
        </div>
      </div>

      <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px;">
        <button type="button" class="btn btn-outline" onclick="closeDetailModal()">Close</button>
        <button type="submit" class="btn btn-primary" id="saveModalBtn" style="display:none;">
          <i class="fa-solid fa-floppy-disk"></i> Save Changes
        </button>
      </div>
    </form>
  </div>
</div>

@section('scripts')
<script>
  let activeDetailTaskId = null;
  let draggedTaskId = null;
  let isEditingWebTask = false;

  function openDetailModal(id, title, description, priority, status, dueDate, startTime, endTime) {
    activeDetailTaskId = id;
    isEditingWebTask = false;

    document.getElementById('detailForm').action = '/tasks/' + id + '/update';
    document.getElementById('detailTitle').value = title;
    document.getElementById('detailDescription').value = description || '';
    document.getElementById('detailPriority').value = priority;
    document.getElementById('detailStatus').value = status;
    document.getElementById('detailDueDate').value = dueDate || '';
    document.getElementById('detailStartTime').value = startTime || '';
    document.getElementById('detailEndTime').value = endTime || '';
    
    // View-Only Mode by Default
    setWebModalReadOnly(true);

    document.getElementById('detailModal').classList.add('show');
  }

  function closeDetailModal() {
    document.getElementById('detailModal').classList.remove('show');
  }

  function toggleWebEditMode() {
    isEditingWebTask = !isEditingWebTask;
    setWebModalReadOnly(!isEditingWebTask);
  }

  function setWebModalReadOnly(readOnly) {
    document.getElementById('detailTitle').readOnly = readOnly;
    document.getElementById('detailDescription').readOnly = readOnly;
    document.getElementById('detailDueDate').readOnly = readOnly;
    document.getElementById('detailStartTime').readOnly = readOnly;
    document.getElementById('detailEndTime').readOnly = readOnly;
    
    document.getElementById('detailStatus').disabled = readOnly;
    document.getElementById('detailPriority').disabled = readOnly;

    document.getElementById('saveModalBtn').style.display = readOnly ? 'none' : 'inline-flex';
    document.getElementById('editModalBtn').innerHTML = readOnly 
      ? '<i class="fa-solid fa-pen-to-square"></i> Edit Task' 
      : '<i class="fa-solid fa-eye"></i> View Mode';
  }

  // HTML5 Drag & Drop Handlers for Kanban Board
  function handleDragStart(e, taskId) {
    draggedTaskId = taskId;
    e.dataTransfer.setData('text/plain', taskId);
    e.dataTransfer.effectAllowed = 'move';
  }

  function handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  }

  function handleDrop(e, targetStatus) {
    e.preventDefault();
    if (!draggedTaskId) return;

    fetch('/tasks/' + draggedTaskId + '/status', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': '{{ csrf_token() }}',
        'Accept': 'application/json'
      },
      body: JSON.stringify({ status: targetStatus })
    })
    .then(res => res.json())
    .then(data => {
      window.location.reload();
    })
    .catch(err => console.error('Drag drop status update error:', err));
  }
</script>
@endsection
@endsection
