# rofi-emoji
Download latest Unicode emoji, Apply nicknames, Copy-Paste/Autotype them from Rofi! 

# Dependencies
- rofi
- xsel
- xdotool
- curl

# Installation
- save the script to ``$PATH`` (I suggest ~/.local/bin)  
- edit the location of the emoji cache file (``$EMOJI_FILE`` defaults to ~/Documents/unicode-emoji.txt)  
- run the command to download latest emoji list from Unicode.org ``rofi-emoji.sh --download``
- set a keybind with your DE to run the script without any CLI args

# Other things to consider
- you can add nicknames to emoji to assist searching for ones with obscure titles.  
  these nicknames are saved within the script file itself, not the cache file (so that they are not replaced when you redownload the list from unicode.org)
  I supplied some nicknames which discord users will be familiar with already.
  these nicknames are *in addition* to the default ones from unicode.org. they will not replace them.

# CLI options
```
-D, --download			downloads a list of most recent emoji straight from unicode.org  
-F, --force-download		use after the -D option to download without saving previous $EMOJI_FILE to a .BAK backup  
-n, --nicknames			append a list of custom emoji nicknames to the $EMOJI_FILE; nicknames are stored in the script itself  
-t, --test-nicknames		use after the -n option to print the emoji names that would be altered by -n  
-h, --help			show this help list  
```
