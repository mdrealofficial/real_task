<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Task Flow — Web App</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  
  <style>
    :root {
      --bg-color: #f8fafc;
      --card-bg: #ffffff;
      --border-color: #e2e8f0;
      --text-main: #0f172a;
      --text-muted: #64748b;
      --primary: #4f46e5;
      --primary-hover: #4338ca;
      --primary-light: rgba(79, 70, 229, 0.1);
      --accent-cyan: #06b6d4;
      --accent-emerald: #10b981;
      --accent-rose: #f43f5e;
      --accent-amber: #f59e0b;
      --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
      --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
      --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
    }

    [data-theme="dark"] {
      --bg-color: #0f172a;
      --card-bg: #1e293b;
      --border-color: #334155;
      --text-main: #f8fafc;
      --text-muted: #94a3b8;
      --primary-light: rgba(99, 102, 241, 0.2);
    }

    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
    body { background-color: var(--bg-color); color: var(--text-main); height: 100vh; overflow: hidden; display: flex; flex-direction: column; }

    /* Login Screen Modal */
    #loginOverlay {
      position: fixed; inset: 0; background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px);
      display: flex; align-items: center; justify-content: center; z-index: 9999;
    }
    .login-card {
      background: var(--card-bg); width: 100%; max-width: 400px; padding: 32px; border-radius: 16px;
      border: 1px solid var(--border-color); box-shadow: var(--shadow-lg); text-align: center;
    }
    .login-logo {
      width: 54px; height: 54px; background: var(--primary-light); color: var(--primary);
      border-radius: 14px; display: inline-flex; align-items: center; justify-content: center;
      font-size: 26px; margin-bottom: 16px;
    }
    .form-group { text-align: left; margin-bottom: 16px; }
    .form-group label { display: block; font-size: 12px; font-weight: 600; color: var(--text-muted); margin-bottom: 6px; }
    .form-control {
      width: 100%; padding: 10px 14px; font-size: 14px; background: var(--bg-color); color: var(--text-main);
      border: 1px solid var(--border-color); border-radius: 8px; outline: none; transition: all 0.2s;
    }
    .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }

    .btn {
      display: inline-flex; align-items: center; justify-content: center; gap: 8px;
      padding: 10px 18px; font-size: 14px; font-weight: 600; border-radius: 8px; border: none;
      cursor: pointer; transition: all 0.2s;
    }
    .btn-primary { background: var(--primary); color: #fff; }
    .btn-primary:hover { background: var(--primary-hover); }
    .btn-outline { background: transparent; border: 1px solid var(--border-color); color: var(--text-main); }
    .btn-outline:hover { background: var(--border-color); }
    .btn-block { width: 100%; }

    /* App Workspace Layout */
    .app-wrapper { display: flex; flex: 1; overflow: hidden; position: relative; }

    /* Sidebar Navigation */
    .sidebar {
      width: 240px; background: var(--card-bg); border-right: 1px solid var(--border-color);
      display: flex; flex-direction: column; transition: width 0.3s; z-index: 100;
    }
    .sidebar.collapsed { width: 64px; }
    .sidebar-header {
      height: 64px; padding: 0 16px; display: flex; align-items: center; justify-content: space-between;
      border-bottom: 1px solid var(--border-color);
    }
    .brand { display: flex; align-items: center; gap: 10px; font-weight: 800; font-size: 18px; }
    .brand-icon {
      width: 32px; height: 32px; background: var(--primary-light); color: var(--primary);
      border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 16px;
    }
    .sidebar-menu { flex: 1; padding: 12px 8px; overflow-y: auto; }
    .nav-item {
      display: flex; align-items: center; gap: 12px; padding: 10px 12px; font-size: 13px; font-weight: 600;
      color: var(--text-muted); border-radius: 8px; cursor: pointer; margin-bottom: 4px; transition: all 0.15s;
    }
    .nav-item:hover, .nav-item.active { background: var(--primary-light); color: var(--primary); }
    .nav-badge { margin-left: auto; background: var(--border-color); color: var(--text-main); font-size: 11px; padding: 2px 8px; border-radius: 12px; }

    .sidebar-footer { padding: 12px; border-top: 1px solid var(--border-color); font-size: 12px; }
    .user-info { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; }
    .avatar { width: 28px; height: 28px; background: var(--primary); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; }

    /* Main Area */
    .main-canvas { flex: 1; display: flex; flex-direction: column; overflow: hidden; }

    /* Top Navigation Header */
    .top-header {
      height: 64px; padding: 0 20px; background: var(--card-bg); border-bottom: 1px solid var(--border-color);
      display: flex; align-items: center; justify-content: space-between; gap: 12px;
    }
    .category-title { font-size: 16px; font-weight: 700; }
    .search-box {
      position: relative; max-width: 220px; flex: 1;
    }
    .search-box i { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 13px; }
    .search-box input { padding-left: 34px; height: 36px; }

    .view-toggle { display: flex; background: var(--bg-color); padding: 3px; border-radius: 8px; border: 1px solid var(--border-color); }
    .view-btn { padding: 5px 12px; font-size: 12px; font-weight: 600; border-radius: 6px; border: none; cursor: pointer; color: var(--text-muted); background: transparent; }
    .view-btn.active { background: var(--card-bg); color: var(--primary); box-shadow: var(--shadow-sm); }

    /* Top Progress Bar */
    .progress-bar-container { background: var(--card-bg); border-bottom: 1px solid var(--border-color); }
    .progress-stats { padding: 8px 20px; display: flex; align-items: center; gap: 12px; font-size: 12px; }
    .stat-pill {
      background: var(--primary-light); color: var(--primary); padding: 3px 10px; border-radius: 12px; font-weight: 700; border: 1px solid rgba(79,70,229,0.3);
    }
    .progress-line-track { height: 4px; background: var(--border-color); width: 100%; position: relative; }
    .progress-line-fill { height: 100%; background: linear-gradient(90deg, var(--primary), var(--accent-emerald)); width: 0%; transition: width 0.4s ease; }

    /* Content Area: Kanban vs List */
    .content-viewport { flex: 1; padding: 20px; overflow-x: auto; overflow-y: auto; }

    /* Kanban Board */
    .kanban-board { display: flex; gap: 16px; height: 100%; min-width: 900px; }
    .kanban-col {
      flex: 1; min-width: 240px; background: var(--card-bg); border-radius: 12px; border: 1px solid var(--border-color);
      display: flex; flex-direction: column; max-height: 100%;
    }
    .kanban-header {
      padding: 14px 16px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; font-size: 13px; font-weight: 700;
    }
    .kanban-count { background: var(--bg-color); padding: 2px 8px; border-radius: 10px; font-size: 11px; color: var(--text-muted); }
    .kanban-cards { padding: 12px; flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; }

    /* Task Card */
    .task-card {
      background: var(--bg-color); border: 1px solid var(--border-color); border-radius: 10px; padding: 12px;
      cursor: pointer; transition: transform 0.15s, box-shadow 0.15s; position: relative;
    }
    .task-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); border-color: var(--primary); }
    .card-badge { display: inline-block; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 6px; margin-bottom: 8px; }
    .badge-p1 { background: rgba(244, 63, 94, 0.15); color: var(--accent-rose); }
    .badge-p2 { background: rgba(245, 158, 11, 0.15); color: var(--accent-amber); }
    .badge-p3 { background: rgba(6, 182, 212, 0.15); color: var(--accent-cyan); }
    .badge-p4 { background: rgba(100, 116, 139, 0.15); color: var(--text-muted); }
    .card-title { font-size: 14px; font-weight: 600; margin-bottom: 4px; word-break: break-word; }
    .card-desc { font-size: 12px; color: var(--text-muted); margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
    .card-meta { display: flex; align-items: center; justify-content: space-between; font-size: 11px; color: var(--text-muted); }

    /* Task List View */
    .task-list { display: flex; flex-direction: column; gap: 8px; max-width: 900px; margin: 0 auto; }
    .list-item {
      background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 10px; padding: 12px 16px;
      display: flex; align-items: center; gap: 14px; cursor: pointer; transition: all 0.15s;
    }
    .list-item:hover { border-color: var(--primary); box-shadow: var(--shadow-sm); }
    .checkbox { width: 18px; height: 18px; border-radius: 50%; border: 2px solid var(--border-color); display: flex; align-items: center; justify-content: center; cursor: pointer; }
    .checkbox.checked { background: var(--accent-emerald); border-color: var(--accent-emerald); color: #fff; }

    /* Task Modal Dialog */
    .modal-backdrop {
      position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px);
      display: none; align-items: center; justify-content: center; z-index: 1000;
    }
    .modal-backdrop.show { display: flex; }
    .modal-box {
      background: var(--card-bg); width: 100%; max-width: 500px; padding: 24px; border-radius: 16px;
      border: 1px solid var(--border-color); box-shadow: var(--shadow-lg); max-height: 90vh; overflow-y: auto;
    }

    /* Responsive Mobile Adjustments */
    @media (max-width: 768px) {
      .sidebar { position: absolute; left: -240px; height: 100%; }
      .sidebar.open { left: 0; }
      .brand-title { display: none; }
      .search-box { max-width: 130px; }
      .content-viewport { padding: 12px; }
    }
  </style>
</head>
<body>

  <!-- Login Modal Overlay -->
  <div id="loginOverlay">
    <div class="login-card">
      <div class="login-logo"><i class="fa-solid fa-square-check"></i></div>
      <h2 style="font-size: 20px; font-weight: 800; margin-bottom: 6px;">Sign In to Task Flow</h2>
      <p style="font-size: 12px; color: var(--text-muted); margin-bottom: 24px;">Enter your credentials to sync your tasks</p>
      
      <form id="loginForm" onsubmit="handleLogin(event)">
        <div class="form-group">
          <label>Email Address</label>
          <input type="email" id="loginEmail" class="form-control" placeholder="name@example.com" value="mdreal.official@gmail.com" required>
        </div>
        <div class="form-group">
          <label>Password</label>
          <input type="password" id="loginPassword" class="form-control" placeholder="••••••••" value="Staritlab77" required>
        </div>
        <div id="loginError" style="color: var(--accent-rose); font-size: 12px; margin-bottom: 14px; display: none;"></div>
        <button type="submit" class="btn btn-primary btn-block"><i class="fa-solid fa-right-to-bracket"></i> Sign In</button>
      </form>
    </div>
  </div>

  <!-- App Main Workspace -->
  <div class="app-wrapper">
    <!-- Sidebar -->
    <aside class="sidebar" id="appSidebar">
      <div class="sidebar-header">
        <div class="brand">
          <div class="brand-icon"><i class="fa-solid fa-square-check"></i></div>
          <span class="brand-title">Task Flow</span>
        </div>
        <button class="btn btn-outline" onclick="toggleSidebar()" style="padding: 6px 10px;"><i class="fa-solid fa-chevron-left"></i></button>
      </div>

      <div class="sidebar-menu">
        <div class="nav-item active" onclick="selectCategory('today', this)">
          <i class="fa-regular fa-calendar-check"></i> Today <span class="nav-badge" id="todayBadge">0</span>
        </div>
        <div class="nav-item" onclick="selectCategory('upcoming', this)">
          <i class="fa-regular fa-calendar"></i> Upcoming
        </div>
        <div class="nav-item" onclick="selectCategory('inbox', this)">
          <i class="fa-solid fa-inbox"></i> Inbox & Backlog
        </div>
        <div class="nav-item" onclick="selectCategory('recurring', this)">
          <i class="fa-solid fa-arrows-rotate"></i> Recurring Tasks
        </div>

        <div style="font-size: 11px; font-weight: 700; color: var(--text-muted); margin: 16px 8px 8px;">PROJECTS & TAGS</div>
        <div class="nav-item" onclick="selectCategory('work', this)"><i class="fa-solid fa-folder" style="color: var(--accent-amber);"></i> Work & Dev</div>
        <div class="nav-item" onclick="selectCategory('personal', this)"><i class="fa-solid fa-user" style="color: var(--accent-cyan);"></i> Personal</div>
        <div class="nav-item" onclick="selectCategory('health', this)"><i class="fa-solid fa-heart" style="color: var(--accent-rose);"></i> Health & Wellness</div>
      </div>

      <div class="sidebar-footer">
        <div class="user-info">
          <div class="avatar" id="userAvatar">U</div>
          <div style="flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" id="userEmailText">user@example.com</div>
        </div>
        <div style="display:flex; justify-content:space-between; gap:6px;">
          <button class="btn btn-outline" onclick="toggleTheme()" style="flex:1;"><i class="fa-solid fa-moon"></i></button>
          <button class="btn btn-outline" onclick="handleLogout()" style="flex:1; color: var(--accent-rose);"><i class="fa-solid fa-right-from-bracket"></i></button>
        </div>
        <div style="text-align:center; font-size:10px; color:var(--text-muted); margin-top:8px;">Task Flow v1.0.15</div>
      </div>
    </aside>

    <!-- Main Workspace -->
    <main class="main-canvas">
      <!-- Top Navigation Header -->
      <header class="top-header">
        <button class="btn btn-outline" onclick="toggleSidebar()" style="padding: 6px 10px;"><i class="fa-solid fa-bars"></i></button>
        <h1 class="category-title" id="activeCategoryTitle">Today's Tasks</h1>

        <div class="search-box">
          <i class="fa-solid fa-magnifying-glass"></i>
          <input type="text" class="form-control" placeholder="Search tasks..." oninput="handleSearch(this.value)">
        </div>

        <div class="view-toggle">
          <button class="view-btn active" id="btnViewKanban" onclick="setViewMode('kanban')"><i class="fa-solid fa-table-columns"></i> Kanban</button>
          <button class="view-btn" id="btnViewList" onclick="setViewMode('list')"><i class="fa-solid fa-list"></i> List</button>
        </div>

        <button class="btn btn-primary" onclick="openCreateModal()"><i class="fa-solid fa-plus"></i> New Task</button>
      </header>

      <!-- Top Progress Bar Line -->
      <div class="progress-bar-container">
        <div class="progress-stats">
          <div class="stat-pill" id="completionPill">0% Completed</div>
          <span id="completionCountText" style="color: var(--text-muted);">(0 of 0 tasks done)</span>
        </div>
        <div class="progress-line-track">
          <div class="progress-line-fill" id="progressFill"></div>
        </div>
      </div>

      <!-- Main Content Viewport -->
      <div class="content-viewport" id="contentViewport">
        <!-- Dynamic Kanban or List View rendered via JS -->
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
      <form onsubmit="handleCreateTask(event)">
        <div class="form-group">
          <label>Task Title *</label>
          <input type="text" id="newTaskTitle" class="form-control" placeholder="What needs to be done?" required>
        </div>
        <div class="form-group">
          <label>Description / Notes</label>
          <textarea id="newTaskDesc" class="form-control" rows="2" placeholder="Optional notes..."></textarea>
        </div>
        <div style="display:flex; gap:10px; margin-bottom:16px;">
          <div class="form-group" style="flex:1;">
            <label>Due Date</label>
            <input type="date" id="newTaskDueDate" class="form-control">
          </div>
          <div class="form-group" style="flex:1;">
            <label>Priority</label>
            <select id="newTaskPriority" class="form-control">
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
            <input type="time" id="newTaskStartTime" class="form-control">
          </div>
          <div class="form-group" style="flex:1;">
            <label>End Time</label>
            <input type="time" id="newTaskEndTime" class="form-control">
          </div>
        </div>
        <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px;">
          <button type="button" class="btn btn-outline" onclick="closeCreateModal()">Cancel</button>
          <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check"></i> Create Task</button>
        </div>
      </form>
    </div>
  </div>

@verbatim
  <script>
    let state = {
      user: null,
      token: null,
      tasks: [],
      viewMode: 'kanban',
      activeCategory: 'today',
      searchQuery: ''
    };

    document.addEventListener('DOMContentLoaded', () => {
      const savedUser = localStorage.getItem('taskflow_user');
      const savedToken = localStorage.getItem('taskflow_token');
      if (savedUser && savedToken) {
        state.user = JSON.parse(savedUser);
        state.token = savedToken;
        document.getElementById('loginOverlay').style.display = 'none';
        document.getElementById('userEmailText').innerText = state.user.email;
        document.getElementById('userAvatar').innerText = state.user.email[0].toUpperCase();
        fetchTasks();
      }
    });

    async function handleLogin(e) {
      e.preventDefault();
      const email = document.getElementById('loginEmail').value;
      const password = document.getElementById('loginPassword').value;
      const errBox = document.getElementById('loginError');

      try {
        const res = await fetch('/api/v1/auth/login', {
          method: 'POST',
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: JSON.stringify({ email, password })
        });
        const data = await res.json();
        if (data.success) {
          state.user = data.user;
          state.token = data.token;
          localStorage.setItem('taskflow_user', JSON.stringify(data.user));
          localStorage.setItem('taskflow_token', data.token);
          document.getElementById('loginOverlay').style.display = 'none';
          document.getElementById('userEmailText').innerText = state.user.email;
          document.getElementById('userAvatar').innerText = state.user.email[0].toUpperCase();
          fetchTasks();
        } else {
          errBox.innerText = data.message || 'Invalid credentials';
          errBox.style.display = 'block';
        }
      } catch (err) {
        errBox.innerText = 'Server connection failed';
        errBox.style.display = 'block';
      }
    }

    async function fetchTasks() {
      if (!state.user) return;
      try {
        const res = await fetch(`/api/v1/tasks?user_id=${state.user.id}`);
        const data = await res.json();
        if (data.success) {
          state.tasks = data.tasks;
          renderApp();
        }
      } catch (err) {
        console.error('Fetch tasks error:', err);
      }
    }

    async function syncTasksToServer() {
      if (!state.user) return;
      try {
        const res = await fetch('/api/v1/tasks/sync', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': `Bearer ${state.token}`
          },
          body: JSON.stringify({ user_id: state.user.id, tasks: state.tasks })
        });
        const data = await res.json();
        if (data.success) {
          state.tasks = data.tasks;
          renderApp();
        }
      } catch (err) {
        console.error('Sync error:', err);
      }
    }

    async function handleCreateTask(e) {
      e.preventDefault();
      const newTask = {
        id: 'web-' + Date.now(),
        title: document.getElementById('newTaskTitle').value.trim(),
        description: document.getElementById('newTaskDesc').value.trim() || null,
        status: 'todo',
        priority: document.getElementById('newTaskPriority').value,
        due_date: document.getElementById('newTaskDueDate').value || null,
        start_time: document.getElementById('newTaskStartTime').value || null,
        end_time: document.getElementById('newTaskEndTime').value || null,
        tags_json: null,
        checklist_json: '[]',
        recurrence_json: null,
        reminders_json: '[]',
        version: 1
      };

      state.tasks.unshift(newTask);
      closeCreateModal();
      renderApp();
      syncTasksToServer();
    }

    async function toggleTaskStatus(taskId) {
      const task = state.tasks.find(t => t.id === taskId);
      if (task) {
        task.status = (task.status === 'done') ? 'todo' : 'done';
        renderApp();
        syncTasksToServer();
      }
    }

    function renderApp() {
      updateProgressStats();
      const viewport = document.getElementById('contentViewport');

      const filtered = state.tasks.filter(t => {
        if (state.searchQuery) {
          return t.title.toLowerCase().includes(state.searchQuery.toLowerCase());
        }
        return true;
      });

      if (state.viewMode === 'kanban') {
        const cols = { backlog: [], todo: [], inProgress: [], done: [] };
        filtered.forEach(t => {
          const s = t.status || 'todo';
          if (cols[s]) cols[s].push(t);
          else cols.todo.push(t);
        });

        viewport.innerHTML = `
          <div class="kanban-board">
            ${renderKanbanCol('Backlog', 'backlog', cols.backlog)}
            ${renderKanbanCol('To Do', 'todo', cols.todo)}
            ${renderKanbanCol('In Progress', 'inProgress', cols.inProgress)}
            ${renderKanbanCol('Done', 'done', cols.done)}
          </div>
        `;
      } else {
        viewport.innerHTML = `
          <div class="task-list">
            ${filtered.map(t => renderListItem(t)).join('')}
          </div>
        `;
      }
    }

    function renderKanbanCol(title, statusKey, items) {
      return `
        <div class="kanban-col">
          <div class="kanban-header">
            <span>${title}</span>
            <span class="kanban-count">${items.length}</span>
          </div>
          <div class="kanban-cards">
            ${items.map(t => renderTaskCard(t)).join('')}
          </div>
        </div>
      `;
    }

    function renderTaskCard(t) {
      const pClass = `badge-${t.priority || 'p3'}`;
      const isDone = t.status === 'done';
      return `
        <div class="task-card" onclick="toggleTaskStatus('${t.id}')">
          <span class="card-badge ${pClass}">${(t.priority || 'p3').toUpperCase()}</span>
          <div class="card-title" style="${isDone ? 'text-decoration: line-through; color: var(--text-muted);' : ''}">${t.title}</div>
          ${t.description ? `<div class="card-desc">${t.description}</div>` : ''}
          <div class="card-meta">
            <span><i class="fa-regular fa-clock"></i> ${t.due_date || 'No Date'}</span>
            <span><i class="fa-regular fa-circle-check"></i></span>
          </div>
        </div>
      `;
    }

    function renderListItem(t) {
      const isDone = t.status === 'done';
      return `
        <div class="list-item" onclick="toggleTaskStatus('${t.id}')">
          <div class="checkbox ${isDone ? 'checked' : ''}"><i class="fa-solid fa-check" style="font-size: 10px;"></i></div>
          <div style="flex:1;">
            <div style="font-weight: 600; ${isDone ? 'text-decoration: line-through; color: var(--text-muted);' : ''}">${t.title}</div>
            <div style="font-size:11px; color:var(--text-muted);">${t.due_date || 'No Date'}</div>
          </div>
          <span class="card-badge badge-${t.priority || 'p3'}">${(t.priority || 'p3').toUpperCase()}</span>
        </div>
      `;
    }

    function updateProgressStats() {
      const total = state.tasks.length;
      const done = state.tasks.filter(t => t.status === 'done').length;
      const pct = total === 0 ? 0 : Math.round((done / total) * 100);

      document.getElementById('completionPill').innerText = `${pct}% Completed`;
      document.getElementById('completionCountText').innerText = `(${done} of ${total} tasks done)`;
      document.getElementById('progressFill').style.width = `${pct}%`;
    }

    function setViewMode(mode) {
      state.viewMode = mode;
      document.getElementById('btnViewKanban').classList.toggle('active', mode === 'kanban');
      document.getElementById('btnViewList').classList.toggle('active', mode === 'list');
      renderApp();
    }

    function selectCategory(cat, el) {
      state.activeCategory = cat;
      document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
      if (el) el.classList.add('active');
      document.getElementById('activeCategoryTitle').innerText = el ? el.innerText : cat;
      renderApp();
    }

    function handleSearch(val) {
      state.searchQuery = val;
      renderApp();
    }

    function toggleSidebar() {
      document.getElementById('appSidebar').classList.toggle('collapsed');
      document.getElementById('appSidebar').classList.toggle('open');
    }

    function toggleTheme() {
      const isDark = document.body.getAttribute('data-theme') === 'dark';
      document.body.setAttribute('data-theme', isDark ? 'light' : 'dark');
    }

    function openCreateModal() { document.getElementById('createModal').classList.add('show'); }
    function closeCreateModal() { document.getElementById('createModal').classList.remove('show'); }

    function handleLogout() {
      localStorage.removeItem('taskflow_user');
      localStorage.removeItem('taskflow_token');
      location.reload();
    }
  </script>
@endverbatim
</body>
</html>
