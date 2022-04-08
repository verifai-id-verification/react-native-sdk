# Verifai react-native-sdk

## Table of contents

- [Verifai react-native-sdk](#verifai-react-native-sdk)
  - [Table of contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Install Verifai](#install-verifai)
    - [Add licence](#add-licence)
    - [Android](#android)
    - [iOS](#ios)
  - [Usage](#usage)
    - [Core](#core)
    - [NFC](#nfc)
    - [Liveness](#liveness)
  - [Customization](#customization)
    - [Core settings](#core-settings)
    - [Core - Instruction screens](#core---instruction-screens)
    - [NFC - Instruction screens](#nfc---instruction-screens)
    - [Scan help](#scan-help)
    - [Validators](#validators)
    - [Document Filters](#document-filters)
    - [Liveness checks](#liveness-checks)
  - [Support](#support)

## Getting started

If you are new to React Native and want to start a new project, the official
[React Native](https://reactnative.dev/docs/environment-setup) docs explain how
to setup your develop environment. The Verifai sdk uses native modules which
means the React Native CLI Quickstart has to be used, Expo is not possible.

### Install Verifai

To integrate the sdk in your project, install it from npm with:

```sh
yarn add @verifai/react-native-sdk
# or
npm install @verifai/react-native-sdk
```

### Add licence

The Verifai SDK does not work without a valid licence. The licence can be copied
from the dashboard, and has to be set with the `Core.setLicence` method, see
[usage](#core).

An easy way to store the licence and keep it outside version control, is to copy
it in a local `licence.js` file next to your `App.js`. Add `licence.js` to
your `.gitignore` file. It can look approximately like this:

```js
export const licence = `=== Verifai Licence file V2 ===
...
`
```

Then import the licence variable in your `App.js` like this:

```js
import { licence } from './licence';
```

### Android

In order for the sdk to find the native Android libraries add the Verifai maven
repository in your root `build.gradle` file:

```groovy
allprojects {
    repositories {
        maven { url 'https://dashboard.verifai.com/downloads/sdk/maven/' }
    }
}
```

To avoid conflicts between native android runtime libraries, add the
`packagingOptions` code snippet in the `build.gradle` file of your app, not in
the root!

```groovy
android {
    packagingOptions {
        jniLibs {
            pickFirsts += ['**/*.so']
        }
    }
}
```

If you run into memory errors during the build of your app, uncomment (or if it
is not there add) the following line in your gradle.properties file:

```ini
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
```

### iOS

When using Cocoapods, add the following to your `Podfile`:

```shell
pod 'VerifaiNFC', :podspec => '../node_modules/@verifai/react-native-sdk/VerifaiNFC.podspec'
pod 'verifai-react-native', :path => '../node_modules/@verifai/react-native-sdk'
```

Afterwards you can run `pod install`. That's all it takes!

## Usage

The SDK has 3 modules:

- Core: The core scanning functionality
- NFC: Performs an NFC scan on the document (compatible device required)
- Liveness: Performs a liveness check and optionally a face matching check

### Core

An example on how to run the most basic core functionality

```ts
import { Core } from '@verifai/react-native-sdk';

// Import licence variable stored in a local licence.js file that is ignored by
// version control
import { licence } from './licence';

// When the SDK finishes, an action is cancelled or an error is given these
// listeners will handle the returned object. The result object in the onSuccess
// listener conforms to the VerifaiResult object. The image results have been
// reworked to return something react native can understand. Read the
// documentation for more info.

// First set up the listeners
Core.setOnSuccess(result => console.log("success"))
Core.setOnCancelled(() => console.log("Cancelled"))
Core.setOnError(message => console.error(message))

// Set the licence (more info in the documentation)
Core.setLicence(licence)
Core.configure({ "enableVisualInspection": true })
// Start the SDK, this displays the SDK on the screen. The result is returned
// through the listeners
Core.start()
```

### NFC

An example on how to run the most basic NFC functionality. The NFC module can
only be run after a scan from the Core module has been performed. Also you need
to make sure the licence has been setup by the Core before running the Liveness
module.

```ts
import { NFC } from '@verifai/react-native-sdk';

// Listener for when the NFC process finishes or an error occurs. The result
// object conforms to the structure of VerifaiNFCResult. The image results have
// been reworked to return something react native can understand. Read the
// documentation for more info.
NFC.setOnSuccess((result: Object) => { 
  console.log(JSON.stringify(result, null, 2)) 
})
NFC.setOnCancelled(() => console.log("Cancelled"))
NFC.setOnError(message => console.error(message))
// Now we can start the NFC SDK. This will present the scanning screen. There
// are a few things we can setup while starting the NFC check to see the full
// list check out the documentation. Important: For the NFC check to work
// properly the main scan should have been performed.
NFC.start({
  "retrieveImage": true,
  "showDismissButton": true,
})
```

### Liveness

An example on how to run the most basic Liveness functionality. The Liveness
module can only be run after a scan from the Core module has been performed.
Also you need to make sure the licence has been setup by the Core before running
the Liveness module.

```ts
import { Liveness } from '@verifai/react-native-sdk';

// Listeners for when the liveness check finishes or an error occurs. The result
// object conforms to the structure of VerifaiLivenessCheckResults. Please read
// the documentation for more info.  
Liveness.setOnSuccess((result: Object) => { 
  console.log(JSON.stringify(result, null, 2)) 
})
Liveness.setOnError(message => console.error(message))
// Now we can start the liveness check, this shows the liveness check screen
// There are a few things we can setup while starting the liveness check to see
// the full list check out the documentation. Important: For the liveness check
// to work properly the main scan should have been performed
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

## Customization

Each module has extensive custimzation options to control the SDK's behavior.
You can customize options while scanning, scan help instruction, pre scan
instruction. You can also customize what kind of documents are allowed or filter
which options a user can choose from.

Extensive documentation on this is available in our
[documentation](https://docs.verifai.com).

Below you can find some examples on how to setup some components to give you an
idea of what you can setup.

### Core settings

The core offers several settings that allow you too better setup the SDK and
which flows a user gets.

Below is an example of the settings you can set, you can customize these to fit
your own need. For extensive explanation of what eacht setting does please check
out documentation. YOu can set these values in the `Core.configure` function.

```ts
"enablePostCropping": true,
"enableManual": true,
"requireDocumentCopy": true,
"requireCroppedImage": true,
"requireMRZContents": false,
"requireNFCWhenAvailable": false,
"readMRZContents": true,
"enableVisualInspection": true,
"documentFiltersAutoCreateValidators": true,
"customDismissButtonTitle": null,
```

### Core - Instruction screens

There are several ways of customizing the instruction screens. The easiest way
is to use our own design but customize the values yourself, place these values
inside `Core.configure`:

```ts
"instructionScreenConfiguration": {
  "showInstructionScreens": false,
  "instructionScreens": [
    {
      "screen": InstructionScreenId.MrzPresentFlowInstruction,
      "type": InstructionType.Media, // Possible values "MEDIA", "HIDDEN", "DEFAULT" or "WEB"
      // Values for both MEDIA and WEB based instruction screens
      "title": "Custom Instruction",
      "continueButtonLabel": "Let's do it!",
      "header": "Check out the video below",
      "mp4FileName": "DemoMp4", // This file needs to be available in your main bundle
      "instruction": "This is some custom instruction text that you can provide. In this example we're customizing the screen that asks if the document has an MRZ (Machine Readable Zone). So does the document have a MRZ? Answer below.",
    }
  ]
}
```

You can also use a web based instruction screen:

```ts
"instructionScreenConfiguration": {
  "showInstructionScreens": false,
  "instructionScreens": [
    {
      "screen": InstructionScreenId.MrzPresentFlowInstruction,
      "type": InstructionType.Web, 
      // Values for both MEDIA and WEB based instruction screens
      "title": "Custom Instruction",
      "continueButtonLabel": "Let's do it!",
      // Web only instruction screen values (type = WEB)
      "url": "https://www.verifai.com/en/support/supported-documents/",
    }
  ]
}
```

For exact options and possible values check out our documetation.

### NFC - Instruction screens

It's also possible to setup the NFC's instruction screens.

The most simple way is to use our own design but customize the values yourself,
place these values inside `NFC.start`:

```ts
// Setup the NFC instruction screens, check out docs for more info
"instructionScreenConfiguration": {
  "showInstructionScreens": true,
  "instructionScreens": [
    {
      "screen": "nfcScanFlowInstruction", // Currently the only instruction screen in the NFC module
      "type": InstructionType.Media, // Possible values "MEDIA", "HIDDEN", "DEFAULT" or "WEB"
      // Values for both MEDIA and WEB based instruction screens
      "title": "Custom NFC Instruction",
      "continueButtonLabel": "Let's do it!",
      // Native only instruction with local screen values (type = MEDIA)
      "header": "Check out the video below",
      "mp4FileName": "DemoMp4", // This file needs to be available in your main bundle
      "instruction": "The US passport has the NFC chip in a very peculiar place. You need to open up the booklet and look for the image of a satellite looking spacecraft on the back (the voyager spacecraft). Place the top back part of your device in one swift motion on top of that spacecraft to start the NFC scan process.",
    }
  ]
}
```

You could also use a web based instruction screen:

```ts
// Setup the NFC instruction screens, check out docs for more info
"instructionScreenConfiguration": {
  "showInstructionScreens": true,
  "instructionScreens": [
    {
      "screen": "nfcScanFlowInstruction", // Currently the only instruction screen in the NFC module
      "type": InstructionType.Web, 
      // Values for both MEDIA and WEB based instruction screens
      "title": "Custom NFC Instruction",
      "continueButtonLabel": "Let's do it!",
      // Web only instruction screen values (type = WEB)
      "url": "https://www.verifai.com/en/support/supported-documents/",
    }
  ]
}
```

### Scan help

When a scan fails or if we detect the user is having difficulties scanning we
offer help screens that give more detailed information about scanning.

In the case of the Core module we also offer an optional fallback option so that
if all else fails, the user can at least take an image of the document that can
be processed manually by a human. For the scan help we let you configure the
instruction and video shown to the user. Please keep in mind the video is muted.

You can customize this screen in the following way, place these values inside
`Core.configure`:

```ts
// Setup scan help, scan help in this case gets shown when scanning fails,
// check out docs for more info
"scanHelpConfiguration": {
  "isScanHelpEnabled": true,
  "customScanHelpScreenInstructions": "Our own custom instruction",
  "customScanHelpScreenMp4FileName": "DemoMp4"
}
```

In the NFC module we also offer scan help when an NFC scan fails. For the scan
help we let you configure the instruction and video shown to the user. Please
keep in mind the video is muted.

You can customize this screen in the following way, place these values inside
`NFC.start`:

```ts
// Setup scan help, scan help in this case gets shown when NFC scanning fails,
// check out docs for more info
"scanHelpConfiguration": {
    "isScanHelpEnabled": true,
    "customScanHelpScreenInstructions": "Our own custom instruction",
    "customScanHelpScreenMp4FileName": "DemoMp4"
}
```

### Validators

Just like for the native SDK we've opened up the possibility to setup validators
via the react native bridge. For an extensive explanation on what validators are
please check out our main documentation. We currently don't provide the option
to setup custom validators via the bridge. The bridge provides access to the
following validator types:

```ts
// Enum that describes a document Validator type
enum ValidatorType {
  // Validator that only allows documents from the countries provided
  DocumentCountryAllowList = 0,
  // Validator that blocks the documents from the countries provided   
  DocumentCountryBlockList, 
  // Validator that checks if document has an MRZ
  DocumentHasMrz, 
  // Validator that only validates certain document types  
  DocumentTypes, 
  // Validator that requires the MRZ to be correct
  MrzAvailable, 
  // Validators that ensure the NFC key if available is correct
  NFCKeyWhenAvailable 
}
```

In the example below we setup one of each validator as an example. Please be
aware that if setup incorrectly validators can cancel each other out.

```ts
// Example of adding validators
"validators": [
  {
    "type": ValidatorType.DocumentCountryAllowList,
    "countryList": [
      "NL"
    ]
  },
  {
    "type": ValidatorType.DocumentCountryBlockList,
    "countryList": [
      "BE"
    ]
  },
  {
    "type": ValidatorType.DocumentHasMrz
  },
  {
    "type": ValidatorType.DocumentTypes,
    "validDocumentTypes": [
      DocumentType.IdCard,
      DocumentType.Passport,
      DocumentType.DriversLicence
    ]
  },
  {
    "type": ValidatorType.MrzAvailable,
  },
  {
    "type": ValidatorType.NFCKeyWhenAvailable,
  }
],
```

### Document Filters

We've also opened up the possibility to setup document filters via the react
native bridge. Document filters allow you to cntrol which dcuments a uer can
choose when using the manual flow of the SDK. More information about this is
available in the documentation.

We provide the following document filters:

```ts
// Enum that describes document filters that filter the available documents in
// the manual document selection flow
enum DocumentFilterType {
  // Filter that only allows certain document types
  DocumentTypeAllowList = 0, 
  // Filter that only allows documents from certain provided countries
  DocumentAllowList, 
  // Filter that blocks certain document countries
  DocumentBlockList, 
}
```

Here's an example on how to set the document filters, pass these values in the
`Core.configure` function.

```ts
// Setting document filters example
"documentFilters": [
  {
    "type": DocumentFilterType.DocumentTypeAllowList,
    "validDocumentTypes": [
      DocumentType.IdCard,
      DocumentType.Passport,
      DocumentType.DriversLicence
    ]
  },
  {
    "type": DocumentFilterType.DocumentAllowList,
    "countryCodes": [
      "NL"
    ]
  },
  {
    "type": DocumentFilterType.DocumentBlockList,
    "countryCodes": [
      "BE"
    ]
  }
],
```

### Liveness checks

We also offer a bridge to the liveness checks tat the SDK provides. The
following Liveness checks are available:

```ts
// Enum of possible liveness checks
enum LivenessCheck {
  // Check where a user is asked to close their eyes for x amount of time
  CloseEyes = 0, 
  // Check where a user is asked to tilt their head a certain amount of degrees
  Tilt,
  // Check where the user is asked to say certain words
  Speech,   
  // Check where the user is asked to take a selfie and the face is matched with
  // the one on the document or NFC
  FaceMatching
}
```

Below you can find an example of each liveness check, you can configure the
values to match your needs or just pass an empty list and the SDK will use a
default set of checks.

You can set these values by passing them in the `Liveness.start` function.

```ts
"resultOutputDirectory": RNFS.DocumentDirectoryPath,
"showDismissButton": true,
"customDismissButtonTitle": "Close",
"checks": [
  {
    "check": LivenessCheck.CloseEyes,
    "numberOfSeconds": 5,
    "instruction": "Close your eyes for at least 5 seconds"
  },
  {
    "check": LivenessCheck.Tilt,
    "faceAngleRequirement": 25,
    "instruction": "Tilt your head until the green line is reached"
  },
  {
    "check": LivenessCheck.Speech,
    "speechRequirement": "apple banana pizza",
    "locale": "en-US",
    "instruction": "Please say the following words"
  },
  {
    "check": LivenessCheck.FaceMatching,
    "imageSource": FaceMatchImageSource.DocumentScan
  }
]
```

## Support

For additional support remember to consult our
[documentation](https://docs.verifai.com) or reach out to us via our
[support channels](https://support.verifai.com).
