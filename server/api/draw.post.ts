import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  const body = await readBody<{ adminCode: string; force?: boolean; reset?: boolean }>(event)
  const config = useRuntimeConfig()

  if (!body.adminCode || body.adminCode !== String(config.adminCode)) {
    throw createError({ statusCode: 403, message: 'Unauthorized' })
  }

  const supabase = createClient(config.public.supabaseUrl, config.supabaseServiceRoleKey)

  if (body.reset) {
    await supabase.from('draws').delete().neq('id', '00000000-0000-0000-0000-000000000000')
    await supabase.from('app_state').update({ draw_completed: false, updated_at: new Date().toISOString() }).eq('id', 1)
    return { success: true, message: 'Draw reset' }
  }

  const { data: appState } = await supabase.from('app_state').select().single()
  if (appState?.draw_completed) {
    throw createError({ statusCode: 409, message: 'Draw already completed. Use reset: true to redo.' })
  }

  const { data: participants, error: pErr } = await supabase
    .from('participants')
    .select()
    .order('joined_at')

  if (pErr || !participants?.length) {
    throw createError({ statusCode: 400, message: 'No participants found' })
  }

  if (participants.length < 2 && !body.force) {
    throw createError({ statusCode: 400, message: 'Need at least 2 participants (use force: true to override)' })
  }

  const { data: teams, error: tErr } = await supabase.from('teams').select().order('fifa_rank')

  if (tErr || !teams?.length) {
    throw createError({ statusCode: 500, message: 'No teams found — seed the teams table first' })
  }

  const getShuffled = (seed: number) => shuffle(teams.filter(t => t.seed === seed))
  const s1 = getShuffled(1)
  const s2 = getShuffled(2)
  const s3 = getShuffled(3)
  const s4 = getShuffled(4)

  const drawRows = participants.flatMap((p, i) => [
    { participant_id: p.id, team_id: s1[i % s1.length]!.id },
    { participant_id: p.id, team_id: s2[i % s2.length]!.id },
    { participant_id: p.id, team_id: s3[i % s3.length]!.id },
    { participant_id: p.id, team_id: s4[i % s4.length]!.id },
  ])

  const { error: dErr } = await supabase.from('draws').insert(drawRows)
  if (dErr) {
    throw createError({ statusCode: 500, message: dErr.message })
  }

  await supabase
    .from('app_state')
    .update({ draw_completed: true, participant_count: participants.length, updated_at: new Date().toISOString() })
    .eq('id', 1)

  return { success: true, participants: participants.length, drawCount: drawRows.length }
})

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j]!, a[i]!]
  }
  return a
}
