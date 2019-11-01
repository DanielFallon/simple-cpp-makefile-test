.PHONY: default
default: test

# C++ Build
CXX      := g++
CXXFLAGS := -pedantic-errors -Wall -Wextra -Werror
LDFLAGS  := -L/usr/lib -lstdc++ -lm

# Source Files
SOURCES  := $(shell find src/ -type f -name '*.cpp')

# Output Artifacts
OBJ_DIR  := build
OBJECTS  := $(patsubst src/%.cpp,$(OBJ_DIR)/%.o,$(SOURCES))
PROGRAM  := main

# Test Output Files
TESTS    := $(patsubst %.out,%,$(wildcard test/*.out))

# Pattern rule to compile *.cpp files
$(OBJ_DIR)/%.o: src/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -o $@ -c $<

.PHONY: build
build: $(PROGRAM)
$(PROGRAM): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) -o $(PROGRAM) $(OBJECTS)

.PHONY: test $(TESTS)
test: $(TESTS)
# Enable debugging symbols for tests
$(TESTS): CXXFLAGS += -DDEBUG -g
$(TESTS): $(PROGRAM)
	-@echo "[Begin $@]"
	-@echo "  Input: $@.in" &&\
	  cat '$@.in' 2>/dev/null | sed 's/^/  |/'
	-@echo "  Expected Output: $@.out" &&\
	  cat '$@.out' 2>/dev/null | sed 's/^/  |/'
	-@cat '$@.in' 2>/dev/null | ./$(PROGRAM) >'$@.result' 
	-@diff '$@.out' '$@.result' 2>&1 >/dev/null  \
		&& echo "+ Test Case Pass" \
		|| ( printf "\033[1;31m  Actual Output: $@.result\n" && \
			 cat '$@.result' | sed 's/^/  |/' && \
			 printf "! Test Case Fail\033[0m\n" )

.PHONY: clean
clean:
	-@rm -rvf $(OBJ_DIR)
	-@rm -vf $(PROGRAM)
	-@rm -vf tests/*.result
