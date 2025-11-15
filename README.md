# ECHOIC - Pronunciation Practice Platform

A full-stack Flask web application for practicing pronunciation through song lyrics. Upload songs, record your pronunciation, and get real-time feedback with AI-powered speech recognition.

## Features

- **User Authentication**: Secure registration and login system
- **Song Management**: Upload songs with lyrics and audio files
- **Voice Recording**: Record your pronunciation directly in the browser
- **Pronunciation Recognition**: AI-powered speech-to-text using Google Speech Recognition
- **Pronunciation Evaluation**: Get instant feedback and scoring on your pronunciation
- **Multi-language Support**: Practice in English, Spanish, French, German, Italian, Portuguese, Japanese, Korean, Chinese, Russian, and more
- **Progress Tracking**: View your practice history and improvement over time

## Technology Stack

### Backend
- **Flask**: Python web framework
- **SQLAlchemy**: ORM for database management
- **Flask-Login**: User session management
- **SpeechRecognition**: Google Speech-to-Text API integration
- **python-Levenshtein**: Text similarity calculation for pronunciation scoring
- **pydub**: Audio file processing

### Frontend
- **HTML5/CSS3**: Responsive design
- **JavaScript**: Audio recording with MediaRecorder API
- **Jinja2**: Template engine

### Database
- **SQLite**: Lightweight database for development (easily upgradeable to PostgreSQL for production)

## Installation

### Prerequisites
- Python 3.8 or higher
- pip (Python package manager)
- ffmpeg (for audio processing)

### Install ffmpeg

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install ffmpeg
```

**macOS:**
```bash
brew install ffmpeg
```

**Windows:**
Download from https://ffmpeg.org/download.html and add to PATH

### Setup

1. **Clone the repository:**
```bash
git clone <repository-url>
cd echoic
```

2. **Create a virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Initialize the database:**
```bash
flask init-db
```

Or simply run the app (it will auto-create the database):
```bash
python app.py
```

5. **Access the application:**
Open your browser and navigate to: `http://localhost:5000`

## Usage

### 1. Register an Account
- Click "Register" in the navigation
- Fill in your username, email, and password
- Submit the form

### 2. Login
- Enter your credentials on the login page
- You'll be redirected to your dashboard

### 3. Upload a Song
- Click "Upload New Song" from the dashboard
- Fill in the song details:
  - **Title**: Name of the song
  - **Artist**: Artist name (optional)
  - **Language**: Select the language for pronunciation recognition
  - **Audio File**: Upload the song audio (optional, MP3/WAV/OGG/M4A/FLAC)
  - **Lyrics**: Enter the song lyrics (one line per phrase)
- Click "Upload Song"

### 4. Practice Pronunciation
- Click "Practice" on any song from your dashboard
- Select a line from the lyrics by clicking "Practice" button
- Click "Start Recording" and speak the line
- Click "Stop Recording" when done
- The system will automatically:
  - Transcribe your speech
  - Compare it to the expected text
  - Calculate a similarity score (0-100%)
  - Provide detailed feedback

### 5. View Progress
- See your recent practice attempts on the song practice page
- Scores are color-coded:
  - **Green (90-100%)**: Excellent
  - **Blue (75-89%)**: Good
  - **Yellow (60-74%)**: Fair
  - **Red (0-59%)**: Needs improvement

## Project Structure

```
echoic/
├── app.py                      # Main Flask application
├── config.py                   # Configuration settings
├── models.py                   # Database models
├── pronunciation_service.py    # Speech recognition and evaluation
├── requirements.txt            # Python dependencies
├── templates/                  # HTML templates
│   ├── base.html              # Base template
│   ├── login.html             # Login page
│   ├── register.html          # Registration page
│   ├── dashboard.html         # User dashboard
│   ├── upload.html            # Song upload form
│   └── practice.html          # Practice page
├── static/                     # Static files
│   ├── css/
│   │   └── style.css          # Application styles
│   ├── js/
│   │   └── recorder.js        # Audio recording logic
│   ├── uploads/               # User-uploaded songs
│   └── recordings/            # User pronunciation recordings
└── echoic.db                  # SQLite database (auto-created)
```

## API Endpoints

### Authentication
- `GET/POST /register`: User registration
- `GET/POST /login`: User login
- `GET /logout`: User logout

### Song Management
- `GET /dashboard`: View all user songs
- `GET/POST /upload`: Upload new song
- `GET /song/<id>`: Practice a song
- `POST /song/<id>/delete`: Delete a song

### Pronunciation Evaluation
- `POST /api/evaluate`: Evaluate pronunciation recording
- `GET /api/attempts/<song_id>`: Get practice history

## Configuration

Edit `config.py` to customize:

- `SECRET_KEY`: Flask session secret (change in production!)
- `SQLALCHEMY_DATABASE_URI`: Database connection string
- `UPLOAD_FOLDER`: Directory for uploaded songs
- `RECORDINGS_FOLDER`: Directory for pronunciation recordings
- `MAX_CONTENT_LENGTH`: Maximum file upload size (default: 16MB)
- `ALLOWED_AUDIO_EXTENSIONS`: Allowed audio file formats

## Database Models

### User
- `id`: Primary key
- `username`: Unique username
- `email`: Unique email address
- `password_hash`: Hashed password
- `created_at`: Registration timestamp

### Song
- `id`: Primary key
- `title`: Song title
- `artist`: Artist name
- `lyrics`: Song lyrics (text)
- `audio_filename`: Uploaded audio file
- `language`: Language code (e.g., 'en-US')
- `user_id`: Foreign key to User
- `uploaded_at`: Upload timestamp

### PronunciationAttempt
- `id`: Primary key
- `user_id`: Foreign key to User
- `song_id`: Foreign key to Song
- `line_number`: Line index in lyrics
- `expected_text`: Expected pronunciation
- `transcription`: Recognized speech
- `audio_filename`: Recorded audio file
- `score`: Similarity score (0-100)
- `feedback`: Detailed feedback text
- `timestamp`: Recording timestamp

## Pronunciation Evaluation Algorithm

The system uses a multi-step approach:

1. **Speech Recognition**: Google Speech-to-Text API transcribes the audio
2. **Text Normalization**: Both texts are normalized (lowercase, remove punctuation)
3. **Similarity Calculation**: Levenshtein distance measures text similarity
4. **Score Calculation**: `score = (1 - distance/max_length) * 100`
5. **Feedback Generation**: Contextual feedback based on score and differences

## Supported Languages

- English (US, UK)
- Spanish (Spain, Mexico)
- French
- German
- Italian
- Portuguese (Brazil)
- Japanese
- Korean
- Chinese (Simplified)
- Russian

*Note: Speech recognition quality depends on Google's language support*

## Production Deployment

For production deployment:

1. **Set environment variables:**
```bash
export SECRET_KEY='your-secret-key-here'
export DATABASE_URL='postgresql://user:pass@localhost/echoic'
```

2. **Use a production database:**
   - Replace SQLite with PostgreSQL or MySQL
   - Update `SQLALCHEMY_DATABASE_URI` in config

3. **Use a production server:**
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

4. **Enable HTTPS:**
   - Use nginx or Apache as reverse proxy
   - Configure SSL certificates

5. **Set DEBUG=False:**
   - Remove `debug=True` from `app.run()`

## Troubleshooting

### Microphone not working
- Grant browser permission to access microphone
- Check browser compatibility (Chrome/Firefox recommended)
- Ensure HTTPS is enabled (required for microphone access)

### Speech recognition errors
- Check internet connection (Google API requires internet)
- Speak clearly and at moderate pace
- Ensure audio quality is good

### Audio file upload errors
- Check file format (MP3, WAV, OGG, M4A, FLAC)
- Ensure file size is under 16MB
- Verify ffmpeg is installed

## License

This project is open source and available for educational purposes.

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Support

For issues and questions, please open an issue on the GitHub repository.

---

**Happy practicing! 🎵**
