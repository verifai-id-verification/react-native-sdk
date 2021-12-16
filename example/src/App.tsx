import * as React from 'react';

import { StyleSheet, View, Button } from 'react-native';
import { Core, Liveness, Nfc } from 'verifai-react-native-sdk';
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
      <Button
        title="Start"
        color="#ff576d"
        onPress={
          () => {
            Core.setOnSuccess(coreListener.onSuccess)
            Core.setOnCancelled(coreListener.onCancelled)
            Core.setOnError(coreListener.onError)
            Core.start(VERIFAI_LICENCE)
          }
        }
      />

      <Button
        title="Start Liveness"
        color="#ff576d"
        onPress={
          () => {
            Liveness.setOnSuccess(livenessListener.onSuccess)
            Liveness.setOnError(livenessListener.onError)
            Liveness.start()
          }
        }
      />

      <Button
        title="Start NFC"
        color="#ff576d"
        onPress={
          () => {
            Nfc.setOnSuccess(nfcListener.onSuccess)
            Nfc.setOnCancelled(nfcListener.onCancelled)
            Nfc.setOnError(nfcListener.onError)
            Nfc.start()
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
});
