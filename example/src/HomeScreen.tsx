
import * as React from 'react';

import { SafeAreaView, View, Image } from 'react-native'
import {
  Core,
  NFC,
  InstructionScreenId,
  NfcInstructionScreenId,
  InstructionType,
  InstructionArgument,
  ValidatorType,
  DocumentFilterType,
  DocumentType,
} from '@verifai/react-native-sdk';
import FlowComboBox, { FlowType } from './FlowComboBox'
import VerifaiButton from './VerifaiButton'
import license from './License'
import styles from './Styles'
import { deleteFields } from './Utils'

function HomeScreen({ navigation }) {
  const [selectedFlowValue, setSelectedFlowValue] = React.useState(FlowType.Api);
  const handleFlowValueChange = (value: FlowType, _itemIndex: Number) => {
    setSelectedFlowValue(value);
  }

  return (
    <SafeAreaView style={styles.container}>
      <FlowComboBox onValueChange={handleFlowValueChange} />

      <View style={styles.spacer}></View>

      <VerifaiButton
        title='Core Scan'
        onPress={
          async () => {
            try {
              // Example of setting up the Core SDK
              // Set the license (more info in the documentation)
              await Core.setLicense(license)

              const validators = [
                {
                  type: ValidatorType.DocumentCountryBlocklist,
                  countryCodes: ['NL'],
                },
                {
                  type: ValidatorType.DocumentTypes,
                  documentTypes: [
                    DocumentType.DrivingLicense
                  ],
                },
                {
                  type: ValidatorType.NfcKeyWhenAvailable,
                },
              ]

              const filters = [
                {
                  type: DocumentFilterType.DocumentAllowlist,
                  countryCodes: ['NL'],
                },
                {
                  type: DocumentFilterType.DocumentTypeAllowlist,
                  documentTypes: [DocumentType.Passport],
                }
              ]

              const instructionScreenConfig = {
                showInstructionScreens: true,
                instructionScreens: {
                  [InstructionScreenId.MrzPresentFlowInstruction]: {
                    type: InstructionType.Web,
                    arguments: {
                      type: InstructionArgument.Web,
                      title: 'Example title',
                      url: 'https://www.verifai.com',
                      continueButtonLabel: 'Test',
                      negativeButtonLabel: 'Stop',
                    }
                  }
                }
              }

              // Optional: Configure the SDK, for possible values please check the documentation
              // Default values are optional and only listed here for example purposes
              await Core.configure({
                requireDocumentCopy: true,
                enableCropping: true,
                enableManualFlow: true,
                requireMrz: false,
                requireNfcWhenAvailable: false,
                validators: [], // To use the example: validators: validators,
                documentFilters: [], // To use the example: documentFilters: filters,
                autoCreateValidators: true,
                isScanHelpEnabled: true,
                requireCroppedImage: true,
                instructionScreenConfiguration: {}, // To use the example: instructionScreenConfiguration: instructionScreenConfig,
                enableVisualInspection: false,
              })

              // Start the SDK, this displays the SDK on the screen
              // In your own app you'll only implement one of these two flows
              let result: any | null = null;
              switch (selectedFlowValue) {
                case FlowType.Api:
                  result = await Core.start('React Native Core') // Pass string argument: `internal reference`
                  break;
                case FlowType.Local:
                  result = await Core.startLocal()
                  break;
              }

              let frontImage: String = result.frontImage
              // Filter out the base64 images for console print
              deleteFields(result, ['frontImage', 'backImage'])
              navigation.navigate('Scan result', {
                scanResult: result,
                image: frontImage,
              })
            } catch (e) {
              console.error(e)
              if (e.code === 'canceled') {
                // Use this if you want to implement specifc logic handling the canceled flow
                console.log('Flow was aborted')
              }
            }
          }
        }
      />

      <VerifaiButton
        title='NFC Scan'
        onPress={
          async () => {
            try {
              // Set the license (more info in the documentation)
              await NFC.setLicense(license)

              const instructionScreenConfig = {
                showInstructionScreens: true,
                instructionScreens: {
                  [NfcInstructionScreenId.NfcScanFlowInstruction]: {
                    type: InstructionType.Web,
                    arguments: {
                      type: InstructionArgument.Web,
                      title: 'Example title',
                      url: 'https://www.verifai.com',
                      continueButtonLabel: 'Start',
                      negativeButtonLabel: 'Stop',
                    }
                  }
                },
              }

              // Now we can configure the NFC SDK. This will present the scanning screen.
              // There are a few things we can setup while starting the NFC check
              // to see the full list check out the documentation.
              await NFC.configure({
                // Core config is exactly as the configuration for the Core module shown above
                core: {
                  enableManualFlow: true,
                },
                nfc: {
                  retrieveFaceImage: true,
                  instructionScreenConfiguration: {}, // To use the example: instructionScreenConfiguration: instructionScreenConfig,
                }
              })

              // Start the NFC SDK. This will start the core flow first,
              // and the NFC flow immediately afterwards.
              // In your own app you'll only implement one of these two flows
              let result: any | null = null;
              let faceImage: any | null = null;
              switch (selectedFlowValue) {
                case FlowType.Api:
                  result = await NFC.start('React Native NFC') // Pass string argument: `internal reference`
                  faceImage = result.faceImage
                  break;
                case FlowType.Local:
                  result = await NFC.startLocal()
                  if (result.nfc != null) {
                    faceImage = result.nfc.faceImage
                  }
                  break;
              }

              // Filter out the base64 images for console print
              deleteFields(result, ['frontImage', 'backImage', 'faceImage'])
              navigation.navigate('Scan result', {
                scanResult: result,
                image: faceImage,
              })

              if (result.nfcError != null) {
                // NFC failed, but there is still a result from the core scan
                console.error(result.nfcError)
              }
            } catch (e) {
              console.error(e)
              if (e.code === 'canceled') {
                // Use this if you want to implement specifc logic handling the canceled flow
                console.log('Flow was aborted')
              }
            }
          }
        }
      />

      <View style={styles.spacer}></View>

      <View style={styles.footer}>
        <Image source={require('./Verifai_logo.png')} style={{height: 25, width: 109}} />
      </View>
    </SafeAreaView>
  );
}

export default HomeScreen;
