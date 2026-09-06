-- ==============================================================================
-- 🌿 CALENDA — KULÜPLER & BİRLİKTE ODAKLANMA VERİTABANI ŞEMASI (MIGRATION)
-- ==============================================================================

-- 1. KULÜPLER TABLOSU
CREATE TABLE IF NOT EXISTS clubs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    icon_name TEXT DEFAULT 'matcha_cup',
    invite_code VARCHAR(8) UNIQUE NOT NULL,
    daily_target_minutes INT DEFAULT 60,
    max_members INT DEFAULT 15,
    created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. KULÜP ÜYELERİ TABLOSU
CREATE TABLE IF NOT EXISTS club_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    avatar_animal TEXT DEFAULT '01_rabbit',
    avatar_accessory TEXT DEFAULT 'none',
    avatar_bg_color TEXT DEFAULT '#FAF7F2',
    role TEXT DEFAULT 'member', -- 'owner', 'member'
    daily_goal_minutes INT DEFAULT 60,
    is_ghost_mode BOOLEAN DEFAULT false,
    joined_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(club_id, user_id)
);

-- 3. BİRLİKTE ODAKLANMA OTURUMLARI (LIVE SESSIONS)
CREATE TABLE IF NOT EXISTS club_focus_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    host_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    host_name TEXT NOT NULL,
    title TEXT NOT NULL,
    focus_tag TEXT DEFAULT 'Ders & Çalışma',
    duration_minutes INT NOT NULL DEFAULT 25,
    status TEXT DEFAULT 'active', -- 'active', 'completed', 'cancelled'
    started_at TIMESTAMPTZ DEFAULT now(),
    ended_at TIMESTAMPTZ
);

-- 4. OTURUM KATILIMCILARI
CREATE TABLE IF NOT EXISTS session_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES club_focus_sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    active_minutes INT DEFAULT 0,
    joined_at TIMESTAMPTZ DEFAULT now(),
    left_at TIMESTAMPTZ,
    completed BOOLEAN DEFAULT false
);

-- 5. GÜNLÜK KULÜP İLERLEMESİ (GÜNLÜK İSTATİSTİKLER)
CREATE TABLE IF NOT EXISTS club_daily_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_focus_minutes INT DEFAULT 0,
    goal_met BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(club_id, user_id, date)
);

-- ==============================================================================
-- 🔒 ROW LEVEL SECURITY (RLS) POLİTİKALARI
-- ==============================================================================
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_focus_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_daily_progress ENABLE ROW LEVEL SECURITY;

-- Okuma İzinleri (Kulüpler ve üyeler erişebilir)
CREATE POLICY "Clubs read policy" ON clubs FOR SELECT USING (true);
CREATE POLICY "Clubs insert policy" ON clubs FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Clubs update policy" ON clubs FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Club members read policy" ON club_members FOR SELECT USING (true);
CREATE POLICY "Club members insert policy" ON club_members FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Club members update policy" ON club_members FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Focus sessions read policy" ON club_focus_sessions FOR SELECT USING (true);
CREATE POLICY "Focus sessions insert policy" ON club_focus_sessions FOR INSERT WITH CHECK (auth.uid() = host_user_id);
CREATE POLICY "Focus sessions update policy" ON club_focus_sessions FOR UPDATE USING (auth.uid() = host_user_id);

CREATE POLICY "Session participants policy" ON session_participants FOR ALL USING (true);
CREATE POLICY "Daily progress policy" ON club_daily_progress FOR ALL USING (true);

-- ==============================================================================
-- ⚡ SUPABASE REALTIME YAYINI AKTİFLEŞTİRME
-- ==============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE club_focus_sessions;
