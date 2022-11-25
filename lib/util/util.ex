defmodule Burrito.Util do
  @spec get_current_os :: :darwin | :linux | :windows
  def get_current_os do
    case :os.type() do
      {:win32, _} -> :windows
      {:unix, :darwin} -> :darwin
      {:unix, :linux} -> :linux
    end
  end

  @spec get_libc_type :: :glibc | :musl | nil
  def get_libc_type do
    if get_current_os() != :linux do
      nil
    else
      {result, _} = System.cmd("ldd", ["--version"])

      cond do
        String.contains?(result, "musl") -> :musl
        true -> :glibc
      end
    end
  end

  def get_current_cpu do
    arch_string =
      :erlang.system_info(:system_architecture)
      |> to_string()
      |> String.downcase()
      |> String.split("-")
      |> List.first()

    case arch_string do
      "x86_64" -> :x86_64
      "arm64" -> :arm64
      "aarch64" -> :aarch64
      "arm" -> :arm
      _ -> :unknown
    end
  end

  @spec get_otp_version :: String.t()
  def get_otp_version() do
    {:ok, opt_version} =
      :file.read_file(
        :filename.join([
          :code.root_dir(),
          "releases",
          :erlang.system_info(:otp_release),
          "OTP_VERSION"
        ])
      )

    String.trim(opt_version)
  end
end
