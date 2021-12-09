import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { VerifaiCore } from 'verifai-core-react-native';

export default function App() {
  const licence: string = `
asdf
`

  VerifaiCore.start(licence)

  return (
    <View style={styles.container}>
      <Text>Result: Hoi</Text>
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
