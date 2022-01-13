import * as React from 'react';

import { StyleSheet, View, Pressable, Text } from 'react-native';
import {
  Core, Liveness, NFC,
  LivenessCheck,
  VerifaiInstructionScreenId,
  VerifaiInstructionType
} from 'verifai-react-native-sdk';

import { VERIFAI_LICENCE } from 'react-native-dotenv';

export default function App() {
  const coreListener = {
    onSuccess: (message: Object) => { console.log(JSON.stringify(message, null, 2)) },
    onCancelled: () => { console.log("cancelled") },
    onError: (message: String) => { console.error(message) },
  }

  const livenessListener = {
    onSuccess: (message: Object) => { console.log(JSON.stringify(message, null, 2)) },
    onError: (message: String) => { console.error(message) },
  }

  const nfcListener = {
    onSuccess: (message: Object) => { console.log(JSON.stringify(message, null, 2)) },
    onCancelled: () => { console.log("cancelled") },
    onError: (message: String) => { console.error(message) },
  }


  return (
    <View style={styles.container}>
      <VerifaiButton
        title="Start"
        color="#ff576d"
        onPress={
          () => {
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
            Liveness.start([
              {
                "check": LivenessCheck.CloseEyes, "numberOfSeconds": 5
              },
              {
                "check": LivenessCheck.Tilt, "faceAngleRequirement": 25
              },
              {
                "check": LivenessCheck.FaceMatching, "imageType": "doc"
              },
              {
                "check": LivenessCheck.FaceMatching, "imageType": "nfc"
              }
            ])
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
            NFC.start()
          }
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
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
