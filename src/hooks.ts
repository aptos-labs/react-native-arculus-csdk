import { useCallback, useEffect, useState } from 'react';

import reactNativeArculusCsdkEventEmitter from './ReactNativeArculusCsdkEventEmitter';

type ArculusCardConnectionStatus = 'closed' | 'scanning' | 'connected';

type UseArculusCardConnectionStatusArgs = {
  onConnectionClose?: () => void;
  onConnect?: () => void;
  onStartScanning?: () => void;
};

export const useArculusCardConnectionStatus = (
  args?: UseArculusCardConnectionStatusArgs
) => {
  const { onConnectionClose, onConnect, onStartScanning } = args ?? {};

  const [status, setStatus] = useState<ArculusCardConnectionStatus>('closed');

  const handleCardConnected = useCallback(() => {
    setStatus('connected');

    onConnect?.();
  }, [onConnect]);

  useEffect(
    () =>
      reactNativeArculusCsdkEventEmitter.addListener(
        'ArculusCardConnected',
        handleCardConnected
      ).remove,
    [handleCardConnected]
  );

  const handleCardConnectionClosed = useCallback(() => {
    setStatus('closed');

    onConnectionClose?.();
  }, [onConnectionClose]);

  useEffect(
    () =>
      reactNativeArculusCsdkEventEmitter.addListener(
        'ArculusCardConnectionClosed',
        handleCardConnectionClosed
      ).remove,
    [handleCardConnectionClosed]
  );

  const handleStartScanning = useCallback(() => {
    setStatus('scanning');

    onStartScanning?.();
  }, [onStartScanning]);

  useEffect(
    () =>
      reactNativeArculusCsdkEventEmitter.addListener(
        'ArculusCardStartScanning',
        handleStartScanning
      ).remove,
    [handleStartScanning]
  );

  return {
    isClosed: status === 'closed',
    isConnected: status === 'connected',
    isScanning: status === 'scanning',
    status,
  };
};
