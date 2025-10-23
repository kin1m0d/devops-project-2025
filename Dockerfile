FROM python:3.9-slim

# Set the working directory
WORKDIR /app

COPY app.py .

RUN pip install --no-cache-dir flask

EXPOSE 8080

CMD ["python", "app.py"]