# stenojump
 Stenography practice game designed for practicing theory knowledge in sequence, with options for setting speed (strokes/minute) and progressive speed increase across a single level to increase fluency. 

## Current State

Levels are available from chapter 5 up to partway through chapter 8 of the Lapwing textbook. No briefs or sequenced lessons are currently included. Two game modes are presently available:
 - Progression
 - Speed Build (subject to renaming)

### Progression Game

Starts at the beginnig of the level sequence (with basic, 3 key words) at the selected speed and progresses through theory concepts. Optionally can repeat the same concept at higher speeds by toggling 'speed build' and selecting your target speed. Hints are shown (if available for that word, they currently need to be manually included in the level data) on a failed word.

Starting from a specific level can be selected by choosing "custom" and selecting the level. 

On reaching the end of a level sequence, you can elect to repeat it with an increase in speed that you specify, or quit to main menu - currently this leaves you with your last save at the final level. 

Progress is saved on your device and resets to checkpoint levels (the first level, and then review levels from the lapwing practice exercises) if you lose all lives in a run. This can be disabled in settings. Scoring currently counts words completed successfully and deducts a point when you die.

### Speed Build

Select a specific level and repeat it strating at the chosen starting speed and increasing by the amount you select, until you fail a level. New levels are unlocked by completing the previous level in either Progression or Speed Build modes, at any speed. 


### Level Creator 

The level creator is built into the game for custom levels - be advised that it is a bit mouse click intensive and may not be the most intuitive - suggestions are welcome. Level format is a json which you can also create by hand - the level creator will parse a word list and get the initial information into the level, which is convenient. Custom levels are currently only selectable in progression mode. To be addressed in a coming release. 

### Settings

Main menu is navigable with tab and enter, arrow keys, or, if you left arrow to the cat's text box, typed commands. Considering starting with tha command box focused in future, but this is still up in the air.

Main settings menu is largely functional, barring any notes in the current release. Available settings as follows:
 - Max number of lives: Default is 3
 - Custom level size: Can override the default level length to produce levels within your chosen minimum and maximum size. When disabled, the level size is dictated by the specific level file
 - Target order: what order words appear in in the level. "Default" is set in the level files, "Random" forces randomization, "Ordered" covers words in the order in the level file (will be the same every time, but may not cover all concepts for levels covering multiple concepts, depending on how the level file is set up)
 - Autojump: Disabled, was experimental to allow less precise timing - Technical challenges may lead to not implementing
 - Checkpoints enabled: Enables restart from specific checkpoint levels on losing a progression run. If off, 'resume' will restart from the first level with the current settings after losing. Default is "on"
 - Checkpoints on all levels: Enables restart from any level on losing a progression run.
 - Target Visibility: Sets which targets can be seen during gameplay. "All" - anything visible on screen; "Next" - only the next available word; "In Range" - only on the closer side of the screen, "None" - Written target never visible, meant to pair with TTS *Note: this is particularly tricky due to TTS limitations on single words. Ideally will replace TTS with recordings of the word for built in level. Still exploring technical ways to do this.*
 - Solid Background for targets: Customize colors/background for targets in levels to improve visual contrast according to your preferences
 -  Speak all UI Elements: Read out UI elements (i.e button text, labels) on focus. Meant to improve navigation for low vision users as engine presently has no technical compatibility with screen readers and I lack th technical ability to create it. *Note: Not currently functional*
 -  Choose Voice: Select your preferred built in TTS voice

## Future Plans

In no particular order, some things that need work and/or have plans in progress. I do this for fun, and am inclined to work on things in order of interest, unless there is a pressing need to address a specific thing (usually when I introduce a bug that makes things crash). 

 - Art needs work. Eventually would like to have a variety of environments to sync with story mode (see below)
 - Sound - there currently isn't any, apart from TTS for target words and a 'meow' easter egg in the main menu.
 - Nicer UX
 - Level Description section in level creator
 - Speed Build - crawling a specific folder for custom levels.
 - Sequenced lessons featuring words in order from passages, for example. The infrastructure to do this is complete, but I have not sat down to make sentences (partly because there aren't many sentences to make with the low level of Lapwing theory currently complete and no briefs).
 - Multiple save slots
 - Story mode: providing theory lessons with some untimed gameplay to practice the introduced concepts, followed by a runner level to increase fluency. This is still in the concept stage and may not emerge, depending on what I can come up with. But I'm interested in it, so there is a possibility that it happens faster than more 'core' seeming features. 
