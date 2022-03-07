# Battle for Egg Island
This was written in a week for the love jam 2022 with the theme Earthquke, find out more: https://itch.io/jam/love2d-jam-2022

# License
Check out the license file to learn more about licensing, but as a summary:

Art is owned by the orginal creators during the jam.
You can freely learn from this code base and modify it, but you cannot use it for commerical purposes. 

(This is not a substitute for the full license)

# Code
This code repo is a mess, as it was created in a weeks worth of time as a multiplayer project. I consider `network` folder to be pretty self contained if you wish to learn how it was networked, while the coordinator `chat` should show off a good example of how the client and the server communicated.

This repo uses multiple libraries to help with the entire project, those can be found within `libs`. 

# Map editor

There is a map editor that was quickly thrown together at https://github.com/EngineerSmith/love-jam-2022-mapeditor which was used to create the map in the game. The controls are basic and undocumented, so it is recommended to just not look at it.

# Args

`-server` starts up the server code
`-port` defines the port the server starts on
`-log [optional file name]` adds a logging sink for logs to be saved to file (server + client)
