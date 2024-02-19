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

#where to save the emojis file
EMOJI_FILE="$HOME/Documents/unicode-emoji.txt"

function download(){
	if [[ -e "$EMOJI_FILE" ]] ; then
		mv -i "$EMOJI_FILE" "$EMOJI_FILE"_"$(date +%s)".BAK
	else
		touch "$EMOJI_FILE"
	fi

	source_url="https://unicode.org/Public/emoji/latest/emoji-test.txt"
	html_content=$(curl -s "$source_url")

	#extract lines containing qualified emojis
	echo "$html_content" | grep '; fully-qualified' | awk -F'# ' '{print $2}' > "$EMOJI_FILE"

	#remove unicode version number from all lines (matches "EX.YY " and "EXX.Y ")
	sed -E -i 's/E[0-9]+(\.[0-9]+) //g' "$EMOJI_FILE"
}

function force_download(){
	source_url="https://unicode.org/Public/emoji/latest/emoji-test.txt"
	html_content=$(curl -s "$source_url")

	#extract lines containing qualified emojis
	echo "$html_content" | grep '; fully-qualified' | awk -F'# ' '{print $2}' > "$EMOJI_FILE"

	#remove unicode version number from all lines (matches "EX.YY " and "EXX.Y ")
	sed -E -i 's/E[0-9]+(\.[0-9]+) //g' "$EMOJI_FILE"
}

function display() {
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

function nicknames() {
  for emoji in "${!NICKNAME_MAP[@]}"; do
    nickname="${NICKNAME_MAP[$emoji]}"

    sed -i "s/^$emoji /$emoji $nickname | /" "$EMOJI_FILE"
  done
}

function test_nicknames() {
  for emoji in "${!NICKNAME_MAP[@]}"; do
    nickname="${NICKNAME_MAP[$emoji]}"

    #debugging line: will match all emoji and simulate appending nicknames without saving to file
    sed -n "s/^$emoji /$emoji $nickname | /p" "$EMOJI_FILE"
  done
}

#primitive argparsing
if [[ "$1" =~ -D|--download ]]; then
    if [[ "$2" =~ -F|--force-download ]]; then
        force_download
    else
        download
    fi
    exit 0
elif [[ "$1" =~ -n|--nicknames ]]; then
    if [[ "$2" =~ -t|--test-nicknames ]]; then
        test_nicknames
    else
        nicknames
    fi
    exit 0
elif [[ "$1" =~ -h|--help ]]; then
    echo "Usage: $0 [-D|--download -F|--force-download] [-n|--nicknames -t|--test-nicknames] [-h|--help]"
	echo
	echo "	-D, --download			downloads a list of most recent emoji straight from unicode.org"
    echo "	-F, --force-download		use after the -D option to download without saving previous $EMOJI_FILE to a .BAK backup"
    echo
    echo "	-n, --nicknames			append a list of custom emoji nicknames to the $EMOJI_FILE; nicknames are stored in the script itself"
    echo "	-t, --test-nicknames		use after the -n option to print the emoji names that would be altered by -n"
    echo
    echo "	-h, --help			show this help list"
    exit 0
fi

#download all emoji if they don't exist yet
if [ ! -f "$EMOJI_FILE" ]; then
    download
fi

#display rofi menu if all potential args exit 0
display
