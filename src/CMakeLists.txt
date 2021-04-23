add_library(asteroid-calendar main.cpp resources.qrc)
set_target_properties(asteroid-calendar PROPERTIES PREFIX "" SUFFIX "")

target_link_libraries(asteroid-calendar PUBLIC
	AsteroidApp)

install(TARGETS asteroid-calendar
	DESTINATION ${CMAKE_INSTALL_BINDIR})
