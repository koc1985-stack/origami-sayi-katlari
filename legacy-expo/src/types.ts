// Origami Sayı Katları — temel tipler
//
// v1 kapsamı: tek boyutlu (1D) şerit, sadece '+' ve '×' operatörleri.
// '−' ve '÷' ile 2D ızgara sonraki sürümlere bırakıldı (bkz. README).

export type Operator = '+' | '×';

/** Şerit üzerindeki bir hücre (sayı). */
export interface Cell {
  /** Animasyon/liste anahtarı için sabit kimlik. */
  id: string;
  value: number;
}

/** İki komşu hücre arasındaki katlama çizgisi. */
export interface Crease {
  id: string;
  operator: Operator;
}

/** Bir level'ın statik tanımı (üretilen veya elle hazırlanmış). */
export interface LevelDef {
  id: string;
  /** Başlangıç hücre değerleri, soldan sağa. */
  values: number[];
  /** values.length - 1 uzunluğunda operatör dizisi. */
  operators: Operator[];
  /** Oyuncunun ulaşması gereken hedef sayı. */
  target: number;
  /**
   * Solver tarafından hesaplanan: kaç farklı katlama SIRASI (parantezleme)
   * hedefe ulaşıyor. Düşük sayı = zor (tek doğru yol), yüksek sayı = kolay.
   */
  solutionCount: number;
  /** Bu parantezlemenin toplam kaç farklı sonucu olabildiği (Catalan(n-1)). */
  totalArrangements: number;
}

/** Oynanabilir şeridin canlı durumu. */
export interface StripState {
  cells: Cell[];
  creases: Crease[]; // cells.length - 1 uzunluğunda
  foldCount: number;
  undosUsed: number;
}
