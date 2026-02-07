FROM node:current-slim

WORKDIR /usr/src/app

COPY . .

RUN npm install -g bun

RUN bun install 
RUN apt-get update -y && apt-get install -y openssl
EXPOSE 3000 

CMD ["sh", "-c", "bunx prisma migrate deploy && bun run index.ts"]