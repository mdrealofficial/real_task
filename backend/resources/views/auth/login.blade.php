@extends('layouts.app')

@section('title', 'Sign In — Task Flow')

@section('content')
<div style="position: fixed; inset: 0; background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%); display: flex; align-items: center; justify-content: center; z-index: 9999; padding: 20px;">
  <div style="background: #ffffff; width: 100%; max-width: 420px; padding: 36px; border-radius: 20px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.4); text-align: center; border: 1px solid rgba(255,255,255,0.2);">
    
    <div style="width: 60px; height: 60px; background: rgba(79, 70, 229, 0.1); color: #4f46e5; border-radius: 16px; display: inline-flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 20px;">
      <i class="fa-solid fa-square-check"></i>
    </div>
    
    <h2 style="font-size: 22px; font-weight: 800; color: #0f172a; margin-bottom: 8px; letter-spacing: -0.5px;">Sign In to Task Flow</h2>
    <p style="font-size: 13px; color: #64748b; margin-bottom: 28px; line-height: 1.4;">Enter your registered credentials to access your web dashboard</p>
    
    <form action="{{ route('login.post') }}" method="POST" style="text-align: left;">
      @csrf
      <div class="form-group" style="margin-bottom: 18px;">
        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 8px;">Email Address</label>
        <input type="email" name="email" class="form-control" placeholder="name@example.com" value="{{ old('email') }}" required style="width: 100%; padding: 12px 14px; font-size: 14px; background: #f8fafc; color: #0f172a; border: 1px solid #cbd5e1; border-radius: 10px; outline: none;">
      </div>
      
      <div class="form-group" style="margin-bottom: 22px;">
        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 8px;">Password</label>
        <input type="password" name="password" class="form-control" placeholder="••••••••" value="" required style="width: 100%; padding: 12px 14px; font-size: 14px; background: #f8fafc; color: #0f172a; border: 1px solid #cbd5e1; border-radius: 10px; outline: none;">
      </div>

      @if($errors->has('email'))
        <div style="background: rgba(244, 63, 94, 0.1); border: 1px solid rgba(244, 63, 94, 0.3); color: #f43f5e; font-size: 13px; padding: 10px 14px; border-radius: 8px; margin-bottom: 18px;">
          <i class="fa-solid fa-triangle-exclamation"></i> {{ $errors->first('email') }}
        </div>
      @endif

      <button type="submit" class="btn btn-primary btn-block" style="width: 100%; padding: 12px; font-size: 14px; font-weight: 700; background: #4f46e5; color: #ffffff; border: none; border-radius: 10px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;">
        <i class="fa-solid fa-right-to-bracket"></i> Sign In to Dashboard
      </button>
    </form>
  </div>
</div>
@endsection
