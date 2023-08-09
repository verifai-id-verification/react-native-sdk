import * as React from 'react';

import { Liveness, LivenessCheck } from '@verifai/react-native-sdk'
import { SafeAreaView, Image, ScrollView, Text } from 'react-native'
import styles from './Styles'
import VerifaiButton from './VerifaiButton'
import { deleteFields } from './Utils'

function ScanResultScreen({ route, navigation }) {
  const { scanResult, image } = route.params

  return (
    <SafeAreaView style={styles.container}>
      <VerifaiButton
        title='Start Liveness'
        onPress={
          async () => {
            try {
              // Print scan result to the console
              console.log(JSON.stringify(scanResult, null, 2))

              // Configure the module if you want to customize the default behaviour
              await Liveness.configure({
                showDismissButton: true,
                customSkipButtonTitle: 'Close',
                showSkipButton: true,
              })

              // Now we can start the liveness check, this shows the liveness check screen
              // There are a few things we can setup while starting the liveness check
              // to see the full list check out the documentation.
              // Important: For the liveness check to work properly the main scan should have been performed
              let checks: { [key: string]: any }[] = [
                {
                  type: LivenessCheck.CloseEyes,
                  numberOfSeconds: 3,
                  instruction: 'Hi, please close your eyes.', // Optional for customization
                },
                {
                  type: LivenessCheck.Tilt,
                  faceAngle: 15,
                },
                {
                  // iOS only check, on Android it is ignored
                  type: LivenessCheck.Speech,
                  speechRequirement: 'Hi React Native example',
                  locale: 'en-US', // Underscore is not supported for locale string
                },
              ]

              // For face matching you can use either the document front image from the core,
              // or the face image from the NFC module
              if (image != null) {
                checks.push({
                  type: LivenessCheck.FaceMatching,
                  documentImage: image,
                })
              }
              const result = await Liveness.start(checks)
              deleteFields(result, ["documentImage"])
              navigation.navigate('Liveness result', {
                result: result,
              })
            } catch (e) {
              console.error(e)
            }
          }
        }
      />

      <ScrollView style={{ height: '50%' }}>
        {
          image ? <Image
            style={{
              width: '100%',
              height: undefined,
              aspectRatio: image.width / image.height,
            }}
            source={{
              uri: 'data:image/png;base64,' + image.base64,
            }}
          /> : null
        }
      </ScrollView>
      <ScrollView style={{ height: '50%' }}>
        <Text
          style={{
            width: '100%',
            height: undefined,
          }}
        >Result: {JSON.stringify(scanResult, null, 2)}</Text>
      </ScrollView>
    </SafeAreaView>
  );
}

export default ScanResultScreen
