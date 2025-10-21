import requests
import subprocess
def run_strix(task):
    try:
        result = subprocess.run(["strix", "--model", "ollama/llama3", task], capture_output=True, text=True)
        return result.stdout
    except Exception as e:
        return str(e)
def route_to_chatrouter(message):
    response = requests.post("http://localhost:3000/route", json={"message": message})
    return response.json()
if __name__ == "__main__":
    task = "Simulate pentest on example.com"
    strix_result = run_strix(task)
    print("STRIX:", strix_result)
    routed = route_to_chatrouter(f"Process: {strix_result}")
    print("Routed:", routed)
    requests.post("http://localhost:7777/add", json={"text": f"Task done: {task}", "user_id": "me"})