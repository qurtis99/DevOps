# Makefile

CXX = g++
CXXFLAGS = -Wall -std=c++11
TARGET = my_program

all: $(TARGET)

$(TARGET): src/main.o src/TrigFunction.o
	$(CXX) $(CXXFLAGS) -o $(TARGET) src/main.o src/TrigFunction.o

src/main.o: src/main.cpp src/TrigFunction.h
	$(CXX) $(CXXFLAGS) -c src/main.cpp -o src/main.o

src/TrigFunction.o: src/TrigFunction.cpp src/TrigFunction.h
	$(CXX) $(CXXFLAGS) -c src/TrigFunction.cpp -o src/TrigFunction.o

clean:
	rm -f src/*.o $(TARGET)
