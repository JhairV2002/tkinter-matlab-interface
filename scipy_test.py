import matlab.engine
import time

eng = matlab.engine.start_matlab()
eng.apartado1(nargout=0)

input()

eng.close()