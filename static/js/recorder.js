// Audio recording and pronunciation evaluation

let mediaRecorder;
let audioChunks = [];
let recordedBlob;
let currentLineNumber = null;
let currentLineText = null;

const recordBtn = document.getElementById('recordBtn');
const stopBtn = document.getElementById('stopBtn');
const playbackBtn = document.getElementById('playbackBtn');
const recordedAudio = document.getElementById('recordedAudio');
const recordingStatus = document.getElementById('recordingStatus');
const evaluationResult = document.getElementById('evaluationResult');
const selectedLineDiv = document.getElementById('selectedLine');

// Select a line to practice
function selectLine(lineNumber, lineText) {
    currentLineNumber = lineNumber;
    currentLineText = lineText;

    // Update UI
    selectedLineDiv.innerHTML = `
        <p><strong>Practicing line ${lineNumber + 1}:</strong></p>
        <p class="selected-text">"${lineText}"</p>
    `;

    // Enable record button
    recordBtn.disabled = false;
    stopBtn.disabled = true;
    playbackBtn.disabled = true;

    // Clear previous evaluation
    evaluationResult.style.display = 'none';

    // Highlight selected line
    document.querySelectorAll('.lyric-line').forEach(line => {
        line.classList.remove('active');
    });
    document.querySelector(`[data-line-number="${lineNumber}"]`).classList.add('active');
}

// Start recording
async function startRecording() {
    try {
        // Request microphone access
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

        // Create MediaRecorder
        mediaRecorder = new MediaRecorder(stream);
        audioChunks = [];

        mediaRecorder.ondataavailable = (event) => {
            audioChunks.push(event.data);
        };

        mediaRecorder.onstop = async () => {
            // Create blob from chunks
            recordedBlob = new Blob(audioChunks, { type: 'audio/wav' });

            // Create URL for playback
            const audioUrl = URL.createObjectURL(recordedBlob);
            recordedAudio.src = audioUrl;

            // Enable playback button
            playbackBtn.disabled = false;

            // Automatically evaluate
            await evaluatePronunciation();
        };

        // Start recording
        mediaRecorder.start();

        // Update UI
        recordBtn.disabled = true;
        stopBtn.disabled = false;
        playbackBtn.disabled = true;
        recordingStatus.innerHTML = '<span class="recording-active">🔴 Recording...</span>';
        evaluationResult.style.display = 'none';

    } catch (error) {
        console.error('Error accessing microphone:', error);
        recordingStatus.innerHTML = '<span class="error">Error: Could not access microphone. Please grant permission.</span>';
    }
}

// Stop recording
function stopRecording() {
    if (mediaRecorder && mediaRecorder.state !== 'inactive') {
        mediaRecorder.stop();

        // Stop all tracks
        mediaRecorder.stream.getTracks().forEach(track => track.stop());

        // Update UI
        recordBtn.disabled = false;
        stopBtn.disabled = true;
        recordingStatus.innerHTML = '<span class="success">✓ Recording complete!</span>';
    }
}

// Play recorded audio
function playRecording() {
    recordedAudio.play();
}

// Evaluate pronunciation
async function evaluatePronunciation() {
    if (!recordedBlob || currentLineNumber === null || !currentLineText) {
        return;
    }

    recordingStatus.innerHTML = '<span class="processing">⏳ Evaluating pronunciation...</span>';

    try {
        // Create FormData
        const formData = new FormData();
        formData.append('audio', recordedBlob, 'recording.wav');
        formData.append('song_id', SONG_ID);
        formData.append('line_number', currentLineNumber);
        formData.append('expected_text', currentLineText);
        formData.append('language', SONG_LANGUAGE);

        // Send to server
        const response = await fetch('/api/evaluate', {
            method: 'POST',
            body: formData
        });

        const data = await response.json();

        if (data.success) {
            // Display results
            displayEvaluation(data);
            recordingStatus.innerHTML = '<span class="success">✓ Evaluation complete!</span>';
        } else {
            recordingStatus.innerHTML = `<span class="error">Error: ${data.error}</span>`;
        }

    } catch (error) {
        console.error('Error evaluating pronunciation:', error);
        recordingStatus.innerHTML = '<span class="error">Error: Could not evaluate pronunciation. Please try again.</span>';
    }
}

// Display evaluation results
function displayEvaluation(data) {
    const scoreValue = document.getElementById('scoreValue');
    const transcriptionText = document.getElementById('transcriptionText');
    const feedbackText = document.getElementById('feedbackText');

    // Update score
    scoreValue.textContent = `${data.score}%`;

    // Color code score
    scoreValue.className = 'score-value';
    if (data.score >= 90) {
        scoreValue.classList.add('score-excellent');
    } else if (data.score >= 75) {
        scoreValue.classList.add('score-good');
    } else if (data.score >= 60) {
        scoreValue.classList.add('score-fair');
    } else {
        scoreValue.classList.add('score-poor');
    }

    // Update transcription
    transcriptionText.textContent = data.transcription || '(no speech detected)';

    // Update feedback
    feedbackText.innerHTML = data.feedback.replace(/\n/g, '<br>');

    // Show evaluation result
    evaluationResult.style.display = 'block';

    // Scroll to result
    evaluationResult.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Check browser support
if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    recordingStatus.innerHTML = '<span class="error">Your browser does not support audio recording.</span>';
    recordBtn.disabled = true;
}
