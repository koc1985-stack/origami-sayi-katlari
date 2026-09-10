import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

interface Props {
  value: number;
  highlighted?: boolean;
}

export default function Cell({ value, highlighted }: Props) {
  return (
    <View style={[styles.cell, highlighted && styles.cellHighlighted]}>
      <Text style={styles.value}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  cell: {
    minWidth: 56,
    height: 56,
    borderRadius: 14,
    backgroundColor: '#FDF6E9',
    borderWidth: 2,
    borderColor: '#E4C687',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 8,
    shadowColor: '#000',
    shadowOpacity: 0.08,
    shadowRadius: 3,
    shadowOffset: { width: 0, height: 2 },
  },
  cellHighlighted: {
    backgroundColor: '#FFF1C9',
    borderColor: '#E0A62E',
  },
  value: {
    fontSize: 20,
    fontWeight: '700',
    color: '#4A3B22',
  },
});
