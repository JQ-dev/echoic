from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

db = SQLAlchemy()


class User(UserMixin, db.Model):
    """User model for authentication"""

    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relationships
    songs = db.relationship('Song', backref='uploader', lazy=True, cascade='all, delete-orphan')
    attempts = db.relationship('PronunciationAttempt', backref='user', lazy=True, cascade='all, delete-orphan')

    def set_password(self, password):
        """Hash and set password"""
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        """Check if password is correct"""
        return check_password_hash(self.password_hash, password)

    def __repr__(self):
        return f'<User {self.username}>'


class Song(db.Model):
    """Song model for uploaded songs"""

    __tablename__ = 'songs'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    artist = db.Column(db.String(200))
    lyrics = db.Column(db.Text)
    audio_filename = db.Column(db.String(255))
    language = db.Column(db.String(50), default='en')
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    uploaded_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relationships
    attempts = db.relationship('PronunciationAttempt', backref='song', lazy=True, cascade='all, delete-orphan')

    def get_lyrics_lines(self):
        """Get lyrics as a list of lines"""
        if not self.lyrics:
            return []
        return [line.strip() for line in self.lyrics.split('\n') if line.strip()]

    def __repr__(self):
        return f'<Song {self.title} by {self.artist}>'


class PronunciationAttempt(db.Model):
    """Pronunciation attempt model for tracking user practice"""

    __tablename__ = 'pronunciation_attempts'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    song_id = db.Column(db.Integer, db.ForeignKey('songs.id'), nullable=False)
    line_number = db.Column(db.Integer, nullable=False)
    expected_text = db.Column(db.Text, nullable=False)
    transcription = db.Column(db.Text)
    audio_filename = db.Column(db.String(255))
    score = db.Column(db.Float)
    feedback = db.Column(db.Text)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<PronunciationAttempt {self.id} - Score: {self.score}>'
