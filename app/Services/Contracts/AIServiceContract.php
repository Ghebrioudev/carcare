<?php

namespace App\Services\Contracts;

interface AIServiceContract
{
    /**
     * Send a chat completion request with conversation history and a system prompt.
     *
     * @param  string  $systemPrompt
     * @param  array<int, array{role: string, content: string}>  $messages
     * @return string The assistant's text response.
     *
     * @throws \RuntimeException If the AI provider fails or returns an invalid response.
     */
    public function chat(string $systemPrompt, array $messages): string;
}
