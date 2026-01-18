extends Node

# DeepSeek API Client for Godot
# Handles HTTP requests to DeepSeek API

signal request_completed(response_data: Dictionary)
signal request_failed(error: Dictionary)

var api_config: Dictionary = {}
var http_request: HTTPRequest

func _ready():
	load_config()
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func load_config():
	"""Load API configuration from JSON file"""
	var config_path = "res://config/deepseek_api.json"
	var config_file = FileAccess.open(config_path, FileAccess.READ)
	
	if config_file == null:
		push_error("Failed to load DeepSeek API config from: " + config_path)
		return
	
	var json_string = config_file.get_as_text()
	config_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse DeepSeek API config JSON: " + json.get_error_message())
		return
	
	api_config = json.data
	print("DeepSeek API config loaded successfully")

func chat_completion(messages: Array, model: String = "") -> void:
	"""Send a chat completion request to DeepSeek API
	
	Args:
		messages: Array of message dictionaries with 'role' and 'content' keys
		model: Model to use (defaults to config model)
	"""
	if api_config.is_empty():
		push_error("API config not loaded")
		request_failed.emit({"error": "API config not loaded"})
		return
	
	var endpoint = api_config.get("api_base_url", "https://api.deepseek.com/v1") + "/chat/completions"
	var selected_model = model if model != "" else api_config.get("model", "deepseek-chat")
	var api_key = api_config.get("api_key", "")
	
	if api_key == "" or api_key.begins_with("your-"):
		push_error("API key not configured properly")
		request_failed.emit({"error": "API key not configured"})
		return
	
	var request_body = {
		"model": selected_model,
		"messages": messages,
		"temperature": 0.7,
		"max_tokens": 2000
	}
	
	var json_body = JSON.stringify(request_body)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	var error = http_request.request(endpoint, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		push_error("Failed to send HTTP request: " + str(error))
		request_failed.emit({"error": "HTTP request failed", "error_code": error})
		return
	
	print("DeepSeek API request sent to: ", endpoint)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""Handle HTTP request completion"""
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("HTTP request failed with result: " + str(result))
		request_failed.emit({
			"error": "HTTP request failed",
			"result": result,
			"response_code": response_code
		})
		return
	
	var json = JSON.new()
	var json_string = body.get_string_from_utf8()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse response JSON: " + json.get_error_message())
		request_failed.emit({
			"error": "Failed to parse response",
			"response_code": response_code,
			"body": json_string
		})
		return
	
	var response_data = json.data
	
	if response_code >= 200 and response_code < 300:
		print("DeepSeek API request successful")
		request_completed.emit(response_data)
	else:
		push_error("API request failed with status: " + str(response_code))
		request_failed.emit({
			"error": "API request failed",
			"response_code": response_code,
			"response_data": response_data
		})

func get_chat_response(messages: Array, model: String = "") -> String:
	"""Convenience method to get chat response as string (synchronous-like)
	
	Note: This uses a simple approach. For better async handling, use chat_completion() with signals.
	"""
	var response_text = ""
	var got_response = false
	
	var callback = func(data: Dictionary):
		if data.has("choices") and data.choices.size() > 0:
			response_text = data.choices[0].message.content
		got_response = true
	
	request_completed.connect(callback, CONNECT_ONE_SHOT)
	chat_completion(messages, model)
	
	# Wait for response (simple polling - not ideal for production)
	var max_wait = api_config.get("timeout", 30)
	var waited = 0.0
	while not got_response and waited < max_wait:
		await get_tree().process_frame
		waited += get_process_delta_time()
	
	return response_text
