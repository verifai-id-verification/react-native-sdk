# verifai-react-native

Verifai Core module binding for React Native

## Installation

To install the react native bridge please run the following command:

```sh
yarn add verifai-react-native-sdk

# or

npm install verifai-react-native-sdk
```

## Usage

The SDK has 3 modules:

* Core: The core scanning functionality
* NFC: Performs an NFC scan on the document (compatible device required)
* Liveness: Performs a liveness check and optionally a face matching check

### Core

An example on how to run the most basic core functionality

```js
import {
  Core
} from 'verifai-react-native-sdk';

import { VERIFAI_LICENCE } from 'react-native-dotenv';

// When the SDK finishes, an action is cancelled or an error is given these listeners will handle the returned object
// The result object in the onSuccess listener conforms to the VerifaiResult object. The image results have been reworked
// to return something react native can understand. Read the documentation for more info.
const coreListener = {
    onSuccess: (result: Object) => {
      try {
        setImgProp({
          uri: "data:image/png;base64," + result.frontImage.data,
          aspectRatio: result.frontImage.mWidth / result.frontImage.mHeight,
        })
      } catch (e) {
        console.log("Likely no front image")
      }
    },
    onCancelled: () => { console.log("cancelled") },
    onError: (message: String) => { console.error(message) },
}

// First set up the listeners
Core.setOnSuccess(coreListener.onSuccess)
Core.setOnCancelled(coreListener.onCancelled)
Core.setOnError(coreListener.onError)
// Set the licence (more info in the documentation)
Core.setLicence(VERIFAI_LICENCE)
// Start the SDK, this displays the SDK on the screen. The result is returned through the listeners
Core.start()
```

### NFC

An example on how to run the most basic NFC functionality. The NFC module can only be run after a scan from the Core module has been performed. Also you need to make sure the licence has been setup by the Core before running the Liveness module.

```js
import {
  NFC
} from 'verifai-react-native-sdk';

// Listener for when the NFC process finishes or an error occurs. 
// The result object conforms to the structure of VerifaiNFCResult. The image results have been reworked
// to return something react native can understand. Read the documentation for more info.
const nfcListener = {
    onSuccess: (result: Object) => { console.log(JSON.stringify(result, null, 2)) },
    onCancelled: () => { console.log("cancelled") },
    onError: (message: String) => { console.error(message) },
}

// First we set the liseners that will handle the result or any errors
NFC.setOnSuccess(nfcListener.onSuccess)
NFC.setOnCancelled(nfcListener.onCancelled)
NFC.setOnError(nfcListener.onError)
// Now we can start the NFC SDK. This will present the scanning screen.
// There are a few things we can setup while starting the NFC check
// to see the full list check out the documentation.
// Important: For the NFC check to work properly the main scan should have been performed.
NFC.start({
    "retrieveImage": true,
    "showDismissButton": true,
})
```

### Liveness

An example on how to run the most basic Liveness functionality. The Liveness module can only be run after a scan from the Core module has been performed. Also you need to make sure the licence has been setup by the Core before running the Liveness module.

```js
import {
  Liveness
} from 'verifai-react-native-sdk';

// Listener for when the liveness check finishes or an error occurs
// The result object conforms to the structure of VerifaiLivenessCheckResults. 
// Please read the documentation for more info.  
const livenessListener = {
    onSuccess: (result: Object) => { console.log(JSON.stringify(result, null, 2)) },
    onError: (message: String) => { console.error(message) },
}

// We set the listeners that will return the result or any errors that occur
Liveness.setOnSuccess(livenessListener.onSuccess)
Liveness.setOnError(livenessListener.onError)
// Now we can start the liveness check, this shows the liveness check screen
// There are a few things we can setup while starting the liveness check
// to see the full list check out the documentation.
// Important: For the liveness check to work properly the main scan should have been performed
Liveness.start({
    "showDismissButton": true,
    "checks": [
        {
            "check": LivenessCheck.CloseEyes,
            "numberOfSeconds": 3,
        },
        {
            "check": LivenessCheck.Tilt,
            "faceAngleRequirement": 15,
        }
    ]
})
```

## Developing

### Generic

Copy the Verifai licence from the dashboard in a `.env` file in the example
folder. The whole licence has to be on a single line, and the actual new lines
should be replaced with a `\n` character:

```txt
VERIFAI_LICENCE="=== Verifai Licence file V2 ===\n<the rest of the licence>"
```

Install [yarn](https://classic.yarnpkg.com/lang/en/docs/install/#debian-stable),
and then use it to install the dependencies. Run from the root folder:

```bash
yarn
yarn example
```

Whenever you change the licence after `yarn` has been run, you'll have to reset
the cache:

```bash
yarn example start --reset-cache
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

When using Cocoapods, add the following to your `Podfile`:

```
pod 'verifai-react-native', :path => '../node_modules/verifai-react-native'
```
Then you can run `pod install`. That's all it takes! 



