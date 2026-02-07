#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

const char* ssid = "ResQ";
const char* password = "12345678";
const char* esp32IP = "192.168.4.2";

ESP8266WebServer server(80);

void handleRoot() {
  String page =
    "<html><body style='text-align:center;font-family:Arial;'>"
    "<h2>ResQ Node</h2>"
    "<form action='/sos'>"
    "<button style='font-size:22px;padding:15px;'>SEND SOS</button>"
    "</form>"
    "</body></html>";
  server.send(200, "text/html", page);
}

void handleSOS() {
  WiFiClient client;
  if (client.connect(esp32IP, 80)) {
    client.print(
      "GET /sos HTTP/1.1\r\n"
      "Host: 192.168.4.2\r\n"
      "Connection: close\r\n\r\n"
    );
  }
  server.send(200, "text/html", "<h3>✅ SOS SENT</h3>");
}

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) delay(500);

  Serial.print("ESP8266 IP: ");
  Serial.println(WiFi.localIP());

  server.on("/", handleRoot);
  server.on("/sos", handleSOS);
  server.begin();
}

void loop() {
  server.handleClient();
}
