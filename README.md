# Dart12
312 Decryptor standalone app for all platforms (not ios or macos tho)

3121534312 is a Youtube channel that uses a substitution cipher accross all their videos.

I am a part of the RGN community, who are actively researching on that channel. We need
some good tool to decode those videos and their texts, which is why i initally made
https://312.alimad.co
This is a remake of that website, because sometimes one might need offline access to it.

## Improvements
This is a much optimized implementation of the 312 decoder, it might work well with larger 
texts.

This implementation is clear, written entirely by hand, and doesnt attempt at evaluating
scores for decoding maximum letters to keep things well defined. (There were issues with
the evaluation on the main website, if you find them in this app, you have to toggle
the capitalization mode, and if a sentence starts with 71/72/73, replace it with nothing.

The thing is now cross platform :)

## Learnt
Dart & Flutter

I didnt have any experience in both these languages before, though i found out dart to be 
much close to C#. Also, using Flutter was a breeze as opposed to ReactNative. All I had to do
is put one SafeArea() and the whole app was wrapped in it, I had major issues with this
for ReactNative. The android export was also easily done, which has not been the case for my
computer for a long time.

## Credits
Salute to 3121534312 for coming up with this awesome cipher

Salute to RGN and his community for all their research on this topic, especially TMGeneral

All the code in /lib was written by Muhammad Ali

No AI was used in the development of this project

A short recording/livestream is available on youtube for no reason lol :)

https://www.youtube.com/watch?v=9dNMOSfPwVM

Meow
