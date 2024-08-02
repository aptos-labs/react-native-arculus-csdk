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

import { type Command, type RootStackParamList } from '../types';

const sections: ReadonlyArray<SectionListData<Command, { title: string }>> = [
  {
    title: 'CARD BASICS',
    data: [
      {
        title: 'Get Card GGUID',
        handler: async () => 'not implemented',
        output: 'Card GGUID',
      },
      {
        title: 'Get Firmware Vers',
        handler: async () => 'not implemented',
        output: 'Firmware Version',
      },
      {
        title: 'Verify PIN',
        inputs: ['pin'],
        handler: async () => 'not implemented',
        output: 'Output',
      },
      {
        title: 'Store PIN',
        inputs: ['pin'],
        handler: async () => 'not implemented',
        output: 'Output',
      },
      {
        title: 'Update PIN',
        inputs: ['oldPin', 'newPin'],
        handler: async () => 'not implemented',
        output: 'Status',
      },
    ],
  },
  {
    title: 'CREATE WALLET',
    data: [
      {
        title: 'Create Wallet (Seed)',
        inputs: ['pin', 'wordCount', 'path', 'curve'],
        handler: async () => 'not implemented',
        output: 'New Phrase/Keys',
      },
      {
        title: 'Create Aptos Wallet (Seed)',
        inputs: ['pin'],
        handler: async () => 'not implemented',
        output: 'New Phrase/Keys',
      },
    ],
  },
  {
    title: 'RESTORE WALLET',
    data: [
      {
        title: 'Restore Wallet (Seed)',
        inputs: ['pin', 'words', 'path', 'curve'],
        handler: async () => 'not implemented',
        output: 'Keys',
      },
    ],
  },
  {
    title: 'RESET WALLET',
    data: [
      {
        title: 'Reset Wallet',
        inputs: [],
        handler: async () => 'not implemented',
        output: 'Status',
      },
    ],
  },
  {
    title: 'PUBLIC KEYS',
    data: [
      {
        title: 'Get PubKey By Path',
        inputs: ['path', 'curve'],
        handler: async () => 'not implemented',
        output: 'PubKey',
      },
      {
        title: 'Get Aptos PubKey',
        inputs: [],
        handler: async () => 'not implemented',
        output: 'PubKey',
      },
    ],
  },
  {
    title: 'SIGN HASH DATA',
    data: [
      {
        title: 'Sign Hash By Path',
        inputs: ['pin', 'path', 'curve', 'algorithm', 'hash'],
        handler: async () => 'not implemented',
        output: 'Signed Hash',
      },
      {
        title: 'Sign Aptos Hash',
        inputs: ['pin', 'hash'],
        handler: async () => 'not implemented',
        output: 'Signed Hash',
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
