#!/bin/bash

#!/bin/bash

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


random_string() {
    local word="$(openssl rand -hex 16)"
    echo "$word"
}


wait_secs() {
    local seconds=$1
    sleep "$seconds"
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

# General function to display icons based on status
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
    local type="$1"       # Message type (success, error, etc.)
    local text="$2"       # Message text
    local timestamp="${3:-false}" # Option to display timestamp (default is false)

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
    local formatted_message="$icon $text"
    if [ "$timestamp" = true ]; then
        formatted_message="[$(date '+%Y-%m-%d %H:%M:%S')] $formatted_message"
    fi

    # Display the message with icon, color, style, and timestamp (if enabled)
    echo -e "$(colorize "$formatted_message" "$color" "$style")"
}

echo_message() {
    local type="$1"
    local text="$2"
    local timestamp="${3:-true}"
    echo -e "$(format_message "$type" "$text" $timestamp)"
}

# Function to display a step with improved formatting
echo_step() {
    local current_step="$1"  # Current step number
    local total_steps="$2"   # Total number of steps
    local message="$3"       # Step message
    local type="${4:-default}"  # Status type (default to 'info')
    local timestamp="${5}"   # Optional timestamp flag

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


wait_stack() {
    local stack_name=$1
    local retries=${2:-10}            # Number of retries before giving up (default 10)
    local interval=${3:-5}            # Initial time between retries (seconds, default 5)
    local max_interval=${4:-60}       # Maximum time between retries (seconds, default 60)
    local backoff_factor=${5:-1.05}    # Backoff factor (default 1.1)
    
    # Track the start time
    local start_time=$(date +%s)

    # Display initial message
    echo_message "info" "Waiting for $stack_name to come online..."
    
    # Loop to check if the service is online
    for i in $(seq 1 $retries); do
        # Check if the Docker service/stack is running
        docker service ls --filter "name=$stack_name" --filter "desired-state=running" > /dev/null 2>&1
        
        # Check if the service is running
        if [ $? -eq 0 ]; then
            # Service is online
            echo_message "success" "$stack_name is now online."
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
            tput cuu1  # Move the cursor up one line
            tput el   # Clear the current line
        fi

        local time_spent="Elapsed time: $elapsed_time seconds, Next retry in: $next_retry seconds"
        echo_message "info" "Attempt $i/$retries: $stack_name not online, retrying in $interval seconds... ($time_spent)"

        wait_secs "$interval"

        # Increase the wait interval using the backoff factor, but don't exceed the max interval
        interval=$next_retry
    done

    local elapsed_time=$(( $(date +%s) - $start_time ))

    # If it doesn't become online after all retries, print error
    echo_message "error" "$stack_name did not come online after $elapsed_time seconds."
    return 1
}


read_yaml_key() {
    local yaml_file="$1"
    local key="$2"
    local default_value="$3"

    # Check if the YAML file exists
    if [ ! -f "$yaml_file" ]; then
        echo "Error: YAML file '$yaml_file' not found."
        return 1
    fi

    # Extract the value using yq, with a fallback for missing keys
    local value
    value=$(yq e "$key" "$yaml_file" 2>/dev/null)  # Suppress yq errors

    # Check if yq returned a non-empty, non-null value
    if [ -n "$value" ] && [ "$value" != "null" ]; then
        echo "$value"
    else
        echo "$default_value"
    fi
}

# Test JSON file
wait_stack "my_stack_name" 5 5 60 1.1

# Test YAML file
yaml_file="config.yaml"

# Read a key from the YAML file
key="apiVersion"
default_value="v1"
api_version=$(read_yaml_key "$yaml_file" "$key" "$default_value")

# Print the extracted value
echo "API Version: $api_version"

# Read another key from the YAML file
key="kind"
default_value="Pod"
kind=$(read_yaml_key "$yaml_file" "$key" "$default_value")

# Print the extracted value
echo "Kind: $kind"

# Read another key from the YAML file
key="metadata.name"
default_value="n8n-compact"
name=$(read_yaml_key "$yaml_file" "$key" "$default_value")