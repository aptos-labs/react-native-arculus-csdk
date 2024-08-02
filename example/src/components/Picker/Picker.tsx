import { Picker as RNPicker } from '@react-native-picker/picker';
import type { FC } from 'react';
import { StyleSheet } from 'react-native';

type PickerItem = {
  label: string;
  value: number;
};

export type PickerProps = {
  items: PickerItem[];
  selectedValue?: number;
  onValueChange: (value: number) => void;
};

const Picker: FC<PickerProps> = ({ items, selectedValue, onValueChange }) => {
  return (
    <RNPicker
      selectedValue={selectedValue}
      onValueChange={onValueChange}
      style={styles.picker}
      itemStyle={styles.item}
    >
      {items.map(({ label, value }) => (
        <RNPicker.Item key={value} label={label} value={value} />
      ))}
    </RNPicker>
  );
};

export default Picker;

const styles = StyleSheet.create({
  picker: {
    flex: 1,
  },
  item: {
    height: 40,
  },
});
