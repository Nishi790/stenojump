# stenojump
 Stenography practice game designed for practicing theory knowledge in sequence, with options for setting speed (strokes/minute) and progressive speed increase across a single level to increase fluency. 

## Current State

Levels are available from chapter 5 up to partway through chapter 8 of the Lapwing textbook. No briefs or sequenced lessons are currently included. Starting from a specific level can be selected bu choosing "custom" and selecting the level. Hints are shown (if available for that word, they currently need to be manually included in the level data) on a failed word.

On reaching the end of a level sequence, you can elect to repeat it with an increase in speed that you specify, or quit to main menu - currently this leaves you with your last save at the final level. 

Level creator is built into the game for custom levels - be advised that it is a bit mouse click intensive and may not be the most intuitive - suggestions are welcome. Level format is a json which you can also create by hand - the level creator will parse a word list and get the initial information into the level, which is convenient. 

Main menu is navigable with tab and enter, arrow keys, or, if you left arrow to the cat's text box, typed commands. Considering starting with tha command box focused in future, but this is still up in the air.

Progress is saved on your device and resets to checkpoint levels (the first level, and then review levels from the lapwing practice exercises) if you lose all lives in a run. Scoring is effectively a placeholder - it counts words completed successfully and deducts a point when you die.

Main settings menu is functional, but may display the settings incorrectly compared to what is stored in the config file and being used - it's in the bug pile to be fixed. All run specific settings (strokes per minute, level sequence, turning on speed building mode to repeat each level until reaching a target speed, and turning on TTS reading of the words) work - the TTS is a work in progress in terms of timing to read the word.

## Future Plans

In no particular order, some things that need work and/or have plans in progress. I do this for fun, and am inclined to work on things in order of interest, unless there is a pressing need to address a specific thing (usually when I introduce a bug that makes things crash). 

 - Art needs work. I am not an artist.
 - Sound - there currently isn't any, apart from TTS for target words. 
 - Sequenced lessons featuring words in order from passages, for example. The infrastructure to do this is complete, but I have not sat down to make sentences (partly because there aren't many sentences to make with the low level of Lapwing theory currently complete and no briefs).
 - Multiple save slots
 - High score table for if you reach the end of a sequence of levels (Scoring needs to be finalized first?)
 - I am considering an 'auto jump' mode that allows you to stroke words at any speed faster than 'when they run into you' and har the character 'dash' forward and clear the obstacle. This would reduce the need for precise timing, as long as you were staying at/above the target stroke rate, which increases accessibility for people more concerned about staying on approximate speed 
 - I am working on ideas for a 'story' mode that includes actual theory lessons and practice games that are untimed, followed by the obstacle run, to allow learners to get both timed and untimed practice. This is still in the concept stage and may not emerge, depending on what I can come up with. But I'm interested in it, so there is a possibility that it happens faster than more 'core' seeming features. 
