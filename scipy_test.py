import matlab.engine
import matlab


# eng = matlab.engine.start_matlab()
# eng.apartado1(nargout=0)


eng = matlab.engine.start_matlab()
eng.cd(r"simulifi1")
eng.apartado1(
    matlab.double([150]),
    matlab.double([1000]),
    matlab.double([4]),
    matlab.double([2]),
    matlab.double([100]),
    nargout=0,
)
