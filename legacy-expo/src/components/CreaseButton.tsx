import React from 'react';
import { Pressable, StyleSheet, Text } from 'react-native';
import { Operator } from '../types';

interface Props {
  operator: Operator;
  onPress: () => void;
}

const OPERATOR_COLORS: Record<Operator, string> = {
  '+': '#3E8E5A',
  '×': '#7A4FC9',
};

export default function CreaseButton({ operator, onPress }: Props) {
  const color = OPERATOR_COLORS[operator];
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.crease,
        { borderColor: color },
        pressed && { backgroundColor: color },
      ]}
      hitSlop={10}
      accessibilityLabel={`${operator} işlemiyle katla`}
    >
      {({ pressed }) => (
        <Text style={[styles.symbol, { color: pressed ? '#FFF' : color }]}>{operator}</Text>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  crease: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 2,
    backgroundColor: '#FFFFFF',
  },
  symbol: {
    fontSize: 18,
    fontWeight: '800',
  },
});
