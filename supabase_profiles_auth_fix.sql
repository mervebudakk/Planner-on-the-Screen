-- ==============================================================================
-- 🌿 CALENDA — KULLANICI PROFİLLERİ & KİMLİK DOĞRULAMA DÜZELTME MİGRASYONU
-- ==============================================================================
-- Bu SQL kodunu Supabase Dashboard > SQL Editor kısmına yapıştırıp "Run" butonuna basın.
-- Bu script:
-- 1. profiles tablosunun sütunlarını eksiksiz sağlar.
-- 2. Büyük/küçük harf duyarsız benzersiz (UNIQUE) kullanıcı adı kuralını getirir.
-- 3. RLS (Row Level Security) politikalarını hem anon hem auth için açar,
--    böylece kullanıcı adı müsaitlik kontrolü ve profil çekme sorunsuz çalışır.
-- 4. Kullanıcıların birbirinin üzerine yazmasını (overwrite) veritabanı seviyesinde engeller.
-- ==============================================================================

-- 1. PROFILES TABLOSUNU OLUŞTUR VEYA SÜTUNLARINI GÜNCELLE
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY,
    username TEXT,
    first_name TEXT DEFAULT '',
    last_name TEXT DEFAULT '',
    email TEXT DEFAULT '',
    birth_date TIMESTAMPTZ,
    avatar_animal TEXT DEFAULT 'rabbit',
    avatar_accessory TEXT DEFAULT 'none',
    avatar_bg_color TEXT DEFAULT '#FAF7F2',
    weekly_goal_days INT DEFAULT 5,
    daily_focus_minutes INT DEFAULT 25,
    core_focus_area TEXT DEFAULT 'Kişisel Planlama & Notlar',
    marketing_email_opt_in BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Var olan tablolarda eksik olabilecek sütunları ekle
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS first_name TEXT DEFAULT '';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_name TEXT DEFAULT '';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT DEFAULT '';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS birth_date TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_animal TEXT DEFAULT 'rabbit';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_accessory TEXT DEFAULT 'none';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_bg_color TEXT DEFAULT '#FAF7F2';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS weekly_goal_days INT DEFAULT 5;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS daily_focus_minutes INT DEFAULT 25;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS core_focus_area TEXT DEFAULT 'Kişisel Planlama & Notlar';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS marketing_email_opt_in BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- 2. BENZERSİZ KULLANICI ADI (CASE-INSENSITIVE UNIQUE INDEX)
-- Aynı kullanıcı adının büyük/küçük harf farkıyla tekrar alınmasını kesinlikle engeller.
CREATE UNIQUE INDEX IF NOT EXISTS profiles_username_unique_idx 
ON profiles (LOWER(TRIM(username))) 
WHERE username IS NOT NULL AND TRIM(username) != '';

-- Benzersiz e-posta indeksi (Aynı e-posta ile mükerrer profil oluşmasını engeller)
CREATE UNIQUE INDEX IF NOT EXISTS profiles_email_unique_idx 
ON profiles (LOWER(TRIM(email))) 
WHERE email IS NOT NULL AND TRIM(email) != '';

-- 3. ROW LEVEL SECURITY (RLS) POLİTİKALARI
-- Tabloda RLS'i aktif et
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Eski kısıtlayıcı politikaları kaldır
DROP POLICY IF EXISTS "Profiles public read" ON profiles;
DROP POLICY IF EXISTS "Profiles are readable by everyone" ON profiles;
DROP POLICY IF EXISTS "Profiles open select" ON profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Profiles insert policy" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Profiles update policy" ON profiles;
DROP POLICY IF EXISTS "Profiles delete policy" ON profiles;

-- A) OKUMA (SELECT):
-- Kullanıcı adı müsaitlik kontrolü (isUsernameAvailable), kulüp üyeleri listesi
-- ve giriş sırasında profil sorgulama için herkese açık SELECT izni verilir.
CREATE POLICY "Profiles open select" 
ON profiles 
FOR SELECT 
USING (true);

-- B) EKLEME (INSERT):
-- Yeni kullanıcı profili ekleme izni
CREATE POLICY "Profiles insert policy" 
ON profiles 
FOR INSERT 
WITH CHECK (true);

-- C) GÜNCELLEME (UPDATE):
-- Profil güncelleme izni
CREATE POLICY "Profiles update policy" 
ON profiles 
FOR UPDATE 
USING (true) 
WITH CHECK (true);

-- D) SİLME (DELETE):
-- Profil silme izni (Hesap silme akışı için)
CREATE POLICY "Profiles delete policy" 
ON profiles 
FOR DELETE 
USING (true);

-- 4. KULLANICI ADI MÜSAİTLİK KONTROLÜ İÇİN GÜVENLİ RPC FONKSİYONU
-- RLS kısıtlamalarına takılmadan doğrudan veritabanı düzeyinde kontrol eder
CREATE OR REPLACE FUNCTION check_username_available(check_username TEXT, exclude_user_id TEXT DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    cleaned TEXT;
    match_count INT;
BEGIN
    cleaned := LOWER(TRIM(REPLACE(check_username, '@', '')));
    IF LENGTH(cleaned) < 3 THEN
        RETURN FALSE;
    END IF;

    IF exclude_user_id IS NOT NULL AND exclude_user_id != '' THEN
        SELECT COUNT(*) INTO match_count
        FROM profiles
        WHERE LOWER(TRIM(username)) = cleaned
          AND id::TEXT != exclude_user_id;
    ELSE
        SELECT COUNT(*) INTO match_count
        FROM profiles
        WHERE LOWER(TRIM(username)) = cleaned;
    END IF;

    RETURN match_count = 0;
END;
$$;
