use Mix.Config

config :relay_service,
  relay_GPIOs: [
    internal_heater: 17,
    internal_cooler: 27,
    fermentor_1_heater: 22,
    fermentor_2_heater: 5
  ]
