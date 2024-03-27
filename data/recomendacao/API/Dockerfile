# Use the official Python image
FROM python:3.9 

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements_dev.txt .

# Install any dependencies
RUN pip install -r requirements_dev.txt

# Copy the rest of the application code
COPY . .

# Set up permissions for the log directory
RUN chown -R /opt/airflow/logs/scheduler
RUN mkdir -p /opt/airflow/logs/scheduler \
    && chown -R airflow:airflow /opt/airflow/logs

# Command to run the API
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
