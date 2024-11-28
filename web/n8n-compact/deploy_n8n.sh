#!/bin/bash

# Enable error handling
set -e


# Variables for JSON schema and config files
n8n_json_schema='{
    "type": "object",
    "properties": {
        "webhook_url": {
            "type": "string",
            "format": "uri"
        },
        "editor_url": {
            "type": "string",
            "minLength": 1
        },
        "smtp": {
            "type": "object",
            "properties": {
                "email": {
                    "type": "string",
                    "format": "email"
                },
                "user": {
                    "type": "string"
                },
                "password": {
                    "type": "string"
                },
                "host": {
                    "type": "string"
                },
                "port": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 65535
                },
                "ssl": {
                    "type": "boolean"
                }
            },
            "required": ["email", "user", "password", "host", "port"]
        }
    },
    "required": ["webhook_url", "editor_url", "smtp"]
}'


# Define colors with consistent names
declare -A COLORS=(
    [yellow]="\e[33m"
    [green]="\e[32m"
    [white]="\e[97m"
    [beige]="\e[93m"
    [red]="\e[91m"
    [blue]="\e[34m"
    [cyan]="\e[36m"
    [magenta]="\e[35m"
    [black]="\e[30m"
    [gray]="\x1b[90m"
    [orange]="\x1b[38;5;214m"
    [reset]="\e[0m"
)


# Define text styles
declare -A STYLES=(
    [bold]="\e[1m"
    [dim]="\e[2m"
    [italic]="\e[3m"
    [underline]="\e[4m"
    [hidden]="\e[8m"
    [reset]="\e[0m"
)


# Global variables
HAS_TIMESTAMP=true
DEFAULT_NETWORK="default_network"


# Function to generate a random string
random_string() {
    local length="${1:-16}"

    local word="$(openssl rand -hex $length)"
    echo "$word"
}


# Function to wait for a specified number of seconds
wait_secs() {
    local seconds=$1
    sleep "$seconds"
}


clear_line() {
    tput cuu1  # Move the cursor up one line
    tput el   # Clear the current line
}


# Function to strip existing ANSI escape sequences (colors and styles) from a string
strip_ansi() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*[mK]//g'
}


# Function to apply color and style to a string, even if it contains existing color codes
colorize() {
    local text="$1"
    local color_name=$(echo "$2" | tr '[:upper:]' '[:lower:]')
    local style_name=$(echo "$3" | tr '[:upper:]' '[:lower:]')

    # Remove any existing ANSI escape sequences (colors or styles) from the text
    text=$(strip_ansi "$text")

    # Get color code, default to reset if not found
    local color_code="${COLORS[$color_name]:-${COLORS[reset]}}"
    
    # If no style name is provided, use "reset" style as default
    if [[ -z "$style_name" ]]; then
        local style_code="${STYLES[reset]}"
    else
        local style_code="${STYLES[$style_name]:-${STYLES[reset]}}"
    fi

    # Print the text with the chosen color and style
    echo -e "${style_code}${color_code}${text}${STYLES[reset]}${COLORS[reset]}"
}


# Function to display a step with improved formatting
get_status_icon() {
    local type="$1"

    case "$type" in
        "success") echo "✅" ;;   # Success icon
        "error") echo "❌" ;;     # Error icon
        "warning") echo "⚠️ " ;;  # Warning icon
        "info") echo "📖" ;;       # Info icon
        "highlight") echo "✨" ;; # Highlight icon
        "debug") echo "🐞" ;;     # Debug icon
        "critical") echo "🚨" ;;  # Critical icon
        "note") echo "📝" ;;      # Note icon
        "important") echo "⚡" ;; # Important icon
        "wait") echo "⏳" ;;      # Highlight icon
        *) echo "🔵" ;;           # Default icon (e.g., ongoing step)
    esac
}


# Function to get the color code based on the message type
get_status_color() {
    case "$type" in
        "success") echo "green" ;;
        "error") echo "red" ;;
        "warning") echo "yellow" ;;
        "info") echo "white" ;;
        "highlight") echo "cyan" ;;
        "debug") echo "blue" ;;
        "critical") echo "magenta" ;;
        "note") echo "gray" ;;
        "important") echo "orange" ;;
        "wait") echo "white" ;;
        *) echo "white" ;;  # Default to white for unknown types
    esac
}


# Function to get the style code based on the message type
get_status_style() {
    case "$type" in
        "success" | "info") echo "bold" ;;  # Bold for success and info
        "error" | "critical") echo "italic" ;;  # Italic for error and critical
        "warning") echo "underline" ;;  # Underline for warning
        "highlight" | "wait") echo "bold,italic" ;;  # Bold and italic for highlight
        *) echo "normal" ;;  # Default to normal style
    esac
}


# General function to format and display messages with optional timestamp, color, and icon
format_message() {
    local type="$1"              # Message type (success, error, etc.)
    local text="$2"              # Message text
    local timestamp="${3:-true}" # Option to display timestamp (default is false)

    # Determine color based on message type
    local color
    color=$(get_status_color "$type")

    # Determine style based on message type (optional)
    local style_code
    style_code=$(get_status_style "$type")

    # Get icon based on status
    local icon  
    icon=$(get_status_icon "$type")

    # Add timestamp if enabled
    local formatted_message="$text"
    if [ "$timestamp" = true ]; then
        formatted_message="[$(date '+%Y-%m-%d %H:%M:%S')] $formatted_message"
    fi

    # Display the message with icon, color, style, and timestamp (if enabled)
    echo -e "$icon $(colorize "$formatted_message" "$color" "$style")"
}


# Function to display a message with improved formatting
echo_message() {
    local type="$1"
    local text="$2"
    local timestamp="${3:-true}"
    echo -e "$(format_message "$type" "$text" $timestamp)"
}


# Function to display a step with improved formatting
echo_step() {
    local current_step="$1"     # Current step number
    local total_steps="$2"      # Total number of steps
    local message="$3"          # Step message
    local type="${4:-default}"  # Status type (default to 'info')
    local timestamp="${5}"      # Optional timestamp flag

    # If 'timestamp' is passed as an argument, prepend the timestamp to the message
    if [ -n "$timestamp" ]; then
        local formatted_message=$(format_message "$type" "$step_message" true)
    else
        local formatted_message=$(format_message "$type" "$step_message" false)
    fi

    # Format the step message with the specified color and style
    local message="Step $current_step/$total_steps: $message"
    formatted_message=$(format_message "$type" "$message" $timestamp)

    # Print the formatted message with the icon and message
    echo -e "$formatted_message"
}


# Recursive function to validate JSON against a schema
validate_json_recursive() {
    local json="$1"
    local schema="$2"
    local parent_path="$3"  # Track the JSON path for better error reporting
    local valid=true
    local errors=()

    # Extract required keys, properties, and additionalProperties from the schema
    local required_keys=$(echo "$schema" | jq -r '.required[]? // empty')
    local properties=$(echo "$schema" | jq -r '.properties // empty')
    local additional_properties=$(echo "$schema" | jq -r 'if has("additionalProperties") then .additionalProperties else true end')

    # Check if required keys are present
    for key in $required_keys; do
        if ! echo "$json" | jq -e ". | has(\"$key\")" >/dev/null; then
            errors+=("Missing required key: ${parent_path}${key}")
            valid=false
        fi
    done

    # Validate each property
    for key in $(echo "$properties" | jq -r 'keys[]'); do
        local expected_type
        local actual_type
        local sub_schema
        local value

        expected_type=$(echo "$properties" | jq -r ".\"$key\".type // empty")
        sub_schema=$(echo "$properties" | jq -c ".\"$key\"")
        value=$(echo "$json" | jq -c ".\"$key\"")
        actual_type=$(echo "$json" | jq -r ".\"$key\" | type // empty")

        if [ "$expected_type" = "object" ]; then
            if [ "$actual_type" = "object" ]; then
                validate_json_recursive "$value" "$sub_schema" "${parent_path}${key}."
            else
                errors+=("Key '${parent_path}${key}' expected type 'object', but got '$actual_type'")
                valid=false
            fi
        elif [ "$expected_type" = "array" ]; then
            if [ "$actual_type" = "array" ]; then
                items_schema=$(echo "$sub_schema" | jq -c '.items')
                array_length=$(echo "$value" | jq 'length')

                for ((i=0; i<array_length; i++)); do
                    element=$(echo "$value" | jq -c ".[$i]")
                    element_type=$(echo "$element" | jq -r 'type')  # Get type of element

                    # Check the expected type for the array items and match with element type
                    item_expected_type=$(echo "$items_schema" | jq -r '.type // empty')

                    # Handle type mismatch in array elements
                    if [ "$item_expected_type" != "$element_type" ]; then
                        errors+=("Array element ${parent_path}${key}[$i] expected type '$item_expected_type', but got '$element_type'")
                        valid=false
                    else
                        # Continue validation for each array element recursively
                        validate_json_recursive "$element" "$items_schema" "${parent_path}${key}[$i]."
                    fi
                done
            else
                errors+=("Key '${parent_path}${key}' expected type 'array', but got '$actual_type'")
                valid=false
            fi
        else
            # Handle specific cases for 'integer', 'string', 'number', etc.
            if [[ "$expected_type" == "integer" && "$actual_type" == "number" ]]; then
                # Check if the value is not an integer (i.e., it has a fractional part)
                if [[ $(echo "$value" | jq '. % 1 != 0') == "true" ]]; then
                    errors+=("Key '${parent_path}${key}' expected type 'integer', but got 'number'")
                    valid=false
                fi
            elif [ "$expected_type" != "$actual_type" ] && [ "$actual_type" != "null" ]; then
                # Handle if expected type does not match the actual type
                # Check if expected_type is an array of types, and if the actual type matches any of them
                if [[ "$expected_type" =~ \[.*\] ]]; then
                    # Expected type is a list of types (e.g., ["string", "number"])
                    expected_types=$(echo "$expected_type" | sed 's/[\[\]" ]//g')  # Remove brackets and spaces
                    for type in $(echo "$expected_types" | tr ',' '\n'); do
                        if [ "$type" == "$actual_type" ]; then
                            valid=true
                            break
                        fi
                    done
                    if [ "$valid" = false ]; then
                        errors+=("Key '${parent_path}${key}' expected one of the types [${expected_types}], but got '$actual_type'")
                        valid=false
                    fi
                else
                    errors+=("Key '${parent_path}${key}' expected type '$expected_type', but got '$actual_type'")
                    valid=false
                fi
            fi

            # Handle 'null' type
            if [ "$expected_type" = "null" ] && [ "$actual_type" != "null" ]; then
                errors+=("Key '${parent_path}${key}' expected type 'null', but got '$actual_type'")
                valid=false
            fi

            # Handle additional constraints
            handle_constraints "$value" "$sub_schema" "${parent_path}${key}" errors valid
        fi

    done

    # Handle additional properties when additionalProperties is false
    if [ "$additional_properties" = "false" ]; then
        for key in $(echo "$json" | jq -r 'keys[]'); do
            # Check if the key is not present in the properties of the schema
            if ! echo "$properties" | jq -e ". | has(\"$key\")" >/dev/null; then
                errors+=("Key '${parent_path}${key}' is an extra property, but additionalProperties is false.")
                valid=false
            fi
        done
    fi

    # Print errors if any
    if [ "$valid" = false ]; then
        for error in "${errors[@]}"; do
            echo "$error"
        done
    fi
}


# Function to handle additional constraints
handle_constraints() {
    local value="$1"
    local schema="$2"
    local key_path="$3"
    local -n errors_ref=$4
    local -n valid_ref=$5

    # Pattern (regex matching)
    local pattern=$(echo "$schema" | jq -r '.pattern // empty')
    if [ -n "$pattern" ]; then
        if ! [[ "$value" =~ $pattern ]]; then
            errors_ref+=("Key '${key_path}' does not match the pattern '$pattern'")
            valid_ref=false
        fi
    fi

    # Enum (fixed values)
    local enum_values=$(echo "$schema" | jq -r '.enum // empty')
    if [ "$enum_values" != "null" ]; then
        if ! echo "$enum_values" | jq -e ". | index($value)" >/dev/null; then
            errors_ref+=("Key '${key_path}' value '$value' is not in the enum list: $enum_values")
            valid_ref=false
        fi
    fi

    # MultipleOf (numerical constraint)
    local multiple_of=$(echo "$schema" | jq -r '.multipleOf // empty')
    if [ -n "$multiple_of" ]; then
        if ! (( $(echo "$value % $multiple_of" | bc) == 0 )); then
            errors_ref+=("Key '${key_path}' value '$value' is not a multiple of $multiple_of")
            valid_ref=false
        fi
    fi
}


# Main function to validate a JSON file against a schema
validate_json() {
    local json_file="$1"
    local schema_file="$2"

    local json=$(cat "$json_file")
    local schema=$(cat "$schema_file")

    validate_json_recursive "$json" "$schema" ""
}


# Function to handle exit codes and display success or failure messages
handle_exit() {
    local exit_code="$1"
    local current_step="$2"     # Current step index (e.g., 3)
    local total_steps="$3"      # Total number of steps (e.g., 4)
    local message="$4"          # Descriptive message for success or failure

    # Validate that current step is less than or equal to total steps
    if [ "$current_step" -gt "$total_steps" ]; then
        echo_message "error" "Current step ($current_step) exceeds total steps ($total_steps)."
        exit 1
    fi

    local status="success"
    local status_message="$message succeeded"
    
    if [ "$exit_code" -ne 0 ]; then
        status="error"
        status_message="$message failed"
        echo_message "error" "Error Code: $exit_code"
        deploy_failed_message "$service_name"
    fi
    
    echo_step "$current_step" "$status_message" "$status" "$HAS_TIMESTAMP"
    
    # Exit with failure if there's an error
    if [ "$status" == "error" ]; then
        exit 1
    fi
}



# Function to check if a service is online
is_service_online() {
    local service_name=$1
    local retries=${2:-10}            # Number of retries before giving up (default 10)
    local interval=${3:-5}            # Initial time between retries (seconds, default 5)
    local max_interval=${4:-60}       # Maximum time between retries (seconds, default 60)
    local backoff_factor=${5:-1.05}   # Backoff factor (default 1.1)

    # Track the start time
    local start_time=$(date +%s)

    # Display initial message
    echo_message "info" "Waiting for $service_name to come online..."
    
    # Loop to check if the service is online
    for i in $(seq 1 $retries); do
        # Check if the Docker service/stack is running
        docker service ls --filter "name=$service_name" --filter "desired-state=running" > /dev/null 2>&1

        # Check if the service is running
        if [ $? -eq 0 ]; then
            # Service is online
            echo_message "success" "$service_name is now online."
            return 0
        fi

        # Calculate the elapsed time
        local elapsed_time=$(( $(date +%s) - $start_time ))

        # Calculate the next retry interval using bc for floating point arithmetic
        local next_retry=$(echo "$interval * $backoff_factor" | bc)
        if [ $(echo "$next_retry > $max_interval" | bc) -eq 1 ]; then
            next_retry=$max_interval
        fi

        # If not online, erase the previous message and display the new one
        if [ $i -gt 1 ]; then
            clear_line
        fi

        local time_spent="Elapsed time: $elapsed_time seconds, Next retry in: $next_retry seconds"
        local attempt_step="Attempt $i/$retries"
        local explanation="$stack_name not online, retrying in $interval seconds..."
        
        echo_message "info" "$attempt_step: $explanation ($time_spent)"
        wait_secs "$interval"

        # Increase the wait interval using the backoff factor, but don't exceed the max interval
        interval=$next_retry
    done

    local elapsed_time=$(( $(date +%s) - $start_time ))

    # If it doesn't become online after all retries, print error
    echo_message "error" "$service_name did not come online after $elapsed_time seconds."
    return 1
}


# Function to check if a service is running
check_service() {
    local service_name="$1"

    # Check if the service exists and is running in Swarm
    docker service ls --filter "name=$service_name" --format "{{.Name}}" | grep -wq "$service_name"

    if [ $? -eq 0 ]; then
        # Further verify if the service is running with all replicas up
        local replicas=$(docker service ls --filter "name=$service_name" --format "{{.Replicas}}" | awk -F/ '{print $1}')
        local total_replicas=$(docker service ls --filter "name=$service_name" --format "{{.Replicas}}" | awk -F/ '{print $2}')

        if [ "$replicas" -eq "$total_replicas" ]; then
            return 0  # Service is running with all replicas
        else
            return 1  # Service is found but not fully running
        fi
    else
        return 1  # Service is not running
    fi
}


# Function to deploy a service using a Docker Compose file
deploy_service_on_swarm() {
    local service_name=$1
    local compose_path=$2

    echo_message "info" "Deploying service $service_name on Docker Swarm..."

    # Deploy the service using Docker stack
    docker stack deploy --prune --resolve-image always -c "$compose_path" "$service_name"

    # Verify if the service is running
    check_service "$service_name"
    if [ $? -eq 0 ]; then
        echo_message "success" "Service $service_name deployed and running successfully." $HAS_TIMESTAMP
    else
        echo_message "error" "Service $service_name failed to deploy or is not running correctly." $HAS_TIMESTAMP
        exit 1
    fi
}


# Function to deploy a service
deploy_failed_message() {
    service_name="$1"
    echo_message "error" "Failed to deploy service $service_name!"
}


deploy_success_message() {
    service_name="$1"
    echo_message "success" "Successfully deployed service $service_name!"
}


# Function to validate schema with JSON files
validate_schema() {
    local schema_file="$1"
    local config_file="$2"
    
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        echo_message "error" "Python is not installed. Please install Python 3 with command 'apt install python3'."
        return 1
    fi

    # Check if validate_schema.py script exists
    if [ ! -f "validate_schema.py" ]; then
        echo_message "error" "'validate_schema.py' script is missing."
        return 1
    fi

    # Run the Python script for validation
    echo_message "info" "Validating configuration..."

    python3 validate_schema.py "$schema_file" "$config_file" &> /dev/null
    local EXIT_CODE=$?

    # Provide feedback based on the result
    if [ $EXIT_CODE -eq 0 ]; then
        echo_message "success" "JSON configuration is valid."
    else
        echo_message "error" "JSON configuration validation failed."
    fi

    return $EXIT_CODE
}


# Function to build config and compose files for a service
build_service_info() {
    local service_name="$1"

    # Build config file
    local config_path="${service_name}_config.json"

    # Build compose file
    local compose_path="${service_name}.yaml"

    # Build compose func name
    local compose_func="compose_${service_name}"

    # Return files
    echo "$config_path $compose_path $compose_func"
}


# Function to replace variables in a template
replace_variables_in_template() {
    local template="$1"
    declare -n variables=$2  # Pass associative array by reference

    # Loop over each key-value pair in the associative array
    for key in "${!variables[@]}"; do
        value="${variables[$key]}"

        # Escape special characters in the value for sed
        escaped_value=$(printf '%s\n' "$value" | sed 's/[&/\]/\\&/g')

        # Replace all instances of __KEY__ with the value
        template=$(echo "$template" | sed "s|__${key}__|${escaped_value}|g")
    done

    # Output the substituted template
    echo "$template"
}


# Function to validate a Docker Compose file
validate_compose_file() {
    local compose_file="$1"

    # Check if the file exists
    if [ ! -f "$compose_file" ]; then
        echo_message "error" "File '$compose_file' not found."
        exit 1
    fi

    # Validate the syntax of the Docker Compose file
    docker-compose -f "$compose_file" config > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo_message "success" "Docker Compose file '$compose_file' is valid."
    else
        echo_message "error" "Docker Compose file '$compose_file' is invalid."
        docker-compose -f "$compose_file" config
        exit 1
    fi
}


# Function to get the password from a JSON file
get_postgres_password() {
    local config_file=$1
    password_postgres=$(jq -r '.password' $config_file)
    echo "$password_postgres"
}


# Function to write JSON configuration file
write_json() {
    local config_path=$1
    local config_data=$2

    # Ensure directory exists
    if [ ! -d "$(dirname "$config_path")" ]; then
        mkdir -p "$(dirname "$config_path")"
    fi

    # Write the configuration to file
    printf "%s" "$config_data" > "$config_path"

    # Check if the write was successful
    if [ $? -eq 0 ]; then
        echo_message "success" "JSON saved successfully to $config_path" $HAS_TIMESTAMP
    else
        echo_message "error" "Failed to save JSON to $config_path: $?" $HAS_TIMESTAMP
        exit 1
    fi
}


# Function to replace variables in a template
replace_variables_in_template() {
    local template="$1"
    declare -A variables=("${!2}")
    for key in "${!variables[@]}"; do
        template="${template//\{$key\}/${variables[$key]}}"
    done
    echo "$template"
}



convert_array_to_json() {
    local input_array=("$@")  # Accepts the key-value pairs as an array
    local json="{"

    # Loop through each key-value pair
    for pair in "${input_array[@]}"; do
        # Split the pair into key and value
        local key=$(echo "$pair" | cut -d'=' -f1)
        local value=$(echo "$pair" | cut -d'=' -f2)

        # Add to JSON object
        json+="\"$key\": \"$value\","
    done

    # Remove the last comma and close the JSON object
    json="${json%,}}"

    # Print the final JSON string
    echo "$json"
}


# Save an array of key-value pairs into a JSON file
save_array_to_json() {
    local file_path="$1"  # File path to save the JSON data
    shift  # Remove the first argument, leaving only the associative array

    # Declare the associative array
    declare -A input_array=("${@}")

    # Convert the associative array to JSON
    json_content=$(convert_array_to_json input_array[@])

    # Save the JSON content to the specified file
    write_json "$file_path" "$json_content"
}


# Function to retrieve a value from a JSON file
read_json_key() {
    local json_data="$1"
    local key="$2"
    local default_value="$3"

    # Extract the value using jq
    local value
    value=$(echo "$json_data" | jq -r "$key")

    # If the value is not null or empty, return it, otherwise return the default value
    if [ -n "$value" ] && [ "$value" != "null" ]; then
        echo "$value"
    else
        echo "$default_value"
    fi
}


# Function to execute a setUp action
execute_set_up_action() {
    local action="$1"  # JSON object representing the setUp action

    # Extract the name, command, and variables from the action
    local action_name
    action_name=$(echo "$action" | jq -r '.name')
    
    local action_command
    action_command=$(echo "$action" | jq -r '.command')

    # Extract variables if they exist (empty string if not defined)
    local action_variables
    action_variables=$(echo "$action" | jq -r '.variables // empty')

    # Display the action's name and variables (if present)
    echo_step 2 6 "[$service_name] Running setUp action: $action_name" "info" "$HAS_TIMESTAMP"

    # If there are variables, export them for the command execution
    if [ -n "$action_variables" ]; then
        echo_step 2 6 "[$service_name] Setting variables for action: $action_name" "info" "$HAS_TIMESTAMP"
        # Export each variable safely, ensuring no unintended command execution
        for var in $(echo "$action_variables" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"'); do
            # Escape and export the variable
            local var_name=$(echo "$var" | cut -d'=' -f1)
            local var_value=$(echo "$var" | cut -d'=' -f2)
            export "$var_name"="$var_value"
        done
    fi

    # Safely format the command using printf to avoid eval
    # Substitute the variables in the command
    local formatted_command
    formatted_command=$(printf "%s" "$action_command")

    # Display the command being executed
    echo "Running command: $formatted_command"

    # Execute the formatted command
    bash -c "$formatted_command"

    # Check if the command executed successfully and handle exit
    local exit_code=$?
    handle_exit "$exit_code" 2 6 "Executing setUp action: $action_name"
}


# Helper function to load service configuration (Redis or Postgres)
# TODO: Try to retrieve the information from docker-compose from stack if present,
#       if not retrieve on file from docker inspect,
#       otherwise raise critical error and exit
load_service_config() {
    local service_name="$1"
    local config_file="${service_name}_config.json"
    
    # Try loading from file or fallback to container inspection if file not found
    if [[ -f "$config_file" ]]; then
        cat "$config_file"
    else
        echo_message "warning" "$config_file not found. Attempting to retrieve configuration from running service."
        docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$service_name" 2>/dev/null || echo "{}"
    fi
}


# Function to deploy a service
deploy_service() {
    # Arguments
    local service_name="$1"   # Service name (e.g., redis, postgres)
    local service_json="$2"   # JSON data with service variables

    # Declare an associative array to hold service variables
    declare -A service_variables

    # Parse JSON data and populate associative array
    while IFS="=" read -r key value; do
        service_variables["$key"]="$value"
    done < <(echo "$service_json" | jq -r '.variables | to_entries | .[] | "\(.key)=\(.value)"')

    # Step 1: Deploy Dependencies
    echo_step 1 7 "[$service_name] Checking and deploying dependencies" "info" "$HAS_TIMESTAMP"
    local dependencies
    dependencies=$(echo "$service_json" | jq -r '.dependencies[]?')

    # Check if there are dependencies, and if none, display a message
    if [ -z "$dependencies" ]; then
        echo_step 1 7 "[$service_name] No dependencies to deploy" "info" "$HAS_TIMESTAMP"
    else
        for dep in $dependencies; do
            echo_step 1 7 "[$service_name] Deploying dependency: $dep" "info" "$HAS_TIMESTAMP"
            
            # Fetch JSON for the dependency (assuming `fetch_service_json` provides the JSON for a service)
            local dep_service_json
            dep_service_json=$(fetch_service_json "$dep")
            
            deploy_service "$dep" "$dep_service_json"
            handle_exit $? 1 7 "Deploying dependency $dep"
        done
    fi

    # Step 2: Execute setUp actions (if defined in the service JSON)
    echo_step 2 7 "[$service_name] Executing setUp actions" "info" "$HAS_TIMESTAMP"
    local setUp_actions
    setUp_actions=$(echo "$service_json" | jq -r '.setUp[]?')

    if [ -n "$setUp_actions" ]; then
        for action in $setUp_actions; do
            # Perform the action (you can define custom functions to execute these steps)
            echo_step 2 6 "[$service_name] Running setUp action: $action" "info" "$HAS_TIMESTAMP"
            # Call an appropriate function to handle this setUp action (e.g., `execute_set_up_action`)
            execute_set_up_action "$action"
            handle_exit $? 2 7 "Executing setUp action $action"
        done
    else
        echo_step 2 7 "[$service_name] No setUp actions defined" "info" "$HAS_TIMESTAMP"
    fi

    # Step 3: Build service-related file paths and Docker Compose template
    echo_step 3 7 "[$service_name] Building file paths" "info" "$HAS_TIMESTAMP"
    build_service_info "$service_name"
    local config_path=$(echo "$service_info" | awk '{print $1}')
    local compose_path=$(echo "$service_info" | awk '{print $2}')
    local compose_template_func=$(echo "$service_info" | awk '{print $3}')

    # Retrieve and substitute variables in Docker Compose template
    echo_step 4 7 "[$service_name] Creating Docker Compose template" "info" "$HAS_TIMESTAMP"
    local template=$($compose_template_func)
    local substituted_template
    substituted_template=$(replace_variables_in_template "$template" "$service_variables")

    # Write the substituted template to the compose file
    echo "$substituted_template" > "$compose_path"
    handle_exit $? 4 7 "[$service_name] Creating file $compose_path"

    # Step 5: Validate the Docker Compose file
    echo_step 5 6 "[$service_name] Validating Docker Compose file" "info" "$HAS_TIMESTAMP"
    validate_compose_file "$compose_path"
    handle_exit $? 5 7 "[$service_name] Validating Docker Compose file $compose_path"

    # Step 6: Deploy the service on Docker Swarm
    echo_step 6 6 "[$service_name] Deploying service on Docker Swarm" "info" "$HAS_TIMESTAMP"
    deploy_service_on_swarm "$service_name" "$compose_path"
    is_service_online "$service_name"
    handle_exit $? 6 7 "Deploying service $service_name"

    # Step 7: Save service-specific information to a configuration file
    echo_step 7 6 "[$service_name] Saving service configuration" "info" "$HAS_TIMESTAMP"
    save_variables_to_json "$config_path" "${service_variables[@]}"
    handle_exit $? 7 7 "Saving information for service $service_name"

    # Final Success Message
    deploy_success_message "$service_name"
}


# Function to create a PostgreSQL database
create_postgres_database() {
    local db_name="$1"
    local db_user="${2:-postgres}"
    local container_name="${3:-postgres_db}"

    local container_id
    local db_exists

    # Display a message about the database creation attempt
    echo_message "info" "Creating PostgreSQL database: $db_name in container: $container_name"

    # Check if the container is running
    container_id=$(docker ps -q --filter "name=^${container_name}$")
    if [ -z "$container_id" ]; then
        echo_message "error" "Container '${container_name}' is not running. Cannot create database."
        return 1
    fi

    # Check if the database already exists
    db_exists=$(docker exec "$container_id" psql -U "$db_user" -lqt | cut -d \| -f 1 | grep -qw "$db_name")
    if [ "$db_exists" ]; then
        echo_message "info" "Database '$db_name' already exists. Skipping creation."
        return 0
    fi

    # Create the database if it doesn't exist
    echo_message "info" "Creating database '$db_name'..."
    if docker exec "$container_id" psql -U "$db_user" -c "CREATE DATABASE \"$db_name\";" > /dev/null 2>&1; then
        echo_message "success" "Database '$db_name' created successfully."
        return 0
    else
        echo_message "error" "Failed to create database '$db_name'. Please check the logs for details."
        return 1
    fi
}


generate_n8n_set_up_actions() {
    local n8n_config_json=$1
    local n8n_instance_id=$2  # New parameter for the n8n instance identifier
    local postgres_db=$(echo "$n8n_config_json" | jq -r '.variables.DB_NAME')
    local postgres_user=$(echo "$n8n_config_json" | jq -r '.dependencies.postgres.variables.DB_USER')
    local postgres_container=$(echo "$n8n_config_json" | jq -r '.dependencies.postgres.variables.CONTAINER_NAME')

    # Escape the variables to prevent issues with special characters
    local escaped_postgres_db
    local escaped_postgres_user
    local escaped_postgres_container

    escaped_postgres_db=$(printf '%q' "$postgres_db")
    escaped_postgres_user=$(printf '%q' "$postgres_user")
    escaped_postgres_container=$(printf '%q' "$postgres_container")

    # Ensure the database name is unique based on the instance ID to prevent conflicts
    local unique_postgres_db="${escaped_postgres_db}_${n8n_instance_id}"

    # Generate actions with dynamically injected values, including the n8n instance ID for uniqueness
    jq -n \
        --arg POSTGRES_DB "$unique_postgres_db" \
        --arg POSTGRES_USER "$escaped_postgres_user" \
        --arg POSTGRES_CONTAINER "$escaped_postgres_container" \
        --arg INSTANCE_ID "$n8n_instance_id" \
        '{
            "actions": [
                {
                    "name": "Create Postgres Database",
                    "command": "create_postgres_database \($POSTGRES_DB) \($POSTGRES_USER) \($POSTGRES_CONTAINER)",
                    "variables": {
                        "POSTGRES_DB": $POSTGRES_DB,
                        "POSTGRES_USER": $POSTGRES_USER,
                        "POSTGRES_CONTAINER": $POSTGRES_CONTAINER,
                        "INSTANCE_ID": $INSTANCE_ID
                    }
                }
            ]
        }'
}


# Function to generate n8n config
generate_n8n_config() {
    local identifier="$1"
    local image_version="${2:-latest}"      # Accept image version or default to latest
    local container_port="${3:-5678}"       # Accept container port or default to 5678
    local network_name="${4:-DEFAULT_NETWORK}"  # Accept network name or default to default_network

    # Load Redis config or retrieve it from a running container
    local redis_config
    redis_config=$(load_service_config "redis")

    # Load Postgres config or retrieve it from a running container
    local postgres_config
    postgres_config=$(load_service_config "postgres")

    # If both Redis and Postgres configs are missing, exit
    if [[ "$redis_config" == "{}" && "$postgres_config" == "{}" ]]; then
        echo_message "critical" "Both Redis and Postgres configurations are missing. Exiting."
        exit 1
    fi

    # Generate the n8n configuration JSON with service and dependency details
    local n8n_config_json
    n8n_config_json=$(jq -n \
        --arg SERVICE_NAME "n8n" \
        --arg IMAGE_NAME "n8n_$image_version" \
        --arg CONTAINER_NAME "n8n" \
        --arg CONTAINER_PORT "$container_port" \
        --arg SERVICE_URL "http://localhost:$container_port" \
        --arg VOLUME_NAME "n8n_data" \
        --arg INSTANCE_ID "$identifier" \
        --arg DB_NAME "n8n_queue_$identifier" \
        --arg NETWORK_NAME "$network_name" \
        --arg REDIS_CONFIG "$redis_config" \
        --arg POSTGRES_CONFIG "$postgres_config" \
        '{
            "variables": {
                "SERVICE_NAME": $SERVICE_NAME,
                "IMAGE_NAME": $IMAGE_NAME,
                "CONTAINER_NAME": $CONTAINER_NAME,
                "CONTAINER_PORT": $CONTAINER_PORT,
                "SERVICE_URL": $SERVICE_URL,
                "VOLUME_NAME": $VOLUME_NAME,
                "NETWORK_NAME": $NETWORK_NAME
            },
            "dependencies": {
                "redis": ($REDIS_CONFIG | fromjson),
                "postgres": ($POSTGRES_CONFIG | fromjson)
            },
            "setUp": []
        }')

    # Generate setUp actions dynamically
    local setUp_actions
    setUp_actions=$(generate_n8n_set_up_actions "$n8n_config_json")

    # Inject generated setUp actions into the final config
    jq -n \
        --argjson CONFIG "$n8n_config_json" \
        --argjson SETUP_ACTIONS "$setUp_actions" \
        '. + { "setUp": $SETUP_ACTIONS.actions }'
}


# Function to generate n8n configuration with dependencies
generate_n8n_config() {
    local image_version="${1:-latest}"  # Accept image version or default to latest
    local container_port="${2:-5678}"   # Accept container port or default to 5678
    local network_name="${3:-DEFAULT_NETWORK}"  # Accept network name or default to default_network

    # Load dependency JSONs into variables
    local redis_config
    local postgres_config
    redis_config=$(cat redis_config.json)
    postgres_config=$(cat postgres_config.json)

    # Generate n8n configuration with dependencies
    local n8n_config_json
    n8n_config_json=$(jq -n \
        --arg SERVICE_NAME "n8n" \
        --arg IMAGE_NAME "n8n_$image_version" \
        --arg CONTAINER_NAME "n8n" \
        --arg CONTAINER_PORT "$container_port" \
        --arg SERVICE_URL "http://localhost:$container_port" \
        --arg VOLUME_NAME "n8n_data" \
        --arg NETWORK_NAME "$network_name" \
        --arg REDIS_CONFIG "$redis_config" \
        --arg POSTGRES_CONFIG "$postgres_config" \
        '{
            "variables": {
                "SERVICE_NAME": $SERVICE_NAME,
                "IMAGE_NAME": $IMAGE_NAME,
                "CONTAINER_NAME": $CONTAINER_NAME,
                "CONTAINER_PORT": $CONTAINER_PORT,
                "SERVICE_URL": $SERVICE_URL,
                "VOLUME_NAME": $VOLUME_NAME,
                "NETWORK_NAME": $NETWORK_NAME
            },
            "dependencies": {
                "redis": ($REDIS_CONFIG | fromjson),
                "postgres": ($POSTGRES_CONFIG | fromjson)
            },
            "setUp": []
        }')

    # Generate setUp actions dynamically based on n8n_config_json
    local setUp_actions
    setUp_actions=$(generate_n8n_set_up_actions "$n8n_config_json")

    # Inject the dynamically generated setUp actions into the final config
    jq -n \
        --argjson CONFIG "$n8n_config_json" \
        --argjson SETUP_ACTIONS "$setUp_actions" \
        '. + { "setUp": $SETUP_ACTIONS.actions }'
}


# Function to generate Redis service configuration JSON
generate_redis_config() {
    local image_version="${1:-"latest"}"   # Accept image version or default to 6.2.5
    local container_port="${2:-6379}"      # Accept container port or default to 6379
    local network_name="${3:-DEFAULT_NETWORK}"  # Accept network or default to default_network

    jq -n \
        --arg SERVICE_NAME "redis" \
        --arg IMAGE_NAME "redis_$image_version" \
        --arg CONTAINER_NAME "redis" \
        --arg CONTAINER_PORT "$container_port" \
        --arg SERVICE_URL "redis://redis:$container_port" \
        --arg VOLUME_NAME "redis_data" \
        --arg NETWORK_NAME "$network_name" \
        '{
            "variables": {
                "SERVICE_NAME": $SERVICE_NAME,
                "IMAGE_NAME": $IMAGE_NAME,
                "CONTAINER_NAME": $CONTAINER_NAME,
                "CONTAINER_PORT": $CONTAINER_PORT,
                "SERVICE_URL": $SERVICE_URL,
                "VOLUME_NAME": $VOLUME_NAME,
                "NETWORK_NAME": $NETWORK_NAME
            },
            "dependencies": {}
        }'
}


# Function to generate Postgres service configuration JSON
generate_postgres_config() {
    local image_version="${1:-"14"}"                # Accept image version or default to 14
    local container_port="${2:-5432}"               # Accept container port or default to 5432
    local network_name="${3:-DEFAULT_NETWORK}"      # Accept network or default to default_network
    local postgres_password="$(random_string)"
    
    jq -n \
        --arg SERVICE_NAME "postgres" \
        --arg IMAGE_NAME "postgres_$image_version" \
        --arg CONTAINER_NAME "postgres" \
        --arg CONTAINER_PORT "$container_port" \
        --arg DB_PASSWORD "$postgres_password" \
        --arg VOLUME_NAME "postgres_data" \
        --arg NETWORK_NAME "$network_name" \
        '{
            "variables": {
                "SERVICE_NAME": $SERVICE_NAME,
                "IMAGE_NAME": $IMAGE_NAME,
                "CONTAINER_NAME": $CONTAINER_NAME,
                "CONTAINER_PORT": $CONTAINER_PORT,
                "DB_USER": $DATABASE_URL,
                "DB_PASSWORD": $DB_PASSWORD,
                "DB_NAME": $DB_NAME,
                "VOLUME_NAME": $VOLUME_NAME,
                "NETWORK_NAME": $NETWORK_NAME
            },
            "dependencies": {},
            "setUp": []
        }'
}


# Function to create the Redis YAML file
compose_redis() {
    cat <<EOL
version: "3.7"
services:
  __SERVICE_NAME__:
    image: redis:__IMAGE_VERSION__
    image_name: __IMAGE_NAME__
    container_name: __CONTAINER_NAME__
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "__CONTAINER_PORT__"
    ]
    volumes:
      - __VOLUME_NAME__:/data
    networks:
      - __NETWORK_NAME__

volumes:
  __VOLUME_NAME__:
    external: true
    name: __VOLUME_NAME__

networks:
  __NETWORK_NAME__:
    external: true
    name: __NETWORK_NAME__
EOL
}


compose_postgres() {
    cat <<EOL
version: "3.7"
services:
  __SERVICE_NAME__:
    image: postgres:__IMAGE_VERSION__
    image_name: __IMAGE_NAME__
    container_name: __CONTAINER_NAME__
    environment:
      - POSTGRES_PASSWORD: __DB_PASSWORD__
      - PG_MAX_CONNECTIONS=500

    ## uncomment the following line to use a custom configuration file
    #ports:
    #  - __CONTAINER_PORT__:5432

    volumes:
      - __VOLUME_NAME__:/var/lib/postgresql/data

    networks:
      - __NETWORK_NAME__

volumes:
  __VOLUME_NAME__:
    external: true
    name: __VOLUME_NAME__

networks:
  __NETWORK_NAME__:
    external: true
    name: __NETWORK_NAME__
EOL 
}


compose_n8n() {
    cat  <<EOL
version: '3.7'

# Common environment variables definition
x-common-env: &common-env
  DB_TYPE: postgresdb
  DB_POSTGRESDB_DATABASE: __DB_NAME__
  DB_POSTGRESDB_HOST: __DB_HOST__
  DB_POSTGRESDB_PORT: __DB_PORT__
  DB_POSTGRESDB_USER: postgres
  DB_POSTGRESDB_PASSWORD: __DB_PASSWORD__
  N8N_ENCRYPTION_KEY: __ENCRYPTION_KEY__
  N8N_HOST: __EDITOR_HOST__
  N8N_EDITOR_BASE_URL: __PROTOCOL__://__EDITOR_HOST__/
  WEBHOOK_URL: __PROTOCOL__://__WEBHOOK_HOST__/
  N8N_PROTOCOL: __PROTOCOL__
  NODE_ENV: production
  EXECUTIONS_MODE: queue

# Common service dependencies definition
x-common-depends-on: &common-depends-on
  __REDIS_SERVICE_NAME__:
    condition: service_healthy
  __DB_SERVICE_NAME__:
    condition: service_healthy

services:
  # Editor service definition
  editor:
    image: n8nio/n8n:__IMAGE_VERSION__
    command: start
    environment:
      <<: *common-env  # Import common environment variables
      N8N_SMTP_SENDER: __SMTP_SENDER__
      N8N_SMTP_USER: __SMTP_USER__
    depends_on:
      <<: *common-depends-on  # Import common dependencies

  # Webhook service definition
  webhook:
    image: n8nio/n8n:__IMAGE_VERSION__
    command: webhook
    environment:
      <<: *common-env  # Import common environment variables
      N8N_SMTP_SENDER: __SMTP_SENDER__
      N8N_SMTP_USER: __SMTP_USER__
    depends_on:
      <<: *common-depends-on  # Import common dependencies

  # Worker service definition
  worker:
    image: n8nio/n8n:__IMAGE_VERSION__
    command: worker --concurrency=10
    environment:
      <<: *common-env  # Import common environment variables
      N8N_SMTP_SENDER: __SMTP_SENDER__
      N8N_SMTP_USER: __SMTP_USER__
    depends_on:
      <<: *common-depends-on  # Import common dependencies

networks:
  __NETWORK_NAME__:
    external: true
    name: __NETWORK_NAME__
EOL
}


deploy_redis() {
    local image_version="${1:-"6.2.5"}"   # Accept image version or default to 6.2.5
    local container_port="${2:-6379}"      # Accept container port or default to 6379
    local network_name="${3:-DEFAULT_NETWORK}"  # Accept network or default to default_network

    # Generate the Redis service JSON configuration using the helper function
    local redis_config_json
    redis_config_json=$(generate_redis_config "$image_version" "$container_port" "$network_name")

    # Deploy the Redis service using the JSON
    deploy_service "$service_name" "$redis_config_json"
}

###### Deployment functions 

# Function to deploy a PostgreSQL service
deploy_postgres() {
    local image_version="${1:-"14"}"              # Accept image version or default to 14
    local container_port="${2:-5432}"             # Accept container port or default to 5432
    local network_name="${3:-DEFAULT_NETWORK}"    # Accept network or default to default_network

    # Create a JSON object to pass as an argument
    local redis_config_json
    postgres_config_json=$(generate_postgres_config "$image_version" "$container_port" "$network_name")

    # Deploy the PostgreSQL service using the JSON
    deploy_service "$service_name" "$postgres_config_json"
}


# Function to deploy a n8n service
deploy_n8n() {
    local identifier="$1"
    local network_name="${2:-DEFAULT_NETWORK}"  # Accept network or default to default_network    
    local service_name="n8n_$identifier"

    # Generate the n8n service JSON configuration using the helper function
    local n8n_config_json
    n8n_config_json=$(generate_n8n_config "$identifier")

    # Deploy the n8n service using the JSON
    deploy_service "$service_name" "$n8n_config_json"

    echo_message "highlight" "You must create the login and password in the first access of the N8N"
}

prepare_environment() {
    echo_message "info" "Preparing environment"

    # Check if the script is running as root
    if [ "$EUID" -ne 0 ]; then
        echo_message "error" "Please run this script as root or use sudo."
        exit 1
    fi

    echo_step 1 4 "Updating system and upgrading packages" "info" $HAS_TIMESTAMP
    if apt update -y && apt upgrade -y > /dev/null 2>&1; then
        echo_message "success" "System updated and packages upgraded."
    else
        echo_message "error" "Failed to update and upgrade system packages."
        exit 1
    fi

    echo_step 2 4 "Installing required packages: sudo, apt-utils, jq, python3" "info" $HAS_TIMESTAMP
    if apt install sudo apt-utils jq python3 -y > /dev/null 2>&1; then
        echo_message "success" "Required packages installed successfully."
    else
        echo_message "error" "Failed to install required packages."
        exit 1
    fi

    echo_step 3 4 "Installing Docker" "info" $HAS_TIMESTAMP
    if apt install docker.io -y > /dev/null 2>&1; then
        echo_message "success" "Docker installed successfully."
    else
        echo_message "error" "Failed to install Docker."
        exit 1
    fi

    echo_step 4 4 "Initializing Docker Swarm" "info" $HAS_TIMESTAMP
    if docker info | grep -q 'Swarm: active'; then
        echo_message "info" "Docker Swarm is already initialized."
    else
        if docker swarm init > /dev/null 2>&1; then
            echo_message "success" "Docker Swarm initialized successfully."
        else
            echo_message "error" "Failed to initialize Docker Swarm."
            exit 1
        fi
    fi

    echo_message "success" "Environment prepared successfully." $HAS_TIMESTAMP
}
