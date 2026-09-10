import React from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { LevelDef } from '../types';

interface Props {
  levels: LevelDef[];
  onSelect: (index: number) => void;
}

export default function LevelSelectScreen({ levels, onSelect }: Props) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Origami Sayı Katları</Text>
      <Text style={styles.subtitle}>Doğru sırayla katla, hedefe ulaş.</Text>
      <FlatList
        data={levels}
        keyExtractor={(item) => item.id}
        numColumns={4}
        columnWrapperStyle={styles.row}
        contentContainerStyle={styles.list}
        renderItem={({ item, index }) => (
          <Pressable style={styles.levelButton} onPress={() => onSelect(index)}>
            <Text style={styles.levelNumber}>{index + 1}</Text>
          </Pressable>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAF3E0',
    paddingTop: 80,
    paddingHorizontal: 24,
  },
  title: {
    fontSize: 26,
    fontWeight: '800',
    color: '#4A3B22',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#A0895A',
    textAlign: 'center',
    marginTop: 6,
    marginBottom: 32,
  },
  list: {
    alignItems: 'center',
  },
  row: {
    justifyContent: 'center',
    gap: 14,
    marginBottom: 14,
  },
  levelButton: {
    width: 60,
    height: 60,
    borderRadius: 16,
    backgroundColor: '#FFF',
    borderWidth: 2,
    borderColor: '#E4C687',
    alignItems: 'center',
    justifyContent: 'center',
  },
  levelNumber: {
    fontSize: 20,
    fontWeight: '700',
    color: '#7A5A2E',
  },
});
