#!/usr/bin/env bash
#	This script was originally written by some guy named "taldy" on github, i think. i rewrote the download portion because it had broken
#	The rewrite also removes the need for xmllint, cuz i didn't know how to get it working. instead i just brute forced it with grep lol
#
#   Requirements:
#     rofi, xsel, xdotool, curl
#
#   Notes:
#     * You'll need a emoji font like "Noto Emoji" or "EmojiOne".
#     * Confirming an item will automatically type it.
#     * Ctrl+C will copy it to your clipboard WITHOUT pasting it.

#where to save the emojis file by default
DEFAULT_EMOJI_FILE="$HOME/.config/rofi-emoji/unicode-emoji.txt"

#this value is altered by the --emoji-file option and will be used as the new default if not blank
CUSTOM_EMOJI_FILE=""

if [[ "$CUSTOM_EMOJI_FILE" == "" ]]; then
	EMOJI_FILE="$DEFAULT_EMOJI_FILE"
else
	EMOJI_FILE="$CUSTOM_EMOJI_FILE"
fi

#function to set custom emoji file path in (saved in script file itself)
set_emoji_file() {
    local value="$1"
    if [[ "$value" != "$CUSTOM_EMOJI_FILE" ]]; then
	    sed -i "s|^CUSTOM_EMOJI_FILE=\".*\"$|CUSTOM_EMOJI_FILE=\"$value\"|" "$0"
	else
		echo "No change to custom emoji file"
	fi
}

function download(){
	#check if $EMOJI_FILE already exists, or make a new one
	if [[ -e "$EMOJI_FILE" ]] ; then
		backup_file="$EMOJI_FILE"_"$(date +%s)".BAK
		echo "♻️  Backing up current emoji file to $backup_file"
		mv "$EMOJI_FILE" "$backup_file"
	else
		echo "🆕 creating new emoji file at $EMOJI_FILE"
		mkdir -p $(dirname "$EMOJI_FILE") || { echo "Error: Failed to create directory"; exit 1; }
		touch "$EMOJI_FILE"
	fi


	source_url="https://unicode.org/Public/emoji/latest/emoji-test.txt"
	echo "🔻 downloading and extracting emoji from $source_url"
	html_content=$(curl -s "$source_url")

	#extract lines containing qualified emojis
	echo "$html_content" | grep '; fully-qualified' | awk -F'# ' '{print $2}' > "$EMOJI_FILE"

	#remove unicode version number from all lines (matches "EX.YY " and "EXX.Y ")
	sed -E -i 's/E[0-9]+(\.[0-9]+) //g' "$EMOJI_FILE"
}

function display() {
	#show the rofi gui
	echo "currently using $EMOJI_FILE as source"
	echo "run $0 -d to download new list of emoji, -h to show help"
    emoji=$(cat "$EMOJI_FILE" | grep -v '#' | grep -v '^[[:space:]]*$')
    line=$(echo "$emoji" | rofi -dmenu -i -p "Emoji" -kb-custom-1 Ctrl+c $@)
    exit_code=$?
    line=($line)

	#autotyping
    if [ $exit_code == 0 ]; then
        sleep 0.1  #delay pasting so the text-entry can come active
        xdotool type --clearmodifiers "${line[0]}"
    elif [ $exit_code == 10 ]; then
        echo -n "${line[0]}" | xsel -i -b
    fi

    echo -n "${line[0]}" | xsel -i -b
}

#ASSIGN CUSTOM NICKNAMES TO EMOJI (these names are in addition to the default ones from Unicode.org)
declare -A NICKNAME_MAP=(
  ["😃"]="smiley"
  ["😄"]="smile"
  ["😁"]="grinning"
  ["😆"]="laugh"
  ["😅"]="sweat smile"
  ["🤣"]="rofl"
  ["🙂"]="slight smile"
  ["😊"]="blush"
  ["😇"]="innocent"
  ["😍"]="in love"
  ["☺️"]="relaxed"
  ["🥲"]="smile cry"
  ["😋"]="yum"
  ["🤗"]="hug"
  ["🫣"]="hands over face | hands covering face | hiding face"
  ["🤨"]="sus"
  ["😶"]="no mouth"
  ["🫥"]="invisible"
  ["😬"]="grimace"
  ["😮‍💨"]="sigh"
  ["🤥"]="pinnochio | liar"
  ["😴"]="zzz"
  ["🤒"]="fever | sick"
  ["🤧"]="blowing nose | sick | kleenex | tissue"
  ["🥴"]="drunk"
  ["😵"]="dead | x eyes"
  ["😵‍💫"]="dizzy face"
  ["🤯"]="mind blown"
  ["😎"]="cool face"
  ["😭"]="sob"
  ["😤"]="triumph"
  ["🤬"]="curse | swearing"
  ["🙂‍↕️"]="nod"
  ["😈"]="imp | devil"
  ["👿"]="angry imp | devil"
  ["💩"]="shit | poop | crap"
  ["👹"]="monster"
  ["👾"]="space invader"
  ["💋"]="kissing lips"
  ["🖖"]="spock hand"
  ["✌️"]="v | peace"
  ["🤘"]="metal"
  ["🖕"]="fuck yourself | fu | birdie"
  ["🙏"]="praying"
  ["💪"]="arm | muscle"
  ["🦕"]="dino"
  ["🦖"]="dino"
  ["🥐"]="crescent roll"
  ["🍾"]="champagne"
  ["🗿"]="moyai | easter island statue | bruh"
  ["🪇"]="mexican rattles | celebrate"
  ["⚠️"]="alert | hazard | danger | exclamation triangle"
  ["🏴‍☠️"]="jolly roger"
  ["🇬🇧"]="uk"
  ["🇺🇸"]="usa | america"
)

function append_nicknames() {
	echo "🤓 appending emoji nicknames (--nicknames to view)"
	for emoji in "${!NICKNAME_MAP[@]}"; do
		nickname="${NICKNAME_MAP[$emoji]}"

		sed -i "s/^$emoji /$emoji $nickname | /" "$EMOJI_FILE"
	done
	echo "💾 file saved at $EMOJI_FILE"
}

prompt_confirmation() {
    local prompt_message="$1"
    read -p "$prompt_message (y/n): " response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        return 0 # Yes
    elif [[ "$response" == "n" || "$response" == "N" ]]; then
        return 1 # No
    else
        echo "Invalid response. Please enter 'y' for yes or 'n' for no."
        prompt_confirmation "$prompt_message"
    fi
}

#iterate through the command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--emoji-file)
        	if [[ -n "$2" ]]; then
        		if [[ ! "$2" =~ ^- ]]; then
	                set_emoji_file "$2"
	                shift
    			else
    			    echo "Error: No path provided for -e|--emoji-file" >&2
            	fi
            else
            	echo "Reset default emoji file to $DEFAULT_EMOJI_FILE"
            	set_emoji_file ""
            	shift
    		fi
    		exit 0
            ;;
        -d|--download)
            if [[ -n "$2" ]]; then
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    EMOJI_FILE="$2"
                    download
                    append_nicknames

                    #automatically ask if you want to set a new custom emoji files based on download location
                    echo "⚠️ You have downloaded the emoji list to a non-default location."
                    echo "⚠️ You have the option to set this location as the new default for all aspects of the script."
                    if prompt_confirmation "Do you want to set the default emoji file to '$EMOJI_FILE'?"; then
    					set_emoji_file "$EMOJI_FILE"
    				echo "Emoji file set successfully."
						else
    				echo "Operation canceled."
					fi
                    shift
                else
                    echo "Error: Invalid file path provided after '-d|--download'" >&2
                    exit 1
                fi
            else
                download
                append_nicknames
                shift
            fi
            exit 0
            ;;
        -n|--nicknames)
			if [[ -n "$2" ]]; then
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
	        		EMOJI_FILE="$2"
	        		echo "Showing nicknames applied to $EMOJI_FILE:"
            		echo
	        		grep "|" "$EMOJI_FILE"
	        	else
                    echo "Error: Invalid file path provided after '-d|--download'" >&2
                    exit 1
                fi
            else
            	echo "Showing nicknames applied to $EMOJI_FILE:"
            	echo
            	grep "|" "$EMOJI_FILE"
            fi
            exit 0
            ;;
        -h|--help)
        	if [[ "$CUSTOM_EMOJI_FILE" != "" ]]; then
        		echo "⚠️ Custom emoji file location is currently: $CUSTOM_EMOJI_FILE"
        	fi
            echo "Usage: $0 [-e|--emoji-file] [-d|--download] [-n|--nicknames] [-h|--help]"
            echo
            echo "Options:"
            echo "  -e, --emoji-file <emoji_file>  Set a new default path for the emoji list to be downloaded to"
            echo "                                 Leave blank to reset to $DEFAULT_EMOJI_FILE"
            echo
            echo "  -d, --download <emoji_file>    Downloads a list of most recent emoji from unicode.org"
            echo "                                 Defaults to $DEFAULT_EMOJI_FILE unless previously altered by -e"
            echo
            echo "  -n, --nicknames                Shows the list of nicknames saved in the script file which are appended to <emoji_file>"
            echo
            echo "  -h, --help                     Show this help message"
            echo "                                 If a custom <emoji_file> is set, --help will display it"
            echo
            exit 0
            ;;
        -*)
            #handle other arguments if needed
            echo "Invalid command line option. try $0 --help"
            exit 1
            ;;
    esac
done
display
