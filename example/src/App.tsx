import * as React from 'react';

import { StyleSheet, View, Button } from 'react-native';
import { VerifaiCore } from 'verifai-core-react-native';
import { VERIFAI_LICENCE } from 'react-native-dotenv';

export default function App() {
  const onSuccess = (message: Object) => { console.log(JSON.stringify(message, null, 2)) }
  const onCancelled = () => { console.log("cancelled") }
  const onError = (message: String) => { console.error(message) }

  return (
    <View style={styles.container}>
      <Button
        title="Start"
        color="#ff576d"
        onPress={
          () => {
            VerifaiCore.setOnSuccess(onSuccess)
            VerifaiCore.setOnCancelled(onCancelled)
            VerifaiCore.setOnError(onError)
            VerifaiCore.start(VERIFAI_LICENCE)
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
