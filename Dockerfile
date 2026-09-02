# Start with an official lightweight Python image.
FROM python:3.11-slim

# Set the working directory inside the container.
WORKDIR /app

# Copy the dependency file first.
COPY requirements.txt .

# Install the application's Python dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the FastAPI application into the image.
COPY app.py .

# Document that the application listens on port 8000.
EXPOSE 8000

# Start the FastAPI application.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]