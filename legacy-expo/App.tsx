import React, { useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView, StyleSheet } from 'react-native';
import LevelSelectScreen from './src/screens/LevelSelectScreen';
import GameScreen from './src/screens/GameScreen';
import { levels } from './src/data/levels';

export default function App() {
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);

  return (
    <SafeAreaView style={styles.root}>
      <StatusBar style="dark" />
      {selectedIndex === null ? (
        <LevelSelectScreen levels={levels} onSelect={setSelectedIndex} />
      ) : (
        <GameScreen
          level={levels[selectedIndex]}
          levelNumber={selectedIndex + 1}
          totalLevels={levels.length}
          onExit={() => setSelectedIndex(null)}
          onNextLevel={() =>
            setSelectedIndex((i) => (i !== null && i + 1 < levels.length ? i + 1 : i))
          }
          hasNextLevel={selectedIndex !== null && selectedIndex + 1 < levels.length}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: '#FAF3E0',
  },
});
