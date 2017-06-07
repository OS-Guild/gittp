defmodule Gittp.Cache do
  require Logger

  def start_link(repo_path) do
    Agent.start_link(fn -> files_in_dir("/", repo_path) end, [name: __MODULE__])
  end

  def refresh(repo_path) do
    put_files(files_in_dir("/", repo_path))
  end

  def files_in_dir(dir, repo_path) do
      repo_path
      |> Path.join(dir) 
      |> File.ls!
      |> Enum.filter(fn f -> f != ".git" end)
      |> Enum.reduce([], fn (f, acc) -> 
          file_path = Path.join([repo_path, dir, f])

          if File.dir? file_path do 
              Enum.concat(acc, files_in_dir(Path.join(dir, f), repo_path))
          else 
              [{Path.relative_to(file_path, repo_path), file_content(file_path)} | acc]
          end
        end)
      |> Map.new
  end

   defp file_content(path) do             
         content = File.read! path 
          %{"content" => content, 
            "checksum" => Gittp.Utils.hash_string(content), 
            "path" => path, 
            "isDirectory" => false}
    end

  def put_files(files) when is_map(files) do
    Agent.update(__MODULE__, fn _ -> files end)
  end

  def get_file_content(path) do
    Agent.get(__MODULE__, fn m -> Map.get(m, path) end)
  end 
end