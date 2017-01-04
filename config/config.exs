# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :metex, owm_url: "http://api.openweathermap.org/data/2.5/weather"

import_config "#{Mix.env}.exs"
