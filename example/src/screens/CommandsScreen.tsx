import {
  SectionList,
  type SectionListData,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { AptosCard, ArculusCard } from '@aptos-labs/react-native-arculus-csdk';

import { type Command, type RootStackParamList } from '../types';

const sections: ReadonlyArray<SectionListData<Command, { title: string }>> = [
  {
    title: 'ARCULUS CARD',
    data: [
      {
        title: 'Change PIN',
        inputs: ['oldPIN', 'newPIN'],
        handler: ArculusCard.changePIN,
        output: '',
      },
      {
        title: 'Create wallet',
        inputs: ['pin', 'nbrOfWords'],
        handler: ({ wordCount, ...args }) =>
          ArculusCard.createWallet({
            ...args,
            wordCount: Number(wordCount),
          }),
        output: 'Phrase',
      },
      {
        title: 'Get firmware version',
        handler: ArculusCard.getFirmwareVersion,
        output: 'Firmware Version',
      },
      {
        title: 'Get GGUID',
        handler: ArculusCard.getGGUID,
        output: 'GGUID',
      },
      {
        title: 'Get info',
        inputs: ['path', 'curve'],
        handler: ({ curve, ...args }) =>
          ArculusCard.getInfo({ ...args, curve: Number(curve) }),
        output: 'Info',
      },
      {
        title: 'Get public key from path',
        inputs: ['path', 'curve'],
        handler: ({ curve, ...args }) =>
          ArculusCard.getPublicKeyFromPath({ ...args, curve: Number(curve) }),
        output: 'Public key',
      },
      {
        title: 'Reset wallet',
        inputs: [],
        handler: ArculusCard.resetWallet,
        output: '',
      },
      {
        title: 'Restore wallet',
        inputs: ['pin', 'mnemonicSentence'],
        handler: ArculusCard.restoreWallet,
        output: '',
      },
      {
        title: 'Sign hash',
        inputs: ['pin', 'path', 'curve', 'algorithm', 'hash'],
        handler: ({ curve, algorithm, ...args }) =>
          ArculusCard.signHash({
            ...args,
            curve: Number(curve),
            algorithm: Number(algorithm),
          }),
        output: 'Signed hash',
      },
      {
        title: 'Verify PIN',
        inputs: ['pin'],
        handler: ArculusCard.verifyPIN,
        output: '',
      },
    ],
  },
  {
    title: 'APTOS CARD',
    data: [
      {
        title: 'Create wallet',
        inputs: ['pin'],
        handler: AptosCard.createWallet,
        output: 'Phrase',
      },
      {
        title: 'Get info',
        inputs: [],
        handler: AptosCard.getInfo,
        output: 'Info',
      },
      {
        title: 'Get public key',
        inputs: [],
        handler: AptosCard.getPublicKey,
        output: 'Public key',
      },
      {
        title: 'Sign hash',
        inputs: ['pin', 'hash'],
        handler: AptosCard.signHash,
        output: 'Signed hash',
      },
    ],
  },
];

const SectionSeparatorComponent = () => (
  <View style={styles.sectionSeparator} />
);

const ItemSeparatorComponent = () => <View style={styles.itemSeparator} />;

const CommandsScreen = () => {
  const { navigate } =
    useNavigation<NativeStackNavigationProp<RootStackParamList>>();

  return (
    <SectionList
      stickySectionHeadersEnabled={false}
      sections={sections}
      keyExtractor={(command) => command.title}
      SectionSeparatorComponent={SectionSeparatorComponent}
      ItemSeparatorComponent={ItemSeparatorComponent}
      renderItem={({ item: command }) => (
        <TouchableOpacity
          style={styles.itemContainer}
          onPress={() => navigate('Output', { command })}
        >
          <Text style={styles.itemText}>{command.title}</Text>
        </TouchableOpacity>
      )}
      renderSectionHeader={({ section: { title } }) => (
        <View style={styles.sectionHeaderContainer}>
          <Text style={styles.sectionHeaderTitle}>{title}</Text>
        </View>
      )}
      style={styles.sectionList}
    />
  );
};

const styles = StyleSheet.create({
  itemContainer: {
    paddingLeft: 40,
    paddingRight: 20,
    paddingVertical: 10,
  },
  itemSeparator: {
    marginLeft: 16,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderColor: 'lightgrey',
  },
  itemText: {
    fontSize: 18,
  },
  sectionHeaderContainer: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 8,
  },
  sectionHeaderTitle: {
    color: 'grey',
    fontSize: 13,
  },
  sectionList: {
    backgroundColor: 'white',
  },
  sectionSeparator: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderColor: 'lightgrey',
  },
});

export default CommandsScreen;
