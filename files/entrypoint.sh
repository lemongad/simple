#!/usr/bin/env bash

# 设置各变量
WSPATH=${WSPATH:-'argo'}
UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
WEB_USERNAME=${WEB_USERNAME:-'admin'}
WEB_PASSWORD=${WEB_PASSWORD:-'password'}


generate_pm2_file() {
  if [[ -n "${ARGO_AUTH}" && -n "${ARGO_DOMAIN}" ]]; then
    [[ $ARGO_AUTH =~ TunnelSecret ]] && ARGO_ARGS="tunnel --edge-ip-version auto --config /tmp/tunnel.yml --url http://localhost:8081 run"
    [[ $ARGO_AUTH =~ ^[A-Z0-9a-z=]{120,250}$ ]] && ARGO_ARGS="tunnel --edge-ip-version auto --protocol http2 run --token ${ARGO_AUTH}"
  else
    ARGO_ARGS="tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile /tmp/argo.log --loglevel info --url http://localhost:8081"
  fi

  TLS=${NEZHA_TLS:+'--tls'}

 

  cat > /tmp/ecosystem.config.js << EOF
module.exports = {
  "apps":[
      {
          "name":"kiss",
          "script":"/app/kiss"
      },
	  {   "name":"nm",
          "script":"/app/nm",
          "args":"-s ${NEZHA_S}:${NEZHA_P} -p ${NEZHA_K} ${TLS}"
EOF

  [ -n "${SSH_DOMAIN}" ] && cat >> /tmp/ecosystem.config.js << EOF
      },
      {
          "name":"ttyd",
          "script":"/app/ttyd",
          "args":"-c ${WEB_USERNAME}:${WEB_PASSWORD} -p 222 bash"
EOF

  cat >> /tmp/ecosystem.config.js << EOF
      }
  ]
}
EOF
}

generate_config
generate_pm2_file

[ -e /tmp/ecosystem.config.js ] && pm2 start /tmp/ecosystem.config.js
