from __future__ import division

import re
import sys

from google.cloud import speech

import pyaudio
from six.moves import queue
from zmq import device
import os
import json
import requests
import telegram
from collections import deque

RATE = 16000
CHUNK = int(RATE / 10)  # 100ms
# TOKEN = ADD YOUR TELEGRAM BOT TOKEN HERE AND UNCOMMENT THIS LINE
r = requests.get('https://api.telegram.org/bot' + TOKEN + '/getUpdates')
#os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = something.json replace the something.json file with the path to your google cloud key

WORD_LIMIT = 10 
words = deque([]) 

#Retrieving Loopback Device
device_idx = 0 
for i in range(pyaudio.PyAudio().get_device_count()):
    if (pyaudio.PyAudio().get_device_info_by_index(i).get('name') == "Loopback Audio"):
        device_idx = i
print(device_idx)

class MicrophoneStream(object):
    """Opens a recording stream as a generator yielding the audio chunks."""

    def __init__(self, rate, chunk):
        self._rate = rate
        self._chunk = chunk

        # Create a thread-safe buffer of audio data
        self._buff = queue.Queue()
        self.closed = True

    def __enter__(self):
        self._audio_interface = pyaudio.PyAudio()
        self._audio_stream = self._audio_interface.open(
            format=pyaudio.paInt16,
            # The API currently only supports 1-channel (mono) audio
            # https://goo.gl/z757pE
            channels=1,
            rate=self._rate,
            input=True,
            input_device_index=device_idx,
            frames_per_buffer=self._chunk,
            # Run the audio stream asynchronously to fill the buffer object.
            # This is necessary so that the input device's buffer doesn't
            # overflow while the calling thread makes network requests, etc.
            stream_callback=self._fill_buffer,
        )

        self.closed = False

        return self

    def __exit__(self, type, value, traceback):
        self._audio_stream.stop_stream()
        self._audio_stream.close()
        self.closed = True
        # Signal the generator to terminate so that the client's
        # streaming_recognize method will not block the process termination.
        self._buff.put(None)
        self._audio_interface.terminate()

    def _fill_buffer(self, in_data, frame_count, time_info, status_flags):
        """Continuously collect data from the audio stream, into the buffer."""
        self._buff.put(in_data)
        return None, pyaudio.paContinue

    def generator(self):
        while not self.closed:
            # Use a blocking get() to ensure there's at least one chunk of
            # data, and stop iteration if the chunk is None, indicating the
            # end of the audio stream.
            chunk = self._buff.get()
            if chunk is None:
                return
            data = [chunk]

            # Now consume whatever other data's still buffered.
            while True:
                try:
                    chunk = self._buff.get(block=False)
                    if chunk is None:
                        return
                    data.append(chunk)
                except queue.Empty:
                    break
            yield b"".join(data)

def sendMessage(name, text):
    data = r.json()
    name = 'E'
    messages = data["result"]
    chat_id = ''
    if (messages):
        for message in messages:
            if name == message['message']['from']['first_name']:
                chat_id = message['message']['from']['id']
    bot = telegram.Bot(token=TOKEN)
    bot.sendMessage(chat_id=chat_id, text=text)

def check(name, responses):
    for response in responses:  
        if not response.results:
            continue

        result = response.results[0]
        if not result.alternatives:
            continue
        transcript = result.alternatives[0].transcript
        if result.is_final:
            for word in (transcript.split()):
                words.append(str(word).lower())
            while (len(words) > WORD_LIMIT):
                poppedWord = words.popleft()
            print(*words)
            if (name.lower() in words):
                sendMessage(name, "You have just been mentioned!")
                sendMessage(name, "The following is a transcription of what has been said: ")
                sendMessage(name, ' '.join(words))

def main(name):
    language_code = "en-US"  # a BCP-47 language tag

    client = speech.SpeechClient()
    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=RATE,
        language_code=language_code,
    )

    streaming_config = speech.StreamingRecognitionConfig(
        config=config, interim_results=True
    )

    with MicrophoneStream(RATE, CHUNK) as stream:
        audio_generator = stream.generator()
        requests = (
            speech.StreamingRecognizeRequest(audio_content=content)
            for content in audio_generator
        )

        responses = client.streaming_recognize(streaming_config, requests)

        # Now, put the transcription responses to use.
        check(name, responses)

main('Evan')