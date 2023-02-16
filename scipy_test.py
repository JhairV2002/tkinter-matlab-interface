import matlab.engine
import matlab


# eng = matlab.engine.start_matlab()
# eng.apartado1(nargout=0)


eng = matlab.engine.start_matlab()
eng.cd(r"simulifi1")
eng.apartado1(
    # lumens
    matlab.double([150]),
    # Area
    matlab.double([1000]),
    # leds
    matlab.double([1]),
    # users
    matlab.double([2]),
    # Angulo
    matlab.double([100]),
    nargout=0,
)
