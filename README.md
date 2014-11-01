# Kickr

Kickr allows players to arrange a match of “[kicker](http://en.wikipedia.org/wiki/Table_football)”. It uses WebSockets ([socket.io](http://socket.io)) to keep players in sync and has a responsive interface, making it usable on both desktop and mobile devices.

When four players have joined a table, all of them will receive a notification. When available, the browser’s [notification API](http://www.w3.org/TR/notifications/) will be used, otherwise a simple alert will be triggered.

[Try it out live!](https://kickr-sample.herokuapp.com)

## How to use

1. Install [Node.js](http://nodejs.org), then clone the repository and install dependencies.
2. Provide an environment variable `KICKR_TABLES` with a comma-separated list of table names (default is `1,2,3`).
3. Running `npm start` precompiles assets and launches the server.

Example:

    git clone https://github.com/sklppr/kickr && cd kickr
    npm install
    KICKR_TABLES="one,two,three" && npm start

Kickr is also ready to be deployed to **Heroku**.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/sklppr/kickr)

Foosball icon designed by [Joe Harrison](http://www.thenounproject.com/joe_harrison) from the [Noun Project](http://www.thenounproject.com).
