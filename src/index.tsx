import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'verifai-react-native-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

NativeModules.Core
  ? NativeModules.Core
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const { Core, Liveness, NFC } = NativeModules;

// Enum of possible liveness checks
enum LivenessCheck {
  CloseEyes = 0, // Check where a user is asked to close their eyes for x amount of time
  Tilt, // Check where a user is asked to tilt their head a certain amount of degrees
  Speech, // Check where the user is asked to say certain words
  FaceMatching, // Check where the user is asked to take a selfie and the face is matched with the one on the document or NFC
}

// Enum that describes an instruction screen
enum InstructionScreenId {
  MrzPresentFlowInstruction = 0, // Instruction screen that explains how to check if the document has an MRZ
  MrzScanFlowInstruction, // Instruction screen explaining what the MRZ is and where to scan it
  MrzNotDetectedHint, // The text inside the blue hint instruction screen (Android only)
  DocumentPickerHelp // The question mark button in the document picker
}

// Enum that describes an instruction screen type
enum InstructionType {
  Default = 0, // The Verifai default instruction screen
  Media, // A native instruction screen with your own custom values, check the docs for more info
  Web, // A instruction screen that opens and displays a URL provided by you. More info about this in the docs.
  Hidden // Do not display the instruction screen
}

// Enum that describes a document Validator type
enum ValidatorType {
  DocumentCountryWhitelist = 0, // Validator that only allows documents from the countries provided
  DocumentCountryBlackList, // Validator that blocks the documents from the countries provided
  DocumentHasMrz, // Validator that checks if document has an MRZ
  DocumentTypes, // Validator that only validates certain document types
  MrzAvailable, // Validator that requires the MRZ to be correct
  NFCKeyWhenAvailable // Validators that ensure the NFC key if available is correct
}

// Enum that describes document filters that filter the available documents in the manual document selection flow
enum DocumentFilterType {
  DocumentTypeWhiteList = 0, // Filter that only allows certain document types
  DocumentWhiteList, // Filter that only allows documents from certain provided countries
  DocumentBlackList, // Filter that blocks certain document countries
}

// Enum that describes certain document types
enum DocumentType {
  IdCard = 0,
  DriversLicence,
  Passport,
  Refugee,
  EmergencyPassport,
  ResidencePermitTypeI,
  ResidencePermitTypeII,
  Visa,
  Unknown
}

// Enum that describes the face image source to compare agains the selvie in the liveness check
enum FaceMatchImageSource {
  DocumentScan = 0,
  Nfc
}

export {
  Core, Liveness, NFC,
  LivenessCheck,
  InstructionScreenId,
  InstructionType,
  ValidatorType,
  DocumentFilterType,
  DocumentType,
  FaceMatchImageSource
};