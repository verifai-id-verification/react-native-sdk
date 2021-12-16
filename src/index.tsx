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
export { Core, Liveness, NFC };
