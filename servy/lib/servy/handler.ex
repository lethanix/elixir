defmodule Servy.Handler do
  def handle(request) do
    request 
    |> parse 
    |> route 
    |> format_response
  end

  def parse(request) do
    # TODO: Parse the request string into a map:
    conv = %{method: "GET", path: "/services", resp_body: ""}
  end

  def route(conv) do
    # TODO: Create a new map that also has the response body:
    conv = %{method: "GET", path: "/services", resp_body: "Lambda, SQS, S3"}
  end

  def format_response(conv) do
    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Lambda, SQS, S3
    """
  end
end

request = """
GET /services HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
