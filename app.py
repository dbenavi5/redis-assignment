from fastapi import FastAPI, HTTPException, Request
import redis
import os

app = FastAPI()

# Redis connection settings.

# In Module 1, Redis runs directly on out local Mac, so localhost is
# the correct default.

# Later, Kubernetes will override REDIS_HOST and set it to the Redis
# Kubernetes Service name.
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))


# Create the Redis client.
r = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    print(f'Incoming request path: {request.url.path}')
    response = await call_next(request)
    return response

@app.get("/")
def root():
    return {"message": "FastAPI is working"}

@app.post("/cache")
def store_value(key: str, value: str):
    r.set(key, value)
    return {"message": f"Stored key '{key}'"}

@app.get("/cache")
def get_value(key: str):
    value = r.get(key)

    if value is None:
        raise HTTPException(
            status_code=404,
            detail="Ket not found"
        )

    return {
        "key": key,
        "value": value.decode()
    }