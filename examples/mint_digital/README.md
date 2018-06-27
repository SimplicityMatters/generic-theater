# MintDigital

[https://medium.com/mint-digital/stateful-websockets-with-elixirs-genstage-a29eab420c0d]()

Lame usage:
* Open iex -S mix: `{_, pid} = MintDigital.join(:dummy)`
* Then quickly `Enum.map(["q","qu","que","quer","query"], &MintDigital.Query.update(pid, &1))`

The actual search, `Search.run`, halts for 0.5 seconds, and returns 'Exact{query}' if query's length > 3

Expected outcome is hard to say.  Often it will give 'q' and 'Exactquery'.  But if you waited more than the 3000 milliseconds to Query.update, you'll get 'q', 'qu', and 'Exactquery'.

You will get a warning everytime it discards an event from the buffer (there wasn't demand enough to run the search)

It saves the last thing you type as its 'produce'.  When it is given demand every 3 seconds, it always will process the last query, if any.

Relevant comments form Ed's wrap-up
* We would not currently handle a rate limit that needed to be shared across multiple clients;
* The GenStage processes are not supervised;

It also seems like a consumer starts w/ 1 demand, "q" is processed everytime I start this example up.  However, if I spam, eventually it ignores it.

I've also noticed that it accumulates demand forever; I believe due to a new entry in the map every second.