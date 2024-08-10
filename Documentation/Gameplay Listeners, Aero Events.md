# Gameplay Listeners / Aero Events

Gameplay Listeners are a feature of Aero Engine added to reduce `if` and `switch` usage in update, stepHit, beatHit, etc. Gameplay Listeners use FlxSignal to allow you to run code on specific events. Instead of running an `if` every frame to run code, you can run `if` only once to add code to the update event. All listeners are listed below, along with their returns and variable names in [here](/source/backend/GameplayEvents.hx)

Every time a note is hit - returns the hit note - `NOTE_HIT`
Every time a note is missed - returns the missed note - `NOTE_MISS`
Every time a beat is hit - returns curBeat - `CONDUCTOR_BEAT`
Every time a step is hit - returns curStep - `CONDUCTOR_STEP`
Every time `update` is run - returns elapsed - `GAME_UPDATE`
Every time the game has been paused or resumed - returns true for pause, false for resumes - `GAME_PLAYUPDATE`

Events are automatically removed when PlayState is reset. If events are not being deleted, you may be adding them after its been reset, or deleted the line that calls `GameplayEvents.init`