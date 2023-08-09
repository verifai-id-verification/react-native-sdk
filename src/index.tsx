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

type ResultType = {
  [key: string]: any
};

const LivenessCheckPlatformStrings: ResultType = {
  ios: {
    CloseEyes: 'CloseEyes',
    Tilt: 'Tilt',
    Speech: 'Speech',
    FaceMatching: 'FaceMatching',
  },
  android: {
    CloseEyes: 'com.verifai.liveness.pub.checks.CloseEyes',
    Tilt: 'com.verifai.liveness.pub.checks.Tilt',
    Speech: 'com.verifai.liveness.pub.checks.Speech',
    FaceMatching: 'com.verifai.liveness.pub.checks.FaceMatching',
  },
};


// Enum of possible liveness checks
enum LivenessCheck {
  CloseEyes = LivenessCheckPlatformStrings[Platform.OS].CloseEyes,       // Check where a user is asked to close their eyes for x amount of time
  Tilt = LivenessCheckPlatformStrings[Platform.OS].Tilt,                 // Check where a user is asked to tilt their head a certain amount of degrees
  Speech = LivenessCheckPlatformStrings[Platform.OS].Speech,             // Check where the user is asked to say certain words (iOS only)
  FaceMatching = LivenessCheckPlatformStrings[Platform.OS].FaceMatching, // Check where the user is asked to take a selfie and the face is matched with the one on the document or NFC
}

// Enum for the type of a instruction screen in the Core module
enum InstructionScreenId {
  MrzPresentFlowInstruction = 'MrzPresentFlowInstruction', // Instruction screen that explains how to check if the document has an MRZ
  MrzScanFlowInstruction = 'MrzScanFlowInstruction',       // Instruction screen explaining what the MRZ is and where to scan it
  MrzNotDetectedHint = 'MrzNotDetectedHint',               // The text inside the blue hint instruction screen (Android only)
  DocumentPickerInstruction = 'DocumentPickerInstruction'  // The question mark button in the document picker
}

// Enum for the type of a instruction screen in the Nfc module
enum NfcInstructionScreenId {
  NfcScanFlowInstruction = 'NfcScanFlowInstruction'
}

// Enum that describes an instruction screen type
enum InstructionType {
  DefaultScreen = 'DefaultScreen', // The Verifai default instruction screen
  Custom = 'Custom',               // A native instruction screen with your own custom values, check the docs for more info
  Web = 'Web',                     // A instruction screen that opens and displays a URL provided by you. More info about this in the docs.
  Hidden = 'Hidden',               // Do not display the instruction screen
}

enum InstructionArgument {
  Custom = 'com.verifai.core.pub.instructionScreens.InstructionScreenArguments.Custom', // Custom argument type
  Web = 'com.verifai.core.pub.instructionScreens.InstructionScreenArguments.Web',       // Web argument type
}

// Enum that describes a document Validator type
enum ValidatorType {
  DocumentCountryAllowlist = 'DocumentCountryAllowlistValidator', // Only allows documents from the countries provided
  DocumentCountryBlocklist = 'DocumentCountryBlocklistValidator', // Blocks the documents from the countries provided
  DocumentHasMrz = 'DocumentHasMrzValidator',                     // Validates that the document has a MRZ
  DocumentTypes = 'DocumentTypesValidator',                       // Validates certain document types
  MrzAvailable = 'MrzAvailableValidator',                         // Validates that the MRZ has been read
  NfcKeyWhenAvailable = 'NfcKeyWhenAvailableValidator'            // Validates that the NFC key if available is correct
}

const DocumentFilterPlatformStrings: ResultType
 = {
  ios: {
    DocumentTypeAllowlist: 'DocumentTypeAllowlistFilter',
    DocumentAllowlist: 'DocumentAllowlistFilter',
    DocumentBlocklist: 'DocumentBlocklistFilter',
  },
  android: {
    DocumentTypeAllowlist: 'com.verifai.core.pub.filters.DocumentTypeAllowlistFilter',
    DocumentAllowlist: 'com.verifai.core.pub.filters.DocumentAllowlistFilter',
    DocumentBlocklist: 'com.verifai.core.pub.filters.DocumentBlocklistFilter',
  },
};

// Enum that describes document filters that filter the available documents in the manual document selection flow
enum DocumentFilterType {
  DocumentTypeAllowlist = DocumentFilterPlatformStrings[Platform.OS].DocumentTypeAllowlist, // Filter that only allows certain document types
  DocumentAllowlist = DocumentFilterPlatformStrings[Platform.OS].DocumentAllowlist,         // Filter that only allows documents from certain provided countries
  DocumentBlocklist = DocumentFilterPlatformStrings[Platform.OS].DocumentBlocklist,         // Filter that blocks certain document countries
}

// Enum that describes certain document types
enum DocumentType {
  Passport = 'Passport',
  IdentityCard = 'IdentityCard',
  DrivingLicense = 'DrivingLicense',
  RefugeeTravelDocument = 'RefugeeTravelDocument',
  EmergencyPassport = 'EmergencyPassport',
  ResidencePermitTypeI = 'ResidencePermitTypeI',
  ResidencePermitTypeII = 'ResidencePermitTypeII',
  Visa = 'Visa',
  Unknown = 'Unknown'
}

export {
  Core, Liveness, NFC,
  LivenessCheck,
  InstructionScreenId,
  NfcInstructionScreenId,
  InstructionType,
  InstructionArgument,
  ValidatorType,
  DocumentFilterType,
  DocumentType,
};
