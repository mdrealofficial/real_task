<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>@yield('title', 'Task Flow — Personal Task Management')</title>
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
      --primary-light: rgba(79, 70, 229, 0.12);
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

    .app-wrapper { display: flex; flex: 1; overflow: hidden; position: relative; }

    /* Sidebar Navigation */
    .sidebar {
      width: 240px; background: var(--card-bg); border-right: 1px solid var(--border-color);
      display: flex; flex-direction: column; transition: width 0.25s ease; z-index: 100; flex-shrink: 0; position: relative;
    }
    .sidebar.collapsed { width: 64px; }
    .sidebar.collapsed .brand-title,
    .sidebar.collapsed .nav-text,
    .sidebar.collapsed .nav-badge,
    .sidebar.collapsed .nav-section-title,
    .sidebar.collapsed .user-email-text,
    .sidebar.collapsed .version-text { display: none !important; }
    
    .sidebar.collapsed .sidebar-header { padding: 0 8px; justify-content: center; }
    .sidebar.collapsed .brand { justify-content: center; gap: 0; }
    .sidebar.collapsed .nav-item { justify-content: center; padding: 10px 0; gap: 0; }
    .sidebar.collapsed .nav-item i { font-size: 18px; margin: 0; }
    .sidebar.collapsed .user-info { justify-content: center; margin-bottom: 8px; }
    .sidebar.collapsed #sidebarToggleIcon { transform: rotate(180deg); }

    .sidebar-header {
      height: 64px; padding: 0 16px; display: flex; align-items: center; justify-content: space-between;
      border-bottom: 1px solid var(--border-color);
    }
    .brand { display: flex; align-items: center; gap: 10px; font-weight: 800; font-size: 18px; }
    .brand-icon {
      width: 32px; height: 32px; background: var(--primary-light); color: var(--primary);
      border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0;
    }
    .sidebar-menu { flex: 1; padding: 12px 8px; overflow-y: auto; overflow-x: hidden; }
    .nav-item {
      display: flex; align-items: center; gap: 12px; padding: 10px 12px; font-size: 13px; font-weight: 600;
      color: var(--text-muted); border-radius: 8px; cursor: pointer; text-decoration: none; margin-bottom: 4px; transition: all 0.15s;
    }
    .nav-item:hover, .nav-item.active { background: var(--primary-light); color: var(--primary); }
    .nav-badge { margin-left: auto; background: var(--border-color); color: var(--text-main); font-size: 11px; padding: 2px 8px; border-radius: 12px; }

    .sidebar-footer { padding: 12px; border-top: 1px solid var(--border-color); font-size: 12px; }
    .user-info { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; }
    .avatar { width: 28px; height: 28px; background: var(--primary); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; flex-shrink: 0; }

    /* Main Area */
    .main-canvas { flex: 1; display: flex; flex-direction: column; overflow: hidden; min-width: 0; }

    /* Top Navigation Header */
    .top-header {
      height: 64px; padding: 0 20px; background: var(--card-bg); border-bottom: 1px solid var(--border-color);
      display: flex; align-items: center; justify-content: space-between; gap: 12px;
    }
    .category-title { font-size: 16px; font-weight: 700; white-space: nowrap; }
    .search-box { position: relative; max-width: 220px; flex: 1; }
    .search-box i { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 13px; }
    .search-box input { padding-left: 34px; height: 36px; }

    .form-control {
      width: 100%; padding: 8px 12px; font-size: 14px; background: var(--bg-color); color: var(--text-main);
      border: 1px solid var(--border-color); border-radius: 8px; outline: none; transition: all 0.2s;
    }
    .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }

    .btn {
      display: inline-flex; align-items: center; justify-content: center; gap: 8px;
      padding: 8px 16px; font-size: 13px; font-weight: 600; border-radius: 8px; border: none;
      cursor: pointer; text-decoration: none; transition: all 0.2s;
    }
    .btn-primary { background: var(--primary); color: #fff; }
    .btn-primary:hover { background: var(--primary-hover); }
    .btn-outline { background: transparent; border: 1px solid var(--border-color); color: var(--text-main); }
    .btn-outline:hover { background: var(--border-color); }
    .btn-block { width: 100%; }

    .view-toggle { display: flex; background: var(--bg-color); padding: 3px; border-radius: 8px; border: 1px solid var(--border-color); }
    .view-btn { padding: 5px 12px; font-size: 12px; font-weight: 600; border-radius: 6px; border: none; cursor: pointer; color: var(--text-muted); text-decoration: none; background: transparent; }
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
      display: flex; align-items: center; gap: 14px; transition: all 0.15s;
    }
    .list-item:hover { border-color: var(--primary); box-shadow: var(--shadow-sm); }

    /* Modal Backdrop */
    .modal-backdrop {
      position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px);
      display: none; align-items: center; justify-content: center; z-index: 1000;
    }
    .modal-backdrop.show { display: flex; }
    .modal-box {
      background: var(--card-bg); width: 100%; max-width: 500px; padding: 24px; border-radius: 16px;
      border: 1px solid var(--border-color); box-shadow: var(--shadow-lg); max-height: 90vh; overflow-y: auto;
    }

    .mobile-menu-btn { display: none; }
    @media (max-width: 768px) {
      .sidebar { position: absolute; left: -240px; height: 100%; }
      .sidebar.open { left: 0; }
      .brand-title { display: none; }
      .search-box { max-width: 130px; }
      .content-viewport { padding: 12px; }
      .mobile-menu-btn { display: inline-flex; }
    }
  </style>
  @yield('styles')
</head>
<body>
  @yield('content')

  <script>
    function toggleSidebar() {
      document.getElementById('appSidebar').classList.toggle('collapsed');
      document.getElementById('appSidebar').classList.toggle('open');
    }

    function toggleTheme() {
      const isDark = document.body.getAttribute('data-theme') === 'dark';
      document.body.setAttribute('data-theme', isDark ? 'light' : 'dark');
    }

    function openCreateModal() {
      document.getElementById('createModal').classList.add('show');
    }

    function closeCreateModal() {
      document.getElementById('createModal').classList.remove('show');
    }
  </script>
  @yield('scripts')
</body>
</html>
