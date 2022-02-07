import * as React from 'react';

import { StyleSheet, View, Pressable, Text, Image } from 'react-native';
import {
  Core, Liveness, NFC,
  LivenessCheck,
  VerifaiInstructionScreenId,
  VerifaiInstructionType,
  VerifaiValidatorType,
  VerifaiDocumentType,
  FaceMatchImageSource
} from 'verifai-react-native-sdk';

import { VERIFAI_LICENCE } from 'react-native-dotenv';

var RNFS = require('react-native-fs');

export default function App() {
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

  const livenessListener = {
    onSuccess: (result: Object) => { console.log(JSON.stringify(result, null, 2)) },
    onError: (message: String) => { console.error(message) },
  }

  const nfcListener = {
    onSuccess: (result: Object) => { console.log(JSON.stringify(result, null, 2)) },
    onCancelled: () => { console.log("cancelled") },
    onError: (message: String) => { console.error(message) },
  }

  const [ imgProp, setImgProp ] = React.useState({
    aspectRatio: 1,
    uri: "data:image/png;base64,",
  });

  return (
    <View style={styles.container}>
      <VerifaiButton
        title="Start"
        color="#ff576d"
        onPress={
          () => {
            Core.setOnSuccess(coreListener.onSuccess)
            Core.setOnCancelled(coreListener.onCancelled)
            Core.setOnError(coreListener.onError)
            Core.setLicence(VERIFAI_LICENCE)
            Core.configure({
              "enablePostCropping": true,
              "enableManual": true,
              "requireDocumentCopy": true,
              "requireCroppedImage": true,
              "requireMRZContents": false,
              "requireNFCWhenAvailable": false,
              "readMRZContents": true,
              "enableVisualInspection": true,
              "instructionScreenConfiguration": {
                "showInstructionScreens": false,
                "instructionScreens": [
                  {
                    "screen": VerifaiInstructionScreenId.MRZ_PRESENT_FLOW_INSTRUCTION, 
                    "type": VerifaiInstructionType.MEDIA, // Possible values "MEDIA", "HIDDEN", "DEFAULT" or "WEB"
                    // Values for both MEDIA and WEB based instruction screens
                    "title": "Custom Instruction",
                    "continueButtonLabel": "Let's do it!",
                    // Native only instruction with local screen values (type = MEDIA)
                    "header": "Check out the video below",
                    "mp4FileName": "DemoMp4", // This file needs to be available in your main bundle
                    "instruction": "This is some custom instruction text that you can provide. In this example we're customizing the screen that asks if the document has an MRZ (Machine Readable Zone). So does the document have a MRZ? Answer below.",
                    // Web only instruction screen values (type = WEB)
                    "url": "https://www.verifai.com/en/support/supported-documents/",
                  }
                ]
              },
              // Setup scan help, scan help in this case gets shown when scanning fails, check out docs for more info
              "scanHelpConfiguration": {
                "isScanHelpEnabled": true,
                "customScanHelpScreenInstructions": "Our own custom instruction",
                "customScanHelpScreenMp4FileName": "DemoMp4"
              },
              // Example of adding validators
              "validators": [
                {
                  "type": VerifaiValidatorType.DocumentCountryWhitelist,
                  "countryList": [
                    "NL"
                  ]
                },
                {
                  "type": VerifaiValidatorType.DocumentCountryBlackList,
                  "countryList": [
                    "BE"
                  ]
                },
                {
                  "type": VerifaiValidatorType.DocumentHasMrz
                },
                {
                  "type": VerifaiValidatorType.DocumentTypes,
                  "validDocumentTypes": [
                    VerifaiDocumentType.idCard,
                    VerifaiDocumentType.passport,
                    VerifaiDocumentType.driversLicence
                  ]
                },
                {
                  "type": VerifaiValidatorType.MrzAvailable,
                },
                {
                  "type": VerifaiValidatorType.NFCKeyWhenAvailable,
                }
              ],
              // Setting document filters example
              "documentFilters": [
                {
                  "type": "VerifaiDocumentTypeWhiteListFilter",
                  "validDocumentTypes": [
                    VerifaiDocumentType.idCard,
                    VerifaiDocumentType.passport,
                    VerifaiDocumentType.driversLicence
                  ]
                },
                {
                  "type": "VerifaiDocumentWhiteListFilter",
                  "countryCodes": [
                    "NL"
                  ]
                },
                {
                  "type": "VerifaiDocumentBlackListFilter",
                  "countryCodes": [
                    "BE"
                  ]
                }
              ],
              "documentFiltersAutoCreateValidators": true,
              "customDismissButtonTitle": null,
            })
            Core.start()
          }
        }
      />

      <VerifaiButton
        title="Start Liveness"
        color="#ff576d"
        onPress={
          () => {
            Liveness.setOnSuccess(livenessListener.onSuccess)
            Liveness.setOnError(livenessListener.onError)
            Liveness.start({
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
                  "ImageSource": FaceMatchImageSource.documentScan
                }
              ]
            })
          }
        }
      />

      <VerifaiButton
        title="Start NFC"
        color="#ff576d"
        onPress={
          () => {
            NFC.setOnSuccess(nfcListener.onSuccess)
            NFC.setOnCancelled(nfcListener.onCancelled)
            NFC.setOnError(nfcListener.onError)
            NFC.start({ 
              "retrieveImage": true,
              "showDismissButton": true,
              "customDismissButtonTitle": "Close",
              // Setup the NFC instruction screens, check out docs for more info
              "instructionScreenConfiguration": {
                "showInstructionScreens": true,
                "instructionScreens": [
                  {
                    "screen": "nfcScanFlowInstruction", // Currently the only instruction screen in the NFC module
                    "type": VerifaiInstructionType.MEDIA, // Possible values "MEDIA", "HIDDEN", "DEFAULT" or "WEB"
                    // Values for both MEDIA and WEB based instruction screens
                    "title": "Custom NFC Instruction",
                    "continueButtonLabel": "Let's do it!",
                    // Native only instruction with local screen values (type = MEDIA)
                    "header": "Check out the video below",
                    "mp4FileName": "DemoMp4", // This file needs to be available in your main bundle
                    "instruction": "The US passport has the NFC chip in a very peculiar place. You need to open up the booklet and look for the image of a satellite looking spacecraft on the back (the voyager spacecraft). Place the top back part of your device in one swift motion on top of that spacecraft to start the NFC scan process.",
                    // Web only instruction screen values (type = WEB)
                    "url": "https://www.verifai.com/en/support/supported-documents/",
                  }
                ]
              }
              ,
              // Setup scan help, scan help in this case gets shown when NFC scanning fails, check out docs for more info
              "scanHelpConfiguration": {
                "isScanHelpEnabled": true,
                "customScanHelpScreenInstructions": "Our own custom instruction",
                "customScanHelpScreenMp4FileName": "DemoMp4"
              }
            })
          }
        }
      />
      <VerifaiButton
        title="Test"
        color="#ff576d"
        onPress={
          () => {
            setImgProp({
              uri: "data:image/png;base64,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",
              aspectRatio: 279/64,
            })
          }
        }
      />
      <Image
        style={{
          width: '100%',
          height: undefined,
          aspectRatio: imgProp.aspectRatio,
        }}
        source={{
          uri: imgProp.uri,
        }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 20,
    flex:1,
    flexDirection: "column",
    justifyContent: "space-between"
  },
  buttonContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    margin: 16,
    borderRadius: 4,
    elevation: 3,
    backgroundColor: '#FF576D',
    height: 50,
    width: 300
  },
});

// Custom button
function VerifaiButton(props) {
  const { onPress, title = 'Name me'} = props;
  return (
    <Pressable
        onPress={onPress}
        style={styles.buttonContainer}
      >
      <Text style={styles.text}>{title}</Text>
    </Pressable>
  );
}
