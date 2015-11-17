from os import listdir
from subprocess import call
import random


class Speech:

    sound_files = {}

    def __init__(self, root):
        for id in listdir(root):
            dir = root+"/"+id
            files = map(lambda file: dir+"/"+file, listdir(dir))
            random.shuffle(files)
            self.sound_files[id] = files

    def say(self, id):
        files = self.sound_files[id]
        files.append(files.pop(0))
        print "Say "+ files[-1]
        call(["omxplayer", files[-1]])
