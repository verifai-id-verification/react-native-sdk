FROM node:17-alpine
LABEL maintainer="Jeroen Oomkes <jeroen.oomkes@verifai.com>"
RUN apk add git --no-cache
CMD ["/bin/ash"]