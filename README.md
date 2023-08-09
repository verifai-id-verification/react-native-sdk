# Verifai react-native-sdk

## Table of contents

- [Verifai react-native-sdk](#verifai-react-native-sdk)
  - [Table of contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Install Verifai](#install-verifai)
    - [Add license](#add-license)
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
    - [Scan help (iOS only)](#scan-help-ios-only)
    - [Validators](#validators)
    - [Document Filters](#document-filters)
    - [Liveness checks](#liveness-checks)
  - [Support](#support)
  - [Change log](#change-log)
    - [2.0.0](#200)
    - [1.3.0](#130)
    - [1.2.0](#120)
    - [1.1.0](#110)
    - [1.0.5](#105)
    - [1.0.4](#104)
    - [1.0.3](#103)
    - [1.0.2](#102)
    - [1.0.1](#101)
    - [1.0.0](#100)

## Getting started

If you are new to React Native and want to start a new project,
the official [React Native](https://reactnative.dev/docs/environment-setup)
docs explain how to setup your develop environment.
The Verifai sdk uses native modules which means the React Native CLI Quickstart has to be used,
Expo is not possible.

### Install Verifai

To integrate the sdk in your project, install it from npm with:

```sh
yarn add @verifai/react-native-sdk
# or
npm install @verifai/react-native-sdk
```

### Add license

The Verifai SDK does not work without a valid license.
The license can be copied from the dashboard, and has to be set with the `Core.setLicense` method,
see [usage](#core).

An easy way to store the license and keep it outside version control,
is to copy it in a local `License.tsx` file next to your `App.tsx`.
Add `License.tsx` to your `.gitignore` file.
Example:

```tsx
const license: string = `=== Verifai Licence file V2 ===
...
`
export default license
```

Then import the license variable in your `App.tsx` like this:

```tsx
import license from './License'
```

### Android

To avoid conflicts between native android runtime libraries,
add the `packagingOptions` code snippet in the `build.gradle` file of your app,
not in the root!

```groovy
android {
    packagingOptions {
        jniLibs {
            pickFirsts += ['**/*.so']
        }
    }
}
```

If you run into memory errors during the build of your app,
uncomment (or if it is not there add) the following line in your gradle.properties file:

```ini
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
```

### iOS

When using Cocoapods, add the following to your `Podfile`:

```shell
pod 'verifai-react-native', :path => '../node_modules/@verifai/react-native-sdk'
```

Afterwards you can run `pod install`. That's all it takes!

## Usage

The SDK has 3 modules:

- Core: The core scanning functionality
- NFC: Does the core scanning and a NFC scan on the document (compatible device required)
- Liveness: Performs a liveness check and optionally a face matching check

For both the Core and NFC modules there are two ways to use the SDK.
The new preferred way of doing it is the API flow.
This is the way explained in the code examples of this README.
It will send the scan result to our `Identity Review` system.
Verifai will review the scan, and the scan result will be made available through a web hook,
and no longer in the app itself.
This allows for more security and validity.
In case you rather like to get the result locally in your app itself,
the previous way of doing it is still available.
Instead of using the `Core.start` or `NFC.start`, you'll have to use:
`Core.startLocal` or `NFC.startLocal`.
For more information, please consult the online documentation.

### Core

An example on how to run the most basic core functionality

```ts
import { Core } from '@verifai/react-native-sdk'

// Import license variable stored in a local license.js file that is ignored by
// version control
import license from './License'

// Example async function for starting the sdk
const startSdk = async () => {
  try {
    // Set the license (more info in the documentation)
    await Core.setLicense(license)
    // Set the confiuration options
    await Core.configure({ enableVisualInspection: true })
    // Start the SDK
    const result = await Core.start('React Native Core') // Pass string argument: `internal reference`
    // Process the result here
  } catch (e) {
    // Catch error
    console.error(e)
  }
}
```

### NFC

An example on how to run the most basic NFC functionality.
The NFC module can only be run after a scan from the Core module has been performed.
Also you need to make sure the license has been setup by the Core before running the NFC module.

```ts
import { NFC } from '@verifai/react-native-sdk'

// Import license variable stored in a local license.js file that is ignored by
// version control
import license from './License'

// Example async function for starting the sdk
const startSdk = async () => {
  try {
    // Set the license (more info in the documentation)
    await NFC.setLicense(license)
    // Set the confiuration options
    await NFC.configure({
      // Core config is exactly as the configuration for the Core module shown above
      core: {
        enableManualFlow: true,
      },
      nfc: {
        retrieveFaceImage: true,
        instructionScreenConfiguration: {}, // To use the example: instructionScreenConfiguration: instructionScreenConfig,
      }
    })
    // Start the SDK
    const result = await NFC.start('React Native NFC') // Pass string argument: `internal reference`
    // Process the result here
  } catch (e) {
    // Catch error
    console.error(e)
  }
}
```

### Liveness

An example on how to run the most basic Liveness functionality.
The Liveness module can only be run after a scan from the Core module has been performed.
Also you need to make sure the license has been setup by the Core before running the Liveness module.

```ts
import { Liveness } from '@verifai/react-native-sdk';


const startLiveness = async () => {
  // There are a few things we can setup while starting the liveness check to see
  // the full list check out the documentation. Important: For the liveness check
  // to work properly the main scan should have been performed
  // Configure the module if you want to customize the default behaviour
  await Liveness.configure({
    showDismissButton: true,
    customSkipButtonTitle: 'Close',
    showSkipButton: true,
  })

  // Setup the liveness checks:
  let checks: { [key: string]: any }[] = [
    {
      type: LivenessCheck.CloseEyes,
      numberOfSeconds: 3,
      instruction: 'Hi, please close your eyes.', // Optional for customization
    },
    {
      type: LivenessCheck.Tilt,
      faceAngle: 15,
    },
    {
      // iOS only check, on Android it is ignored
      type: LivenessCheck.Speech,
      speechRequirement: 'Hi React Native example',
      locale: 'en-US', // Underscore is not supported for locale string
    },
  ]

  // Now we can start the liveness check, this shows the liveness check screen
  // There are a few things we can setup while starting the liveness check
  // to see the full list check out the documentation.
  // Important: For the face match check, the Core or NFC scan should be done first
  const result = await Liveness.start(checks)
}
```

## Customization

Each module has extensive custimzation options to control the SDK's behavior.
You can customize options while scanning, scan help instruction, pre scan instruction.
You can also customize what kind of documents are allowed or filter which options a user can choose from.

Extensive documentation on this is available in our [documentation](https://docs.verifai.com).

Below you can find some examples on how to setup some components to give you an idea of what you can setup.

### Core settings

The core offers several settings that allow you too better setup the SDK and which flows a user gets.

Below is an example of the settings you can set, you can customize these to fit your own needs.
For extensive explanation of what eacht setting does please check out documentation.
You can set these values in the `Core.configure` function.

```ts
await Core.configure({
  requireDocumentCopy: true,
  enableCropping: true,
  enableManualFlow: true,
  requireMrz: false,
  requireNfcWhenAvailable: false,
  autoCreateValidators: true,
  isScanHelpEnabled: true,
  requireCroppedImage: true,
  enableVisualInspection: false,
  instructionScreenConfiguration: {}, // See section: Core - Instruction screens
  validators: [], // See section: Validators
  filters: [], // See section: Document filters
  scanHelpConfiguration: {}, // iOS only
})
```

### Core - Instruction screens

There are several ways of customizing the instruction screens.
The easiest way is to use our own design but customize the values yourself,
place these values inside `Core.configure`:

```ts
const instructionScreenConfig = {
  showInstructionScreens: true,
  instructionScreens: {
    //... Other screens
    [InstructionScreenId.MrzPresentFlowInstruction]: {
      type: InstructionType.Custom,
      arguments: {
        type: InstructionArgument.Custom,
        title: 'MRZ',
        header: 'Does document have MRZ?',
        mediaResource: "DemoMp4", // This file needs to be available in your main bundle (iOS), or resources (Android)
        continueButtonLabel: 'Yes',
        negativeButtonLabel: 'No',
      }
    }
  }
}
```

You can also use a web based instruction screen:

```ts
const instructionScreenConfig = {
  showInstructionScreens: true,
  instructionScreens: {
    //... Other screens
    [InstructionScreenId.MrzScanFlowInstruction]: {
      type: InstructionType.Web,
      arguments: {
        type: InstructionArgument.Web,
        title: "Hi",
        url: "https://www.verifai.com",
        continueButtonLabel: "Test",
        negativeButtonLabel: "Stop",
      }
    }
  }
}
```

For exact options and possible values check out our native documentation.

### NFC - Instruction screens

It's also possible to setup the NFC's instruction screens.

The most simple way is to use our own design, but customize the values yourself.
Put these values inside `NFC.start`:

```ts
// Setup the NFC instruction screens, check out docs for more info
const instructionScreenConfig = {
  showInstructionScreens: true,
  instructionScreens: {
    [NfcInstructionScreenId.NfcScanFlowInstruction]: {
      type: InstructionType.Web,
      arguments: {
        type: InstructionArgument.Web,
        title: 'Hi',
        url: 'https://www.verifai.com',
        continueButtonLabel: 'Start',
        negativeButtonLabel: 'Stop',
      }
    }
  },
}
```

### Scan help (iOS only)

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
scanHelpConfiguration: {
  isScanHelpEnabled: true,
  customScanHelpScreenInstructions: 'Our own custom instruction',
  customScanHelpScreenMp4FileName: 'DemoMp4'
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
scanHelpConfiguration: {
  isScanHelpEnabled: true,
  customScanHelpScreenInstructions: 'Our own custom instruction',
  customScanHelpScreenMp4FileName: 'DemoMp4'
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
  DocumentCountryAllowlist = 'DocumentCountryAllowlistValidator', // Only allows documents from the countries provided
  DocumentCountryBlocklist = 'DocumentCountryBlocklistValidator', // Blocks the documents from the countries provided
  DocumentHasMrz = 'DocumentHasMrzValidator',                     // Validates that the document has a MRZ
  DocumentTypes = 'DocumentTypesValidator',                       // Validates certain document types
  MrzAvailable = 'MrzAvailableValidator',                         // Validates that the MRZ has been read
  NfcKeyWhenAvailable = 'NfcKeyWhenAvailableValidator'            // Validates that the NFC key if available is correct
}
```

In the example below we setup one of each validator as an example.
Please be aware that if setup incorrectly validators can cancel each other out.

```ts
// Example of adding validators
const validators = [
  {
    type: ValidatorType.DocumentCountryBlocklist,
    countryCodes: ["NL"],
  },
  {
    type: ValidatorType.DocumentTypes,
    documentTypes: [
      DocumentType.DrivingLicense
    ],
  },
  {
    type: ValidatorType.NfcKeyWhenAvailable,
  },
]
```

### Document Filters

We've also opened up the possibility to setup document filters via the react
native bridge. Document filters allow you to control which dcuments a user can
choose when using the manual flow of the SDK. More information about this is
available in the documentation.

We provide the following document filters:

```ts
// Enum that describes document filters that filter the available documents in the manual document selection flow
enum DocumentFilterType {
  DocumentTypeAllowlist, // Filter that only allows certain document types
  DocumentAllowlist,     // Filter that only allows documents from certain provided countries
  DocumentBlocklist,     // Filter that blocks certain document countries
}
```

Here's an example on how to set the document filters,
pass these values to the filter fields in the `Core.configure` function.

```ts
// Setting document filters example
const filters = [
  {
    type: DocumentFilterType.DocumentAllowlist,
    countryCodes: ['NL'],
  },
  {
    type: DocumentFilterType.DocumentTypeAllowlist,
    documentTypes: [DocumentType.Passport],
  }
]
```

### Liveness checks

We also offer a bridge to the liveness checks that the SDK provides.
The following code example shows how to configure the liveness module.

```ts
// Configure the module if you want to customize the default behaviour
await Liveness.configure({
  showDismissButton: true,
  customSkipButtonTitle: 'Close',
  showSkipButton: true,
})
```

These Liveness checks are available:

```ts
// Enum of possible liveness checks
enum LivenessCheck {
  CloseEyes = LivenessCheckPlatformStrings[Platform.OS].CloseEyes,       // Check where a user is asked to close their eyes for x amount of time
  Tilt = LivenessCheckPlatformStrings[Platform.OS].Tilt,                 // Check where a user is asked to tilt their head a certain amount of degrees
  Speech = LivenessCheckPlatformStrings[Platform.OS].Speech,             // Check where the user is asked to say certain words (iOS only)
  FaceMatching = LivenessCheckPlatformStrings[Platform.OS].FaceMatching, // Check where the user is asked to take a selfie and the face is matched with the one on the document or NFC
}
```

Below you can find an example of each liveness check,
you can configure the values to match your needs or just pass an empty list and the SDK will use a default set of checks.
You can set these values by passing them in the `Liveness.start` function.

```ts
const startLiveness = () => {
  // Now we can start the liveness check, this shows the liveness check screen
  // There are a few things we can setup while starting the liveness check
  // to see the full list check out the documentation.
  // Important: For the liveness check to work properly the main scan should have been performed
  const checks: { [key: string]: any }[] = [
    {
      type: LivenessCheck.CloseEyes,
      numberOfSeconds: 3,
      instruction: 'Hi, please close your eyes.', // Optional for customization
    },
    {
      type: LivenessCheck.Tilt,
      faceAngle: 15,
    },
    {
      // iOS only check, on Android it is ignored
      type: LivenessCheck.Speech,
      speechRequirement: 'Hi React Native example',
      locale: 'en-US', // Underscore is not supported for locale string
    },
  ]
  const result = await Liveness.start(checks)
}
```

## Support

For additional support remember to consult our
[documentation](https://docs.verifai.com) or reach out to us via our
[support channels](https://support.verifai.com).

## Change log

### 2.0.0

- New major release, backwards incompatible with v1.3.0
- Refactoring the whole sdk to v6 of the native sdk's
- Upgrade to iOS sdk v6.0.1
- Upgrade to Android sdk v6.0.0
- Make use of Promises for native functions

### 1.3.0

- Fixed document filters interface inconsistency between Android and iOS.

### 1.2.0

- Updated React Native to version 0.70.6
- Fixed document filters interface inconsistency between Android and iOS
`validDocumentTypes` to `documentTypes`.

### 1.1.0

- Updated iOS SDK to version 5.4.1
  - This adds support for PACE
  - Adds support for renamed OpenSSL library
- Updated Android SDK to version 4.11.1
  - This adds support for PACE

### 1.0.5

- Updates dependancy packages that have vulnerabilities
- Improvements to README

### 1.0.4

- Updated iOS SDK to version 5.3.0
  - Adds 21 languages to the SDK
- Support for iOS 11 dropped

### 1.0.3

- Updates dependancy package that has a vulnerability

### 1.0.2

- Updated iOS SDK to 5.2.2

### 1.0.1

- Improved README
- Fixed issue where pod installation could fail

### 1.0.0

- Initial release
