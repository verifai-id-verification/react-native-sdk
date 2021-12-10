import * as React from 'react';

import { StyleSheet, View, Button } from 'react-native';
import { VerifaiCore } from 'verifai-core-react-native';

export default function App() {
  const licence = `=== Verifai Licence file V2 ===`

  return (
    <View style={styles.container}>
      <Button
        title="Start"
        color="#ff576d"
        onPress={
          () => {
            VerifaiCore.start(licence)
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
