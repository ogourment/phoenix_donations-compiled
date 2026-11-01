defmodule Mix.Tasks.Compile.BinaryPhoenixDonations do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "ebin/Elixir.PhoenixDonations.Cache.beam" =>
      "1400AD97C21EC6EC6FC802E72572C8A8780BF18957ADAE55091127CFCA1F11A9",
    "ebin/Elixir.PhoenixDonations.DeclarationSchema.beam" =>
      "792F45D90D2B3753602FC0F8826C7648862C1AE1CAE7967311FD4E8BCD6BCF98",
    "ebin/Elixir.PhoenixDonations.Declarations.beam" =>
      "DEA077135A35690EB74F90933DFC2436C95B3988B2888384FD0BB42EA9B60790",
    "ebin/Elixir.PhoenixDonations.Presentation.beam" =>
      "A1CB0D0AC271D69306CB28EA07CCDB23D0C0EB33129DF48E10F5D5C2E4DED206",
    "ebin/Elixir.PhoenixDonations.Provider.beam" =>
      "075237400FA76C061AED90C04453EE5D022C7535B5F902F1B5D5724422F4FE92",
    "ebin/Elixir.PhoenixDonations.Providers.Manifund.beam" =>
      "F56B6217893C3CD7728A15608BDAD07D9F58E8BE9847972A59D78DF9E0FBD569",
    "ebin/Elixir.PhoenixDonations.Snapshot.beam" =>
      "6AD1857976B2DADBE9E1CA6F4D7F12BC2ED97C78D7055DEA9E99474A8EDBBACE",
    "ebin/Elixir.PhoenixDonations.beam" =>
      "A0953E483C7D7F96A6FAF4E79A6BE92D1FEF978F4DFCE5A49897671DD2947C98",
    "ebin/phoenix_donations.app" =>
      "FCEFBAB96C7B8170EB0A47D1E06631A8DE3CF5783C7FC8D0979AD7ACAB5EB39C"
  }

  @impl true
  def run(_args) do
    series = Version.parse!(System.version()) |> Map.take([:major, :minor])

    unless series == %{major: 1, minor: 20} and System.otp_release() == "29" do
      Mix.raise("phoenix_donations requires a binary distribution for Elixir 1.20.x / OTP 29")
    end

    for {path, expected} <- @checksums do
      bytes = File.read!(Path.join(@root, path))

      unless Base.encode16(:crypto.hash(:sha256, bytes)) == expected do
        Mix.raise("phoenix_donations artifact checksum mismatch: #{path}")
      end

      if String.starts_with?(path, "ebin/") do
        target = Path.join(Mix.Project.compile_path(), Path.basename(path))
        File.mkdir_p!(Path.dirname(target))
        File.write!(target, bytes)
      end
    end

    {:ok, []}
  end
end

defmodule Compiled.PhoenixDonations.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_donations,
      version: "0.0.2",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_donations],
      deps: [{:ecto, "~> 3.13", [optional: true, runtime: false]}]
    ]
  end

  def application, do: []
end
