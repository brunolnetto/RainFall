FROM public.ecr.aws/lambda/python:3.9.2023.03.15.15-x86_64 

# Install the requirements.txt
COPY requirements.txt  .
RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Copy all .py files in the current directory to the Lambda task root
COPY *.py ${LAMBDA_TASK_ROOT}/

# Copy model pickle (alternatively, upload it to S3)
# TAKE NOTE: UNCOMMENT LINE BELOW IN CASE THERE IS A MODEL TO PICKLE
# COPY model.pickle ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler
CMD [ "predict_resolver.predict" ]