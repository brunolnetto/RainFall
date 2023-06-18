import pytest
from predict_fun import make_prediction, validate_event, api_return

def test_make_prediction():
    # Test case 1: Testing with a single float value
    payload = 2.5
    expected_output = '42'
    assert make_prediction(payload) == expected_output

    # Test case 2: Testing with a list of integers
    payload = [1, 2, 3]
    expected_output = '42'
    assert make_prediction(payload) == expected_output

    # Add more test cases based on different input scenarios

def test_validate_event():
    # Test case 1: Testing with a single float value
    event = {'body': 2.5}
    expected_payload = [2.5]
    assert validate_event(event, None) == expected_payload

    # Test case 2: Testing with a list of integers
    event = {'body': [1, 2, 3]}
    expected_payload = [1, 2, 3]
    assert validate_event(event, None) == expected_payload

    # Test case 3: Testing with an unknown input format
    event = {'body': 'invalid'}
    
    expected_body = {'message': 'Unknown input format'}
    expected_code = 400

    print(validate_event(event, None))
    print(api_return(expected_body, expected_code))

    assert validate_event(event, None) == api_return(expected_body, expected_code)
    
    # Add more test cases based on different input scenarios

# Run the tests
pytest.main()