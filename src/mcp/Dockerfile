FROM python:3.11-slim

WORKDIR /app

# We will create this requirements file next
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8001

# The command to start your specific server file
CMD ["python", "pronunciation_server.py"]
