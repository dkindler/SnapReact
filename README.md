# Snap React
The following is a feature concept I have created for my job application to Snap Inc.
This demonstration app is less a guide on how the proposed feature should be implemented, and more a prototype to display the fun and excitement that reactions could bring to Snapchat.

### Concept
Snap React is a proposed feature that would allow the sender of a snap to see their recipients raw emotion and reaction as they open up their snap. I considered many ways in which to go about prototyping Snap React, and came up with the following implementation. The feature works as follows:

  1. The sender takes a snap video/photo
  2. The sender selects the option to request reactions to his/her snap and then sends the snap to selected recipients
  3. The recipient receives the snap with an indication that opening the snap will take a reaction video via the front-facing camera
  4. Once the recipient opens the snap, a video is taken of the recipient via the front-facing camera
  5. After the recipient is done viewing the snap, they will be brought to a view where they can review their reaction and determine whether or not to share it with the sender

### Background
I came up with this concept through my own snaps. I love to make people laugh with my stories, and would constantly have friends come to me and say something along the lines of "that snap you posted of Bryce last night was hilarious!". All I could think was that I wish I was there when they opened the snap to share the laugh with them. Snap React gives you authentic reactions to shareable moments.

### Concerns & Considerations
While coming up with ways to implement Snap React there were several points of concern I considered:
 1. The reactor should be notified that they are about to be recorded.
 2. The reactor ultimately decides whether or not a reaction is sent back to the sender.
 3. The reaction should happen the very first time the reactor opens the snap. This will produce authentic reactions that will be more enjoyable to both the recipient and the sender.

### Current Implementation Issues
 1. Before opening a snap react we must wait until the camera is ready to record. This causes a delay. I accounted for this by immediately displaying the snap while covering it with a `UIBlurEffectView` until the front-facing camera is ready to record.
 2. When reacting to a video snapchat, audio from the snap is overbearing. We may want to consider some sort of noise-canceling algorithm to reduce, but not remove, audio from original snap.
 3. Snap React does not seem to be too compatible with stories in its current implementation.
 4. Recipients should have the option to deny reacting to a Snap React, but still be able to open up the snap. This could potentially be accomplished by a gesture recognizer (E.g. 3d tapping a snap cell.)
 5. By alerting the recipient that the snap they are receiving is a Snap React, we may reduce the naturalness of reactions across the board. However, I do believe that it is worth the loss. A survey of a few friends provided some anecdotal evidence (that I could have guessed myself) that users will feel extremely uncomfortable being recorded without being told. My guess is that  Snapchat users will feel the same.

### Alternative Implementations
One implementation I considered was always recording recipients responses while opening snaps, and having the recipient do some sort of gesture (E.g. double tap) when they'd like to see their reaction or would like to share their reaction with the sender. Although I do think this implementation would be interesting and seamless, my biggest concern was privacy. As stated previously, I do not believe users would be comfortable knowing that they are being recorded every time they open up a snap.

### Disclaimer
I have no affiliation with Snap Inc. or any of its products. Snap Inc., Snapchat, and all other Snap Inc. product names are trademarks or registered trademarks of Snap Inc.
