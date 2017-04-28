defmodule Gittp.Cache do
  def start_link(repo_path) do
    File.ls! repo_path 
    |> Enum.map(fn f -> %{:name => f, :is_dir => File.dir? f} end)
    |>  
    Agent.start_link(fn -> %{} end, [name: __MODULE__])
  end

  def files_in_dir(dir, repo_path) do
      dir 
      |> File.ls!
      |> Enum.filter(fn f -> f != ".git" end)
      |> Enum.map(fn f -> if File.dir?(f) do 
                            files_in_dir(f, repo_path)
                          else 
                            full_name = dir |> Path.join(f) |> Path.relative_to(repo_path)
                            {full_name, full_name}
                          end
                  end)
      |> Enum.flat_map(fn f -> case f do
                                [_ | _] -> f
                                _ -> [f]
                               end
                        end)
      |> Map.new
  end

  def put_files(files) when is_map(files) do
    Agent.update(__MODULE__, fn _ -> files end)
  end

  def get_file_content(path) do
    Agent.get(__MODULE__, fn m -> Map.get(m, path) end)
  end 
end