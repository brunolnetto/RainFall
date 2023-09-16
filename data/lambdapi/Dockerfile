FROM public.ecr.aws/lambda/python:3.9.2023.03.15.15-x86_64

# Set the working directory back to the Lambda task root
WORKDIR ${LAMBDA_TASK_ROOT}

# Install system dependencies (if needed)
RUN pip install poetry

# Copy poetry configuration file
COPY pyproject.toml .
COPY poetry.lock .

# Copy your application code
COPY lambda_api/ .
    
# Copy model pickle (alternatively, upload it to S3)
# TAKE NOTE: UNCOMMENT LINE BELOW IN CASE THERE IS A MODEL TO PICKLE
# COPY model.pickle ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler
CMD ["predict_service.predict"]
