-- ==============================================================================
-- 🌿 CALENDA — KULÜPLER & BİRLİKTE ODAKLANMA VERİTABANI ŞEMASI (MIGRATION)
-- ==============================================================================
-- Bu SQL kodunu Supabase Dashboard > SQL Editor kısmına yapıştırıp "Run" butonuna basın.

-- 1. KULÜPLER TABLOSU
CREATE TABLE IF NOT EXISTS clubs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    icon_name TEXT DEFAULT 'matcha_cup',
    invite_code VARCHAR(16) UNIQUE NOT NULL,
    daily_target_minutes INT DEFAULT 60,
    max_members INT DEFAULT 15,
    created_by TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. KULÜP ÜYELERİ TABLOSU
CREATE TABLE IF NOT EXISTS club_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    display_name TEXT NOT NULL,
    avatar_animal TEXT DEFAULT 'rabbit',
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
    host_user_id TEXT,
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
    user_id TEXT NOT NULL,
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
    user_id TEXT NOT NULL,
    date DATE NOT NULL,
    total_focus_minutes INT DEFAULT 0,
    goal_met BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(club_id, user_id, date)
);

-- ==============================================================================
-- 🔒 ROW LEVEL SECURITY (RLS) POLİTİKALARI (Anon & Auth Dostu)
-- ==============================================================================
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_focus_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_daily_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Clubs open policy" ON clubs;
CREATE POLICY "Clubs open policy" ON clubs FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Club members open policy" ON club_members;
CREATE POLICY "Club members open policy" ON club_members FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Focus sessions open policy" ON club_focus_sessions;
CREATE POLICY "Focus sessions open policy" ON club_focus_sessions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Session participants open policy" ON session_participants;
CREATE POLICY "Session participants open policy" ON session_participants FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Daily progress open policy" ON club_daily_progress;
CREATE POLICY "Daily progress open policy" ON club_daily_progress FOR ALL USING (true) WITH CHECK (true);

-- ==============================================================================
-- ⚡ SUPABASE REALTIME YAYINI AKTİFLEŞTİRME
-- ==============================================================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'club_focus_sessions'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE club_focus_sessions;
    END IF;
END $$;

-- ==============================================================================
-- 💬 6. KULLANICI GERİ BİLDİRİMLERİ TABLOSU (FEEDBACK)
-- ==============================================================================
-- Kullanıcıların profil sekmesinden gönderdikleri geri bildirimler burada toplanır.
-- Supabase Dashboard > Table Editor > user_feedbacks sekmesinden görüntüleyebilirsiniz.
CREATE TABLE IF NOT EXISTS user_feedbacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT,
    username TEXT,
    email TEXT,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE user_feedbacks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "User feedbacks open insert" ON user_feedbacks;
CREATE POLICY "User feedbacks open insert" ON user_feedbacks FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "User feedbacks select" ON user_feedbacks;
CREATE POLICY "User feedbacks select" ON user_feedbacks FOR SELECT USING (true);

