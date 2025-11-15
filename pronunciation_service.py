import speech_recognition as sr
import Levenshtein
import os
from pydub import AudioSegment
import re


class PronunciationService:
    """Service for pronunciation recognition and evaluation"""

    def __init__(self):
        self.recognizer = sr.Recognizer()

    def convert_to_wav(self, audio_path):
        """Convert audio file to WAV format for speech recognition"""
        try:
            # Get file extension
            file_ext = os.path.splitext(audio_path)[1].lower()

            # If already WAV, return path
            if file_ext == '.wav':
                return audio_path

            # Convert to WAV
            audio = AudioSegment.from_file(audio_path)
            wav_path = audio_path.rsplit('.', 1)[0] + '.wav'
            audio.export(wav_path, format='wav')

            return wav_path
        except Exception as e:
            print(f"Error converting audio: {e}")
            return None

    def transcribe_audio(self, audio_path, language='en-US'):
        """Transcribe audio file to text using Google Speech Recognition"""
        try:
            # Convert to WAV if needed
            wav_path = self.convert_to_wav(audio_path)
            if not wav_path:
                return None

            # Load audio file
            with sr.AudioFile(wav_path) as source:
                # Adjust for ambient noise
                self.recognizer.adjust_for_ambient_noise(source, duration=0.5)

                # Record the audio
                audio_data = self.recognizer.record(source)

                # Perform speech recognition
                try:
                    text = self.recognizer.recognize_google(audio_data, language=language)
                    return text
                except sr.UnknownValueError:
                    return ""
                except sr.RequestError as e:
                    print(f"Could not request results from Google Speech Recognition service; {e}")
                    return None

        except Exception as e:
            print(f"Error transcribing audio: {e}")
            return None

    def normalize_text(self, text):
        """Normalize text for comparison (lowercase, remove punctuation)"""
        # Convert to lowercase
        text = text.lower()

        # Remove punctuation and extra whitespace
        text = re.sub(r'[^\w\s]', '', text)
        text = re.sub(r'\s+', ' ', text)

        return text.strip()

    def calculate_similarity(self, expected, actual):
        """Calculate similarity score between expected and actual text using Levenshtein distance"""
        # Normalize both texts
        expected_norm = self.normalize_text(expected)
        actual_norm = self.normalize_text(actual)

        if not expected_norm or not actual_norm:
            return 0.0

        # Calculate Levenshtein distance
        distance = Levenshtein.distance(expected_norm, actual_norm)

        # Calculate similarity percentage
        max_len = max(len(expected_norm), len(actual_norm))
        similarity = (1 - distance / max_len) * 100

        return max(0.0, min(100.0, similarity))

    def generate_feedback(self, expected, actual, score):
        """Generate feedback based on pronunciation score"""
        feedback = []

        if score >= 90:
            feedback.append("Excellent pronunciation! 🎉")
        elif score >= 75:
            feedback.append("Good job! Keep practicing. 👍")
        elif score >= 60:
            feedback.append("Not bad, but there's room for improvement. 💪")
        elif score >= 40:
            feedback.append("Keep trying! Practice makes perfect. 📚")
        else:
            feedback.append("Try again! Listen carefully to the original. 🎧")

        # Detailed comparison
        expected_norm = self.normalize_text(expected)
        actual_norm = self.normalize_text(actual)

        if expected_norm != actual_norm:
            feedback.append(f"\nExpected: \"{expected}\"")
            feedback.append(f"You said: \"{actual}\"")

            # Find differences
            expected_words = expected_norm.split()
            actual_words = actual_norm.split()

            if len(expected_words) != len(actual_words):
                feedback.append(f"\nWord count - Expected: {len(expected_words)}, Yours: {len(actual_words)}")

        return "\n".join(feedback)

    def evaluate_pronunciation(self, audio_path, expected_text, language='en-US'):
        """
        Evaluate pronunciation by transcribing audio and comparing to expected text

        Returns: dict with keys:
            - transcription: The transcribed text
            - score: Similarity score (0-100)
            - feedback: Detailed feedback message
        """
        # Transcribe the audio
        transcription = self.transcribe_audio(audio_path, language)

        if transcription is None:
            return {
                'transcription': '',
                'score': 0.0,
                'feedback': 'Error processing audio. Please try again.'
            }

        if not transcription:
            return {
                'transcription': '',
                'score': 0.0,
                'feedback': 'Could not understand audio. Please speak clearly and try again.'
            }

        # Calculate similarity score
        score = self.calculate_similarity(expected_text, transcription)

        # Generate feedback
        feedback = self.generate_feedback(expected_text, transcription, score)

        return {
            'transcription': transcription,
            'score': round(score, 2),
            'feedback': feedback
        }
