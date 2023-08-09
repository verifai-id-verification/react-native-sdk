import * as React from 'react';

import { Pressable, Text } from 'react-native'
import styles from './Styles'

// Custom Verifai button for ease of testing
function VerifaiButton(props) {
  const { onPress, title = 'Name me' } = props;
  return (
    <Pressable
      onPress={onPress}
      style={styles.buttonContainer}
    >
      <Text style={{ color: 'white' }}>{title}</Text>
    </Pressable>
  );
}

export default VerifaiButton
