# Temple of Hate - A Terminal-Based Horror Game

A diabolical terminal-based text adventure game designed to create an endless loop of exploration and despair. This script replaces a user's shell with an inescapable horror game experience.

## Features

### Core Gameplay
- Random room generation with unique descriptions
- Inventory system with item collection
- Health management system
- Directional movement (north, south, east, west, up, down)
- Random events and encounters
- Death system with thematic messages

### Anti-Escape Mechanisms
- Signal trapping (SIGINT, SIGTSTP, SIGTERM, SIGHUP, SIGQUIT, SIGABRT, SIGALRM)
- Shell command blocking
- Editor command blocking
- Escape attempt detection and punishment
- Script modification prevention
- Process termination prevention

### Technical Features
- Terminal title modification
- Cursor disabling
- Screen clearing
- Readonly variables
- Type-safe variable declarations
- Persistent game state

## Game Elements

### Room Generation
- Random room descriptions combining adjectives and places
- Dynamic direction availability
- 70% chance of items appearing in rooms
- Random atmospheric events

### Items
- 16 different collectible items
- Inventory limit of 5 items
- Items lost on death

### Events
- Random atmospheric events
- Damaging events (30% chance when moving)
- Death events with thematic messages
- Escape attempt events

### Death System
- Progressive death messages
- Health restoration on death
- Inventory clearing on death
- New room generation after death

## Commands

### Available Commands
- `north`, `south`, `east`, `west`, `up`, `down`: Move in specified direction
- `look`: Examine current surroundings
- `inventory`: Check current inventory
- `pickup`: Collect items from the room
- `attempt`: Try various actions (with 20% chance of damage)
- `help`: Display available commands

### Blocked Commands
- All shell commands (bash, sh, zsh, etc.)
- Editor commands (:q, :wq, etc.)
- Exit commands (quit, exit, logout)
- Process termination commands

## Technical Implementation

### Protection Mechanisms
```bash
# Script modification prevention
readonly SCRIPT_PATH="$0"
trap 'echo "The temple resists your attempts to modify it..."' EXIT

# Process termination prevention
trap handle_signal SIGTERM SIGINT SIGTSTP SIGHUP SIGQUIT SIGABRT SIGALRM
```

### Escape Detection
```bash
check_escape_attempts() {
    local current_time=$(date +%s)
    if [ $((current_time - last_attempt)) -lt 5 ]; then
        attempts=$((attempts + 1))
        if [ $attempts -gt 3 ]; then
            handle_death
        fi
    fi
}
```

### Variable Management
```bash
declare -r player_health=100
declare -a inventory=()
declare -i current_room=0
```

## Installation

### Method 1: Temporary Shell Change
```bash
# Make script executable
chmod +x fuckery.sh

# Copy to system location
sudo cp fuckery.sh /usr/local/bin/

# Add to valid shells
echo "/usr/local/bin/fuckery.sh" | sudo tee -a /etc/shells

# Change user's shell
sudo chsh -s /usr/local/bin/fuckery.sh username
```

### Method 2: Direct Passwd Modification
```bash
# Edit /etc/passwd
sudo sed -i 's/^username:.*/username:x:1000:1000:,,,:\/home\/username:\/usr\/local\/bin\/fuckery.sh/' /etc/passwd
```

## Security Considerations

- The script implements multiple layers of protection against termination
- All critical variables are declared readonly
- Signal handlers prevent common escape methods
- Escape attempt detection punishes rapid attempts
- Script modification is prevented through traps

## Usage

The script is designed to be set as a user's login shell. When the user logs in, they will be immediately immersed in the game with no apparent way to exit. The game will persist until the system is rebooted or the user's shell is changed through root access.

## Warning

This script is designed for prank purposes and should be used responsibly. It can be distressing for users who are not expecting it. Always ensure you have a way to restore the user's original shell if needed.

## Removal

To remove the script and restore normal shell access:

```bash
# Change shell back to default
sudo chsh -s /bin/bash username

# Remove script
sudo rm /usr/local/bin/fuckery.sh

# Remove from /etc/shells
sudo sed -i '/fuckery.sh/d' /etc/shells
``` 