# verifai-core-react-native

Verifai Core module binding for React Native

## Installation

```sh
npm install verifai-react-native-sdk
```

## Usage

```js
import {
  Core, Liveness, NFC,
  LivenessCheck,
  VerifaiInstructionScreenId,
  VerifaiInstructionType
} from 'verifai-react-native-sdk';

Core.configure({
  "enableVisualInspection": true,
  "instructionScreenConfiguration": {
  "showInstructionScreens": false,
  },
  "extraValidators": [
    {
      "type": "VerifaiDocumentCountryWhitelistValidator",
      "countryList": [
        "NL"
      ]
    }
  ]
})
Core.setOnSuccess(coreListener.onSuccess)
Core.setOnCancelled(coreListener.onCancelled)
Core.setOnError(coreListener.onError)
Core.start(VERIFAI_LICENCE)
```

## Developing

### Generic

First install dependencies, in root folder run:

```bash
yarn
```

### Android

First create a develop environment with the needed variables. The following
script can be used to configure this. Please edit the ANDROID_HOME path
according to your local installation. NVM is used to set the correct node
version to 12, which is the supported react native version at this moment of
writing. It might be handy to add an alias for this script in your `.bashrc`.

```bash
#!/bin/bash

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

echo "set android sdk env variable and configure the PATH:"
echo "ANDROID_HOME=$ANDROID_HOME"
nvm use 12
```

Start Metro javascript server:

```bash
yarn example start
```

Launch a new terminal (with the dev env) and install the native part of the
module:

```bash
yarn example android
```

For developing with android studio, make sure that the environment variables are
set, by launching `android-studio` from the terminal with the develop
environment ready.

### iOS

TODO
