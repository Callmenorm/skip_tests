# SkipTests

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phoenix.server`

Once the phoenix server has been started. It will scan `./xml` for xml files every 5 minutes.
When it finds a file it will parse it and move the `RetailItem` nodes inside the `RetailsItems` node
into a map held by a GenServer process with the name of `SkipTests.Parse.Scheduler`.

The state of the GenServer process is a map with the filename as the key and the `RetailItems` map
as the value.

The `RetailItems` map maps between the `RetailItem` ItemNo attribute and the rest of the `RetailItem`
attributes.

Once the file is parsed and moved into the GenServer state, then the file is moved to the `./parsed_xml` directory.

There are many edge cases that are not handled and the process is synchronous and eager. I suspect that in a
production environment it would be worth spending the time to use GenStage or Flow to get lazy, asynchronous,
and parallel parsing. I've never done that so I didn't think I'd be able to do it in a couple of hours.

There are really only two files of interest, `./lib/Parse/scheduler.ex` and `./lib/Parse/xml.ex`. I setup a quick
Phoenix project because it provides a very nice way to get supervised applications running quickly.
