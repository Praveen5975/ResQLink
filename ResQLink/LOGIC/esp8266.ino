#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
bool lastButtonState = HIGH;   // button released initially


const char* ssid = "ResQ";
const char* password = "12345678";

// Your specific Field Node IP
IPAddress local_IP(192, 168, 4, 3);
IPAddress gateway(192, 168, 4, 2);
IPAddress subnet(255, 255, 255, 0);

ESP8266WebServer server(80);

#define BUTTON_PIN D2
#define LED_PIN D1

// 100% Offline HTML Theme
const char index_html[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>RescueMesh SOS | Node-02</title>
  <style>
    * { box-sizing: border-box; font-family: system-ui, -apple-system, sans-serif; }
    body { margin: 0; min-height: 100vh; background: radial-gradient(circle at top, #1e3a8a, #020617); color: #ffffff; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; }
    header h1 { font-size: 28px; font-weight: 700; margin-bottom: 6px; }
    header p { font-size: 14px; color: #c7d2fe; margin-bottom: 20px; }
    .card { background: #020617; width: 90%; max-width: 360px; padding: 28px; border-radius: 22px; box-shadow: 0 25px 50px rgba(0,0,0,0.6); border: 1px solid #1e3a8a; }
    .sos-icon { font-size: 60px; margin-bottom: 20px; animation: shake 1.2s infinite; }
    @keyframes shake { 0%, 100% { transform: rotate(0deg); } 25% { transform: rotate(-6deg); } 75% { transform: rotate(6deg); } }
    .sos-btn { width: 100%; padding: 20px; font-size: 22px; font-weight: 900; border: none; border-radius: 18px; cursor: pointer; color: white; background: linear-gradient(90deg, #ef4444, #dc2626, #b91c1c); box-shadow: 0 0 20px rgba(239,68,68,0.5); animation: pulse 1.6s infinite; }
    @keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(239,68,68,0.7); } 70% { box-shadow: 0 0 0 15px rgba(239,68,68,0); } 100% { box-shadow: 0 0 0 0 rgba(239,68,68,0); } }
    .log { margin-top: 22px; padding: 14px; font-size: 13px; background: #0f172a; border: 1px solid #1e293b; border-radius: 12px; color: #94a3b8; min-height: 44px; }
    footer { margin-top: 26px; font-size: 11px; color: #64748b; text-transform: uppercase; letter-spacing: 1px; }
  </style>
</head>
<body>
  <header>
    <h1>RescueMesh SOS</h1>
    <p>Field Node (192.168.4.3)</p>
  </header>
  <div class="card">
    <div class="sos-icon">🚨</div>
    <button class="sos-btn" onclick="sendSOS()">SEND SOS</button>
    <div class="log" id="logText">System idle. Standby mode.</div>
  </div>
  <footer>Offline-First Emergency Transmission</footer>
  <script>
    function sendSOS() {
      const log = document.getElementById("logText");
      log.innerText = "TRANSMITTING PACKET...";
      log.style.color = "#fbbf24";
      fetch('/sos').then(response => {
        if(response.ok) {
          log.innerText = "🚨 SOS BROADCAST SUCCESSFUL";
          log.style.color = "#22c55e";
          setTimeout(() => { 
            log.innerText = "System idle. Awaiting trigger."; 
            log.style.color = "#94a3b8";
          }, 4000);
        }
      }).catch(err => {
        log.innerText = "FAILED TO REACH GATEWAY";
        log.style.color = "#ef4444";
      });
    }
  </script>
</body>
</html>
)rawliteral";

void sendSOS() {
  // Instant visual feedback
  digitalWrite(LED_PIN, HIGH);

  WiFiClient client;
  if (client.connect("192.168.4.2", 80)) {
    client.print(
      "GET /sos HTTP/1.1\r\n"
      "Host: 192.168.4.2\r\n"
      "Connection: close\r\n\r\n"
    );
    client.stop();
  }

  // very short pulse (human‑visible but instant)
  delay(150);
  digitalWrite(LED_PIN, LOW);
}


void handleRoot() {
  server.send(200, "text/html", index_html);
}

void handleWebSOS() {
  sendSOS();
  server.send(200, "text/plain", "SOS SENT");
}

void setup() {
  Serial.begin(115200);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  // Connection logic to your ResQ AP
  WiFi.config(local_IP, gateway, subnet);
  WiFi.begin(ssid, password);
  
  Serial.print("Connecting to ResQ Mesh");
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
    Serial.print(".");
  }
  Serial.println("\nNode Ready at 192.168.4.3");

  server.on("/", handleRoot);
  server.on("/sos", handleWebSOS);
  server.begin();
}

void loop() {
  server.handleClient();

  bool currentButtonState = digitalRead(BUTTON_PIN);

  // Detect ONE press only (HIGH → LOW)
  if (lastButtonState == HIGH && currentButtonState == LOW) {
    sendSOS();   // 🔔 single trigger
  }

  lastButtonState = currentButtonState;
}


