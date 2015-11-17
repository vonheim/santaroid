#!/usr/bin/env python

from time import sleep
from nanpy import SerialManager, ArduinoApi, Servo, DHT
from speech import Speech
from throttle import Throttle
from picam import Picam

pin_light = 0
pin_temperature = 3
pin_sound = 5
pin_motion = 8

connection = SerialManager()
arduino = ArduinoApi(connection=connection)
speech = Speech('../speech/sounds/speech')
throttle = Throttle()
camera = Picam("/home/pi/pictures")
temperature = DHT(pin_temperature, DHT.DHT11)


state = {'light': 'off', 'temperature': 'ok', 'sound': 0}


def check_light():
    light = arduino.analogRead(pin_light)
    print("light: "+str(light))

    current_state = state.get('light')
    if light > 500:
        current_state = 'on'
    if light < 200:
        current_state = 'off'

    if state['light'] != current_state:
        state['light'] = current_state
        say('light_'+current_state, 10)


def check_temperature():
    degrees = temperature.readTemperature(False)
    print "temperature: "+str(degrees)

    current_state = state.get('temperature')
    if degrees > 22:
        current_state = 'warm'
    if degrees < 20:
        current_state = 'cold'

    if state['temperature'] != current_state:
        state['temperature'] = current_state
        say(current_state+'_here', 10)


def check_sound():
    sound = arduino.analogRead(pin_sound)
    print "sound: "+str(sound)

    if sound > 1000:
        say('noisy', 10)


def check_motion():
    motion = arduino.digitalRead(pin_motion)
    print "motion "+str(motion)

    if motion==1:
        say('random', 10)
        camera.take_picture()


def say(id, seconds_until_next_time):
    if throttle.can_execute(id, seconds_until_next_time):
        speech.say(id)



while True:
    check_light()
    check_temperature()
    check_sound()
    check_motion()
    sleep(0.3)
