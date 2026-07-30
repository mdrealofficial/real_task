@extends('layouts.app')

@section('title', 'Sign In — Task Flow')

@section('content')
<div style="position: fixed; inset: 0; background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: center; z-index: 9999;">
  <div class="login-card">
    <div class="login-logo"><i class="fa-solid fa-square-check"></i></div>
    <h2 style="font-size: 20px; font-weight: 800; margin-bottom: 6px;">Sign In to Task Flow</h2>
    <p style="font-size: 12px; color: var(--text-muted); margin-bottom: 24px;">Enter your credentials to access your tasks web dashboard</p>
    
    <form action="{{ route('login.post') }}" method="POST">
      @csrf
      <div class="form-group">
        <label>Email Address</label>
        <input type="email" name="email" class="form-control" placeholder="name@example.com" value="mdreal.official@gmail.com" required>
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" class="form-control" placeholder="••••••••" value="Staritlab77" required>
      </div>

      @if($errors->has('email'))
        <div style="color: var(--accent-rose); font-size: 12px; margin-bottom: 14px;">
          {{ $errors->first('email') }}
        </div>
      @endif

      <button type="submit" class="btn btn-primary btn-block"><i class="fa-solid fa-right-to-bracket"></i> Sign In</button>
    </form>
  </div>
</div>
@endsection
