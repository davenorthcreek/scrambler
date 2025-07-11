import streamlit as st
import random
import re
from datetime import datetime

# Configure the page
st.set_page_config(
    page_title="Sentence Scrambler",
    page_icon="🔤",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 3rem;
        font-weight: bold;
        color: #FF6B6B;
        text-align: center;
        margin-bottom: 2rem;
    }
    .scrambled-sentence {
        font-size: 1.5rem;
        background-color: #E8F4FD;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #4ECDC4;
        margin: 1rem 0;
        text-align: center;
    }
    .original-sentence {
        font-size: 1.2rem;
        background-color: #F0F8E8;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #95E1D3;
        margin: 1rem 0;
        text-align: center;
    }
    .word-card {
        display: inline-block;
        background-color: #FFE66D;
        padding: 0.5rem 1rem;
        margin: 0.3rem;
        border-radius: 0.5rem;
        font-size: 1.1rem;
        font-weight: bold;
        color: #2C3E50;
        border: 2px solid #F39C12;
    }
    .student-section {
        background-color: #F8F9FA;
        padding: 1.5rem;
        border-radius: 0.5rem;
        margin: 1rem 0;
    }
    .teacher-section {
        background-color: #FFF5F5;
        padding: 1.5rem;
        border-radius: 0.5rem;
        margin: 1rem 0;
    }
    .difficulty-easy { border-left: 4px solid #2ECC71; }
    .difficulty-medium { border-left: 4px solid #F39C12; }
    .difficulty-hard { border-left: 4px solid #E74C3C; }
</style>
""", unsafe_allow_html=True)

# Initialize session state
if 'current_sentence' not in st.session_state:
    st.session_state.current_sentence = ""
if 'scrambled_words' not in st.session_state:
    st.session_state.scrambled_words = []
if 'show_answer' not in st.session_state:
    st.session_state.show_answer = False
if 'custom_sentences' not in st.session_state:
    st.session_state.custom_sentences = []

# Pre-made sentences for different difficulty levels
SENTENCES = {
    "Easy (3-5 words)": [
        "The cat is sleeping.",
        "I like to play.",
        "The sun is bright.",
        "Dogs are friendly animals.",
        "We eat breakfast together.",
        "The bird can fly.",
        "My book is blue.",
        "She walks to school.",
        "The flower smells nice.",
        "Dad drives the car."
    ],
    "Medium (6-8 words)": [
        "The little girl plays in the garden.",
        "My family loves to eat pizza together.",
        "The big dog runs very fast outside.",
        "We can see many stars at night.",
        "The teacher reads a story to students.",
        "My mother bakes delicious cookies for us.",
        "The colorful butterfly flies from flower to flower.",
        "Children love to play games during recess.",
        "The brave firefighter helps people in danger.",
        "My grandmother tells wonderful stories about her childhood."
    ],
    "Hard (9+ words)": [
        "The curious little mouse quietly searched for cheese in the kitchen.",
        "During summer vacation, our family enjoys swimming at the beautiful lake.",
        "The dedicated teacher carefully explains difficult math problems to her students.",
        "My younger brother always forgets to brush his teeth before bedtime.",
        "The magnificent rainbow appeared in the sky after the heavy rain.",
        "Every morning, the friendly mailman delivers letters to our neighborhood.",
        "The excited children eagerly waited for the school bus on Monday morning.",
        "My grandmother's homemade apple pie tastes absolutely delicious with vanilla ice cream.",
        "The clever detective solved the mysterious case using important clues and evidence.",
        "During the winter months, many animals hibernate in warm, cozy places."
    ]
}

def scramble_sentence(sentence):
    """Scramble the words in a sentence while keeping punctuation with the last word"""
    # Remove punctuation and split into words
    words = re.findall(r'\b\w+\b', sentence)
    punctuation = re.findall(r'[^\w\s]', sentence)
    
    # Scramble the words
    scrambled = words.copy()
    random.shuffle(scrambled)
    
    return scrambled, punctuation

def create_word_cards(words):
    """Create HTML for word cards"""
    cards_html = ""
    for word in words:
        cards_html += f'<span class="word-card">{word}</span>'
    return cards_html

def main():
    # Header
    st.markdown('<h1 class="main-header">🔤 Sentence Scrambler</h1>', unsafe_allow_html=True)
    st.markdown('<p style="text-align: center; font-size: 1.2rem; color: #666;">A fun tool for primary school teachers to create sentence unscrambling activities!</p>', unsafe_allow_html=True)
    
    # Sidebar - Teacher Controls
    st.sidebar.title("👩‍🏫 Teacher Controls")
    st.sidebar.markdown("---")
    
    # Difficulty selection
    st.sidebar.markdown("### 📊 Difficulty Level")
    difficulty = st.sidebar.selectbox(
        "Choose difficulty:",
        list(SENTENCES.keys()),
        help="Select the appropriate difficulty level for your students"
    )
    
    # Sentence selection method
    st.sidebar.markdown("### 📝 Sentence Selection")
    selection_method = st.sidebar.radio(
        "How would you like to choose a sentence?",
        ["Random from difficulty level", "Choose specific sentence", "Use custom sentence"]
    )
    
    selected_sentence = ""
    
    if selection_method == "Random from difficulty level":
        if st.sidebar.button("🎲 Generate Random Sentence"):
            selected_sentence = random.choice(SENTENCES[difficulty])
            st.session_state.current_sentence = selected_sentence
            st.session_state.scrambled_words, _ = scramble_sentence(selected_sentence)
            st.session_state.show_answer = False
    
    elif selection_method == "Choose specific sentence":
        sentence_options = SENTENCES[difficulty]
        selected_sentence = st.sidebar.selectbox(
            "Select a sentence:",
            sentence_options
        )
        if st.sidebar.button("📝 Use This Sentence"):
            st.session_state.current_sentence = selected_sentence
            st.session_state.scrambled_words, _ = scramble_sentence(selected_sentence)
            st.session_state.show_answer = False
    
    elif selection_method == "Use custom sentence":
        custom_sentence = st.sidebar.text_area(
            "Enter your custom sentence:",
            height=100,
            help="Write your own sentence for students to unscramble"
        )
        if st.sidebar.button("✨ Create Custom Scramble"):
            if custom_sentence.strip():
                st.session_state.current_sentence = custom_sentence.strip()
                st.session_state.scrambled_words, _ = scramble_sentence(custom_sentence.strip())
                st.session_state.show_answer = False
                # Save custom sentence
                if custom_sentence.strip() not in st.session_state.custom_sentences:
                    st.session_state.custom_sentences.append(custom_sentence.strip())
    
    # Display custom sentences history
    if st.session_state.custom_sentences:
        st.sidebar.markdown("### 📚 Your Custom Sentences")
        for i, sent in enumerate(st.session_state.custom_sentences[-5:]):  # Show last 5
            if st.sidebar.button(f"📖 {sent[:30]}{'...' if len(sent) > 30 else ''}", key=f"custom_{i}"):
                st.session_state.current_sentence = sent
                st.session_state.scrambled_words, _ = scramble_sentence(sent)
                st.session_state.show_answer = False
    
    # Main content area
    if st.session_state.current_sentence:
        # Student Section
        st.markdown("## 🎯 Student Activity")
        st.markdown('<div class="student-section">', unsafe_allow_html=True)
        
        # Show difficulty level
        difficulty_class = "difficulty-easy" if "Easy" in difficulty else "difficulty-medium" if "Medium" in difficulty else "difficulty-hard"
        st.markdown(f'<div class="{difficulty_class}" style="padding: 0.5rem; margin: 1rem 0; border-radius: 0.5rem; background-color: #f8f9fa;"><strong>Difficulty: {difficulty}</strong></div>', unsafe_allow_html=True)
        
        # Instructions for students
        st.markdown("### 📋 Instructions")
        st.info("🔤 **Students:** Look at the scrambled words below and try to put them in the correct order to make a sentence!")
        
        # Display scrambled words
        st.markdown("### 🔀 Scrambled Words")
        if st.session_state.scrambled_words:
            word_cards_html = create_word_cards(st.session_state.scrambled_words)
            st.markdown(f'<div class="scrambled-sentence">{word_cards_html}</div>', unsafe_allow_html=True)
        
        # Student input area
        st.markdown("### ✍️ Your Answer")
        student_answer = st.text_input(
            "Type your unscrambled sentence here:",
            placeholder="Write the words in the correct order...",
            help="Arrange the words above to form a complete sentence"
        )
        
        # Check answer button
        col1, col2 = st.columns(2)
        with col1:
            if st.button("✅ Check My Answer", type="primary"):
                if student_answer.strip():
                    # Simple check - remove punctuation and compare
                    student_clean = re.sub(r'[^\w\s]', '', student_answer.strip().lower())
                    original_clean = re.sub(r'[^\w\s]', '', st.session_state.current_sentence.lower())
                    
                    if student_clean == original_clean:
                        st.success("🎉 Excellent! You got it right!")
                        st.balloons()
                    else:
                        st.warning("🤔 Not quite right. Try again!")
                else:
                    st.warning("Please enter your answer first!")
        
        with col2:
            if st.button("💡 Show Answer"):
                st.session_state.show_answer = True
        
        st.markdown('</div>', unsafe_allow_html=True)
        
        # Teacher Section
        st.markdown("## 👩‍🏫 Teacher Section")
        st.markdown('<div class="teacher-section">', unsafe_allow_html=True)
        
        # Show answer (for teacher)
        if st.session_state.show_answer:
            st.markdown("### 📖 Correct Answer")
            st.markdown(f'<div class="original-sentence"><strong>Original Sentence:</strong> {st.session_state.current_sentence}</div>', unsafe_allow_html=True)
        
        # Teaching tips
        with st.expander("💡 Teaching Tips"):
            st.markdown("""
            **How to use this activity:**
            1. **Display the scrambled words** on your smartboard or projector
            2. **Give students time** to work individually or in pairs
            3. **Encourage discussion** about sentence structure
            4. **Use follow-up questions** like:
               - What clues helped you figure out the order?
               - What makes this a complete sentence?
               - Can you identify the subject and predicate?
            5. **Extend the activity** by asking students to create their own sentences
            """)
        
        # Print-friendly version
        if st.checkbox("📄 Print-Friendly Version"):
            st.markdown("---")
            st.markdown("### Print Version")
            st.markdown(f"**Difficulty:** {difficulty}")
            st.markdown(f"**Scrambled Words:** {' | '.join(st.session_state.scrambled_words)}")
            st.markdown(f"**Answer:** {st.session_state.current_sentence}")
            st.markdown("**Student Name:** ________________")
            st.markdown("**Date:** ________________")
        
        st.markdown('</div>', unsafe_allow_html=True)
    
    else:
        # Welcome message
        st.markdown("""
        <div style="text-align: center; padding: 2rem; background-color: #f8f9fa; border-radius: 1rem; margin: 2rem 0;">
            <h2>🎯 Welcome to Sentence Scrambler!</h2>
            <p style="font-size: 1.1rem; color: #666;">
                This tool helps primary school teachers create engaging sentence unscrambling activities.<br>
                Select your options in the sidebar to get started!
            </p>
        </div>
        """, unsafe_allow_html=True)
        
        # Feature highlights
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.markdown("""
            ### 🎲 Easy to Use
            - Choose difficulty levels
            - Generate random sentences
            - Create custom sentences
            """)
        
        with col2:
            st.markdown("""
            ### 👩‍🏫 Teacher-Friendly
            - Instant answer checking
            - Teaching tips included
            - Print-friendly versions
            """)
        
        with col3:
            st.markdown("""
            ### 🎯 Student-Focused
            - Clear instructions
            - Interactive interface
            - Immediate feedback
            """)
    
    # Footer
    st.markdown("---")
    st.markdown(
        f"""
        <div style='text-align: center; color: #666; font-size: 0.9rem;'>
            <p>📚 Sentence Scrambler for Primary Schools | Built with ❤️ using Streamlit</p>
            <p>Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        </div>
        """,
        unsafe_allow_html=True
    )

if __name__ == "__main__":
    main()
