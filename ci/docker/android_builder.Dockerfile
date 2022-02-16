# We don't need the ndk so this image can be used
# instead of the big one for the verifai android sdk
FROM alvrme/alpine-android:android-31-jdk11
LABEL maintainer="Jeroen Oomkes <jeroen.oomkes@verifai.com>"
RUN apk add npm --no-cache && \
    npm install --global yarn