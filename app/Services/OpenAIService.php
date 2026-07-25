<?php

namespace App\Services;

use App\Services\Contracts\AIServiceContract;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OpenAIService implements AIServiceContract
{
    protected string $apiKey;

    protected string $model;

    protected string $baseUrl;

    public function __construct()
    {
        $this->apiKey = (string) config('services.openai.api_key');
        $this->model = (string) config('services.openai.model', 'gpt-3.5-turbo');
        $this->baseUrl = rtrim((string) config('services.openai.base_url', 'https://api.openai.com/v1'), '/');
    }

    public function chat(string $systemPrompt, array $messages): string
    {
        if ($this->apiKey === '') {
            throw new \RuntimeException('OpenAI API key is not configured.');
        }

        $payload = [
            'model' => $this->model,
            'temperature' => 0.3,
            'messages' => [
                ['role' => 'system', 'content' => $systemPrompt],
                ...$messages,
            ],
        ];

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer '.$this->apiKey,
                'Content-Type' => 'application/json',
                'HTTP-Referer' => config('app.url'),
                'X-Title' => config('app.name'),
            ])
                ->timeout(60)
                ->post("{$this->baseUrl}/chat/completions", $payload);

            if (! $response->successful()) {
                Log::error('OpenAI request failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);

                dd($response->status(), $response->json());

                throw new \RuntimeException('AI service returned an error (HTTP '.$response->status().').');
            }

            $body = $response->json();
            $content = $body['choices'][0]['message']['content'] ?? null;

            if (! is_string($content) || trim($content) === '') {
                Log::error('OpenAI returned empty or invalid content', ['body' => $body]);

                throw new \RuntimeException('AI service returned an empty response.');
            }

            return trim($content);
        } catch (\RuntimeException $e) {
            throw $e;
        } catch (\Throwable $e) {
            Log::error('Unexpected OpenAI client error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            throw new \RuntimeException('Unable to reach the AI service at this time.');
        }
    }
}
