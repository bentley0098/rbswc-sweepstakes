export const POINTS = {
  group_win: 3,
  group_draw: 1,
  reach_round_of_32: 2,
  reach_round_of_16: 4,
  reach_quarter_final: 6,
  reach_semi_final: 8,
  reach_final: 10,
  win_world_cup: 15,
} as const

export type PointsKey = keyof typeof POINTS

export function calcUpsetBonus(winnerFifaRank: number, loserFifaRank: number, isDraw: boolean): number {
  const gap = winnerFifaRank - loserFifaRank
  if (gap <= 0) return 0
  if (isDraw) {
    if (gap >= 31) return 3
    if (gap >= 21) return 2
    if (gap >= 11) return 1
    return 0
  } else {
    if (gap >= 31) return 7
    if (gap >= 21) return 5
    if (gap >= 11) return 3
    if (gap >= 6) return 2
    return 1
  }
}
