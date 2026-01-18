# DeepSeek API Configuration

This directory contains configuration files for the DeepSeek API integration.

## Setup

1. Copy `deepseek_api.example.json` to `deepseek_api.json`:
   ```bash
   cp config/deepseek_api.example.json config/deepseek_api.json
   ```

2. Edit `deepseek_api.json` and replace the masked API key (`sk-d7923***********************dca3`) with your **full** DeepSeek API key.

   ⚠️ **Note**: The config file currently contains a masked/partial API key. You must replace it with your complete API key (including the masked portion) for the API to work properly.

   **Your API Key Information:**
   - Key Name: `game_worker_20260110`
   - Full Key: Replace `sk-d7923***********************dca3` with your complete key starting with `sk-d7923...dca3`

## Configuration

The configuration file (`deepseek_api.json`) contains the following settings:

- **api_base_url**: DeepSeek API endpoint (default: `https://api.deepseek.com/v1`)
- **api_key**: Your DeepSeek API key (required)
- **model**: Default model to use (`deepseek-chat` or `deepseek-coder`)
- **model_options**: Available model options
- **timeout**: Request timeout in seconds (default: 30)
- **max_retries**: Maximum number of retry attempts (default: 3)

## Security

⚠️ **Important**: The `deepseek_api.json` file contains sensitive API keys and is excluded from version control via `.gitignore`. Never commit this file to a public repository.

## Usage

In your Godot scripts, you can use the `DeepSeekAPI` class:

```gdscript
# Example: Basic chat completion
var api = $DeepSeekAPI
var messages = [
    {"role": "user", "content": "Hello, how are you?"}
]
api.chat_completion(messages)
api.request_completed.connect(_on_api_response)

func _on_api_response(response: Dictionary):
    if response.has("choices") and response.choices.size() > 0:
        var reply = response.choices[0].message.content
        print("DeepSeek replied: ", reply)
```
