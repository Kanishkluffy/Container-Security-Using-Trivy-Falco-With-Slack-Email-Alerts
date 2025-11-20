# Using an older Python version to demonstrate vulnerabilities
FROM python:3.8-slim

# Set working directory
WORKDIR /app

# Install system dependencies (some with vulnerabilities)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Create a non-root user (security best practice)
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Expose port
EXPOSE 5000

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run the application
CMD ["python", "app.py"]