import React, { useMemo, useState } from 'react';
import {
  LayoutAnimation,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  UIManager,
  View,
} from 'react-native';
import Cell from '../components/Cell';
import CreaseButton from '../components/CreaseButton';
import { createStripFromLevel, foldAt, isFinished, isSolved } from '../engine/foldEngine';
import { LevelDef, StripState } from '../types';

if (Platform.OS === 'android' && UIManager.setLayoutAnimationEnabledExperimental) {
  UIManager.setLayoutAnimationEnabledExperimental(true);
}

interface Props {
  level: LevelDef;
  levelNumber: number;
  totalLevels: number;
  onExit: () => void;
  onNextLevel: () => void;
  hasNextLevel: boolean;
}

export default function GameScreen({
  level,
  levelNumber,
  totalLevels,
  onExit,
  onNextLevel,
  hasNextLevel,
}: Props) {
  const [strip, setStrip] = useState<StripState>(() => createStripFromLevel(level));
  const [history, setHistory] = useState<StripState[]>([]);
  const [failedAttempt, setFailedAttempt] = useState(false);

  const finished = isFinished(strip);
  const won = finished && isSolved(strip, level.target);

  function animateAndSet(next: StripState) {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.spring);
    setStrip(next);
  }

  function handleFold(creaseIndex: number) {
    if (finished) return;
    setHistory((h) => [...h, strip]);
    setFailedAttempt(false);
    const next = foldAt(strip, creaseIndex);
    animateAndSet(next);
    if (next.cells.length === 1 && next.cells[0].value !== level.target) {
      setFailedAttempt(true);
    }
  }

  function handleUndo() {
    if (history.length === 0) return;
    const previous = history[history.length - 1];
    setHistory((h) => h.slice(0, -1));
    setFailedAttempt(false);
    animateAndSet({ ...previous, undosUsed: previous.undosUsed + 1 });
  }

  function handleReset() {
    setHistory([]);
    setFailedAttempt(false);
    animateAndSet(createStripFromLevel(level));
  }

  const progressLabel = useMemo(
    () => `Level ${levelNumber} / ${totalLevels}`,
    [levelNumber, totalLevels],
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Pressable onPress={onExit} hitSlop={12}>
          <Text style={styles.exitLabel}>‹ Levellar</Text>
        </Pressable>
        <Text style={styles.progress}>{progressLabel}</Text>
      </View>

      <View style={styles.targetBox}>
        <Text style={styles.targetLabel}>HEDEF</Text>
        <Text style={styles.targetValue}>{level.target}</Text>
      </View>

      <View style={styles.stripArea}>
        <View style={styles.stripRow}>
          {strip.cells.map((cell, i) => (
            <React.Fragment key={cell.id}>
              <Cell value={cell.value} highlighted={finished} />
              {i < strip.creases.length && (
                <CreaseButton
                  operator={strip.creases[i].operator}
                  onPress={() => handleFold(i)}
                />
              )}
            </React.Fragment>
          ))}
        </View>
      </View>

      <View style={styles.controls}>
        <Pressable
          style={[styles.controlButton, history.length === 0 && styles.controlButtonDisabled]}
          onPress={handleUndo}
          disabled={history.length === 0}
        >
          <Text style={styles.controlLabel}>Geri Al</Text>
        </Pressable>
        <Pressable style={styles.controlButton} onPress={handleReset}>
          <Text style={styles.controlLabel}>Baştan</Text>
        </Pressable>
      </View>

      {failedAttempt && !won && (
        <View style={styles.messageBox}>
          <Text style={styles.messageText}>
            Bu sırayla {strip.cells[0].value} çıktı, hedef {level.target}. Baştan al, farklı bir
            sırayla katla.
          </Text>
        </View>
      )}

      {won && (
        <View style={styles.winOverlay}>
          <Text style={styles.winTitle}>Doğru sıra buydu!</Text>
          <Text style={styles.winSubtitle}>{level.target} sayısına ulaştın.</Text>
          <View style={styles.winButtons}>
            <Pressable style={styles.controlButton} onPress={handleReset}>
              <Text style={styles.controlLabel}>Tekrar Oyna</Text>
            </Pressable>
            {hasNextLevel && (
              <Pressable style={[styles.controlButton, styles.primaryButton]} onPress={onNextLevel}>
                <Text style={[styles.controlLabel, styles.primaryLabel]}>Sonraki Level ›</Text>
              </Pressable>
            )}
          </View>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAF3E0',
    paddingTop: 60,
    paddingHorizontal: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  exitLabel: {
    fontSize: 16,
    color: '#7A5A2E',
    fontWeight: '600',
  },
  progress: {
    fontSize: 14,
    color: '#A0895A',
    fontWeight: '600',
  },
  targetBox: {
    alignItems: 'center',
    marginBottom: 28,
  },
  targetLabel: {
    fontSize: 12,
    letterSpacing: 2,
    color: '#A0895A',
    fontWeight: '700',
  },
  targetValue: {
    fontSize: 44,
    fontWeight: '800',
    color: '#4A3B22',
  },
  stripArea: {
    minHeight: 160,
    justifyContent: 'center',
  },
  stripRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    justifyContent: 'center',
    rowGap: 12,
  },
  controls: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 12,
    marginTop: 24,
  },
  controlButton: {
    paddingVertical: 10,
    paddingHorizontal: 18,
    borderRadius: 12,
    backgroundColor: '#FFF',
    borderWidth: 2,
    borderColor: '#E4C687',
  },
  controlButtonDisabled: {
    opacity: 0.4,
  },
  controlLabel: {
    fontSize: 14,
    fontWeight: '700',
    color: '#7A5A2E',
  },
  messageBox: {
    marginTop: 20,
    alignItems: 'center',
  },
  messageText: {
    textAlign: 'center',
    color: '#A0522D',
    fontSize: 14,
  },
  winOverlay: {
    position: 'absolute',
    left: 20,
    right: 20,
    bottom: 60,
    backgroundColor: '#FFF9EC',
    borderRadius: 20,
    padding: 24,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#E0A62E',
    shadowColor: '#000',
    shadowOpacity: 0.15,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
  },
  winTitle: {
    fontSize: 20,
    fontWeight: '800',
    color: '#4A3B22',
    marginBottom: 4,
  },
  winSubtitle: {
    fontSize: 14,
    color: '#7A5A2E',
    marginBottom: 16,
  },
  winButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  primaryButton: {
    backgroundColor: '#E0A62E',
    borderColor: '#E0A62E',
  },
  primaryLabel: {
    color: '#FFF',
  },
});
