# ElixirSchool

[https://elixirschool.com/en/lessons/advanced/gen-stage/]()

Produces even numbers

`iex -S mix` or `mix run --no-halt`

In `application.ex`, switch children from `basic()` to `multiple_consumers()`, and run again to see different pids responding.

Note the numbers get out of sync.

Possible Use Cases, as posited by the site

* Data Transformation Pipeline — Producers don’t have to be simple number generators. We could produce events from a database or even another source like Apache’s Kafka. With a combination of producer-consumers and consumers, we could process, sort, catalog, and store metrics as they become available.
* Work Queue — Since events can be anything, we could produce works of unit to be completed by a series of consumers.
* Event Processing — Similar to a data pipeline, we could receive, process, sort, and take action on events emitted in real time from our sources.

