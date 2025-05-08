// Supabase client configuration
const supabaseUrl = 'https://diogvptwppeablbfzubf.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRpb2d2cHR3cHBlYWJsYmZ6dWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNzExNDIsImV4cCI6MjA2MDY0NzE0Mn0.93LwCg7eSYjEBMKGEQKTkVlY07kTBUME5gzIoQA4dV8';

const supabase = supabase.createClient(supabaseUrl, supabaseKey);

// Course-related queries
export const getCourses = async () => {
    const { data, error } = await supabase
        .from('courses')
        .select(`
            *,
            categories:category_id (
                name,
                description,
                icon
            )
        `);
    if (error) {
        console.error('Error fetching courses:', error);
        throw error;
    }
    console.log('Fetched courses:', data);
    return data;
};

export const getCourseById = async (id) => {
    const { data, error } = await supabase
        .from('courses')
        .select('*')
        .eq('id', id)
        .single();
    if (error) throw error;
    return data;
};

export const getCoursesByCategory = async (category) => {
    const { data, error } = await supabase
        .from('courses')
        .select('*')
        .eq('category', category);
    if (error) throw error;
    return data;
};

// Admission-related queries
export const submitApplication = async (applicationData) => {
    const { data, error } = await supabase
        .from('applications')
        .insert([applicationData]);
    if (error) throw error;
    return data;
};

export const getApplicationStatus = async (email) => {
    const { data, error } = await supabase
        .from('applications')
        .select('status')
        .eq('email', email)
        .single();
    if (error) throw error;
    return data;
};

// Contact form queries
export const submitContactForm = async (contactData) => {
    const { data, error } = await supabase
        .from('contact_messages')
        .insert([contactData]);
    if (error) throw error;
    return data;
};

// User authentication
export const signUp = async (email, password) => {
    const { data, error } = await supabase.auth.signUp({
        email,
        password
    });
    if (error) throw error;
    return data;
};

export const signIn = async (email, password) => {
    const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
    });
    if (error) throw error;
    return data;
};

export const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
};

// User profile queries
export const getUserProfile = async (userId) => {
    const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();
    if (error) throw error;
    return data;
};

export const updateUserProfile = async (userId, profileData) => {
    const { data, error } = await supabase
        .from('profiles')
        .update(profileData)
        .eq('id', userId);
    if (error) throw error;
    return data;
};

// Add this to your existing script
async function testConnection() {
    try {
        const { data, error } = await supabase
            .from('categories')
            .select('*')
            .limit(1);
        
        if (error) {
            console.error('Connection error:', error);
        } else {
            console.log('Connection successful!');
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

// Add this test function to your code
async function testSupabaseConnection() {
    try {
        const { data, error } = await supabase
            .from('categories')
            .select('*')
            .limit(1);
        
        if (error) {
            console.error('Supabase connection error:', error);
        } else {
            console.log('Supabase connection successful:', data);
        }
    } catch (error) {
        console.error('Error testing connection:', error);
    }
}

// Call the test function when the page loads
document.addEventListener('DOMContentLoaded', () => {
    testConnection();
    testSupabaseConnection();
    loadCategories();
    loadFeaturedCourses();
}); 