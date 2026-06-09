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

export function normalizeStage(round: string): string {
  const r = round.trim().toLowerCase()
  if (r.startsWith('group')) return 'Group Stage'
  if (r.includes('32')) return 'Round of 32'
  if (r.includes('16')) return 'Round of 16'
  if (r.includes('quarter')) return 'Quarter-finals'
  if (r.includes('semi')) return 'Semi-finals'
  if (r.includes('3rd') || r.includes('third') || r.includes('third place')) return 'Third Place'
  if (r === 'final') return 'Final'
  return round
}

export function stageToEventType(stage: string): keyof typeof POINTS | null {
  switch (stage) {
    case 'Round of 32': return 'reach_round_of_16'
    case 'Round of 16': return 'reach_quarter_final'
    case 'Quarter-finals': return 'reach_semi_final'
    case 'Semi-finals': return 'reach_final'
    case 'Third Place': return null
    case 'Final': return 'win_world_cup'
    default: return null
  }
}
