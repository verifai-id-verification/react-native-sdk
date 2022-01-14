/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, { useState } from 'react';
import type {Node} from 'react';
import {
  SafeAreaView,
  Pressable,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  NativeModules
} from 'react-native';

import {
  Colors,
} from 'react-native/Libraries/NewAppScreen';

const { 
  RNVerifaiLicence, 
  RNVerifaiCore 
} = NativeModules;


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
    <View >
      <VerifaiButton 
        title="Setup Licence"
        onPress={ async () => {
          console.log("Tapped Setup Licence");
          SetLicence()
        }}
      />
    </View>
    <View >
      <VerifaiButton 
        title="Start Verifai"
        onPress={ () => {
          console.log("Start Verifai tapped");
          var configuration = {};
          configuration["customDismissButtonTitle"] = "Cancela"
          RNVerifaiCore.setupConfiguration(configuration)
          StartVerifai()
        }}
      />
    </View>
    {/* <View >
      <VerifaiButton 
        title="Start Verifai"
        disable={true}
        //activeOpacity={disabled ? 1 : 0.7}
        onPress={() => {
          alert('You tapped the button!');
        }}
      />
    </View> */}
    </SafeAreaView>
  );
};

// Styles
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
    backgroundColor: '#FF576D',
    height: 50,
  }
});

// Setup the licence
const SetLicence = async () => {
  // Define test licence (this should be put somewhere else before comitting to git)
  let licence = "=== Verifai Licence file V2 ===" + "\n" +
"qhskxC0VNNPYiD2qj8QiqKDZhfwAQnjMb1oor5HuvQ2Xkuz1h47GkorqMHavlPeiFMVP5CqNc3fs" + "\n" +
"XWoKHwnc9wpm2fM9NVcE0DE0KuAYfDLJDWlkZ1CchtxbYo/G4S03UyyGM7yViEelIclPib3E/4oo" + "\n" +
"iCHUbBBdFHfM+cJ2IHX3zZeXnCABD0StAPgqXZ2tH/6Kxw+QvjVcT/we/aNe6luawayHg7aV0fMq" + "\n" +
"xUyikHCOxtZJrIgQa8k3pQcDGxx3mxsaGXslN2h6hPvKaASxbG6MA+F46vqjXF9t31olGfgNehEY" + "\n" +
"5TpkOn3bkj7TqSi/ZItLk840PXJyCMPipJx+EuukzpkHEP8ftldmWKJ6E+JOjXCSXHrZcq6e4d/e" + "\n" +
"hbt00/Oqrt1VWcPpR989rK5WHgSlCEW0er2WepBqCxwkqIyGMGCoFm+ebXyxxyYhYdgEv4wxdAmX" + "\n" +
"388rdtEFRSPPPakfD7YI1uN/YXrCkC9lz5S33YsCeSRqlBIbzM+U+jjvfpur4fkCoBowNANnk63T" + "\n" +
"IpLnzRZQXFF2cimQF6H/kk6ZJC0OMwMeR7dnE8b7t27nxuYi8AYDNpGt50MHbzqm12JqfqPlwUYw" + "\n" +
"5tDiYzcKbArp/nLYJgvGyDodBrbOR/h9YvLXR7oHW8qf1pIDTQ015/snK2pYwYEpi7XawdyqQ2Rw" + "\n" +
"xznSTzfiwR3XQU2gpqNYyjH0to8+gb4W95fdRZeOKjV3QhucqBLWsgfmEw4YRLkEtcjTtryGPL4K"  + "\n" +
"SPgY6bYrPonmtfp4h/EM2pyLH2VUHW9feiRukDVVGpg4mvIXZekwerHqUBBnQ5em7Q/FJBJmV7it" + "\n" +
"G7PYz2gQTjHWOoYF74v65IRrlblV/QSf0y+DafftXcF5SU9JDxphG9n9Qc7RJu5KNDyItm6HPXoA" + "\n" +
"NBLlbQk8xFg/xuB5tmPcHkoz+DsnrzHHtIDS0ufPEFnF9uOE+1SpkSXDcNKn6zRE2FY=";
  try {
    const resultMessage = await RNVerifaiLicence.setLicence(licence);
    console.log(resultMessage);
  } catch (e) {
    console.error(e);
  }
}

// Start Verifai
const StartVerifai = async () => {
  try {
    const resultMessage = await RNVerifaiCore.start();
    console.log(resultMessage);
  } catch (e) {
    console.error(e);
  }
}

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

export default App;
