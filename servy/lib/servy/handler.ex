defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_compute_path
    |> rewrite_messaging_id_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def log(conv), do: IO.inspect(conv)

  def rewrite_compute_path(%{path: "/cloudcompute"} = conv) do
    %{conv | path: "/compute"}
  end

  def rewrite_compute_path(conv), do: conv

  def rewrite_messaging_id_path(%{path: "/messaging?id=" <> id} = conv) do
    %{conv | path: "/messaging/#{id}"}
  end

  def rewrite_messaging_id_path(conv), do: conv

  def track(%{status: 404, path: path} = conv) do
    IO.puts("WARN: #{path} is not a known service category")
    conv
  end

  def track(conv), do: conv

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, status: nil, resp_body: ""}
  end

  def route(%{method: "GET", path: "/compute"} = conv) do
    %{conv | status: 200, resp_body: "Lambda, EC2"}
  end

  def route(%{method: "GET", path: "/messaging"} = conv) do
    %{conv | status: 200, resp_body: "SQS, SNS, MQ"}
  end

  def route(%{method: "GET", path: "/messaging/" <> id} = conv) do
    %{conv | status: 200, resp_body: "/messaging/#{id}"}
  end

  def route(%{method: "DELETE", path: "/messaging/" <> id} = conv) do
    %{conv | status: 403, resp_body: "Deleting a messaging service is forbidden"}
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "Nothing in there"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_code(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_code(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

request = """
GET /messaging HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /compute HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /lost HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
DELETE /messaging/3 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)

request = """
GET /messaging?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
