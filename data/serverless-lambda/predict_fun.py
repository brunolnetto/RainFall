import json

## By loading the pickle outside `predict`,
## we re-use it across different Lambda calls for the same execution instance
# 
# import cloudpickle
# with open('model.pickle', 'rb') as f:
#     model = cloudpickle.load(f)

# REPLACE WITH: 
#   - command call model.predict(payliad).tolist()
def make_prediction(payload):
    #return str(type(payload))
    return list(map(lambda x: x**2, payload))

def api_return(body, status):
    return {
        'isBase64Encoded': False,
        'statusCode': status,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(body, default=str)
    }

# Request input validation 
def validate_event(event, context): 
    body=event['body']

    # REPLACE WITH:
    #   - Custom validation elif steps 
    if isinstance(body, float):
        payload = [body]

    elif isinstance(body, list):
        payload = body

    elif isinstance(body, str):
        payload = json.loads(body)
    
    else:
        error_json={'error': 'Unknown input format'}
        code=400
        
        return api_return(error_json, code)
    
    return payload

# Prediction
def predict(event, context):
    payload=validate_event(event, context)
    
    try:
        output = make_prediction(payload)
    
    except Exception as e:
        error_json={'error': str(e)}
        code=500

        return api_return(error_json, code)

    return api_return(output, 200)