/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import type {Node} from 'react';
import {
  SafeAreaView,
  Pressable,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
} from 'react-native';

import {
  Colors,
} from 'react-native/Libraries/NewAppScreen';

const App: () => Node = () => {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <View style={styles.sectionContainer}>
      <Text
        style={[
          styles.titleContainer,
          {
            color: isDarkMode ? Colors.white : Colors.black,
          },
        ]}>
        Verifai Reactive Testing
      </Text>
    </View>
    <View style={styles.sectionContainer}>
      <Pressable
        onPress={() => {
          alert('You tapped the button!');
        }}
        title="Press Me"
        style={styles.buttonContainer}
      >
        <Text style={styles.text}>Setup VerifaiConfiguration</Text>
      </Pressable>
    </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
  },
  titleContainer: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.white,
    textAlign: 'center'
  },
  text: {
    fontSize: 17,
    color: Colors.white,
    textAlign: 'center'
  },
  buttonContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    margin: 16,
    borderRadius: 4,
    elevation: 3,
    backgroundColor: '#841584',
    height: 50
  }
});

export default App;
