import matlab.engine
import matlab

# eng = matlab.engine.start_matlab()
# eng.apartado1(nargout=0)
eng = matlab.engine.start_matlab()
eng.cd(r"simulifi3")
eng.Rate_2Usuarios(
    nargout=0,
)
