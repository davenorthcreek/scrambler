# 🔤 Sentence Scrambler

A fun and interactive web application designed for primary school teachers to create sentence unscrambling activities for their students.

## Features

- **Multiple Difficulty Levels**: Easy (3-5 words), Medium (6-8 words), Hard (9+ words)
- **Pre-made Sentences**: Over 30 age-appropriate sentences included
- **Custom Sentences**: Teachers can create their own sentences
- **Interactive Interface**: Student-friendly design with colorful word cards
- **Answer Checking**: Instant feedback for students
- **Teaching Tools**: Built-in teaching tips and print-friendly versions
- **Responsive Design**: Works on desktops, tablets, and smartphones

## Quick Start

### Prerequisites

- Python 3.8 or higher
- pip package manager

### Installation

1. **Clone or download the project**
   ```bash
   cd vibe
   ```

2. **Create a virtual environment**
   ```bash
   python3 -m venv venv
   ```

3. **Activate the virtual environment**
   ```bash
   # On Linux/Mac
   source venv/bin/activate
   
   # On Windows
   venv\Scripts\activate
   ```

4. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

5. **Run the application**
   ```bash
   streamlit run app.py
   ```

6. **Open your browser**
   Navigate to `http://localhost:8501`

## How to Use

### For Teachers

1. **Select Difficulty Level**: Choose from Easy, Medium, or Hard based on your students' reading level
2. **Choose a Sentence**: 
   - Use random generation for quick activities
   - Pick specific sentences from the pre-made list
   - Create custom sentences for targeted learning
3. **Display to Students**: Show the scrambled words on your smartboard or projector
4. **Guide Learning**: Use the built-in teaching tips to enhance the activity

### For Students

1. **Read the scrambled words** displayed as colorful cards
2. **Think about the correct order** to form a complete sentence
3. **Type your answer** in the input field
4. **Check your answer** to get instant feedback
5. **Try again** if needed or ask for the answer

## Educational Benefits

- **Sentence Structure**: Helps students understand word order and grammar
- **Reading Comprehension**: Encourages careful reading and analysis
- **Critical Thinking**: Students must use context clues to determine correct order
- **Vocabulary Building**: Exposure to varied sentence structures and words
- **Collaborative Learning**: Great for pair or small group activities

## Technical Features

- **Built with Streamlit**: Modern, responsive web framework
- **No Database Required**: All data is generated dynamically
- **Lightweight**: Minimal dependencies for easy deployment
- **Cross-Platform**: Runs on Windows, Mac, and Linux

## Deployment Options

### Local Development
```bash
streamlit run app.py
```

### Production Deployment
The app can be deployed to various platforms:
- **Heroku**: Easy deployment with git
- **AWS EC2**: Full server control
- **Streamlit Cloud**: Free hosting for public apps
- **Docker**: Containerized deployment

## File Structure

```
vibe/
├── app.py              # Main application file
├── requirements.txt    # Python dependencies
├── README.md          # This file
├── venv/              # Virtual environment (created after setup)
└── .streamlit/        # Streamlit configuration (optional)
```

## Customization

### Adding New Sentences
Edit the `SENTENCES` dictionary in `app.py` to add new pre-made sentences:

```python
SENTENCES = {
    "Easy (3-5 words)": [
        "Your new sentence here.",
        # Add more sentences...
    ],
    # ... other difficulty levels
}
```

### Changing Appearance
Modify the CSS in the `st.markdown()` section to customize colors, fonts, and layout.

### Adding Features
The modular design makes it easy to add new features like:
- Audio pronunciation
- Hint systems
- Progress tracking
- Printable worksheets

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   streamlit run app.py --server.port 8502
   ```

2. **Module not found**
   ```bash
   pip install -r requirements.txt
   ```

3. **Virtual environment issues**
   ```bash
   deactivate
   rm -rf venv
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the MIT License.

## Support

For questions or support, please create an issue in the project repository.

---

**Built with ❤️ for primary school teachers and students**