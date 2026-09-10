// Katlama motoru: bir StripState üzerinde tek bir katlama adımını uygular.
//
// Kural: creases[i], cells[i] ile cells[i+1] arasındadır. O çizgiyi
// katladığında iki hücre operatöre göre TEK hücrede birleşir, o crease
// silinir, ondan sonraki crease'ler bir kayar. '+' ve '×' değişmeli
// (commutative) olduğu için "hangi hücre üstte, hangisi altta katlanıyor"
// sonucu etkilemez — bu bilinçli bir v1 tasarım kararı (bkz. README:
// neden sadece + ve ×).

import { Cell, Crease, LevelDef, Operator, StripState } from '../types';

let idCounter = 0;
function nextId(prefix: string): string {
  idCounter += 1;
  return `${prefix}-${idCounter}`;
}

export function applyOperator(op: Operator, a: number, b: number): number {
  switch (op) {
    case '+':
      return a + b;
    case '×':
      return a * b;
  }
}

export function createStripFromLevel(level: LevelDef): StripState {
  const cells: Cell[] = level.values.map((value, i) => ({
    id: `c-${level.id}-${i}`,
    value,
  }));
  const creases: Crease[] = level.operators.map((operator, i) => ({
    id: `cr-${level.id}-${i}`,
    operator,
  }));
  return { cells, creases, foldCount: 0, undosUsed: 0 };
}

/** creaseIndex konumunda katlama yapar, yeni bir StripState döner. Girdi mutate edilmez. */
export function foldAt(state: StripState, creaseIndex: number): StripState {
  if (creaseIndex < 0 || creaseIndex >= state.creases.length) {
    throw new Error(`Geçersiz crease index: ${creaseIndex}`);
  }
  const left = state.cells[creaseIndex];
  const right = state.cells[creaseIndex + 1];
  const operator = state.creases[creaseIndex].operator;
  const mergedValue = applyOperator(operator, left.value, right.value);

  const merged: Cell = { id: nextId('m'), value: mergedValue };

  const newCells = [
    ...state.cells.slice(0, creaseIndex),
    merged,
    ...state.cells.slice(creaseIndex + 2),
  ];
  const newCreases = [
    ...state.creases.slice(0, creaseIndex),
    ...state.creases.slice(creaseIndex + 1),
  ];

  return {
    cells: newCells,
    creases: newCreases,
    foldCount: state.foldCount + 1,
    undosUsed: state.undosUsed,
  };
}

export function isSolved(state: StripState, target: number): boolean {
  return state.cells.length === 1 && state.cells[0].value === target;
}

export function isFinished(state: StripState): boolean {
  return state.cells.length === 1;
}
