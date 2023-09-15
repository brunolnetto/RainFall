"""
AWS Lambda API for Model Predictions

This module provides an AWS Lambda function for making predictions using a machine learning model.
It includes functions for request input validation, making predictions, and handling API responses.

Functions:
    - make_prediction(payload): Makes predictions using the provided payload.
    - api_return(body, status): Constructs an API response object with the specified body and status code.
    - validate_event(event, context): Validates and extracts the payload from the incoming event.
    - predict(event, context): Main prediction function that handles requests and responses.

Usage:
1. Deploy this Lambda function on AWS and set up API Gateway as a trigger.
2. Send POST requests to the API endpoint to get predictions.

Example Usage:
POST /predict
{
    "data": [1.2, 2.3, 3.4]
}

Dependencies:
- json: For JSON encoding and decoding.
- logging: For logging events and errors.
- model: Import 'model_prediction_map' and 'validate_body' functions from the 'model' module 
    for making predictions.

Logging:
- INFO level: Successful prediction events.
- ERROR level: Error events during prediction.

Author: Bruno Peixoto
E-mail: brunolnetto@gmail.com
Date: 15/09/2023
"""

from json import loads, dumps
import logging

from model_resolver import ALLOWED_TYPES, model_prediction_map, validate_body
from utils import are_types 

# Configure the logging settings
# Set the desired log level
logging.basicConfig(level=logging.INFO)  

# Function aliad for prediciton function wrapping
def make_prediction(payload):
    return model_prediction_map(payload)

# Return json-like format for prediction response
def api_return(body, status, error):
    return {
        'isBase64Encoded': False,
        'statusCode': status,
        'headers': {'Content-Type': 'application/json'},
        'body': dumps(body, default=str),
        'error_message': error
    }

# This function provides entry type validation 
def validate_body(body):
    # Initialization
    is_valid=True
    payload=[]

    # Required: Un-stringify body 
    if isinstance(body, str):
        body_ = loads(body)
    else:
        body_ = body

    # List with valid typed entries
    if isinstance(body_, list):
        are_allowed_types = are_types(body_, ALLOWED_TYPES)
        
        if(are_allowed_types):
            payload = body_
        else:
            is_valid = False
    
    # Variable type within valid types
    elif isinstance(body_, ALLOWED_TYPES):
        payload = [body_]
    else:
        is_valid = False

    return is_valid, payload

# Request event validation (i.e. body) 
def validate_event(event, context):
    # Initialization
    error_msg=''
    
    # Validate provided body
    body=event['body']
    is_valid, payload_list = validate_body(body)
    
    # Validation step
    if is_valid:
        code=200        
    else:
        error_msg='Unknown prediction input format.'
        code=400
        
    return api_return(payload_list, code, error_msg)

# Prediction main map
def predict(event, context):
    # Initialization
    error_msg=''
    prediction_result=[]

    # Payload validation
    payload=validate_event(event, context)
    
    # Try-catch pattern for consistent handling
    try:
        # Response status code
        code=200
        
        # Prediction
        prediction_result = make_prediction(payload)

        # Log successful event
        logging.info("Successful prediction: %s", prediction_result)
    
    except Exception as e:        
        # Response error
        error_msg=str(e)

        # Response status code
        code=500

        # Log unsuccessful event
        logging.error("Unsuccessful prediction: %s", error_msg)

    return api_return(prediction_result, code, error_msg)