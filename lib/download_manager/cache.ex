defmodule DownloadManager.Cache do
  use Nebulex.Cache,
    otp_app: :download_manager,
    adapter: Nebulex.Adapters.Local
end
