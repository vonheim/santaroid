from time import time, sleep


class Throttle:

    wait_until = {}

    def can_execute(self, id, seconds):
        if self.wait_until.get(id) > time():
            return False

        self.wait_until[id] = time() + seconds
        return True
