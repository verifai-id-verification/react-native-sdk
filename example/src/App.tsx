import * as React from 'react';

import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from './HomeScreen'
import ScanResultScreen from './ScanResultScreen'
import LivenessResultScreen from './LivenessResultScreen';

const Stack = createNativeStackNavigator();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name='Verifai Example Home' component={HomeScreen} />
        <Stack.Screen name='Scan result' component={ScanResultScreen} />
        <Stack.Screen name='Liveness result' component={LivenessResultScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default App
