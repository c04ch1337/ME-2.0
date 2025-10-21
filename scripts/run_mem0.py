from mem0 import Memory
from fastapi import FastAPI
import uvicorn
app = FastAPI()
memory = Memory()
@app.post("/add")
def add_memory(data: dict):
    memory.add(data["text"], user_id=data.get("user_id", "me"))
    return {"status": "added"}
@app.get("/get")
def get_memory(user_id: str = "me"):
    return memory.get_all(user_id=user_id)
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=7777)