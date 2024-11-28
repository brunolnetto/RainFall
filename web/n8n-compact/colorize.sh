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
        "info") echo " ℹ️" ;;       # Info icon
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

# Example usage
format_message "success" "Hello, World!" true
format_message "warning" "Warning message!"  true
format_message "error" "Error message!"  true
format_message "info" "Information message!"  true
format_message "highlight" "Highlight message!"  true
format_message "debug" "Debug message!"  true
format_message "critical" "Critical message!"  true
format_message "note" "Note message!"  true
format_message "important" "Important message!"  true
format_message "wait" "Wait message!"  true
format_message "unknown" "Unknown message!"  true

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

# Example usage
echo_step 1 5 "Fazer compras" "success" true
echo_step 2 5 "Beber leite" "error" false
echo_step 3 5 "Tomar banho" "warning" true
echo_step 3 5 "Caminhar"



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

# JSON data as a string
test_json='{
    "name": "John Doe",
    "age": 30,
    "city": "New York",
    "country": "USA",
    "metadata": {
        "status": "success",
        "code": 200
    }
}'

echo "Reading JSON keys..."

# Use the updated function to read keys
name=$(read_json_key "$test_json" ".name" "Unknown")
age=$(read_json_key "$test_json" ".age" 0)
city=$(read_json_key "$test_json" ".city" "Unknown")
country=$(read_json_key "$test_json" ".country" "Unknown")
status=$(read_json_key "$test_json" ".metadata.status" "Unknown")
code=$(read_json_key "$test_json" ".metadata.code" 0)

echo "Name: $name"
echo "Age: $age"
echo "City: $city"
echo "Country: $country"
echo "Status: $status"
echo "Code: $code"
