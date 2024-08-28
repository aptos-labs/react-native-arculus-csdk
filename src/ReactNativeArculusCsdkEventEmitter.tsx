import { NativeEventEmitter } from 'react-native';

import ReactNativeArculusCsdk from './ReactNativeArculusCsdk';

type ReactNativeArculusCsdkEvents =
  | 'ArculusCardConnected'
  | 'ArculusCardConnectionClosed'
  | 'ArculusCardStartScanning';

class ReactNativeArculusCsdkEventEmitter extends NativeEventEmitter {
  constructor() {
    super(ReactNativeArculusCsdk);
  }

  override addListener(
    eventType: ReactNativeArculusCsdkEvents,
    listener: (event: any) => void,
    context?: Object
  ) {
    return super.addListener(eventType, listener, context);
  }
}

const reactNativeArculusCsdkEventEmitter =
  new ReactNativeArculusCsdkEventEmitter();

export default reactNativeArculusCsdkEventEmitter;
