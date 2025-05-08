-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tables if they don't exist
CREATE TABLE IF NOT EXISTS categories (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    name text NOT NULL,
    description text,
    icon text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS courses (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    title text NOT NULL,
    description text,
    category_id uuid REFERENCES categories(id),
    image_url text,
    duration text,
    level text,
    price decimal(10,2),
    is_featured boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create applications table
create table IF NOT EXISTS applications (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references auth.users(id),
    course_id uuid references courses(id),
    status text default 'pending',
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create contact_messages table
create table IF NOT EXISTS contact_messages (
    id uuid default uuid_generate_v4() primary key,
    name text not null,
    email text not null,
    subject text,
    message text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create profiles table
create table IF NOT EXISTS profiles (
    id uuid references auth.users(id) primary key,
    full_name text,
    avatar_url text,
    bio text,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create RLS policies
alter table categories enable row level security;
alter table courses enable row level security;
alter table applications enable row level security;
alter table contact_messages enable row level security;
alter table profiles enable row level security;

-- Categories policies
create policy "Categories are viewable by everyone"
    on categories for select
    using (true);

-- Courses policies
create policy "Courses are viewable by everyone"
    on courses for select
    using (true);

-- Applications policies
create policy "Users can view their own applications"
    on applications for select
    using (auth.uid() = user_id);

create policy "Users can create applications"
    on applications for insert
    with check (auth.uid() = user_id);

-- Contact messages policies
create policy "Anyone can create contact messages"
    on contact_messages for insert
    with check (true);

-- Profiles policies
create policy "Profiles are viewable by everyone"
    on profiles for select
    using (true);

create policy "Users can update their own profile"
    on profiles for update
    using (auth.uid() = id);

-- Update the function instead of recreating
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop and recreate trigger (if needed)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- First insert categories
INSERT INTO categories (name, description, icon) 
VALUES 
    ('Technology', 'Learn cutting-edge technologies and programming skills', 'laptop-code'),
    ('Business', 'Master business strategies and management techniques', 'chart-line'),
    ('Design', 'Develop your creative skills in various design disciplines', 'palette'),
    ('Data Science', 'Master data analysis and machine learning', 'chart-bar'),
    ('Marketing', 'Learn digital marketing strategies', 'bullhorn')
RETURNING id, name;

-- Then insert courses
INSERT INTO courses (title, description, category_id, image_url, duration, level, price, is_featured) 
SELECT 
    'Web Development Bootcamp',
    'Learn full-stack web development with modern technologies and best practices.',
    id,
    'https://images.unsplash.com/photo-1517694712202-14dd9538aa97',
    '12 weeks',
    'Intermediate',
    299.99,
    true
FROM categories 
WHERE name = 'Technology'
RETURNING id, title;

-- Insert more courses with different categories
INSERT INTO courses (title, description, category_id, image_url, duration, level, price, is_featured) 
SELECT 
    'Advanced JavaScript Development',
    'Master modern JavaScript including ES6+, async programming, and frameworks.',
    id,
    'https://images.unsplash.com/photo-1627398242454-45a1465c2479',
    '10 weeks',
    'Advanced',
    399.99,
    true
FROM categories 
WHERE name = 'Technology';

INSERT INTO courses (title, description, category_id, image_url, duration, level, price, is_featured) 
SELECT 
    'Python for Data Science',
    'Learn Python programming with focus on data analysis, pandas, and numpy.',
    id,
    'https://images.unsplash.com/photo-1526379095098-d400fd0bf935',
    '8 weeks',
    'Intermediate',
    299.99,
    true
FROM categories 
WHERE name = 'Data Science';

INSERT INTO courses (title, description, category_id, image_url, duration, level, price, is_featured) 
SELECT 
    'Digital Marketing Strategy',
    'Comprehensive guide to digital marketing including SEO, SEM, and social media.',
    id,
    'https://images.unsplash.com/photo-1432888498266-38ffec3eaf0a',
    '6 weeks',
    'Beginner',
    249.99,
    true
FROM categories 
WHERE name = 'Marketing';

INSERT INTO courses (title, description, category_id, image_url, duration, level, price, is_featured) 
SELECT 
    'Graphic Design Masterclass',
    'Learn professional graphic design using Adobe Creative Suite.',
    id,
    'https://images.unsplash.com/photo-1626785774625-ddcddc3445e9',
    '12 weeks',
    'Intermediate',
    349.99,
    true
FROM categories 
WHERE name = 'Design';

INSERT INTO courses (title, description, category_id, image_url, duration, level, price, is_featured) 
SELECT 
    'Business Analytics',
    'Learn data-driven decision making for business growth.',
    id,
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f',
    '8 weeks',
    'Intermediate',
    299.99,
    true
FROM categories 
WHERE name = 'Business';

SELECT * FROM courses;

SELECT c.title, cat.name as category
FROM courses c
JOIN categories cat ON c.category_id = cat.id;

SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM courses;

SELECT * FROM categories; 