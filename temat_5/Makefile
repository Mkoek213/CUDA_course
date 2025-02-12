.PHONY := clean

NVCC := nvcc
NVCC_FLAGS := --expt-extended-lambda 

all: reduction

reduction: reduction.o
	$(NVCC) $(NVCC_FLAGS) -o $@ $<

reduction.o: reduction.cu Makefile
	$(NVCC) $(NVCC_FLAGS) -c -o $@ $<

clean: 
	@rm -f reduction reduction.o >/dev/null 2>&1