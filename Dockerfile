FROM node:18-alpine

# Uncomment this line if you want to have some vulnerabilities in your Docker image.
RUN apk update && apk upgrade

WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

COPY .next/static ./.next/static
COPY .next/standalone ./
COPY ./public ./public

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
RUN chown nextjs:nodejs ./ --recursive
USER nextjs

EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]
