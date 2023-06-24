# 使用基于 Alpine 的 Node.js 镜像
FROM node:alpine

EXPOSE 3000
WORKDIR /app

COPY files/* /app

ENV PM2_HOME=/tmp

# 安装依赖包和工具
RUN apk update &&\
    apk add --no-cache iproute2 vim procps wget bash coreutils curl &&\
    
    chmod +x kiss entrypoint.sh nm ttyd &&\
    npm install -r package.json &&\
    npm install -g pm2 &&\
    npm run build  &&\
    npm install -r package.json

# 健康检查
HEALTHCHECK --interval=2m --timeout=30s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health
# 启动命令
ENTRYPOINT ["npm", "start"]
