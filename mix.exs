defmodule Mix.Tasks.Compile.BinaryPhoenixDonations do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "ebin/Elixir.PhoenixDonations.Cache.beam" =>
      "1400AD97C21EC6EC6FC802E72572C8A8780BF18957ADAE55091127CFCA1F11A9",
    "ebin/Elixir.PhoenixDonations.Presentation.beam" =>
      "846F448F3505CB9E1DF867C3AD68781F72D1C854B27DEC06FE2B99404BAFB3BB",
    "ebin/Elixir.PhoenixDonations.Provider.beam" =>
      "075237400FA76C061AED90C04453EE5D022C7535B5F902F1B5D5724422F4FE92",
    "ebin/Elixir.PhoenixDonations.Providers.Manifund.beam" =>
      "F56B6217893C3CD7728A15608BDAD07D9F58E8BE9847972A59D78DF9E0FBD569",
    "ebin/Elixir.PhoenixDonations.Snapshot.beam" =>
      "3038B6B3C0BA693B1767BE776E1B457DF22F2451724C2443099CD7146E6486F2",
    "ebin/Elixir.PhoenixDonations.beam" =>
      "A0953E483C7D7F96A6FAF4E79A6BE92D1FEF978F4DFCE5A49897671DD2947C98",
    "ebin/phoenix_donations.app" =>
      "E744CAB263D276D3FA4920971EF80A5AF923F9D3B0BA8BFB7A3403C4A4A401A2"
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
      version: "0.0.1",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_donations],
      deps: []
    ]
  end

  def application, do: []
end
