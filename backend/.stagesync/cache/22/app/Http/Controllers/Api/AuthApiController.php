<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthApiController extends Controller
{
    /**
     * Authenticate user with Email & Password
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $email = strtolower(trim($request->input('email')));
        $password = $request->input('password');

        $user = User::where('email', $email)->first();

        $sha256Hash = hash('sha256', $password . '_salt_2026');
        $isValidPassword = $user && (
            Hash::check($password, $user->password_hash) ||
            $user->password_hash === $sha256Hash ||
            $user->password_hash === hash('sha256', $password)
        );

        if (!$isValidPassword) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email or password.',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'email' => $user->email,
            ],
            'token' => base64_encode($user->id . ':' . time()),
        ]);
    }

    /**
     * Change User Password
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'user_id' => 'required|string',
            'new_password' => 'required|string|min:6',
        ]);

        $user = User::find($request->input('user_id'));

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        $user->password_hash = Hash::make($request->input('new_password'));
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password updated successfully.',
        ]);
    }
}
