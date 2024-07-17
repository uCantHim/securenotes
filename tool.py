import socket
import subprocess

class FlutterConnection:
    _valid_cmds = ['r', 'R', 'q']

    def __init__(self, flutter='flutter'):
        cmd = [flutter, 'run']
        self._proc = subprocess.Popen(cmd,
                                      stdout=subprocess.PIPE,
                                      stdin=subprocess.PIPE)
        assert(self._proc.stdout is not None)
        assert(self._proc.stdin is not None)
        self._stdin = self._proc.stdin
        self._stdout = self._proc.stdout

    def is_running(self) -> bool:
        return self._proc.poll != None

    def reload(self):
        self._send_cmd('r')

    def restart(self):
        self._send_cmd('R')

    def quit(self):
        self._send_cmd('q')

    def quit_and_wait(self) -> int:
        """
        :return: The subprocess's exit code.
        """
        self.quit()
        return self._proc.wait()

    def _send_cmd(self, c: str):
        if c not in self._valid_cmds:
            print(f'Invalid flutter command: {c}')
            return
        try:
            self._stdin.write(c.encode())
            self._stdin.flush()
        except IOError as err:
            print(f'IO error when sending a command to the subprocess: {err}')

def main():
    flutter = FlutterConnection()

    while flutter.is_running():
        c = input('[r] hot reload\n[q] quit\n > ')
        print()

        if c not in ['r', 'c', 'q']:
            print(f'Invalid command.')
        if c == 'r':
            flutter.reload()
        if c == 'q':
            break

    ret = flutter.quit_and_wait()
    print(f'Subprocess has exited with exit code {ret}.')

if __name__ == '__main__':
    main()
