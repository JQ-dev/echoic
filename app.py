from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, send_from_directory
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from werkzeug.utils import secure_filename
import os
from datetime import datetime

from config import Config
from models import db, User, Song, PronunciationAttempt
from pronunciation_service import PronunciationService

# Initialize Flask app
app = Flask(__name__)
app.config.from_object(Config)

# Initialize database
db.init_app(app)

# Initialize Flask-Login
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Initialize pronunciation service
pronunciation_service = PronunciationService()


@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))


def allowed_file(filename, allowed_extensions):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in allowed_extensions


# Create upload directories
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['RECORDINGS_FOLDER'], exist_ok=True)


# =============================================================================
# AUTHENTICATION ROUTES
# =============================================================================

@app.route('/')
def index():
    """Home page"""
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))


@app.route('/register', methods=['GET', 'POST'])
def register():
    """User registration"""
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))

    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        confirm_password = request.form.get('confirm_password', '')

        # Validation
        if not username or not email or not password:
            flash('All fields are required', 'error')
            return render_template('register.html')

        if password != confirm_password:
            flash('Passwords do not match', 'error')
            return render_template('register.html')

        if len(password) < 6:
            flash('Password must be at least 6 characters', 'error')
            return render_template('register.html')

        # Check if user exists
        if User.query.filter_by(username=username).first():
            flash('Username already exists', 'error')
            return render_template('register.html')

        if User.query.filter_by(email=email).first():
            flash('Email already registered', 'error')
            return render_template('register.html')

        # Create new user
        user = User(username=username, email=email)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()

        flash('Registration successful! Please login.', 'success')
        return redirect(url_for('login'))

    return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    """User login"""
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))

    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')

        if not username or not password:
            flash('Username and password are required', 'error')
            return render_template('login.html')

        user = User.query.filter_by(username=username).first()

        if user and user.check_password(password):
            login_user(user)
            next_page = request.args.get('next')
            return redirect(next_page or url_for('dashboard'))
        else:
            flash('Invalid username or password', 'error')

    return render_template('login.html')


@app.route('/logout')
@login_required
def logout():
    """User logout"""
    logout_user()
    flash('You have been logged out', 'success')
    return redirect(url_for('login'))


# =============================================================================
# DASHBOARD & SONG MANAGEMENT ROUTES
# =============================================================================

@app.route('/dashboard')
@login_required
def dashboard():
    """User dashboard showing all songs"""
    songs = Song.query.filter_by(user_id=current_user.id).order_by(Song.uploaded_at.desc()).all()
    return render_template('dashboard.html', songs=songs)


@app.route('/upload', methods=['GET', 'POST'])
@login_required
def upload_song():
    """Upload a new song"""
    if request.method == 'POST':
        title = request.form.get('title', '').strip()
        artist = request.form.get('artist', '').strip()
        lyrics = request.form.get('lyrics', '').strip()
        language = request.form.get('language', 'en-US')

        if not title:
            flash('Song title is required', 'error')
            return render_template('upload.html')

        # Handle audio file upload
        audio_file = request.files.get('audio_file')
        audio_filename = None

        if audio_file and audio_file.filename:
            if allowed_file(audio_file.filename, app.config['ALLOWED_AUDIO_EXTENSIONS']):
                # Create unique filename
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                original_filename = secure_filename(audio_file.filename)
                audio_filename = f"{current_user.id}_{timestamp}_{original_filename}"

                # Save file
                audio_path = os.path.join(app.config['UPLOAD_FOLDER'], audio_filename)
                audio_file.save(audio_path)
            else:
                flash('Invalid audio file format', 'error')
                return render_template('upload.html')

        # Create song record
        song = Song(
            title=title,
            artist=artist,
            lyrics=lyrics,
            audio_filename=audio_filename,
            language=language,
            user_id=current_user.id
        )
        db.session.add(song)
        db.session.commit()

        flash('Song uploaded successfully!', 'success')
        return redirect(url_for('dashboard'))

    return render_template('upload.html')


@app.route('/song/<int:song_id>')
@login_required
def view_song(song_id):
    """View and practice a song"""
    song = Song.query.get_or_404(song_id)

    # Ensure user owns the song
    if song.user_id != current_user.id:
        flash('Access denied', 'error')
        return redirect(url_for('dashboard'))

    # Get previous attempts for this song
    attempts = PronunciationAttempt.query.filter_by(
        user_id=current_user.id,
        song_id=song_id
    ).order_by(PronunciationAttempt.timestamp.desc()).limit(10).all()

    return render_template('practice.html', song=song, attempts=attempts)


@app.route('/song/<int:song_id>/delete', methods=['POST'])
@login_required
def delete_song(song_id):
    """Delete a song"""
    song = Song.query.get_or_404(song_id)

    if song.user_id != current_user.id:
        flash('Access denied', 'error')
        return redirect(url_for('dashboard'))

    # Delete audio file if exists
    if song.audio_filename:
        audio_path = os.path.join(app.config['UPLOAD_FOLDER'], song.audio_filename)
        if os.path.exists(audio_path):
            os.remove(audio_path)

    # Delete all recording files for this song
    for attempt in song.attempts:
        if attempt.audio_filename:
            recording_path = os.path.join(app.config['RECORDINGS_FOLDER'], attempt.audio_filename)
            if os.path.exists(recording_path):
                os.remove(recording_path)

    db.session.delete(song)
    db.session.commit()

    flash('Song deleted successfully', 'success')
    return redirect(url_for('dashboard'))


# =============================================================================
# PRONUNCIATION EVALUATION API ROUTES
# =============================================================================

@app.route('/api/evaluate', methods=['POST'])
@login_required
def evaluate_pronunciation():
    """API endpoint to evaluate pronunciation"""
    try:
        # Get form data
        song_id = request.form.get('song_id', type=int)
        line_number = request.form.get('line_number', type=int)
        expected_text = request.form.get('expected_text', '').strip()
        language = request.form.get('language', 'en-US')

        if not song_id or line_number is None or not expected_text:
            return jsonify({'error': 'Missing required fields'}), 400

        # Get song
        song = Song.query.get(song_id)
        if not song or song.user_id != current_user.id:
            return jsonify({'error': 'Song not found'}), 404

        # Get audio file
        audio_file = request.files.get('audio')
        if not audio_file:
            return jsonify({'error': 'No audio file provided'}), 400

        # Save recording
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        audio_filename = f"{current_user.id}_{song_id}_{line_number}_{timestamp}.wav"
        audio_path = os.path.join(app.config['RECORDINGS_FOLDER'], audio_filename)
        audio_file.save(audio_path)

        # Evaluate pronunciation
        result = pronunciation_service.evaluate_pronunciation(
            audio_path,
            expected_text,
            language
        )

        # Save attempt to database
        attempt = PronunciationAttempt(
            user_id=current_user.id,
            song_id=song_id,
            line_number=line_number,
            expected_text=expected_text,
            transcription=result['transcription'],
            audio_filename=audio_filename,
            score=result['score'],
            feedback=result['feedback']
        )
        db.session.add(attempt)
        db.session.commit()

        return jsonify({
            'success': True,
            'transcription': result['transcription'],
            'score': result['score'],
            'feedback': result['feedback'],
            'attempt_id': attempt.id
        })

    except Exception as e:
        print(f"Error in evaluate_pronunciation: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/api/attempts/<int:song_id>')
@login_required
def get_attempts(song_id):
    """Get all pronunciation attempts for a song"""
    song = Song.query.get_or_404(song_id)

    if song.user_id != current_user.id:
        return jsonify({'error': 'Access denied'}), 403

    attempts = PronunciationAttempt.query.filter_by(
        user_id=current_user.id,
        song_id=song_id
    ).order_by(PronunciationAttempt.timestamp.desc()).all()

    return jsonify([{
        'id': a.id,
        'line_number': a.line_number,
        'expected_text': a.expected_text,
        'transcription': a.transcription,
        'score': a.score,
        'feedback': a.feedback,
        'timestamp': a.timestamp.isoformat()
    } for a in attempts])


# =============================================================================
# STATIC FILE SERVING
# =============================================================================

@app.route('/uploads/<filename>')
@login_required
def uploaded_file(filename):
    """Serve uploaded audio files"""
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)


@app.route('/recordings/<filename>')
@login_required
def recorded_file(filename):
    """Serve recorded audio files"""
    return send_from_directory(app.config['RECORDINGS_FOLDER'], filename)


# =============================================================================
# DATABASE INITIALIZATION
# =============================================================================

@app.cli.command()
def init_db():
    """Initialize the database"""
    db.create_all()
    print("Database initialized!")


@app.cli.command()
def reset_db():
    """Reset the database (WARNING: deletes all data)"""
    db.drop_all()
    db.create_all()
    print("Database reset!")


# =============================================================================
# RUN APPLICATION
# =============================================================================

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=5000)
