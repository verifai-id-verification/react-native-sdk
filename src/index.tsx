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

enum LivenessCheck {
  CloseEyes = 0,
  Tilt,
  Speech,
  FaceMatching,
}

enum VerifaiInstructionScreenId {
  MrzPresentFlowInstruction = 0, // Also known as MO1
  MrzScanFlowInstruction, // Also known as MO2
  MrzNotDetectedHint, // Also known as MO6, The blue hint instruction screen
  DocumentPickerHelp // The question mark button in the document picker
}

enum VerifaiInstructionType {
  Default = 0,
  Media,
  Web,
  Hidden
}

enum VerifaiValidatorType {
  DocumentCountryWhitelist = 0,
  DocumentCountryBlackList,
  DocumentHasMrz,
  DocumentTypes,
  MrzAvailable,
  NFCKeyWhenAvailable
}

enum VerifaiDocumentFilterType {
  DocumentTypeWhiteList = 0,
  DocumentWhiteList,
  DocumentBlackList,
}

enum VerifaiDocumentType {
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

enum FaceMatchImageSource {
  DocumentScan = 0,
  Nfc
}

export {
  Core, Liveness, NFC,
  LivenessCheck,
  VerifaiInstructionScreenId,
  VerifaiInstructionType,
  VerifaiValidatorType,
  VerifaiDocumentFilterType,
  VerifaiDocumentType,
  FaceMatchImageSource
};