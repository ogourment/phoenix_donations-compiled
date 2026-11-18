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
      "8934B2535EB3EEEC7F9CD92B303F8FD2B797166D547CDC3CFC88F9216036BC63",
    "ebin/Elixir.PhoenixDonations.Presentation.beam" =>
      "846F448F3505CB9E1DF867C3AD68781F72D1C854B27DEC06FE2B99404BAFB3BB",
    "ebin/Elixir.PhoenixDonations.Provider.beam" =>
      "075237400FA76C061AED90C04453EE5D022C7535B5F902F1B5D5724422F4FE92",
    "ebin/Elixir.PhoenixDonations.Providers.Manifund.beam" =>
      "7054AE39ED5C302E78A73A1EB4D7E85FE9C90A27D777EECBC95EA5E58AAE0FF3",
    "ebin/Elixir.PhoenixDonations.Snapshot.beam" =>
      "3038B6B3C0BA693B1767BE776E1B457DF22F2451724C2443099CD7146E6486F2",
    "ebin/Elixir.PhoenixDonations.beam" =>
      "A0953E483C7D7F96A6FAF4E79A6BE92D1FEF978F4DFCE5A49897671DD2947C98",
    "ebin/phoenix_donations.app" =>
      "6551E240C5CC4E0285DA5F94A0CD8EABB9A102D93A19CA7CFE57496158D758F2"
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
      version: "0.0.4",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_donations],
      deps: [{:ecto, "~> 3.13", [optional: true, runtime: false]}]
    ]
  end

  def application, do: []
end
