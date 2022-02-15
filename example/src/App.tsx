import * as React from 'react';

import { StyleSheet, View, Pressable, Text, Image } from 'react-native';
import {
  Core, Liveness, NFC,
  LivenessCheck,
  VerifaiInstructionScreenId,
  VerifaiInstructionType,
  VerifaiValidatorType,
  VerifaiDocumentFilterType,
  VerifaiDocumentType,
  FaceMatchImageSource
} from '@verifai/react-native-sdk';

import { VERIFAI_LICENCE } from 'react-native-dotenv';

var RNFS = require('react-native-fs');

export default function App() {
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

  // Listener for when the liveness check finishes or an error occurs
  // The result object conforms to the structure of VerifaiLivenessCheckResults. 
  // Please read the documentation for more info.  
  const livenessListener = {
    onSuccess: (result: Object) => { console.log(JSON.stringify(result, null, 2)) },
    onError: (message: String) => { console.error(message) },
  }

  // Listener for when the NFC process finishes or an error occurs. 
  // The result object conforms to the structure of VerifaiNFCResult. The image results have been reworked
  // to return something react native can understand. Read the documentation for more info.
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
            // Example of setting up the Core SDK
            // First set up the listeners
            Core.setOnSuccess(coreListener.onSuccess)
            Core.setOnCancelled(coreListener.onCancelled)
            Core.setOnError(coreListener.onError)
            // Set the licence (more info in the documentation)
            Core.setLicence(VERIFAI_LICENCE)
            // Optional: Configure the SDK, for possible values please check the documentation
            Core.configure({
              "enablePostCropping": true,
              "enableManual": true,
              "requireDocumentCopy": true,
              "requireCroppedImage": true,
              "requireMRZContents": false,
              "requireNFCWhenAvailable": false,
              "readMRZContents": true,
              "enableVisualInspection": true,
            })
            // Start the SDK, this displays the SDK on the screen. The result is returned through the listeners
            Core.start()
          }
        }
      />

      <VerifaiButton
        title="Start Liveness"
        color="#ff576d"
        onPress={
          () => {
            // Example of setting up the Liveness check SDK
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
          }
        }
      />

      <VerifaiButton
        title="Start NFC"
        color="#ff576d"
        onPress={
          () => {
            // Example of setting up the NFC SDK
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
          }
        }
      />
      {/* Holder that displays the front document image after a scan */}
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
    justifyContent: "space-around"
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

// Custom Verifai button for ease of testing
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
