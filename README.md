Calliandra
==========

Interactive flight route planner and connection map. Written as a SwiftUI desktop app exercise.
<img src="docs/preview.png" width="850" alt="App screenshot">

Build prerequisites
-------------------

`airports.json` and `flights.json` required for this app to work.

```sh
./build_airports.py
```

To use
------

Use the sidebar route planner to build a route from airport codes. Enter an airport code and press Return or click Add to append it to the route.

You can also click an airport on the map to open its detail popup, then use Add to Route to append that airport.

Route stops can be removed, reordered with drag and drop, or cleared. Airports may be revisited more than once, but each entered code must be a known airport in the static airport data.

The map shows the planned route and known connections from the selected airport. Mileage is calculated from either known TPMs or great-circle estimates.

License
-------

© Poren Chiang 2025, released under [BSD-3 License](https://opensource.org/license/bsd-3-clause).
