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

import { CMD, type Command, type RootStackParamList } from '../types';

const sections: ReadonlyArray<SectionListData<Command, { title: string }>> = [
  {
    title: 'CARD BASICS',
    data: [
      {
        cmd: CMD.GetGGUID,
        name: 'Get Card GGUID',
        inp1: null,
        inp2: null,
        out: 'Card GGUID',
      },
      {
        cmd: CMD.GetVersion,
        name: 'Get Firmware Vers',
        inp1: null,
        inp2: null,
        out: 'Firmware Version',
      },
      {
        cmd: CMD.VerifyPIN,
        name: 'Verify PIN',
        inp1: 'PIN',
        inp2: null,
        out: 'Output',
      },
      {
        cmd: CMD.StorePIN,
        name: 'Store PIN',
        inp1: 'PIN',
        inp2: null,
        out: 'Output',
      },
      {
        cmd: CMD.UpdatePIN,
        name: 'Update PIN',
        inp1: 'Old PIN',
        inp2: 'New PIN',
        out: 'Status',
      },
    ],
  },
  {
    title: 'CREATE WALLET',
    data: [
      {
        cmd: CMD.CreateWalletSeed,
        name: 'Create Wallet (Seed)',
        inp1: 'New PIN',
        inp2: '# Words',
        out: 'New Phrase/Keys',
      },
      {
        cmd: CMD.CreateAptosWalletSeed,
        name: 'Create Aptos Wallet (Seed)',
        inp1: 'New PIN',
        inp2: null,
        out: 'New Phrase/Keys',
      },
    ],
  },
  {
    title: 'RESTORE WALLET',
    data: [
      {
        cmd: CMD.RestoreWalletSeed,
        name: 'Restore Wallet (Seed)',
        inp1: 'New PIN',
        inp2: 'Phrase',
        out: 'Keys',
      },
    ],
  },
  {
    title: 'RESET WALLET',
    data: [
      {
        cmd: CMD.ResetWallet,
        name: 'Reset Wallet',
        inp1: null,
        inp2: null,
        out: 'Status',
      },
    ],
  },
  {
    title: 'PUBLIC KEYS',
    data: [
      {
        cmd: CMD.GetPubKeyByPath,
        name: 'Get PubKey By Path',
        inp1: 'Path',
        inp2: 'Curve (0100, etc.)',
        out: 'PubKey',
      },
    ],
  },
  {
    title: 'SIGN HASH DATA',
    data: [
      {
        cmd: CMD.SignHashPath,
        name: 'Sign Hash By Path',
        inp1: 'PIN, Path',
        inp2: 'Hash (hex)',
        out: 'Signed Hash',
      },
      {
        cmd: CMD.SignAptosHash,
        name: 'Sign Aptos Hash',
        inp1: 'PIN',
        inp2: 'Hash (hex)',
        out: 'Signed Hash',
      },
    ],
  },
];

const CommandsScreen = () => {
  const { navigate } =
    useNavigation<NativeStackNavigationProp<RootStackParamList>>();

  return (
    <SectionList
      stickySectionHeadersEnabled={false}
      sections={sections}
      keyExtractor={(command) => command.name}
      SectionSeparatorComponent={() => (
        <View
          style={{
            borderBottomWidth: StyleSheet.hairlineWidth,
            borderColor: 'lightgrey',
          }}
        />
      )}
      ItemSeparatorComponent={() => (
        <View
          style={{
            marginLeft: 16,
            borderBottomWidth: StyleSheet.hairlineWidth,
            borderColor: 'lightgrey',
          }}
        />
      )}
      renderItem={({ item: command }) => (
        <TouchableOpacity
          style={styles.itemContainer}
          onPress={() => navigate('Output', { command })}
        >
          <Text style={styles.itemText}>{command.name}</Text>
        </TouchableOpacity>
      )}
      renderSectionHeader={({ section: { title } }) => (
        <View style={styles.sectionHeaderContainer}>
          <Text style={styles.sectionHeaderTitle}>{title}</Text>
        </View>
      )}
      style={{ backgroundColor: 'white' }}
    />
  );
};

const styles = StyleSheet.create({
  itemContainer: {
    paddingLeft: 40,
    paddingRight: 20,
    paddingVertical: 10,
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
  commandItem: {
    padding: 15,
    backgroundColor: '#fff',
    borderRadius: 5,
    marginVertical: 5,
  },
});

export default CommandsScreen;
