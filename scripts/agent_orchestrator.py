import os
import requests
import subprocess

CHATROUTER_URL = os.getenv("CHATROUTER_URL", "http://chatrouter:3000")
MEM0_URL = os.getenv("MEM0_URL", "http://mem0:7777")
def run_strix(task):
    try:
        result = subprocess.run(["strix", "--model", "ollama/llama3", task], capture_output=True, text=True)
        return result.stdout
    except Exception as e:
        return str(e)
def route_to_chatrouter(message):
    response = requests.post(f"{CHATROUTER_URL}/route", json={"message": message})
    return response.json()
if __name__ == "__main__":
    task = "Simulate pentest on example.com"
    strix_result = run_strix(task)
    print("STRIX:", strix_result)
    routed = route_to_chatrouter(f"Process: {strix_result}")
    print("Routed:", routed)
    requests.post(f"{MEM0_URL}/add", json={"text": f"Task done: {task}", "user_id": "me"})