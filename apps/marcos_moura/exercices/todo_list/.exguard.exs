use ExGuard.Config

guard("unit-test", run_on_start: true)
  |> command("mix test --color")
  |> watch(~r{\.(erl|ex|exs|eex|xrl|yrl)\z}i)
  |> ignore(~r{deps})
  |> notification(:auto)
