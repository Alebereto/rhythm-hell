# rhythm-hell

This project contains a VR rhythm game inspired by Rhythm Heaven, and a level editor for rhythm games, both of which were made in [Godot 4.2](https://godotengine.org/download/archive/4.2-stable/).

This project was done under the supervision of Roi Poranne, as part of my duties towards a BSc in Computer Science at the [University of Haifa](https://www.haifa.ac.il/?lang=en).

# Features

## Game

The idea behind the project was to make a game containing several "micro" rhythm games which are all simple in their mechanics, can be picked up easily, and levels can be created easily for them.

The game (currently) features 3 micro games which are shown below:

[![Gameplay](https://img.youtube.com/vi/rEpayqoDZG0/0.jpg)](https://www.youtube.com/watch?v=rEpayqoDZG0)

### Adding Levels
To add custom levels to the game, just add the level folder into the "CustomLevels" folder in the root of the game.

## Level Editor

The level editor was designed to be generic, so that it could be used to make levels for any micro game, and even for other projects potentially.

Below is a video showcasing some of its features:

[![editor demo]](https://private-user-images.githubusercontent.com/100861860/375179007-8700d0d9-fde0-4080-aaa4-b4700c0a69af.mp4?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3Mjg1MjQ0MDIsIm5iZiI6MTcyODUyNDEwMiwicGF0aCI6Ii8xMDA4NjE4NjAvMzc1MTc5MDA3LTg3MDBkMGQ5LWZkZTAtNDA4MC1hYWE0LWI0NzAwYzBhNjlhZi5tcDQ_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQxMDEwJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MTAxMFQwMTM1MDJaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT00ZGNmZmFiNjRhYWYzZDNlMjk5NjE3ZWVhMzE4YWY3ZTJjMWMwZWE2MjE3YWE5YzY0M2IyOTcxMTM3MDUwYTdlJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.k61bpLSryHSxRok5oJaO9dkEYBtgRmmLmuoEmUd-8c8)

### Making Levels
Each note and event has an id and some other values which can be used differently depending on which micro game is being played.

For instance, in the Karate game, if a note has `id=0` then it will create a normal projectile, whereas `id=1` will create a barrel.
Each micro game has a preset that can be used to see what the different values give.

#### Song
The level editor currently only supports songs in the [ogg Vorbis](https://xiph.org/vorbis/) format. The song can be selected when creating a level, or by modifying the level settings through the "Edit" tab.

#### Level Image
An image for the level that is seen in the menus can be added by adding a "cover.jpg" file in the level folder.


## Installation

Both the game and level editor can be downloaded from the releases. Simply extract the files and start the excecutable.

## Credits

The song "Groovy Ambient Funk" by moodmode that is used in the preset custom levels was taken from [pixabay](https://pixabay.com/music/funk-groovy-ambient-funk-201745/).

The sound effects were all created in [Chiptone](https://sfbgames.itch.io/chiptone).
