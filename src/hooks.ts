import { useCallback, useEffect, useState } from 'react';

import reactNativeArculusCsdkEventEmitter, {
  type ReactNativeArculusCsdkEvent,
} from './ReactNativeArculusCsdkEventEmitter';

export const useArculusCardEvent = (
  eventType: ReactNativeArculusCsdkEvent,
  listener: (event: any) => void
) => {
  useEffect(() => {
    const subscription = reactNativeArculusCsdkEventEmitter.addListener(
      eventType,
      listener
    );

    return () => {
      subscription.remove();
    };
  }, [eventType, listener]);
};

type ArculusCardConnectionStatus = 'closed' | 'open' | 'scanning';

type UseArculusCardConnectionStatusArgs = {
  onConnectionClosed?: () => void;
  onConnectionOpened?: () => void;
  onScanningStarted?: () => void;
};

export const useArculusCardConnectionStatus = (
  args?: UseArculusCardConnectionStatusArgs
) => {
  const { onConnectionClosed, onConnectionOpened, onScanningStarted } =
    args ?? {};

  const [status, setStatus] = useState<ArculusCardConnectionStatus>('closed');

  useArculusCardEvent(
    'ConnectionClosed',
    useCallback(() => {
      setStatus('closed');
      onConnectionClosed?.();
    }, [onConnectionClosed])
  );

  useArculusCardEvent(
    'ConnectionOpened',
    useCallback(() => {
      setStatus('open');
      onConnectionOpened?.();
    }, [onConnectionOpened])
  );

  useArculusCardEvent(
    'ScanningStarted',
    useCallback(() => {
      setStatus('scanning');
      onScanningStarted?.();
    }, [onScanningStarted])
  );

  return {
    isClosed: status === 'closed',
    isOpen: status === 'open',
    isScanning: status === 'scanning',
    status,
  };
};
