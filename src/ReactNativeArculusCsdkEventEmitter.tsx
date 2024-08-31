import { NativeEventEmitter } from 'react-native';

import ReactNativeArculusCsdk from './ReactNativeArculusCsdk';

export type ReactNativeArculusCsdkEvent =
  | 'ConnectionClosed'
  | 'ConnectionOpened'
  | 'ScanningStarted'
  | 'ScanningStopped';

class ReactNativeArculusCsdkEventEmitter extends NativeEventEmitter {
  constructor() {
    super(ReactNativeArculusCsdk);
  }

  override addListener(
    eventType: ReactNativeArculusCsdkEvent,
    listener: (event: any) => void,
    context?: Object
  ) {
    return super.addListener(eventType, listener, context);
  }
}

const reactNativeArculusCsdkEventEmitter =
  new ReactNativeArculusCsdkEventEmitter();

export default reactNativeArculusCsdkEventEmitter;
