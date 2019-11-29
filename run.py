import subprocess
import sys
 
if __name__ == '__main__':
    PATH = sys.argv[0]
    if '/' in PATH:
        PATH = PATH[:PATH.rindex('/')] + '/'
    else:
        PATH = './'
    version = sys.argv[1]
    r = sys.argv[2]
    sb = sys.argv[3]
    model = sys.argv[4]
    shift = sys.argv[5]
    subprocess.check_call([
        './solve.sh', version, r, sb, model, shift
    ], cwd=PATH)
 
    model_step_2 = sys.argv[6]
    subprocess.check_call([
        'java',
        '-Duser.country=UK',
        '-Duser.language=en',
        '-cp',
        '.:choco-solver-3.3.4-with-dependencies.jar',
        'CryptoMain_all',
        '{}-{}/{}-{}-{}'.format(model, shift, version, r, sb),
        version,
        r,
        sb,
        model_step_2
    ], cwd=PATH)
