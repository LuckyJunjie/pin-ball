extends Node

# Example script demonstrating how to use DeepSeekAPI
# Attach this to a node in your scene to test the API integration

@onready var deepseek_api: DeepSeekAPI = $DeepSeekAPI

func _ready():
	# Connect signals
	if deepseek_api:
		deepseek_api.request_completed.connect(_on_api_success)
		deepseek_api.request_failed.connect(_on_api_error)
		
		# Example: Send a chat completion request
		test_chat_completion()

func test_chat_completion():
	"""Example: Send a chat completion request to DeepSeek"""
	if not deepseek_api:
		push_error("DeepSeekAPI node not found")
		return
	
	var messages = [
		{"role": "user", "content": "Hello! Can you help me with a simple question?"}
	]
	
	print("Sending request to DeepSeek API...")
	deepseek_api.chat_completion(messages, "deepseek-chat")

func _on_api_success(response: Dictionary):
	"""Handle successful API response"""
	print("✓ API Request Successful!")
	
	if response.has("choices") and response.choices.size() > 0:
		var choice = response.choices[0]
		if choice.has("message"):
			var content = choice.message.content
			print("Response: ", content)
	else:
		print("Unexpected response format: ", response)

func _on_api_error(error: Dictionary):
	"""Handle API error"""
	print("✗ API Request Failed!")
	print("Error: ", error)
	
	if error.has("error"):
		print("Error message: ", error.error)
	if error.has("response_code"):
		print("HTTP Status Code: ", error.response_code)
