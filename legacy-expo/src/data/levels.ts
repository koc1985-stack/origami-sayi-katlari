// v1 curated level seti — scripts/generateLevels.ts ile üretilip solver
// tarafından doğrulanmıştır (her level'ın solutionCount değeri, hedefe
// ulaşan farklı katlama sırası sayısını gösterir; 1 = tek doğru sıra).
//
// Yeniden üretmek için: npx tsx scripts/generateLevels.ts

import { LevelDef } from '../types';

export const levels: LevelDef[] = [
  {
    id: 'L01-tutorial-add',
    values: [3, 5, 6],
    operators: ['+', '+'],
    target: 14,
    solutionCount: 2,
    totalArrangements: 2,
  },
  {
    id: 'L02-tutorial-add',
    values: [4, 4, 9],
    operators: ['+', '+'],
    target: 17,
    solutionCount: 2,
    totalArrangements: 2,
  },
  {
    id: 'L03-intro-mixed',
    values: [3, 6, 3],
    operators: ['×', '+'],
    target: 27,
    solutionCount: 1,
    totalArrangements: 2,
  },
  {
    id: 'L04-intro-mixed',
    values: [1, 3, 4],
    operators: ['+', '×'],
    target: 16,
    solutionCount: 1,
    totalArrangements: 2,
  },
  {
    id: 'L05-core-4',
    values: [3, 1, 4, 2],
    operators: ['×', '+', '+'],
    target: 17,
    solutionCount: 1,
    totalArrangements: 5,
  },
  {
    id: 'L06-core-4',
    values: [2, 3, 1, 4],
    operators: ['×', '+', '+'],
    target: 12,
    solutionCount: 1,
    totalArrangements: 5,
  },
  {
    id: 'L07-core-5',
    values: [1, 4, 4, 4, 2],
    operators: ['+', '+', '+', '×'],
    target: 25,
    solutionCount: 2,
    totalArrangements: 14,
  },
  {
    id: 'L08-core-5',
    values: [1, 2, 2, 2, 1],
    operators: ['+', '×', '×', '×'],
    target: 10,
    solutionCount: 2,
    totalArrangements: 14,
  },
  {
    id: 'L09-capstone',
    values: [2, 3, 1, 4, 3, 3],
    operators: ['×', '+', '×', '+', '×'],
    target: 37,
    solutionCount: 1,
    totalArrangements: 42,
  },
  {
    id: 'L10-capstone',
    values: [4, 1, 5, 5, 2, 5],
    operators: ['+', '×', '×', '+', '+'],
    target: 200,
    solutionCount: 1,
    totalArrangements: 42,
  },
];
