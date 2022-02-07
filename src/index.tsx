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
  MRZ_PRESENT_FLOW_INSTRUCTION = 0, // Also known as MO1
  MRZ_SCAN_FLOW_INSTRUCTION, // Also known as MO2
  MRZ_NOT_DETECTED_HINT, // Also known as MO6, The blue hint instruction screen
  DOCUMENT_PICKER_HELP // The question mark button in the document picker
}

enum VerifaiInstructionType {
  DEFAULT = 0,
  MEDIA,
  WEB,
  HIDDEN
}

enum VerifaiValidatorType {
  DocumentCountryWhitelist = 0,
  DocumentCountryBlackList,
  DocumentHasMrz,
  DocumentTypes,
  MrzAvailable,
  NFCKeyWhenAvailable
}

enum VerifaiDocumentType {
  idCard = 0,
  driversLicence,
  passport,
  refugee,
  emergencyPassport,
  residencePermitTypeI,
  residencePermitTypeII,
  visa,
  unknown
}

enum FaceMatchImageSource {
  documentScan = 0,
  nfc
}

export {
  Core, Liveness, NFC,
  LivenessCheck,
  VerifaiInstructionScreenId,
  VerifaiInstructionType,
  VerifaiValidatorType,
  VerifaiDocumentType,
  FaceMatchImageSource
};