#!/bin/bash

# Prevent script modification
readonly SCRIPT_PATH="$0"
trap 'echo "The temple resists your attempts to modify it..."' EXIT

# Prevent process termination
trap 'echo "The temple refuses to let you go..."' SIGTERM SIGINT SIGTSTP SIGHUP SIGQUIT SIGABRT SIGALRM

# Game state variables
declare -r player_health=100
declare -a inventory=()
declare -i current_room=0
declare -i total_rooms=0
declare -i game_over=0
declare current_room_object=""
declare room_directions=""
declare current_room_description=""
declare current_room_event=""
declare -i room_has_item=0
declare -i death_count=0
declare -i attempts=0
declare -i last_attempt=0

# Function to check for escape attempts
check_escape_attempts() {
    local current_time=$(date +%s)
    if [ $((current_time - last_attempt)) -lt 5 ]; then
        attempts=$((attempts + 1))
        if [ $attempts -gt 3 ]; then
            echo ""
            echo "The temple grows angry at your persistence..."
            echo "You feel a wave of dark energy wash over you."
            handle_death
            attempts=0
        fi
    else
        attempts=0
    fi
    last_attempt=$current_time
}

# Function to generate available directions
generate_directions() {
    directions=()
    # Randomly determine which directions are available
    if [ $((RANDOM % 2)) -eq 0 ]; then directions+=("north"); fi
    if [ $((RANDOM % 2)) -eq 0 ]; then directions+=("south"); fi
    if [ $((RANDOM % 2)) -eq 0 ]; then directions+=("east"); fi
    if [ $((RANDOM % 2)) -eq 0 ]; then directions+=("west"); fi
    if [ $((RANDOM % 2)) -eq 0 ]; then directions+=("up"); fi
    if [ $((RANDOM % 2)) -eq 0 ]; then directions+=("down"); fi
    
    # If no directions are available, add at least one random direction
    if [ ${#directions[@]} -eq 0 ]; then
        all_dirs=("north" "south" "east" "west" "up" "down")
        directions+=("${all_dirs[$((RANDOM % ${#all_dirs[@]}))]}")
    fi
    
    echo "${directions[@]}"
}

# Function to generate a random object
generate_object() {
    objects=(
        "a rusty key" "a flickering torch" "a torn map" "a mysterious potion" 
        "a dull sword" "a cracked shield" "a decaying body" "a strange book"
        "a broken compass" "a dusty scroll" "a small coin" "a mysterious orb"
        "a wooden staff" "a leather pouch" "a crystal shard" "a ancient tablet"
    )
    rand_index=$((RANDOM % ${#objects[@]}))
    echo "${objects[$rand_index]}"
}

# Function to generate a random room description
generate_room_description() {
    adjectives=(
        "dark" "gloomy" "eerie" "spooky" "creepy" "doom" "dry" "cold"
        "ancient" "forgotten" "cursed" "haunted" "mysterious" "desolate"
        "abandoned" "cryptic" "ominous" "sinister" "twisted"
    )
    places=(
        "room" "cavern" "corridor" "passage" "tunnel" "hallway"
        "chamber" "sanctuary" "catacomb" "crypt" "gallery"
        "library" "laboratory" "prison" "temple" "shrine"
    )
    rand_adj=$((RANDOM % ${#adjectives[@]}))
    rand_place=$((RANDOM % ${#places[@]}))
    echo "${adjectives[$rand_adj]} ${places[$rand_place]}"
}

# Function to generate random events
generate_event() {
    events=(
        "You hear distant footsteps echoing through the halls."
        "A cold draft sends shivers down your spine."
        "The walls seem to be closing in."
        "You feel an unseen presence watching you."
        "A mysterious whisper echoes in your mind."
        "The air grows thick with an unknown energy."
        "Your torch flickers ominously."
        "You hear the sound of metal scraping against stone."
        "A shadow moves in the corner of your eye."
        "The temperature suddenly drops."
    )
    rand_index=$((RANDOM % ${#events[@]}))
    echo "${events[$rand_index]}"
}

# Function to generate damaging events
generate_damaging_event() {
    events=(
        "A hidden trap springs! You take damage."
        "A shadowy figure strikes at you from the darkness!"
        "The floor gives way beneath you!"
        "A poisonous gas fills the room!"
        "A swarm of insects attacks you!"
        "A falling rock narrowly misses you!"
        "An ancient curse takes effect!"
        "A mysterious force drains your life force!"
    )
    rand_index=$((RANDOM % ${#events[@]}))
    echo "${events[$rand_index]}"
}

# Function to display game intro
display_intro() {
    echo "Welcome to the Temple of Hate."
    echo ""
    echo "You find yourself in a strange place with no apparent way out."
    echo "You must adventure, explore and seek your way to freedom."
    echo ""
    echo "You are currently in the starting room. Use 'help' for more info."
    echo "Your health: $player_health"
    echo ""
}

# Function to display room description
display_room() {
    # Generate new room elements only if we don't have any for this room
    if [ -z "$current_room_description" ]; then
        current_room_description=$(generate_room_description)
        current_room_event=$(generate_event)
        room_directions=($(generate_directions))
        
        # Randomly determine if room has an item (70% chance)
        if [ $((RANDOM % 100)) -lt 70 ]; then
            current_room_object=$(generate_object)
            room_has_item=1
        else
            current_room_object=""
            room_has_item=0
        fi
    fi
    
    echo "You are in $current_room_description."
    if [ $room_has_item -eq 1 ]; then
        echo "You see $current_room_object lying on the ground."
    fi
    echo "$current_room_event"
    echo ""
    
    # Display available directions
    echo "Available directions:"
    for dir in "${room_directions[@]}"; do
        echo "- $dir"
    done
    echo ""
    
    echo "Your health: $player_health"
    if [ ${#inventory[@]} -gt 0 ]; then
        echo "Inventory: ${inventory[*]}"
    fi
    echo ""
}

# Function to handle inventory
handle_inventory() {
    if [ $room_has_item -eq 0 ]; then
        echo "There's nothing to pick up here."
        return
    fi
    
    if [ ${#inventory[@]} -lt 5 ]; then
        inventory+=("$current_room_object")
        echo "You pick up $current_room_object"
        current_room_object=""
        room_has_item=0
    else
        echo "Your inventory is full!"
    fi
}

# Function to handle death
handle_death() {
    death_count=$((death_count + 1))
    echo ""
    echo "Your vision fades to black..."
    echo "You feel yourself being pulled into the void..."
    echo ""
    
    case $death_count in
        1)
            echo "A voice whispers: 'Death is not an escape...'"
            ;;
        2)
            echo "The darkness speaks: 'You belong to the temple now...'"
            ;;
        3)
            echo "An ancient presence echoes: 'Your soul is bound here...'"
            ;;
        4)
            echo "The temple itself seems to whisper: 'You are mine...'"
            ;;
        5)
            echo "A chorus of voices chants: 'Forever trapped...'"
            ;;
        *)
            echo "The temple's curse continues: 'There is no escape...'"
            ;;
    esac
    
    echo ""
    echo "Suddenly, you awaken..."
    echo "Your health has been restored, but your inventory is empty."
    echo "The temple has claimed your possessions as tribute."
    echo ""
    
    player_health=100
    inventory=()
    
    # Generate a new room after death
    room_directions=""
    current_room_description=""
    current_room_object=""
    current_room_event=""
    room_has_item=0
    display_room
}

# Function to handle health changes
handle_health() {
    # 30% chance of encountering a damaging event when moving
    if [ $((RANDOM % 100)) -lt 30 ]; then
        damage=$((RANDOM % 20 + 10))
        player_health=$((player_health - damage))
        echo "$(generate_damaging_event)"
        echo "You take $damage damage!"
        
        if [ $player_health -le 0 ]; then
            handle_death
        fi
    fi
}

# Function to handle player input
handle_input() {
    read -rp "What would you like to do? : " action
    case $action in
        help)
            echo "Available commands:"
            echo "- 'north', 'south', 'east', 'west', 'up', 'down' to move in that direction"
            echo "- 'look' to examine your surroundings"
            echo "- 'inventory' to check your inventory"
            echo "- 'pickup' to pick up an item"
            echo "- 'attempt' to try something"
            echo "- 'quit' to exit (haha)" ;;
        north|south|east|west|up|down)
            # Check if the direction is available
            if [[ " ${room_directions[@]} " =~ " ${action} " ]]; then
                handle_health
                # Clear all room elements for new room
                room_directions=""
                current_room_description=""
                current_room_object=""
                current_room_event=""
                room_has_item=0
                display_room
            else
                echo "You cannot go that way."
            fi ;;
        look*)
            display_room ;;
        inventory)
            if [ ${#inventory[@]} -gt 0 ]; then
                echo "Your inventory: ${inventory[*]}"
            else
                echo "Your inventory is empty."
            fi ;;
        pickup*)
            handle_inventory ;;
        attempt*)
            read -rp "What would you like to attempt? " attempt_action
            echo "You attempt to $attempt_action, but nothing happens."
            # 20% chance of taking damage when attempting something
            if [ $((RANDOM % 100)) -lt 20 ]; then
                handle_health
            fi ;;
        quit|exit|logout|:q|:wq|:x|:w|x|q|w)
            check_escape_attempts
            echo ""
            echo "There is no escape.."
            echo ""
            handle_input ;;
        *)
            # Check for common escape attempts
            if [[ "$action" =~ ^(bash|sh|zsh|ksh|csh|tcsh|exit|logout|quit|q|:q|:wq|:x|:w|x|w)$ ]]; then
                check_escape_attempts
                echo ""
                echo "The temple resists your attempts to escape..."
                echo ""
                handle_input
            else
                echo "Invalid command."
            fi ;;
    esac
}

# Function to handle trapped signals
handle_signal() {
    check_escape_attempts
    echo ""
    echo "There is no escape.."
    echo ""
    handle_input
}

# Trap specific signals and assign the handler
trap handle_signal SIGINT SIGTSTP SIGTERM SIGHUP SIGQUIT SIGABRT SIGALRM

# Main game loop
main() {
    # Clear screen and disable cursor
    clear
    echo -e "\e[?25l"
    
    # Set terminal title
    echo -e "\e]0;Temple of Hate\a"
    
    display_intro
    while true; do
        handle_input
    done
}

# Start the game
main

