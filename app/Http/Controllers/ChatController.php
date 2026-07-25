<?php

namespace App\Http\Controllers;

use App\Http\Requests\Chat\SendChatRequest;
use App\Services\ChatService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class ChatController extends Controller
{
    public function __construct(
        protected ChatService $chat,
    ) {}

    public function send(SendChatRequest $request): JsonResponse
    {
        $validated = $request->validated();

        try {
            $result = $this->chat->sendMessage(
                user: $request->user(),
                userMessage: $validated['message'],
                history: $validated['history'] ?? [],
            );

            return response()->json([
                'data' => [
                    'reply' => $result['reply'],
                    'history' => $result['updated_history'],
                ],
            ]);
        } catch (\RuntimeException $e) {
            Log::warning('Chat request failed with known error', [
                'message' => $e->getMessage(),
                'user_id' => $request->user()?->id,
            ]);

            return response()->json([
                'message' => $e->getMessage(),
            ], 503);
        } catch (\Throwable $e) {
            Log::error('Unexpected chat server error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => $request->user()?->id,
            ]);

            return response()->json([
                'message' => 'Something went wrong while contacting the AI assistant.',
            ], 500);
        }
    }
}
