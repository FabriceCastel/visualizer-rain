# visualizer-rain

## Requirements

This sketch requires the Sound library to run. To install the library:

`Tools > Add Tool... > [Libraries tab] > [search for "sound"] > install "Sound" by the Processing
Foundation`

## Known issues

The sound library seems to be unreliable across systems. It will sometimes break when given an .mp3
file for playback and has a tendency to play stereo files with an immutable hard-right pan. The .mp3
problem can be circumvented with the use of a .wav file or by foregoing the SoundFile approach and
using a live audio input instead (the relevant code for this is commented out in the setup()
method).
