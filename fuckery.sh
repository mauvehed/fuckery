#!/bin/bash

# Function to generate a random object
generate_object() {
    objects=("a key" "a torch" "a map" "a potion" "a sword" "a shield" "a body")
    rand_index=$((RANDOM % ${#objects[@]}))
    echo "${objects[$rand_index]}"
}

# Function to generate a random room description
generate_room_description() {
    adjectives=("dark" "gloomy" "eerie" "spooky" "creepy" "doom" "dry" "cold")
    places=("room" "cavern" "corridor" "passage" "tunnel" "hallway")
    rand_adj=$((RANDOM % ${#adjectives[@]}))
    rand_place=$((RANDOM % ${#places[@]}))
    echo "${adjectives[$rand_adj]} ${places[$rand_place]}"
}

# Function to display game intro
display_intro() {
    echo "Welcome to the Temple of Hate."
    echo ""
    echo "You find yourself in a strange place with no apparent way out."
    echo "You must adventure, explore and seek your way to freedom."
    echo ""
    echo "You are currently in the starting room. Use help for more info."
    echo ""
}

# Function to display room description
display_room() {
    echo "You are in $(generate_room_description)."
    echo "You see $(generate_object) lying on the ground."
    echo ""
}

quit() {
    echo ""
    echo "There is no escape.."
    echo ""
    handle_input
}

# Function to handle player input
handle_input() {
    read -rp "What would you like to do? : " action
    case $action in
        help)
            echo "Use 'move' to move to another room, 'attempt' to execute an action, or 'quit' to exit" ;;
        move*)
            display_room ;;
        attempt*)
            read -rp "What would you like to attempt? " attempt_action
            echo "You attempt to $attempt_action, but nothing happens." ;;
        quit)
            quit ;;
        *) 
            echo "Invalid command." ;;
    esac
}

# Function to handle trapped signals
handle_signal() {
    quit
}

# Trap specific signals and assign the handler
trap handle_signal SIGINT SIGTSTP SIGTERM SIGHUP SIGQUIT SIGKILL

# Main game loop
main() {
    display_intro
    while true; do
        handle_input
    done
}

# Start the game
main

