read-records:
	./run build read-records read-record count-chars write-newline alloc

write-records:
	./run build write-records write-record

add-year:
	./run build add-year read-record write-record error-exit count-chars write-newline

clean:
	rm -r ./build/*

all: read-records write-records