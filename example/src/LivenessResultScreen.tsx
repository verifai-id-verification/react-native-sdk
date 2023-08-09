import * as React from 'react';

import { SafeAreaView, ScrollView, Text } from 'react-native'
import styles from './Styles'
import VerifaiButton from './VerifaiButton'

function LivenessResultScreen({ route, navigation }) {
  const { result } = route.params
  console.log(JSON.stringify(result, null, 2))

  return (
    <SafeAreaView style={styles.container}>
      <VerifaiButton
        title='Done'
        onPress={
          () => {
            navigation.navigate('Verifai Example Home')
          }
        }
      />
      <ScrollView>
        <Text
          style={{
            width: '100%',
            height: undefined,
          }}
        > Result: {JSON.stringify(result, null, 2)}
        </Text>
      </ScrollView>
    </SafeAreaView>
  );
}

export default LivenessResultScreen
