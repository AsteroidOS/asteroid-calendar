add_library(asteroid-calendar main.cpp resources.qrc)
set_target_properties(asteroid-calendar PROPERTIES PREFIX "")

asteroid_app_qml_module(asteroid-calendar
	main.qml
	EventDialog.qml
	MonthSelector.qml
)

target_link_libraries(
	asteroid-calendar
	PUBLIC
		Asteroid::AsteroidApp6
)

install(
	TARGETS asteroid-calendar
	DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
