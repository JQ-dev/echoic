import os

class Config:
    """Flask application configuration"""

    # Secret key for session management
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'

    # Database configuration
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///echoic.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Upload folders
    UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static', 'uploads')
    RECORDINGS_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static', 'recordings')

    # Maximum file size (16 MB)
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024

    # Allowed extensions
    ALLOWED_AUDIO_EXTENSIONS = {'mp3', 'wav', 'ogg', 'm4a', 'flac'}
    ALLOWED_TEXT_EXTENSIONS = {'txt', 'lrc'}
