# Pet The Fox

An interactive virtual pet of [Clover Inari](https://www.twitch.tv/cloverinari).

Keep the fox in good health and accumulate honey drops.  

The game is designed to be played with either a mouse or touch interface.
No keyboard or gamepad required.

_* Autosaves occur once a minute_

Donations towards development accepted through [ko-fi](https://ko-fi.com/erodozer)

## Twitch Integration
This game supports integration with Twitch chat, allowing your viewers to take care of the fox with simple commands.

For the web version, you can enable twitch integration by visiting the itch.io page with your channel name in the url, like so
[https://erodozer.itch.io/pet-the-fox?twitch=erodozer](https://erodozer.itch.io/pet-the-fox?twitch=erodozer)

On Desktop, you can open the twitch integration configuration panel by pressing F1.  There you can then enter the channel name that you wish to link your game's session to.

<img width="300" src="https://github.com/erodozer/pet.clover/assets/316728/ec5c45b5-6b15-4440-81c7-d5e092ec2608" />

### Interactions
All interactions start with `!pet` as the command prefix

Commands are set to operate on the same cooldowns, this allows chat to act while the streamer is away/taking a break.
Per cycle stat adjustments are also tweaked to be more frequent and aggressive, encouraging chat engagement.

#### !pet &lt;food | give food
Feeds the fox

#### !pet lights < on | off >
toggle the lights

#### !pet < bath | bathe | wash >
washes the fox

#### !pet < heal | cure | give medicine >
give medicine to the sick fox
