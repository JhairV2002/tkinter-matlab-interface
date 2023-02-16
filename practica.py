import matlab.engine
import matlab


# eng = matlab.engine.start_matlab()
# eng.apartado1(nargout=0)


eng = matlab.engine.connect_matlab()
eng.cd(r"simulifi2")
eng.practica(
    # area
    # matlab.double([200]),
    # lumens
    # matlab.double([200]),
    nargout=0,
)
