import { useState } from 'react';
import { ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { type RouteProp, useRoute } from '@react-navigation/native';

import Picker from '../components/Picker';
import Button from '../components/Button';

import { CARD_ALGORITHMS, CARD_CURVES } from '../constants';
import { CMD, type RootStackParamList } from '../types';
import ReactNativeArculusCsdk from '@aptos-labs/react-native-arculus-csdk';

const OutputScreen = () => {
  const {
    params: { command },
  } = useRoute<RouteProp<RootStackParamList, 'Output'>>();

  const [input1, setInput1] = useState('');
  const [input2, setInput2] = useState(() => {
    switch (command.cmd) {
      case CMD.CreateWalletSeed:
        return '12';
      case CMD.SignHashPath:
        return 'EA83CDCDD06BF61E414054115A551E23133711D0507DCBC07A4BAB7DC4581935';
      default:
        return '';
    }
  });
  const [curveType, setCurveType] = useState<number>();
  const [hashAlgorithm, setHashAlgorithm] = useState<number>();
  const [output, setOutput] = useState('');

  const handleExecute = () => {
    setOutput(
      `Executed ${command.name} with Input 1: ${input1} and Input 2: ${input2}`
    );
    switch (command.cmd) {
      case CMD.GetGGUID:
        ReactNativeArculusCsdk.getGGUID().then(setOutput);
        break;
      case CMD.GetVersion:
        ReactNativeArculusCsdk.getVersion().then(setOutput);
        break;
      case CMD.VerifyPIN:
        ReactNativeArculusCsdk.verifyPIN(input1).then(setOutput);
        break;
      case CMD.StorePIN:
        ReactNativeArculusCsdk.storePIN(input1).then(setOutput);
        break;
      case CMD.UpdatePIN:
        ReactNativeArculusCsdk.updatePIN(input1, input2).then(setOutput);
        break;
      case CMD.CreateWalletSeed:
        ReactNativeArculusCsdk.createWalletSeed(input1, input2).then(setOutput);
        break;
      case CMD.CreateAptosWalletSeed:
        ReactNativeArculusCsdk.createAptosWalletSeed(input1).then(setOutput);
        break;
      default:
        break;
    }
  };

  return (
    <ScrollView style={styles.container} keyboardShouldPersistTaps={'handled'}>
      <View style={[!command.inp1 && styles.hidden]}>
        <Text style={styles.label}>{command.inp1}</Text>
        <TextInput
          style={styles.input}
          value={input1}
          onChangeText={setInput1}
        />
      </View>
      <View style={[!command.inp2 && styles.hidden]}>
        <Text style={styles.label}>{command.inp2}</Text>
        <TextInput
          style={[styles.input, styles.input2]}
          verticalAlign={'top'}
          value={input2}
          onChangeText={setInput2}
          multiline={true}
          numberOfLines={2}
        />
      </View>
      <View style={[command.cmd !== CMD.SignHashPath && styles.hidden]}>
        <Text style={styles.label}>Curve and Hash Algorithm</Text>
        <View style={styles.input3}>
          <Picker
            selectedValue={curveType}
            onValueChange={setCurveType}
            items={CARD_CURVES}
          />
          <Picker
            selectedValue={hashAlgorithm}
            onValueChange={setHashAlgorithm}
            items={CARD_ALGORITHMS}
          />
        </View>
      </View>
      <Button title="Execute" onPress={handleExecute} />
      <Text style={styles.label}>{command.out}</Text>
      <TextInput
        style={[styles.input, styles.output]}
        value={output}
        editable={false}
        multiline={true}
        numberOfLines={10}
      />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 10,
    backgroundColor: '#fff',
  },
  hidden: {
    opacity: 0,
  },
  input: {
    backgroundColor: '#dfdee4',
    padding: 10,
    marginTop: 15,
    marginBottom: 10,
  },
  input2: {
    height: 60,
  },
  input3: {
    flexDirection: 'row',
    marginTop: 15,
    marginBottom: 10,
  },
  label: {
    fontSize: 17,
  },
  output: {
    height: 180,
  },
});

export default OutputScreen;
