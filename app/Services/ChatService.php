<?php

namespace App\Services;

use App\Services\Contracts\AIServiceContract;
use App\Models\User;

class ChatService
{
    public function __construct(
        protected PromptBuilderService $promptBuilder,
        protected AIServiceContract $ai,
    ) {}

    /**
     * Process a single user message, using the provided conversation history
     * to maintain context. Returns the assistant's text response.
     *
     * @param  \App\Models\User  $user
     * @param  string  $userMessage  Sanitized user input.
     * @param  array<int, array{role: string, content: string}>  $history
     * @return array{reply: string, updated_history: array<int, array{role: string, content: string}>}
     */
    public function sendMessage(User $user, string $userMessage, array $history = []): array
    {
        $sanitizedMessage = $this->sanitizeMessage($userMessage);
        if ($sanitizedMessage === '') {
            return [
                'reply' => 'Please enter a question or message so I can help you with your vehicles.',
                'updated_history' => $history,
            ];
        }

        $systemPrompt = $this->promptBuilder->buildSystemPrompt($user);

        // Keep conversation history reasonably sized (last 12 messages / 6 turns)
        // to stay within token limits while still maintaining context.
        $trimmedHistory = array_slice($history, -12);

        $messagesForAI = array_merge($trimmedHistory, [
            ['role' => 'user', 'content' => $sanitizedMessage],
        ]);

        $reply = $this->ai->chat($systemPrompt, $messagesForAI);

        $updatedHistory = array_merge($trimmedHistory, [
            ['role' => 'user', 'content' => $sanitizedMessage],
            ['role' => 'assistant', 'content' => $reply],
        ]);

        return [
            'reply' => $reply,
            'updated_history' => $updatedHistory,
        ];
    }

    protected function sanitizeMessage(string $message): string
    {
        // Trim, strip tags / control characters, collapse multi-line whitespace
        $text = trim($message);
        $text = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/u', '', $text) ?? '';
        $text = preg_replace('/\s+/u', ' ', $text) ?? '';

        // Basic length guard
        if (mb_strlen($text) > 2000) {
            $text = mb_substr($text, 0, 2000);
        }

        return $text;
    }
}
