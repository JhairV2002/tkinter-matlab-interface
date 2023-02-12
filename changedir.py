import os
import matlab.engine

os.chdir(r"./simulifi1/")
eng = matlab.engine.start_matlab()
eng.apartado1(nargout = 0)