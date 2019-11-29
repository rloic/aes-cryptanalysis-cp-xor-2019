import sys
import urllib.request
import subprocess
import os
import shutil
import glob
from typing import List

linux = False
mac = False
windows = False

if sys.platform in ['linux', 'linux1', 'linux2']:
   linux = True
elif sys.platform == 'darwin':
   mac = True
elif sys.platform == 'win32':
   windows = True

def run(cmd: List[str]):
   subprocess.check_call(cmd)

def extract(file: str):
   subprocess.check_call(['tar', '-xvzf', file])
   
def rm(file: str):
   if os.path.isdir(file):
      shutil.rmtree(file)
   else:
      os.remove(file)
      
def move_dir(srcDir, dstDir):
   if not os.path.exists(dstDir):
      os.mkdir(dstDir)
   if os.path.isdir(srcDir) and os.path.isdir(dstDir) :
      for filePath in glob.glob(srcDir + '/*'):
         shutil.move(filePath, dstDir);
   else:
      print("srcDir & dstDir should be Directories")
      
def copy(src: str, dest: str):
   shutil.copyfile(src, dest)

if __name__ == '__main__':
	if linux:
		minizinc_lib = 'MiniZincIDE-2.2.3-bundle-linux-x86_64.tgz'
		picat_lib = 'picat26_linux64.tar.gz'
	elif windows:
		minizinc_lib = 'MiniZincIDE-2.2.3-bundled-setup-win64.exe'
		picat_lib = 'picat26_win64.zip'
	elif mac:
		minizinc_lib = 'MiniZincIDE-2.2.3-bundled.dmg'
		picat_lib = 'picat26_macx.tar.gz'
	else:
	   print('Cannot be executed on {}'.format(sys.platform))
	   exit(0)
	   
	urllib.request.urlretrieve('https://github.com/MiniZinc/MiniZincIDE/releases/download/2.2.3/' + minizinc_lib, minizinc_lib)
	urllib.request.urlretrieve('http://picat-lang.org/download/' + picat_lib, picat_lib)
	urllib.request.urlretrieve('https://oss.sonatype.org/content/repositories/snapshots/org/choco-solver/choco-solver/3.3.4-SNAPSHOT/choco-solver-3.3.4-20151222.130658-1-with-dependencies.jar', 'choco-solver-3.3.4-with-dependencies.jar')
	
	# Install MiniZinc
	if linux:
		extract(minizinc_lib)
		rm(minizinc_lib)
	else:
	   print('Cannot install MiniZinc, you must install the {} file from hand'.format(minizinc_lib))
	   
	# Install Picat
	if linux or mac:
		extract(picat_lib)
		rm(picat_lib)
	else:
	   print('Cannot install Picat, you must install the {} file from hand'.format(picat_lib))
	   
	run(['git', 'clone', 'https://gitlab.inria.fr/source_code/aes-cryptanalysis-cp-xor-2019'])
	move_dir('aes-cryptanalysis-cp-xor-2019', '.')
	move_dir('aes-cryptanalysis-cp-xor-2019/.git', '.git')
	rm('aes-cryptanalysis-cp-xor-2019')
	rm('solve.sh')
	rm('Makefile')
	copy('Makefile.new', 'Makefile')
	copy('solve.new.sh', 'solve.sh')
	run(['make'])
	os.chmod('solve.sh', 0o755)