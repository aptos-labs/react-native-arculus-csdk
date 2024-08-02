import type { FC, ReactNode } from 'react';
import { StyleSheet, Text, TouchableOpacity } from 'react-native';

export type ButtonProps = {
  disabled?: boolean | undefined;
  onPress: () => void;
  title?: ReactNode | undefined;
};

const Button: FC<ButtonProps> = ({ disabled, onPress, title }) => {
  return (
    <TouchableOpacity
      disabled={disabled}
      onPress={onPress}
      style={styles.container}
    >
      <Text style={[styles.title, disabled && styles.disabled]}>{title}</Text>
    </TouchableOpacity>
  );
};

export default Button;

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#0275e3',
    alignSelf: 'center',
    paddingHorizontal: 50,
    paddingVertical: 10,
    marginVertical: 8,
  },
  disabled: {
    color: '#00000033',
  },
  title: {
    color: '#fff',
    fontSize: 17,
  },
});
