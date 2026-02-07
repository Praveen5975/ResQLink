#include <WiFi.h>
#include <WebServer.h>

const char* ssid = "ResQ";
const char* password = "12345678";

IPAddress local_IP(192,168,4,2);
IPAddress gateway(192,168,4,2);
IPAddress subnet(255,255,255,0);

WebServer server(80);
String lastSOS = "No SOS yet";

void handleRoot() {
  String page =
    "<html><head><meta http-equiv='refresh' content='2'></head>"
    "<body style='font-family:Arial;'>"
    "<h1>ResQ Dashboard</h1>"
    "<h3>Status:</h3>"
    "<p>" + lastSOS + "</p>"
    "</body></html>";
  server.send(200, "text/html", page);
}

void handleSOS() {
  IPAddress ip = server.client().remoteIP();
  lastSOS = "🚨 SOS received from Node IP: " + ip.toString();
  Serial.println(lastSOS);
  server.send(200, "text/plain", "SOS RECEIVED");
}

void setup() {
  Serial.begin(115200);

  WiFi.mode(WIFI_AP);
  WiFi.softAPConfig(local_IP, gateway, subnet);
  WiFi.softAP(ssid, password);

  Serial.print("ESP32 AP IP: ");
  Serial.println(WiFi.softAPIP());

  server.on("/", handleRoot);
  server.on("/sos", handleSOS);
  server.begin();
}

void loop() {
  server.handleClient();
}
