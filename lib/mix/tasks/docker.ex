defmodule Mix.Tasks.Docker do
  @moduledoc """
  Builds a docker image based on the release
  """

  @_DOCKERFILE """
FROM nifty/elixir
# FROM msaraiva/elixir
MAINTAINER John Doe <john@example.com>
ENV PORT 4000
EXPOSE 4000
ADD {{{NAME}}}.tgz /home
ENTRYPOINT /home/{{{NAME}}}/bin/{{{NAME}}} console
"""

  @_NAME "{{{NAME}}}"
  @_VERSION "{{{VERSION}}}"
  
  use Mix.Task
  import ReleaseManager.Utils
  
  def run(args) do
    if Mix.Project.umbrella? do
      config = [umbrella?: true]
      for %Mix.Dep{app: app, opts: opts} <- Mix.Dep.Umbrella.loaded do
        Mix.Project.in_project(app, opts[:path], config, fn _ -> do_run(args) end)
      end
    else
      do_run(args)
    end
  end

  defp do_run(args) do
    config = parse_args(args)
    config
    |> ensure_paths
    |> build_release
    |> tar_release
    |> create_dockerfile
    |> create_dockerimage
  end

  defp parse_args(_argv) do
    %{
            name: Mix.Project.config |> Keyword.get(:app) |> Atom.to_string
     }
  end

  defp ensure_paths(config) do
    # Ensure destination base path exists
    "docker/" |> File.mkdir_p!
    "rel/" |> File.mkdir_p!
    
    config
  end
  
  defp build_release(config) do
    info "Building docker image for #{config.name}"

    # Add minimal relx.config file
    File.write "rel/relx.config", "{include_erts, false}."
    # Do it
    Mix.Tasks.Release.run []
    
    config
  end

  defp tar_release(config) do
    tarfile = "docker/" <> config.name <> ".tgz"
    System.cmd "/bin/tar", ["zcvf", tarfile, "-C", "rel/", config.name]

    config
  end
  
  defp create_dockerfile(config) do
    # Generate the file
    contents = @_DOCKERFILE
    |> String.replace @_NAME, config.name

    # Write it 
    dest = "docker/Dockerfile"
    File.write dest, contents
    
    config
  end

  defp create_dockerimage(config) do
    System.cmd "/usr/bin/docker", ["build", "-t", config.name, "docker"]
    File.rm_rf! "docker"

    info "Docker image created successfully as '#{config.name}'."
    
    config
  end


  
end
