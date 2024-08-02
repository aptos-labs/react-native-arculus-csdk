import { useState } from 'react';
import { ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { type RouteProp, useRoute } from '@react-navigation/native';

import { Button } from '../components';
import { type RootStackParamList } from '../types';

const OutputScreen = () => {
  const {
    params: { command },
  } = useRoute<RouteProp<RootStackParamList, 'Output'>>();

  const [inputs, setInputs] = useState<{ [key: string]: string } | undefined>(
    undefined
  );

  const handleInputChange = (key: string) => (value: string) =>
    setInputs({ ...inputs, [key]: value });

  const [output, setOutput] = useState('');

  const handler = () => (inputs ? command.handler(inputs) : command.handler());

  const execute = async () => {
    try {
      const response = await handler();

      return {
        response,
        type: typeof response,
      };
    } catch (e) {
      if (e instanceof Error) {
        return e.message;
      }

      return e;
    }
  };

  const handleExecute = async () => {
    setOutput(
      `Executed ${command.title} with inputs: ${JSON.stringify(inputs)}`
    );

    setOutput(JSON.stringify(await execute(), null, 2));
  };

  return (
    <ScrollView style={styles.container} keyboardShouldPersistTaps={'handled'}>
      {command.inputs?.map((input) => (
        <View key={input}>
          <Text style={styles.label}>{input}</Text>
          <TextInput
            style={styles.input}
            value={inputs?.[input]}
            onChangeText={handleInputChange(input)}
          />
        </View>
      ))}
      <Button title="Execute" onPress={handleExecute} />
      <Text style={styles.label}>{command.output}</Text>
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
