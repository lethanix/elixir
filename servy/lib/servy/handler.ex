defmodule Servy.Handler do
  def handle(request) do
    request 
    |> parse 
    |> log
    |> route 
    |> format_response
  end

  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _ ] = 
      request 
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{method: method, path: path, status: nil, resp_body: ""}
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  def route(conv, "GET", "/compute") do
    %{ conv | status: 200, resp_body: "Lambda, EC2" }
  end

  def route(conv, "GET", "/messaging") do
    %{ conv | status: 200, resp_body:  "SQS, SNS, MQ "}
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

