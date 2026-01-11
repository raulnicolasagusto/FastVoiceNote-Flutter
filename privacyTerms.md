<div style="max-width: 900px; margin: 0 auto; padding: 20px; line-height: 1.6;">

<h1 style="color: #6366F1; border-bottom: 3px solid #6366F1; padding-bottom: 10px; margin-bottom: 10px;">Privacy Policy for FastVoiceNote</h1>
<p style="font-style: italic; color: #999; font-size: 0.9em; margin-bottom: 30px;"><strong>Last Updated:</strong> January 11, 2026</p>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">Introduction</h2>
<p>Welcome to <strong>FastVoiceNote</strong>! This Privacy Policy explains how we handle your information when you use our mobile application. We are committed to protecting your privacy and maintaining transparency about our data practices.</p>
<p><strong>FastVoiceNote</strong> is a voice-first note-taking app. Voice transcription runs <strong>entirely on-device</strong> using <strong>Whisper.cpp</strong>. We do not send audio, text, or images to external servers.</p>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">1. Information We Collect</h2>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">1.1 Data Stored Locally on Your Device</h3>
<div style="background-color: rgba(254, 243, 199, 0.15); padding: 15px; border-left: 4px solid #F59E0B; margin: 20px 0;">
    <strong style="color: #FDB022;">FastVoiceNote stores all user data locally on your device</strong> in the app’s internal database. This includes:
</div>
<ul style="margin: 15px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Notes:</strong> Text content, checklists, titles, and metadata</li>
    <li style="margin-bottom: 8px;"><strong>Voice Notes:</strong> Quick voice recordings transcribed on-device</li>
    <li style="margin-bottom: 8px;"><strong>Meeting Recordings:</strong> Long-form audio recordings (up to 1 hour) with chunked transcription</li>
    <li style="margin-bottom: 8px;"><strong>Images:</strong> Attachments you choose to add to your notes</li>
    <li style="margin-bottom: 8px;"><strong>OCR Transcriptions:</strong> Text extracted from images using Google ML Kit (on-device)</li>
    <li style="margin-bottom: 8px;"><strong>Folders and Categories:</strong> Your organizational structure</li>
    <li style="margin-bottom: 8px;"><strong>Reminders:</strong> Scheduled times for local notifications</li>
    <li style="margin-bottom: 8px;"><strong>Settings and Preferences:</strong> Theme, language, and app configuration</li>
</ul>
<p><strong>Important:</strong> We do <strong>NOT</strong> upload your notes, recordings, images, or personal data to our servers or any cloud services. All data remains on your device unless you explicitly choose to share it.</p>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">1.2 Data Sent to Third-Party Services</h3>
<p><strong>No data is sent to third-party services.</strong> Voice transcription, checklist detection, and note processing are performed locally on your device using Whisper.cpp and on-device logic.</p>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">2. Permissions Used</h2>
<p>FastVoiceNote requests only the permissions necessary for core functionality:</p>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">Microphone (android.permission.RECORD_AUDIO)</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Purpose:</strong> Record voice notes for on-device transcription</li>
    <li style="margin-bottom: 8px;"><strong>Usage:</strong> Activated only when you press the microphone button</li>
    <li style="margin-bottom: 8px;"><strong>Data Storage:</strong> Audio is stored locally on your device</li>
</ul>

<!-- The following permissions are NOT used in the current version. Kept here for clarity and styling consistency. -->
<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">Camera (android.permission.CAMERA)</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Status:</strong> <span style="color:#DC2626;">Not used in this version.</span></li>
</ul>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">Notifications (android.permission.POST_NOTIFICATIONS)</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Status:</strong> Used only if your device prompts for local reminder notifications.</li>
</ul>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">Exact Alarms (android.permission.SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM)</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Status:</strong> May be requested by the OS for precise reminders on some Android versions.</li>
</ul>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">Vibration (android.permission.VIBRATE)</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Status:</strong> Optional haptic feedback; managed by the OS.</li>
</ul>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">Wake Lock (android.permission.WAKE_LOCK)</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Status:</strong> Used temporarily during recording to keep the device awake; managed by the OS.</li>
</ul>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">3. How We Use Your Information</h2>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">3.1 Local Use (No Internet Required)</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;">Creating, editing, and organizing notes and checklists</li>
    <li style="margin-bottom: 8px;">Recording quick voice notes with on-device transcription</li>
    <li style="margin-bottom: 8px;">Recording meetings (up to 1 hour) with chunked audio processing</li>
    <li style="margin-bottom: 8px;">Storing audio recordings and attachments locally</li>
    <li style="margin-bottom: 8px;">Extracting text from images using on-device OCR</li>
    <li style="margin-bottom: 8px;">Managing folders and reminder schedules</li>
    <li style="margin-bottom: 8px;">Applying theme and language preferences</li>
</ul>

<p><strong>Image OCR Feature:</strong> FastVoiceNote includes a one-tap "TRANSCRIBE" button that appears below each image attachment. When you tap this button, the app uses Google ML Kit to extract text from the image entirely on your device. The extracted text is then appended to the bottom of your note, preserving your existing content, checklists, and formatting. No images are uploaded to external servers for processing. If no text is detected in an image, you will receive a friendly notification.</p>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">3.2 Internet-Dependent Features</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>None required for core features.</strong> Internet may be used only for optional actions such as app updates or sharing content via system apps.</li>
</ul>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">4. Data Sharing and Disclosure</h2>
<p><strong>We do NOT sell, rent, or share your personal data</strong>. No audio, text, or images leave your device unless you explicitly share them.</p>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">4.1 Third-Party Service Providers</h3>
<p><strong>No third-party processing.</strong> FastVoiceNote performs transcription and processing on-device.</p>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">4.2 Legal Requirements</h3>
<p>We may disclose information if required by law, court order, or governmental request, or to:</p>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;">Comply with legal obligations</li>
    <li style="margin-bottom: 8px;">Protect our rights, property, or safety</li>
    <li style="margin-bottom: 8px;">Prevent fraud or security threats</li>
</ul>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">4.3 Business Transfers</h3>
<p>If FastVoiceNote is acquired or merged, user data may be transferred as part of that transaction. You will be notified of any change.</p>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">5. Data Retention</h2>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">5.1 Local Data</h3>
<p><strong>User Control:</strong> You can delete notes, audio, and all app data at any time by:</p>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;">Deleting items within the app</li>
    <li style="margin-bottom: 8px;">Clearing app data in Android settings</li>
    <li style="margin-bottom: 8px;">Uninstalling the app</li>
</ul>

<h3 style="color: #8B93FF; margin-top: 25px; margin-bottom: 10px;">5.2 Third-Party Data</h3>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Not applicable:</strong> No third-party processing is used.</li>
</ul>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">6. Data Security</h2>
<p>We take reasonable measures to protect your data:</p>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Local Storage:</strong> Data is stored in the app’s internal storage on your device</li>
    <li style="margin-bottom: 8px;"><strong>On-Device Processing:</strong> Transcription runs locally with Whisper.cpp</li>
    <li style="margin-bottom: 8px;"><strong>No Cloud Transmission:</strong> We do not upload your data</li>
</ul>
<p><strong>Important:</strong> Use a device lock screen and encryption for additional protection. Meeting recordings are processed in chunks and the complete transcription is stored locally; no audio segments are retained after processing.</p>
<p><strong>Meeting Recording Details:</strong> For long-form audio recordings (up to 1 hour), the app divides audio into 20-second segments with 2-second overlap. Each segment is transcribed separately. If a segment fails transcription, it is marked as "[inaudible]" and processing continues. The final note contains the complete transcription with metadata showing duration, number of segments processed, and quality percentage. All audio chunks are deleted after processing.</p>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">7. Children's Privacy</h2>
<p>FastVoiceNote is not intended for children under 13. We do not knowingly collect personal information from children under 13.</p>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">8. International Data Transfers</h2>
<p><strong>Not applicable:</strong> We do not use external services; no international data transfers occur.</p>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">9. Your Rights</h2>
<p>Depending on your location, you may have the following rights:</p>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Access:</strong> Your data is stored locally on your device</li>
    <li style="margin-bottom: 8px;"><strong>Deletion:</strong> Delete your data via the app or device settings</li>
    <li style="margin-bottom: 8px;"><strong>Correction:</strong> Edit notes and preferences within the app</li>
    <li style="margin-bottom: 8px;"><strong>Portability:</strong> Share or export notes using system share features</li>
</ul>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">10. Changes to This Privacy Policy</h2>
<p>We may update this Privacy Policy from time to time. Changes will be posted within the app and/or on our website. Continued use of FastVoiceNote after changes constitutes acceptance of the updated policy.</p>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;">Updated "Last Updated" date at the top</li>
</ul>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">11. Third-Party Links</h2>
<p>FastVoiceNote may contain links you choose to open. We are not responsible for their privacy practices. Please review their policies before providing information.</p>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">12. Contact Us</h2>
<p>If you have questions, concerns, or requests regarding this Privacy Policy or your data, please contact us:</p>
<ul style="margin: 10px 0; padding-left: 20px;">
    <li style="margin-bottom: 8px;"><strong>Email:</strong> morogodigital@gmail.com</li>
    <li style="margin-bottom: 8px;"><strong>Website:</strong> <a href="https://fastvoicenote.blogspot.com" target="_blank" style="color: #6366F1; text-decoration: underline;">https://fastvoicenote.blogspot.com</a></li>
    <li style="margin-bottom: 8px;"><strong>App Name:</strong> FastVoiceNote</li>
    <li style="margin-bottom: 8px;"><strong>Developer:</strong> Raul Nicolas Agusto</li>
</ul>

<h2 style="color: #6366F1; margin-top: 30px; margin-bottom: 15px; border-left: 4px solid #6366F1; padding-left: 15px;">13. Consent</h2>
<p>By using FastVoiceNote, you consent to this Privacy Policy and agree to its terms.</p>

<hr style="margin: 40px 0; border: none; border-top: 1px solid #444;">

<div style="text-align: center; margin-top: 40px; padding: 20px;">
<p><strong>Document Version:</strong> 1.2</p>
    <p><strong>Effective Date:</strong> January 11, 2026</p>
    <p><strong>Last Reviewed:</strong> January 11, 2026</p>
    <p style="margin-top: 20px; color: #999;">© 2026 FastVoiceNote. All rights reserved.</p>
</div>

</div>


