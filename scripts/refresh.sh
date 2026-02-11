#!/usr/bin/env bash

while true; do
  TAB=$(curl -s http://localhost:9223/json | jq -r '.[] | select(.url | contains("nrk.no")) | .webSocketDebuggerUrl' | head -n1)

  [ -z "$TAB" ] && exit 1

  echo '{"id":1,"method":"Page.reload","params":{"ignoreCache":true}}' | websocat -1 "$TAB"
  sleep 5
  notify-send "refreshing" "$TAB"
done




# # Start chrome with remote debugging
# chrome --remote-debugging-port=9222
#
# # find open tabs
# curl http://localhost:9222/json
#
# # find the weSocketDebugURL from the curl response
# "webSocketDebuggerUrl": "ws://localhost:9222/devtools/page/51924214B605A52099F172304C5F59DE"
#
# # run command to refresh
# echo '{"id":1,"method":"Page.reload","params":{"ignoreCache":true}}' | websocat -1 ws://localhost:9223/devtools/page/5044DD38FCA34D51A6C2D42A2F64F877
#
#
# #!/usr/bin/env bash
#
# TAB=$(curl -s http://localhost:9222/json | jq -r '.[] | select(.url | contains("nrk.no")) | .webSocketDebuggerUrl' | head -n1)
#
# [ -z "$TAB" ] && exit 1
#
# echo '{"id":1,"method":"Page.reload","params":{"ignoreCache":true}}' | websocat -1 "$TAB"
