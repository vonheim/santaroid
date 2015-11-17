import datetime
from subprocess import call
import os

class Picam:

    root = None

    def __init__(self, root):
        self.root = root
        if not os.path.isdir(root):
            raise Exception(root+' not a directory')

    def take_picture(self):
        path = self.root +'/'+ datetime.datetime.now().strftime("%Y-%m-%d-%H%M%S") +'.jpg'
        call(['raspistill', '-o', path])
