# rofi-emoji
Download latest Unicode emoji, Apply nicknames, Copy-Paste/Autotype them from Rofi! 

![Screenshot from 2024-02-19 14-25-39](https://github.com/Ao1Pointblank/rofi-emoji/assets/88149675/55a8cde8-2168-4e1f-9e77-17bcc46b0ba8)

# Dependencies
- rofi
- xsel
- xdotool
- curl

# Installation
- Download: ``git clone git clone https://github.com/Ao1Pointblank/rofi-emoji``
- Move to downloaded folder: ``cd rofi-emoji``
- Give execute permission to script: ``chmod +x rofi-emoji.sh``
- Save the script to ``$PATH`` (I suggest ~/.local/bin): ``cp rofi-emoji.sh ~/.local/bin/rofi-emoji.sh``
- Edit the location of the emoji cache file if you want (defaults to ~/.config/rofi-emoji/unicode-emoji.txt): ``rofi-emoji.sh -e <emoji_file>``  
- Download the latest emoji list from Unicode.org: ``rofi-emoji.sh --download``
- Set a keybind with your DE to run the script without any CLI args
![Screenshot from 2024-02-20 16-34-12](https://github.com/Ao1Pointblank/rofi-emoji/assets/88149675/ec03a352-9857-4de7-8857-e3feab629b98)

# Other things to consider
- you can add nicknames to emoji to assist searching for ones with obscure titles.  
  these nicknames are saved within the script file itself, as well as the cache file (so that they are not lost when you redownload the list from unicode.org)
  I supplied some nicknames which discord users will be familiar with already.
  these nicknames are *in addition* to the default ones from unicode.org. they will not replace them.

# CLI options
```
Usage: ./rofi-emoji.sh [-e|--emoji-file] [-d|--download] [-n|--nicknames] [-h|--help]

Options:
  -e, --emoji-file <emoji_file>  Set a new default path for the emoji list to be downloaded to
                                 Leave blank to reset to /home/pointblank/.config/rofi-emoji/unicode-emoji.txt

  -d, --download <emoji_file>    Downloads a list of most recent emoji from unicode.org
                                 Defaults to /home/pointblank/.config/rofi-emoji/unicode-emoji.txt unless previously altered by -e

  -n, --nicknames                Shows the list of nicknames saved in the script file which are appended to <emoji_file>

  -h, --help                     Show this help message
                                 If a custom <emoji_file> is set, --help will display it
```

# To-do
command line option to add new nicknames to the script without needing to manually edit the file
